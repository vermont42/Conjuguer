//
//  LearnerVerbStore.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation
import Observation

/// The app's view of `LearnerVerbs`: it records opens and stars, saves each change, and answers
/// in verbs rather than keys. A verb that has left `verbs.xml` is skipped.
@Observable
final class LearnerVerbStore {
  private(set) var record: LearnerVerbs
  private let getterSetter: GetterSetter

  init(getterSetter: GetterSetter) {
    self.getterSetter = getterSetter
    record = getterSetter.get(key: LearnerVerbs.storageKey).flatMap(LearnerVerbs.init(json:)) ?? LearnerVerbs()
  }

  var starredVerbs: [Verb] {
    verbs(record.starred)
  }

  var recentVerbs: [Verb] {
    verbs(record.recent())
  }

  /// The recent verbs that are not also starred, which My Verbs lists below the starred ones.
  var recentUnstarredVerbs: [Verb] {
    verbs(record.recent().filter { !record.isStarred($0) })
  }

  var myVerbs: [Verb] {
    verbs(record.myVerbs)
  }

  func isStarred(_ verb: Verb) -> Bool {
    record.isStarred(verb.dictionaryKey)
  }

  func hasOpened(_ verb: Verb) -> Bool {
    record.hasOpened(verb.dictionaryKey)
  }

  /// The verb the review card offers: the longest overdue. A verb with no key conjugations, such
  /// as accroire, which is used only in the infinitif, would have nothing to reveal, so it is
  /// passed over.
  func verbDueForReview(at date: Date = .now) -> Verb? {
    record.dueForReview(at: date).lazy
      .compactMap { Verb.verbs[$0] }
      .first { !$0.keyConjugations().isEmpty }
  }

  func daysSinceOpened(_ verb: Verb, at date: Date = .now) -> Int? {
    record.daysSinceOpened(verb.dictionaryKey, at: date)
  }

  func recordOpen(_ verb: Verb, source: AnalyticsSource, at date: Date = .now) {
    record.recordOpen(verb.dictionaryKey, at: date, schedulesReview: source != .reviewCard)
    save()
  }

  func recordReview(_ verb: Verb, at date: Date = .now) {
    record.recordReview(verb.dictionaryKey, at: date)
    save()
  }

  func snoozeReview(_ verb: Verb, at date: Date = .now) {
    record.snoozeReview(verb.dictionaryKey, at: date)
    save()
  }

  /// Returns whether the verb is now starred.
  @discardableResult
  func toggleStar(_ verb: Verb, at date: Date = .now) -> Bool {
    let isStarred = !record.isStarred(verb.dictionaryKey)
    record.setStarred(isStarred, key: verb.dictionaryKey, at: date)
    save()
    return isStarred
  }

  func remove(_ verb: Verb) {
    record.remove(verb.dictionaryKey)
    save()
  }

  func clearRecents() {
    record.clearRecents()
    save()
  }

  private func verbs(_ keys: [String]) -> [Verb] {
    keys.compactMap { Verb.verbs[$0] }
  }

  private func save() {
    if let json = record.json {
      getterSetter.set(key: LearnerVerbs.storageKey, value: json)
    }
  }
}
