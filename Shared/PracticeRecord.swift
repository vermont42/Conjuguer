//
//  PracticeRecord.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// What one quiz answer exercises, and what the review ladder schedules. An irregular verb's
/// question exercises one of its key conjugations, the stem its cell is built on. A regular
/// verb's question exercises a pattern, a tense and person that every verb of the pattern shares,
/// since a learner who can write je parlais can write je chantais. The app decides which question
/// maps to which item (`PracticeItemMapping.swift`). This file only names items, so that the
/// widget, which has no verb list, can read the record.
nonisolated enum PracticeItem: Hashable, Sendable {
  // The stems an irregular verb's tenses are built on: vient, est venu, viendra, and vint. The
  // first three are the key conjugations the verb page and the review card show, in this order.
  enum Stem: String, CaseIterable, Sendable {
    case présent = "present"
    case passéComposé = "passe_compose"
    case futur
    case passéSimple = "passe_simple"

    static let shown: [Stem] = [.présent, .passéComposé, .futur]

    var isShown: Bool {
      Self.shown.contains(self)
    }
  }

  /// `verb` is a `Verb.dictionaryKey`, so that each entry of a doubled infinitive keeps its own.
  case keyConjugation(verb: String, stem: Stem)
  /// `model` is the pattern's `VerbModel` id: a family's base (parler's, finir's, or rendre's), or
  /// a spelling-change model for the cells its change marks. `tense` is a `Tense.articleKey`,
  /// `person` a `PersonNumber` raw value, nil for a participle, and `takesÊtre` marks a compound
  /// tense conjugated with être, whose agreement the avoir verbs never ask.
  case pattern(model: String, tense: String, person: String?, takesÊtre: Bool)

  /// The item's permanent name in the stored record. Changing it would orphan every learner's
  /// schedule for the item.
  var key: String {
    switch self {
    case let .keyConjugation(verb, stem):
      return [Self.keyConjugationPrefix, verb, stem.rawValue].joined(separator: Self.separator)
    case let .pattern(model, tense, person, takesÊtre):
      var parts = [Self.patternPrefix, model, tense]
      if let person {
        parts.append(person)
        if takesÊtre {
          parts.append(Self.êtreMarker)
        }
      }
      return parts.joined(separator: Self.separator)
    }
  }

  init?(key: String) {
    let parts = key.components(separatedBy: Self.separator)
    switch parts.first {
    case Self.keyConjugationPrefix:
      guard parts.count == 3, !parts[1].isEmpty, let stem = Stem(rawValue: parts[2]) else {
        return nil
      }
      self = .keyConjugation(verb: parts[1], stem: stem)
    case Self.patternPrefix:
      guard (3 ... 5).contains(parts.count), !parts[1].isEmpty, !parts[2].isEmpty else {
        return nil
      }
      if parts.count == 5, parts[4] != Self.êtreMarker {
        return nil
      }
      self = .pattern(model: parts[1], tense: parts[2], person: parts.count >= 4 ? parts[3] : nil, takesÊtre: parts.count == 5)
    default:
      return nil
    }
  }

  private static let separator = ":"
  private static let keyConjugationPrefix = "key"
  private static let patternPrefix = "pattern"
  private static let êtreMarker = "etre"
}

