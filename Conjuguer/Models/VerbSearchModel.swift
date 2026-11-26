//
//  VerbSearchModel.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import Foundation
import Observation

/// The verb list's search: what is typed, what it found, the guess when it found nothing, the
/// hardware keyboard's selection, and the `finishSearch` reports. The view keeps the field's
/// focus and the navigation.
@Observable
final class VerbSearchModel {
  /// One matched verb as the list shows it, with its place in the ranking.
  struct Result: Identifiable {
    let match: VerbSearch.Match
    let position: Int

    var id: String {
      match.verb.id
    }
  }

  /// The field's text, as typed. Every change, whether typed, inserted from the letter row, or
  /// requested by another surface, goes through `textChanged`.
  var text = "" {
    didSet {
      if text != oldValue {
        textChanged()
      }
    }
  }

  /// The text trimmed, which is what is searched.
  private(set) var query = ""
  private(set) var results: [Result] = []

  /// Distinct infinitives among the results. Rows outnumber verbs: haïr, ouïr, saillir, and
  /// sortir each carry two entries, and every other count the app quotes is of infinitives.
  private(set) var verbCount = 0

  /// Nil until the guess arrives, and when no verb is near enough to guess.
  private(set) var guess: VerbSearch.Guess?

  /// The verb that Return opens, by id, so that the highlight stays with its verb when the
  /// rows change beneath it.
  private(set) var selectedVerbID: String?

