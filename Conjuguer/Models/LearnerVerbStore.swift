//
//  LearnerVerbStore.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation
import Observation

/// The app's view of `LearnerVerbs`: it records opens and stars, saves each change, and answers
/// in verbs rather than keys. A verb that has left `verbs.xml` is skipped. The record's lists are
/// sorted once per change, since the record never shrinks and views read them on every pass. They
/// stay keys until read, because the store exists before the verbs load.
@Observable
final class LearnerVerbStore {
  private(set) var record: LearnerVerbs
  private var lists: Lists
  private let getterSetter: GetterSetter

  private struct Lists {
    let starred: [String]
    let recent: [String]
    let recentUnstarred: [String]
    let myVerbs: [String]

    init(_ record: LearnerVerbs) {
      starred = record.starred
      recent = record.recent
      recentUnstarred = record.recentUnstarred
      myVerbs = starred + recentUnstarred
    }
  }

  init(getterSetter: GetterSetter) {
    self.getterSetter = getterSetter
    let record = getterSetter.get(key: LearnerVerbs.storageKey).flatMap(LearnerVerbs.init(json:)) ?? LearnerVerbs()
    self.record = record
    lists = Lists(record)
  }

  var starredVerbs: [Verb] {
    verbs(lists.starred)
  }

  var recentVerbs: [Verb] {
    verbs(lists.recent)
  }

  var recentUnstarredVerbs: [Verb] {
    verbs(lists.recentUnstarred)
  }

  var myVerbs: [Verb] {
    verbs(lists.myVerbs)
  }

  func isStarred(_ verb: Verb) -> Bool {
    record.isStarred(verb.dictionaryKey)
  }

  func hasOpened(_ verb: Verb) -> Bool {
    record.hasOpened(verb.dictionaryKey)
  }

  /// Whether any verb counts as opened, which Reset Practice would forget.
  var hasFirstOpens: Bool {
    record.hasFirstOpens
  }

  func openedCount(of verbs: [Verb]) -> Int {
    verbs.count { record.hasOpened($0.dictionaryKey) }
  }

  func recordOpen(_ verb: Verb, at date: Date = .now) {
    change { $0.recordOpen(verb.dictionaryKey, at: date) }
  }

  /// Returns whether the verb is now starred.
  @discardableResult
  func toggleStar(_ verb: Verb, at date: Date = .now) -> Bool {
    let isStarred = !record.isStarred(verb.dictionaryKey)
    change { $0.setStarred(isStarred, key: verb.dictionaryKey, at: date) }
    return isStarred
  }

  func remove(_ verb: Verb) {
    change { $0.remove(verb.dictionaryKey) }
  }

  func clearRecents() {
    change { $0.clearRecents() }
  }

  /// Reset Practice's part: every collection's progress returns to nothing.
  func forgetFirstOpens() {
    change { $0.forgetFirstOpens() }
  }

  private func change(_ body: (inout LearnerVerbs) -> Void) {
    body(&record)
    lists = Lists(record)
    if let json = record.json {
      getterSetter.set(key: LearnerVerbs.storageKey, value: json)
    }
  }

  private func verbs(_ keys: [String]) -> [Verb] {
    keys.compactMap { Verb.verbs[$0] }
  }
}
