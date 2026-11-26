//
//  PracticeStore.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation
import Observation

/// The app's view of `PracticeRecord`: it maps questions and lookups to items, saves each change
/// to the App Group's defaults, and answers in verbs for the review card.
@Observable
final class PracticeStore {
  private(set) var record: PracticeRecord
  private(set) var lastResult: LastQuizResult?
  /// The most right answers in one Speed Round, kept on the device and sent nowhere.
  private(set) var speedRoundBest: Int?
  /// Kept on the device and sent only as a band.
  private(set) var dailyStreak = DailyStreak()
  /// The challenges finished lately, the newest last, kept on the device and sent nowhere. Reset
  /// Practice keeps them, since each is a day's result rather than a record of what is known, and
  /// forgetting one would let its challenge be taken again.
  private(set) var challengeResults: [DailyChallengeResult] = []
  private let getterSetter: GetterSetter
  private let calendar: Calendar

  struct CardOffer: Equatable {
    let verb: Verb
    /// The verb's due key conjugations among those the card shows.
    let items: [PracticeItem]
    /// Whole days since a key conjugation of the verb was last looked up or answered.
    let daysSinceActivity: Int?
    /// Whether that was a lookup rather than a quiz answer.
    let wasLookedUp: Bool
  }

  init(getterSetter: GetterSetter, calendar: Calendar = .current) {
    self.getterSetter = getterSetter
    self.calendar = calendar
    record = getterSetter.get(key: PracticeRecord.storageKey).flatMap(PracticeRecord.init(json:)) ?? PracticeRecord()
    lastResult = getterSetter.get(key: LastQuizResult.storageKey).flatMap(LastQuizResult.init(json:))
    speedRoundBest = getterSetter.get(key: Self.speedRoundBestKey).flatMap { Int($0) }
    dailyStreak = getterSetter.getCodable(key: DailyStreak.storageKey) ?? DailyStreak()
    challengeResults = getterSetter.getCodable(key: DailyChallengeResult.storageKey) ?? []
  }

  static let speedRoundBestKey = "speedRoundBest"

  var isEmpty: Bool {
    record.isEmpty
  }

  func recordAnswer(verb: Verb, tense: Tense, isCorrect: Bool, at date: Date = .now) {
    record.recordAnswer(.exercised(by: tense, of: verb), isCorrect: isCorrect, at: date, calendar: calendar)
    save()
  }

  /// A verb page was opened. An open from the review card does not reschedule, since the learner
  /// has just reviewed the verb.
  func recordLookup(_ verb: Verb, source: AnalyticsSource, at date: Date = .now) {
    let items = PracticeItem.keyConjugations(of: verb)
    guard !items.isEmpty else {
      return
    }
    record.recordLookup(items, at: date, reschedules: source != .reviewCard, calendar: calendar)
    save()
  }

  /// The items due at `date`, the longest overdue first.
  func dueItems(at date: Date = .now) -> [PracticeItem] {
    record.dueItems(at: date)
  }

  func missedItems() -> [PracticeItem] {
    record.missedItems()
  }

  /// Whole days until Review next has an item to ask: 1 for tomorrow. Nil when nothing is
  /// scheduled.
  func daysUntilNextDue(at date: Date = .now) -> Int? {
    record.nextDue(after: date).flatMap { PracticeRecord.daysBetween(date, and: $0, calendar: calendar) }
  }