  @ObservationIgnored private(set) var guessTask: Task<Void, Never>?
  @ObservationIgnored private var tracker = SearchTracker()
  @ObservationIgnored private var passedOver: (query: String, results: [Result])?
  @ObservationIgnored private var failedSearchSound = FailedSearchSound()
  @ObservationIgnored private let analytics: Analytics
  @ObservationIgnored private let soundPlayer: SoundPlayer
  @ObservationIgnored private let suppliedVerbs: [Verb]?
  @ObservationIgnored private lazy var verbs = suppliedVerbs ?? Verb.verbs.values.sorted { lhs, rhs in
    (lhs.frequency, lhs.id) < (rhs.frequency, rhs.id)
  }
  @ObservationIgnored private lazy var verbsByID = Dictionary(verbs.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
  @ObservationIgnored private lazy var guessCandidates = VerbSearch.guessCandidates(of: verbs)

  /// `verbs` defaults to every verb, read when the first search runs.
  init(verbs: [Verb]? = nil, analytics: Analytics = Current.analytics, soundPlayer: SoundPlayer = Current.soundPlayer) {
    suppliedVerbs = verbs
    self.analytics = analytics
    self.soundPlayer = soundPlayer
  }

  var isSearching: Bool {
    !query.isEmpty
  }

  /// Nothing matched. The guess, if there is one, arrives later.
  var hasFailed: Bool {
    isSearching && results.isEmpty
  }

  /// The rows that Return and the arrow keys move through: the results, the guess when nothing
  /// matched, or, with the field empty, the recent verbs the list shows, if it shows them.
  func keyboardTargets(recents: [Verb]) -> [Verb] {
    guard isSearching else {
      return recents
    }
    guard !hasFailed else {
      return guess.map { [$0.verb] } ?? []
    }
    return results.map(\.match.verb)
  }

  /// The selected verb's id while it is among the targets, so that a verb selected among the
  /// recents is not drawn selected in the whole list.
  func highlightedVerbID(recents: [Verb]) -> String? {
    guard let selectedVerbID else {
      return nil
    }
    let isTarget = if !isSearching {
      recents.contains { $0.id == selectedVerbID }
    } else if hasFailed {
      guess?.verb.id == selectedVerbID
    } else {
      results.contains { $0.id == selectedVerbID }
    }
    return isTarget ? selectedVerbID : nil
  }

  func moveSelection(by offset: Int, recents: [Verb]) {
    let targets = keyboardTargets(recents: recents)
    let current = selectedVerbID.flatMap { id in targets.firstIndex { $0.id == id } }
    selectedVerbID = Self.keyboardSelection(after: current, moving: offset, count: targets.count).map { targets[$0].id }
  }

  /// The first arrow press lands on the first row, and the selection stops at either end rather
  /// than wrapping.
  nonisolated static func keyboardSelection(after current: Int?, moving offset: Int, count: Int) -> Int? {
    guard count > 0 else {
      return nil
    }
    guard let current else {
      return offset > 0 ? 0 : nil
    }
    return min(max(current + offset, 0), count - 1)
  }

  /// What Return opens: the highlighted row, else the first result, else the guess, else the
  /// first recent verb. Nil when there is nothing to open, or while the guess is still coming.
  func openForReturn(recents: [Verb]) -> VerbDestination? {
    let targets = keyboardTargets(recents: recents)
    guard !targets.isEmpty else {
      return nil
    }
    guard !hasFailed else {
      return openGuess()
    }
    let index = selectedVerbID.flatMap { id in targets.firstIndex { $0.id == id } } ?? 0
    guard isSearching else {
      return VerbDestination(verb: targets[index], source: .recent)
    }
    return open(results[index])
  }

  /// Ends the search, reporting which result was opened, and says where it leads. Opening
  /// another result after returning to the same results ends nothing more.
  func open(_ result: Result) -> VerbDestination {
    if let search = finishSearch() {
      signal(.opened(query: search.query, resultCount: results.count, kind: result.match.kind, position: result.position, source: search.source))
    }
    return VerbDestination(verb: result.match.verb, source: .search, marks: result.match.conjugation?.marks)
  }

  /// Nil while the guess is still being found, or when there is none.
  func openGuess() -> VerbDestination? {
    guard let guess else {
      return nil
    }
    if let search = finishSearch() {
      signal(.openedGuess(query: search.query, source: search.source))
    }
    return VerbDestination(verb: guess.verb, source: .searchGuess, marks: guess.conjugation?.marks)
  }

  /// Another surface put text in the field, so the search that follows is that surface's. A
  /// search in progress ends here, because its text is about to be replaced.
  func request(text: String, source: AnalyticsSource) {
    passedOver = nil
    if let ended = tracker.fieldOpened(from: source) {
      signalEnded(ended)
    }
    self.text = text
    // An unchanged text sets off no didSet, and the request still begins a search.
    _ = tracker.textChanged(to: text)
  }

  /// The field let go. A surface that opened it with nothing typed began no search.
  func fieldClosed() {
    tracker.fieldClosed()
  }

  /// The app left the foreground, which ends a search in progress.
  func appLeftForeground() {
    if let ended = finishSearch() {
      signalEnded(ended)
    }
  }

  private func textChanged() {
    selectedVerbID = nil
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    notePassedOverQuery(becoming: trimmed)
    // A search ended by clearing the field is reported with the results it showed, which are
    // still these.
    if let ended = tracker.textChanged(to: text) {
      signalEnded(ended)
      passedOver = nil
    }
    guard trimmed != query else {
      return
    }
    query = trimmed
    refreshResults()
  }

  /// A learner who deletes a query letter by letter passed over the query they had typed, not
  /// its last letter, so a search cleared that way reports the text from before the deletions.
  /// Typing forward, or replacing the text, forgets it.
  private func notePassedOverQuery(becoming newQuery: String) {
    guard tracker.search != nil, newQuery.count < query.count, query.hasPrefix(newQuery) else {
      passedOver = nil
      return
    }
    if passedOver == nil {
      passedOver = (query, results)
    }
  }

  /// The results come at once, because an ordinary search is cheap. The guess measures edit
  /// distance against every conjugation of about the query's length, which took up to 0.3 s on
  /// the main actor in a Debug build, so it comes from a task that the next change cancels.
  private func refreshResults() {
    guessTask?.cancel()
    guessTask = nil
    guess = nil
    let matches = isSearching ? VerbSearch.matches(for: query, in: verbs, includeGlosses: true) : []
    results = matches.enumerated().map { Result(match: $1, position: $0) }
    verbCount = Set(matches.map(\.verb.infinitif)).count
    // "j'" and "nous" are a conjugation still being typed, and the trombone would sound mid-word.
    if failedSearchSound.searchChanged(hasFailed: hasFailed, isStillTyping: ConjugationQuery(query).isOnlyPronouns) {
      soundPlayer.play(.randomSadTrombone)
    }
    if hasFailed {
      startGuess()
    }
  }

  private func startGuess() {
    let query = self.query
    let candidates = guessCandidates
    guessTask = Task {
      let finding = await Self.guess(for: query, among: candidates)
      guard !Task.isCancelled, let finding else {
        return
      }
      guess = VerbSearch.guess(from: finding) { verbsByID[$0] }
    }
  }

  @concurrent
  private nonisolated static func guess(for query: String, among candidates: [VerbSearch.GuessCandidate]) async -> VerbSearch.GuessFinding? {
    VerbSearch.guess(for: query, among: candidates)
  }

  private func finishSearch() -> SearchTracker.Search? {
    passedOver = nil
    return tracker.finish()
  }

  private func signalEnded(_ search: SearchTracker.Search) {
    let reported = passedOver ?? (search.query, results)
    signal(.ended(query: reported.query, matches: reported.results.map(\.match), source: search.source))
  }

  private func signal(_ report: SearchReport) {
    analytics.signal(name: .finishSearch, parameters: report.parameters)
  }
}