/// The learner's practice record: a box and a due date for each item a quiz answer, a lookup, or
/// the review card has touched, and how the last answer went. It is kept in the App Group's shared
/// defaults, so that a widget or a reminder can read it, and it is never sent anywhere.
nonisolated struct PracticeRecord: Codable, Equatable, Sendable {
  // A field added later must be optional. Synthesized decoding ignores a default value and
  // requires the key, so any other field would fail to decode every record written before it,
  // and the learner's practice would silently vanish.
  struct Entry: Codable, Equatable, Sendable {
    var schedule: ReviewSchedule
    var lastAnswered: Date?
    var lastAnswerWasRight: Bool?
    var lastLookedUp: Date?

    var lastActivity: Date? {
      [lastAnswered, lastLookedUp].compactMap { $0 }.max()
    }

    /// Whether the last thing to touch the item was a lookup rather than an answer.
    var wasLastLookedUp: Bool {
      guard let lastLookedUp else {
        return false
      }
      return lastAnswered.map { lastLookedUp >= $0 } ?? true
    }
  }

  static let storageKey = "practiceRecord"

  /// Keyed by `PracticeItem.key`.
  private(set) var entries: [String: Entry] = [:]

  init() {}

  init?(json: String) {
    guard
      let data = json.data(using: .utf8),
      let decoded = try? JSONDecoder().decode(PracticeRecord.self, from: data)
    else {
      return nil
    }
    self = decoded
  }

  var json: String? {
    guard let data = try? JSONEncoder().encode(self) else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }

  var isEmpty: Bool {
    entries.isEmpty
  }

  func entry(for item: PracticeItem) -> Entry? {
    entries[item.key]
  }

  mutating func recordAnswer(_ item: PracticeItem, isCorrect: Bool, at date: Date, calendar: Calendar = .current) {
    var entry = entries[item.key] ?? Entry(schedule: .new(at: date))
    entry.schedule = entry.schedule.answered(correctly: isCorrect, at: date, calendar: calendar)
    entry.lastAnswered = date
    entry.lastAnswerWasRight = isCorrect
    entries[item.key] = entry
  }

  /// A lookup puts the items in the first box, or back there: looking a verb up again suggests
  /// it was forgotten, Leitner's wrong answer. With `reschedules` false, for an open from the
  /// review card, which the learner has just reviewed, only an item not yet in the record enters.
  mutating func recordLookup(_ items: [PracticeItem], at date: Date, reschedules: Bool = true, calendar: Calendar = .current) {
    for item in items {
      var entry = entries[item.key] ?? Entry(schedule: .start(at: date, calendar: calendar))
      if reschedules {
        entry.schedule = .start(at: date, calendar: calendar)
      }
      entry.lastLookedUp = date
      entries[item.key] = entry
    }
  }

  /// The review card's conjugations were revealed, which moves each due item up a box. An item
  /// not yet due keeps its place.
  mutating func recordReview(_ items: [PracticeItem], at date: Date, calendar: Calendar = .current) {
    updateDue(items, at: date) { $0.reviewed(at: date, calendar: calendar) }
  }

  /// The review card was dismissed before its conjugations were revealed, so each due item keeps
  /// its box and returns tomorrow.
  mutating func snooze(_ items: [PracticeItem], at date: Date, calendar: Calendar = .current) {
    updateDue(items, at: date) { $0.snoozed(at: date, calendar: calendar) }
  }

  /// The items due at `date`, the longest overdue first. Equal due dates fall back to the key, so
  /// the order never depends on the dictionary's.
  func dueItems(at date: Date) -> [PracticeItem] {
    let due: [(key: String, due: Date)] = entries.compactMap { key, entry in
      entry.schedule.isDue(at: date) ? (key, entry.schedule.due) : nil
    }
    return due
      .sorted { lhs, rhs in
        lhs.due != rhs.due ? lhs.due < rhs.due : lhs.key < rhs.key
      }
      .compactMap { PracticeItem(key: $0.key) }
  }

  /// The items whose last answer was wrong, the most recently missed first. A lookup leaves a
  /// mistake a mistake; only a right answer clears it.
  func missedItems() -> [PracticeItem] {
    let missed: [(key: String, answered: Date)] = entries.compactMap { key, entry in
      guard entry.lastAnswerWasRight == false, let answered = entry.lastAnswered else {
        return nil
      }
      return (key, answered)
    }
    return missed
      .sorted { lhs, rhs in
        lhs.answered != rhs.answered ? lhs.answered > rhs.answered : lhs.key < rhs.key
      }
      .compactMap { PracticeItem(key: $0.key) }
  }

  func nextDue(after date: Date) -> Date? {
    entries.values.map(\.schedule.due).filter { $0 > date }.min()
  }

  /// Whole days from `earlier` to `date`, counted by the calendar: 1 for yesterday.
  static func daysBetween(_ earlier: Date, and date: Date, calendar: Calendar = .current) -> Int? {
    calendar.dateComponents([.day], from: calendar.startOfDay(for: earlier), to: calendar.startOfDay(for: date)).day
  }

  mutating func reset() {
    entries = [:]
  }

  /// Folds in a schedule from before the record existed, which only the migration uses. An item
  /// already in the record keeps its own.
  mutating func adopt(_ item: PracticeItem, schedule: ReviewSchedule, lastLookedUp: Date?) {
    guard entries[item.key] == nil else {
      return
    }
    entries[item.key] = Entry(schedule: schedule, lastLookedUp: lastLookedUp)
  }

  private mutating func updateDue(_ items: [PracticeItem], at date: Date, _ change: (ReviewSchedule) -> ReviewSchedule) {
    for item in items {
      guard var entry = entries[item.key], entry.schedule.isDue(at: date) else {
        continue
      }
      entry.schedule = change(entry.schedule)
      entries[item.key] = entry
    }
  }
}
