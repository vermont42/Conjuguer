//
//  QuizAbandonment.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// The quizzes in progress, kept so that the next launch can report one the app was left during.
/// A quiz writes its entry as it starts and at each question, and removes it when it is quit or
/// reaches its results, so an entry still present at launch belongs to a quiz that ended with the
/// app. Entries are keyed by quiz, since a quiz in a sheet can run beside the Quiz tab's.
enum QuizAbandonment {
  struct Entry: Codable, Equatable {
    let level: String
    let source: String
    /// Nil for Review or My Mistakes, whose question reached is not sent.
    let lastQuestionIndex: Int?
  }

  static let key = "quizzesInProgress"

  static func record(_ entry: Entry, id: String, getterSetter: GetterSetter) {
    var entries = entries(getterSetter: getterSetter)
    entries[id] = entry
    store(entries, getterSetter: getterSetter)
  }

  static func clear(id: String, getterSetter: GetterSetter) {
    var entries = entries(getterSetter: getterSetter)
    guard entries.removeValue(forKey: id) != nil else {
      return
    }
    store(entries, getterSetter: getterSetter)
  }

  /// Sends `quizAbandon` for each quiz the last run left in progress, and forgets them.
  static func reportAndClear(getterSetter: GetterSetter, analytics: Analytics) {
    let entries = entries(getterSetter: getterSetter)
    guard !entries.isEmpty else {
      return
    }
    for entry in entries.values {
      var parameters = [
        ParameterKey.level.rawValue: entry.level,
        ParameterKey.source.rawValue: entry.source
      ]
      if let lastQuestionIndex = entry.lastQuestionIndex {
        parameters[ParameterKey.lastQuestionIndex.rawValue] = "\(lastQuestionIndex)"
      }
      analytics.signal(name: .quizAbandon, parameters: parameters)
    }
    getterSetter.remove(key: key)
  }

  static func entries(getterSetter: GetterSetter) -> [String: Entry] {
    getterSetter.getCodable(key: key) ?? [:]
  }

  private static func store(_ entries: [String: Entry], getterSetter: GetterSetter) {
    guard !entries.isEmpty else {
      getterSetter.remove(key: key)
      return
    }
    getterSetter.setCodable(key: key, value: entries)
  }
}
