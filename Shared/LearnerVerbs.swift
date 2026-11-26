//
//  LearnerVerbs.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// The learner's own verbs: each verb opened, when and how often, and each verb starred. When a
/// verb is due on the review card is the practice record's business (`PracticeRecord`). The app
/// keeps it in the App Group's shared defaults, but the widget does not read it: My Verbs reaches
/// the widget inside the snapshots the app writes. It names verbs by `Verb.dictionaryKey`, so
/// that each entry of a doubled infinitive (haïr, ouïr, saillir, sortir) keeps its own opens and
/// star.
///
/// `firstOpened` says a verb was ever opened, which a collection counts as progress, and only
/// Reset Practice forgets it. `lastOpened` puts a verb in Recent, and Clear and a swipe in My
/// Verbs forget it, so that tidying the list costs no progress (Josh, 2026-11-25).
nonisolated struct LearnerVerbs: Codable, Equatable, Sendable {
  // A field added later must be optional. Synthesized decoding ignores a default value and
  // requires the key, so any other field would fail to decode every record an older build of the
  // app wrote, and the learner's verbs would silently vanish on upgrade.
  struct Entry: Codable, Equatable, Sendable {
    let dictionaryKey: String
    var firstOpened: Date?
    var lastOpened: Date?
    var openCount = 0
    var starred: Date?

    var isStarred: Bool {
      starred != nil
    }
  }

  static let storageKey = "learnerVerbs"
  static let recentLimit = 20

  private(set) var entries: [String: Entry] = [:]

  init() {}

  init?(json: String) {
    guard
      let data = json.data(using: .utf8),
      let decoded = try? JSONDecoder().decode(LearnerVerbs.self, from: data)
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

  func isStarred(_ key: String) -> Bool {
    entries[key]?.isStarred ?? false
  }

  /// Whether the verb has ever been opened, since Reset Practice last forgot first opens. A
  /// collection counts these toward its progress.
  func hasOpened(_ key: String) -> Bool {
    entries[key]?.firstOpened != nil
  }

  var hasFirstOpens: Bool {
    entries.values.contains { $0.firstOpened != nil }
  }

  /// Starred verbs, the most recently starred first.
  var starred: [String] {
    newestFirst(by: \.starred)
  }

  /// Opened verbs, the most recently opened first, starred or not, as the empty search field
  /// lists them.
  var recent: [String] {
    Array(newestFirst(by: \.lastOpened).prefix(Self.recentLimit))
  }

  /// Opened verbs that are not starred, the most recently opened first, as My Verbs lists them
  /// below the starred ones. The starred are left out before the limit, so that they cannot
  /// crowd older opens out of the list.
  var recentUnstarred: [String] {
    Array(newestFirst(by: \.lastOpened).filter { !isStarred($0) }.prefix(Self.recentLimit))
  }

  /// What My Verbs holds: the starred verbs, then the recent ones not starred.
  var myVerbs: [String] {
    starred + recentUnstarred
  }

  mutating func recordOpen(_ key: String, at date: Date) {
    var entry = entries[key] ?? Entry(dictionaryKey: key)
    entry.firstOpened = entry.firstOpened ?? date
    entry.lastOpened = date
    entry.openCount += 1
    entries[key] = entry
  }

  mutating func setStarred(_ isStarred: Bool, key: String, at date: Date) {
    var entry = entries[key] ?? Entry(dictionaryKey: key)
    entry.starred = isStarred ? (entry.starred ?? date) : nil
    store(entry)
  }

  /// Takes the verb out of My Verbs: forgets its star and its last open. Unstarring alone would
  /// move an opened verb from the starred verbs to the recent ones, and a verb deleted from My
  /// Verbs should leave it. That it was ever opened, and how often, stays.
  mutating func remove(_ key: String) {
    guard var entry = entries[key] else {
      return
    }
    entry.starred = nil
    entry.lastOpened = nil
    store(entry)
  }

  /// Empties Recent. Stars stay, and so do first opens and the practice record.
  mutating func clearRecents() {
    for var entry in entries.values {
      entry.lastOpened = nil
      store(entry)
    }
  }

  /// Forgets which verbs were ever opened and how often, for Reset Practice. Stars and Recent
  /// stay.
  mutating func forgetFirstOpens() {
    for var entry in entries.values {
      entry.firstOpened = nil
      entry.openCount = 0
      store(entry)
    }
  }

  /// The keys of the entries that have the date, newest first. Equal dates fall back to the key,
  /// so the order never depends on the dictionary's.
  private func newestFirst(by date: KeyPath<Entry, Date?>) -> [String] {
    let dated: [(key: String, date: Date)] = entries.values.compactMap { entry in
      guard let date = entry[keyPath: date] else {
        return nil
      }
      return (entry.dictionaryKey, date)
    }
    return dated
      .sorted { lhs, rhs in
        lhs.date != rhs.date ? lhs.date > rhs.date : lhs.key < rhs.key
      }
      .map(\.key)
  }

  private mutating func store(_ entry: Entry) {
    entries[entry.dictionaryKey] = entry.starred == nil && entry.lastOpened == nil && entry.firstOpened == nil ? nil : entry
  }
}