  /// The irregular verb whose shown key conjugation is longest overdue, with each of its due key
  /// conjugations that the card shows. A passé simple, which the card does not show, waits for a
  /// quiz.
  func cardOffer(at date: Date = .now) -> CardOffer? {
    let due = dueItems(at: date)
    guard let verb = due.lazy.compactMap(Self.cardVerb(of:)).first(where: { !$0.keyConjugations().isEmpty }) else {
      return nil
    }
    let items = due.filter { Self.cardVerb(of: $0) == verb }
    let entries = PracticeItem.Stem.shown.compactMap { stem in
      record.entry(for: .keyConjugation(verb: verb.dictionaryKey, stem: stem))
    }
    let latest = entries.max { ($0.lastActivity ?? .distantPast) < ($1.lastActivity ?? .distantPast) }
    return CardOffer(
      verb: verb,
      items: items,
      daysSinceActivity: latest?.lastActivity.flatMap { PracticeRecord.daysBetween($0, and: date, calendar: calendar) },
      wasLookedUp: latest?.wasLastLookedUp ?? true
    )
  }

  /// Whether each of the offer's items is still due. A lookup of the verb elsewhere, a quiz
  /// answer, or Reset Practice can end an offer that the card still holds.
  func holds(_ offer: CardOffer, at date: Date = .now) -> Bool {
    Set(offer.items).isSubset(of: dueItems(at: date))
  }

  func recordReview(_ offer: CardOffer, at date: Date = .now) {
    record.recordReview(offer.items, at: date, calendar: calendar)
    save()
  }

  func snooze(_ offer: CardOffer, at date: Date = .now) {
    record.snooze(offer.items, at: date, calendar: calendar)
    save()
  }

  var hasAnythingToReset: Bool {
    !isEmpty || lastResult != nil || speedRoundBest != nil || !dailyStreak.isEmpty
  }

  func recordResult(_ result: LastQuizResult) {
    lastResult = result
    if let json = result.json {
      getterSetter.set(key: LastQuizResult.storageKey, value: json)
    }
  }

  /// A finished Speed Round's right answers, kept when they beat the best. Returns whether they
  /// did. A round with none right sets no best.
  @discardableResult
  func recordSpeedRound(_ correctCount: Int) -> Bool {
    guard correctCount > (speedRoundBest ?? 0) else {
      return false
    }
    speedRoundBest = correctCount
    getterSetter.set(key: Self.speedRoundBestKey, value: "\(correctCount)")
    return true
  }

  func challengeResult(for key: DailyChallenge.Key) -> DailyChallengeResult? {
    challengeResults.last { $0.key == key }
  }

  /// A finished challenge, kept unless its key was finished before, since a challenge is taken
  /// once. Returns the result the challenge keeps.
  @discardableResult
  func recordChallenge(_ result: DailyChallengeResult) -> DailyChallengeResult {
    if let kept = challengeResult(for: result.key) {
      return kept
    }
    challengeResults = Array((challengeResults + [result]).suffix(DailyChallengeResult.keptCount))
    getterSetter.setCodable(key: DailyChallengeResult.storageKey, value: challengeResults)
    return result
  }

  /// Returns the streak the session leaves.
  @discardableResult
  func recordDailySession(at date: Date = .now) -> DailyStreak.Status {
    dailyStreak.recordSession(at: date, calendar: calendar)
    getterSetter.setCodable(key: DailyStreak.storageKey, value: dailyStreak)
    return dailyStreak.status(at: date, calendar: calendar)
  }

  func streakStatus(at date: Date = .now) -> DailyStreak.Status {
    dailyStreak.status(at: date, calendar: calendar)
  }

  /// Settings' Reset Practice, which forgets the last result, the Speed Round's best, and the
  /// daily streak too, but keeps the challenges' results.
  func reset() {
    record.reset()
    save()
    lastResult = nil
    getterSetter.remove(key: LastQuizResult.storageKey)
    speedRoundBest = nil
    getterSetter.remove(key: Self.speedRoundBestKey)
    dailyStreak = DailyStreak()
    getterSetter.remove(key: DailyStreak.storageKey)
  }

  private static func cardVerb(of item: PracticeItem) -> Verb? {
    guard case let .keyConjugation(_, stem) = item, stem.isShown else {
      return nil
    }
    return item.verb
  }

  private func save() {
    if let json = record.json {
      getterSetter.set(key: PracticeRecord.storageKey, value: json)
    }
  }
}
