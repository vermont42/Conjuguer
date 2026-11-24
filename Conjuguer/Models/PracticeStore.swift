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
  private let getterSetter: GetterSetter
  private let calendar: Calendar
  /// The `LearnerVerbs` JSON a first launch with a practice record migrates. It is read at
  /// launch, before anything can save the learner's verbs without their old schedules, and
  /// migrated once the verbs are loaded, since only they say which verbs are irregular.
  @ObservationIgnored private var pendingMigration: String?

  struct CardOffer: Equatable {
    let verb: Verb
    /// The verb's due key conjugations among those the card shows.
    let items: [PracticeItem]
    /// Whole days since a key conjugation of the verb was last looked up or answered.
    let daysSinceActivity: Int?
    /// Whether that was a lookup rather than a quiz answer.
    let wasLookedUp: Bool
  }

  /// `getterSetter` must be the store that holds `LearnerVerbs`, since the first launch with a
  /// practice record migrates its review schedules.
  init(getterSetter: GetterSetter, calendar: Calendar = .current) {
    self.getterSetter = getterSetter
    self.calendar = calendar
    if let stored = getterSetter.get(key: PracticeRecord.storageKey).flatMap(PracticeRecord.init(json:)) {
      record = stored
    } else {
      record = PracticeRecord()
      pendingMigration = getterSetter.get(key: LearnerVerbs.storageKey)
    }
    lastResult = getterSetter.get(key: LastQuizResult.storageKey).flatMap(LastQuizResult.init(json:))
    speedRoundBest = getterSetter.get(key: Self.speedRoundBestKey).flatMap { Int($0) }
  }

  static let speedRoundBestKey = "speedRoundBest"

  var isEmpty: Bool {
    migrateIfNeeded()
    return record.isEmpty
  }

  /// A learner's verbs from before the practice record carry one review schedule per verb, in a
  /// `review` field, and an entry older still counts as looked up on its last open. Each irregular
  /// verb's schedule becomes its key conjugations' schedule. A regular verb's is dropped, since
  /// the card offers only irregular verbs. The record is saved even when nothing migrates, so that
  /// no later launch reads the old opens as schedules.
  func migrateIfNeeded() {
    guard let legacyJSON = pendingMigration, !Verb.verbs.isEmpty else {
      return
    }
    pendingMigration = nil
    if let data = legacyJSON.data(using: .utf8), let legacy = try? JSONDecoder().decode(LegacyLearnerVerbs.self, from: data) {
      for entry in legacy.entries.values {
        guard
          let verb = Verb.verbs[entry.dictionaryKey],
          let schedule = entry.review ?? entry.lastOpened.map({ ReviewSchedule.start(at: $0, calendar: calendar) })
        else {
          continue
        }
        for item in PracticeItem.keyConjugations(of: verb) {
          record.adopt(item, schedule: schedule, lastLookedUp: entry.lastOpened)
        }
      }
    }
    save()
  }

  func recordAnswer(verb: Verb, tense: Tense, isCorrect: Bool, at date: Date = .now) {
    migrateIfNeeded()
    record.recordAnswer(.exercised(by: tense, of: verb), isCorrect: isCorrect, at: date, calendar: calendar)
    save()
  }

  /// A verb page was opened. An open from the review card does not reschedule, since the learner
  /// has just reviewed the verb.
  func recordLookup(_ verb: Verb, source: AnalyticsSource, at date: Date = .now) {
    migrateIfNeeded()
    let items = PracticeItem.keyConjugations(of: verb)
    guard !items.isEmpty else {
      return
    }
    record.recordLookup(items, at: date, reschedules: source != .reviewCard, calendar: calendar)
    save()
  }

  /// The items due at `date`, the longest overdue first.
  func dueItems(at date: Date = .now) -> [PracticeItem] {
    migrateIfNeeded()
    return record.dueItems(at: date)
  }

  func missedItems() -> [PracticeItem] {
    migrateIfNeeded()
    return record.missedItems()
  }

  /// Whole days until Review next has an item to ask: 1 for tomorrow. Nil when nothing is
  /// scheduled.
  func daysUntilNextDue(at date: Date = .now) -> Int? {
    migrateIfNeeded()
    return record.nextDue(after: date).flatMap { PracticeRecord.daysBetween(date, and: $0, calendar: calendar) }
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

  func recordReview(_ offer: CardOffer, at date: Date = .now) {
    record.recordReview(offer.items, at: date, calendar: calendar)
    save()
  }

  func snooze(_ offer: CardOffer, at date: Date = .now) {
    record.snooze(offer.items, at: date, calendar: calendar)
    save()
  }

  var hasAnythingToReset: Bool {
    !isEmpty || lastResult != nil || speedRoundBest != nil
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

  /// Settings' Reset Practice, which forgets the last result and the Speed Round's best too. The
  /// record is saved empty rather than removed, so that the next launch does not migrate the old
  /// schedules again.
  func reset() {
    pendingMigration = nil
    record.reset()
    save()
    lastResult = nil
    getterSetter.remove(key: LastQuizResult.storageKey)
    speedRoundBest = nil
    getterSetter.remove(key: Self.speedRoundBestKey)
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

  /// The fields of a `LearnerVerbs` record that the migration reads. Decoding ignores the rest.
  private struct LegacyLearnerVerbs: Decodable {
    struct Entry: Decodable {
      let dictionaryKey: String
      let lastOpened: Date?
      let review: ReviewSchedule?
    }

    let entries: [String: Entry]
  }
}
