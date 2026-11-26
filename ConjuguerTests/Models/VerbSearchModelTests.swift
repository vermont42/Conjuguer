//
//  VerbSearchModelTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/26/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct VerbSearchModelTests {
  private final class SoundPlayerSpy: SoundPlayer {
    private(set) var playCount = 0

    func setup() {}

    func play(_ sound: Sound, shouldDebounce: Bool, volume: Float) {
      playCount += 1
    }

    func warmUpSounds() {}
    func startMusic() {}
    func stopMusic() {}
  }

  private static let verbs = Verb.verbs.values.sorted { ($0.frequency, $0.id) < ($1.frequency, $1.id) }

  private let analytics = AnalyticsSpy()
  private let soundPlayer = SoundPlayerSpy()

  private func model() -> VerbSearchModel {
    VerbSearchModel(verbs: Self.verbs, analytics: analytics, soundPlayer: soundPlayer)
  }

  private func matches(_ query: String) -> [VerbSearch.Match] {
    VerbSearch.matches(for: query, in: Self.verbs, includeGlosses: true)
  }

  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  @Test func typingShowsResultsAndReportsNothing() {
    let search = model()
    for text in ["v", "ve", "ven"] {
      search.text = text
    }
    #expect(search.query == "ven")
    #expect(search.results.map(\.match) == matches("ven"))
    #expect(search.results.map(\.position) == Array(matches("ven").indices))
    #expect(search.guessTask == nil)
    #expect(analytics.signalNames.isEmpty)
    #expect(soundPlayer.playCount == 0)
  }

  @Test func spacesAreNoSearch() {
    let search = model()
    search.text = "  "
    #expect(!search.isSearching)
    #expect(search.results.isEmpty)
    #expect(!search.hasFailed)
  }

  @Test func theCountIsOfInfinitivesNotRows() throws {
    let search = model()
    search.text = "haïr"
    #expect(search.verbCount == Set(search.results.map(\.match.verb.infinitif)).count)
    #expect(search.results.count > search.verbCount, "haïr has two entries")
  }

  @Test func clearingReportsTheSearchWithTheResultsItShowed() {
    let search = model()
    search.text = "ven"
    search.text = ""
    #expect(!search.isSearching)
    #expect(search.results.isEmpty)
    #expect(analytics.signalNames == [.finishSearch])
    #expect(analytics.signalParameters == [SearchReport.ended(query: "ven", matches: matches("ven")).parameters])
  }

  @Test func backspacingToNothingReportsTheQueryPassedOver() {
    let search = model()
    for text in ["v", "va", "vai", "vais", "vai", "va", "v", ""] {
      search.text = text
    }
    #expect(analytics.signalParameters == [SearchReport.ended(query: "vais", matches: matches("vais")).parameters])
  }

  @Test func typingForwardAgainForgetsTheQueryPassedOver() {
    let search = model()
    for text in ["vais", "va", "vat", ""] {
      search.text = text
    }
    #expect(analytics.signalParameters == [SearchReport.ended(query: "vat", matches: matches("vat")).parameters])
  }

  @Test func aSearchBegunAfterAnOpenPassesOverOnlyItsOwnText() throws {
    let search = model()
    search.text = "vais"
    _ = search.open(try #require(search.results.first))
    for text in ["vai", "va", ""] {
      search.text = text
    }
    #expect(analytics.signalParameters.dropFirst().first == SearchReport.ended(query: "vai", matches: matches("vai")).parameters)
  }

  @Test func clearingAFailedSearchReportsNoResult() {
    let search = model()
    search.text = "xyzzyq"
    search.text = ""
    #expect(analytics.signalParameters.first?["outcome"] == SearchOutcome.noResult.rawValue)
  }

  @Test func aFailedSearchShowsItsEmptyStateAtOnceAndItsGuessLater() async throws {
    let search = model()
    search.text = "finnissons"
    #expect(search.hasFailed)
    #expect(search.guess == nil)
    #expect(search.keyboardTargets(recents: []).isEmpty)
    try await #require(search.guessTask).value
    let guess = try #require(search.guess)
    #expect(guess.verb.infinitif == "finir")
    #expect(guess.conjugation?.text == "finissons")
    #expect(search.keyboardTargets(recents: []) == [guess.verb])
  }

  @Test func nonsenseGetsNoGuess() async throws {
    let search = model()
    search.text = "xyzzyq"
    try await #require(search.guessTask).value
    #expect(search.guess == nil)
  }

  @Test func theNextLetterCancelsAGuessInFlight() async throws {
    let search = model()
    search.text = "parlerx"
    let pending = try #require(search.guessTask)
    search.text = "parler"
    #expect(pending.isCancelled)
    await pending.value
    #expect(search.guess == nil)
    #expect(!search.hasFailed)
    #expect(search.guessTask == nil)
  }

  @Test func aSearchStillFailingGuessesAgainForItsNewText() async throws {
    let search = model()
    search.text = "finnissonsx"
    let first = try #require(search.guessTask)
    search.text = "finnissons"
    #expect(first.isCancelled)
    try await #require(search.guessTask).value
    #expect(search.guess?.verb.infinitif == "finir")
  }

  @Test func theTromboneSoundsOncePerFailedSearch() {
    let search = model()
    search.text = "ven"
    #expect(soundPlayer.playCount == 0)
    search.text = "xyzzy"
    search.text = "xyzzyq"
    #expect(soundPlayer.playCount == 1)
    search.text = ""
    search.text = "xyzzyq"
    #expect(soundPlayer.playCount == 2)
  }

  @Test func theTromboneWaitsOutPronounsAndThenSounds() {
    let search = model()
    search.text = "j'"
    #expect(search.hasFailed)
    #expect(soundPlayer.playCount == 0)
    search.text = "j'xq"
    #expect(soundPlayer.playCount == 1)
  }

  @Test func typingTowardAHyphenatedFormSoundsNothingAndGuessesNothing() {
    let search = model()
    for text in ["d", "di", "dis", "dis-", "dis-m", "dis-mo", "dis-moi"] {
      search.text = text
      #expect(search.guessTask == nil, "\(text)")
    }
    #expect(soundPlayer.playCount == 0)
    #expect(search.results.first?.match.verb.infinitif == "dire")
  }

  @Test func openingAResultReportsWhichAndWhere() throws {
    let search = model()
    search.text = "vais"
    let result = try #require(search.results.first)
    let destination = search.open(result)
    #expect(destination.verb.infinitif == "aller")
    #expect(destination.source == .search)
    #expect(destination.marks != nil)
    #expect(analytics.signalParameters == [
      SearchReport.opened(query: "vais", resultCount: matches("vais").count, kind: result.match.kind, position: 0).parameters
    ])
  }

  @Test func aSearchEndedByAnOpenIsNotReportedAgainWhenCleared() throws {
    let search = model()
    search.text = "ven"
    _ = search.open(try #require(search.results.first))
    _ = search.open(try #require(search.results.last))
    search.text = ""
    #expect(analytics.signalNames.count == 1)
  }

  @Test func openingTheGuessReportsAGuess() async throws {
    let search = model()
    search.text = "finnissons"
    #expect(search.openGuess() == nil)
    try await #require(search.guessTask).value
    let destination = try #require(search.openGuess())
    #expect(destination.verb.infinitif == "finir")
    #expect(destination.source == .searchGuess)
    #expect(destination.marks != nil)
    #expect(analytics.signalParameters == [SearchReport.openedGuess(query: "finnissons").parameters])
  }

  @Test func editingClearsTheSelection() {
    let search = model()
    search.text = "ven"
    search.moveSelection(by: 1, recents: [])
    #expect(search.selectedVerbID == search.results.first?.id)
    search.text = "vend"
    #expect(search.selectedVerbID == nil)
  }

  @Test func returnOpensTheHighlightElseTheFirstResult() throws {
    let unselected = model()
    unselected.text = "ven"
    #expect(unselected.openForReturn(recents: [])?.verb == unselected.results[0].match.verb)
    let search = model()
    search.text = "ven"
    search.moveSelection(by: 1, recents: [])
    search.moveSelection(by: 1, recents: [])
    let second = search.results[1]
    let destination = try #require(search.openForReturn(recents: []))
    #expect(destination.verb == second.match.verb)
    #expect(analytics.signalParameters.last?["resultPosition"] == AnalyticsBand.resultPosition(1))
  }

  @Test func returnOpensTheGuessOnceItArrives() async throws {
    let search = model()
    search.text = "finnissons"
    #expect(search.openForReturn(recents: []) == nil)
    try await #require(search.guessTask).value
    #expect(search.openForReturn(recents: [])?.source == .searchGuess)
  }

  @Test func returnInTheEmptyFieldOpensARecentVerb() throws {
    let search = model()
    let recents = [try verb("aller"), try verb("lire")]
    #expect(search.openForReturn(recents: []) == nil)
    #expect(search.openForReturn(recents: recents) == VerbDestination(verb: recents[0], source: .recent))
  }

  // An open moves its verb to the top of the recents, so a selection kept as a row would now
  // name another verb.
  @Test func theSelectionFollowsItsVerbWhenTheRowsMove() throws {
    let search = model()
    let (aller, lire, venir) = (try verb("aller"), try verb("lire"), try verb("venir"))
    search.moveSelection(by: 1, recents: [aller, lire, venir])
    search.moveSelection(by: 1, recents: [aller, lire, venir])
    let reordered = [lire, aller, venir]
    #expect(search.highlightedVerbID(recents: reordered) == lire.id)
    #expect(search.openForReturn(recents: reordered)?.verb == lire)
    search.moveSelection(by: 1, recents: reordered)
    #expect(search.selectedVerbID == aller.id)
  }

  @Test func aSelectionAmongTheRecentsIsNotDrawnInTheWholeList() throws {
    let search = model()
    let recents = [try verb("aller"), try verb("lire"), try verb("venir")]
    for _ in recents {
      search.moveSelection(by: 1, recents: recents)
    }
    #expect(search.highlightedVerbID(recents: recents) == recents[2].id)
    #expect(search.highlightedVerbID(recents: []) == nil)
  }

  @Test func aRequestBeginsASearchOfTheSurfaceThatSentIt() throws {
    let search = model()
    search.request(text: "ven", source: .control)
    _ = search.open(try #require(search.results.first))
    #expect(analytics.signalParameters.first?["source"] == AnalyticsSource.control.rawValue)
  }

  @Test func aRequestForTheSameTextEndsTheOldSearchAndBeginsAnother() {
    let search = model()
    search.text = "ven"
    search.request(text: "ven", source: .control)
    #expect(analytics.signalParameters.first?["source"] == AnalyticsSource.tab.rawValue)
    search.appLeftForeground()
    #expect(analytics.signalParameters.dropFirst().first?["source"] == AnalyticsSource.control.rawValue)
  }

  @Test func aRequestedSourceSurvivesTheFieldClosingAfterTheFirstLetter() throws {
    let search = model()
    search.request(text: "", source: .control)
    search.text = "ê"
    search.fieldClosed()
    search.appLeftForeground()
    #expect(analytics.signalParameters.first?["source"] == AnalyticsSource.control.rawValue)
  }

  @Test func leavingTheForegroundEndsTheSearch() {
    let search = model()
    search.text = "ven"
    search.appLeftForeground()
    #expect(analytics.signalParameters == [SearchReport.ended(query: "ven", matches: matches("ven")).parameters])
    search.appLeftForeground()
    #expect(analytics.signalNames.count == 1)
  }

  @Test func theFailedSearchSoundRule() {
    var sound = FailedSearchSound()
    let changes = [(true, true), (true, false), (true, false), (false, false), (true, false)]
    let sounded = changes.map { sound.searchChanged(hasFailed: $0, isStillTyping: $1) }
    #expect(sounded == [false, true, false, false, true])
  }
}
