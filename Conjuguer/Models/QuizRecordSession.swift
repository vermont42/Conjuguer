//
//  QuizRecordSession.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// A session drawn from the practice record rather than from a level's tenses: Review, of
/// whatever is due, and Practice My Mistakes, of what was last answered wrongly.
enum QuizRecordSession: CaseIterable {
  case review
  case mistakes

  /// The record's items for the session, in the order it asks them: the most overdue first for
  /// Review, and the most recently missed first for My Mistakes.
  func items(from practice: PracticeStore, at date: Date = .now) -> [PracticeItem] {
    switch self {
    case .review:
      return practice.dueItems(at: date)
    case .mistakes:
      return practice.missedItems()
    }
  }

  /// How many of the session's items can be asked, which the Quiz tab shows.
  func askableCount(from practice: PracticeStore, at date: Date = .now) -> Int {
    items(from: practice, at: date).filter(\.isAskable).count
  }

  var title: String {
    switch self {
    case .review:
      return L.PracticeSession.review
    case .mistakes:
      return L.PracticeSession.mistakes
    }
  }

  var source: AnalyticsSource {
    switch self {
    case .review:
      return .review
    case .mistakes:
      return .mistakes
    }
  }
}

extension PracticeItem {
  /// Whether Review or My Mistakes can ask the item: a pattern this version can read, or a key
  /// conjugation of a verb still in the verb list, still learned verb by verb, and having the
  /// cell.
  var isAskable: Bool {
    guard let tense else {
      return false
    }
    switch self {
    case .keyConjugation:
      return verb?.hasCell(tense) == true
    case .pattern:
      return true
    }
  }
}

extension QuizDraw {
  /// A round of Review or My Mistakes: a question for each of the first `limit` items that can be
  /// asked, held to neither the level's tenses nor its band, since the learner practiced or
  /// looked up each one. A pattern asks its cell of a verb from `band` that shares the pattern, or
  /// of any verb when the band has none, as it may not for a rare spelling-change model. Items in
  /// `excluded`, the session's earlier rounds, are skipped, since a mistake missed again would
  /// otherwise return in Ten More.
  ///
  /// A verb's key conjugations sit together, in the verb page's order, at the place of the first
  /// one drawn, so that a review of venir reads vient · est venu · viendra.
  @MainActor static func sessionQuestions(
    for items: [PracticeItem],
    band: FrequencyBand?,
    excluded: Set<String>,
    limit: Int,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizQuestion] {
    let bandVerbs = verbs(in: band).filter { !excludedEntries.contains($0.dictionaryKey) }
    var everyVerb: [Verb]?
    var groupOrder: [String] = []
    var groups: [String: [(stem: Int, question: QuizQuestion)]] = [:]
    var count = 0

    for item in items where count < limit && !excluded.contains(item.key) && item.isAskable {
      guard let tense = item.tense else {
        continue
      }
      let question: QuizQuestion
      let groupKey: String
      var stemOrder = 0
      switch item {
      case let .keyConjugation(verbKey, stem):
        guard let verb = item.verb else {
          continue
        }
        question = QuizQuestion(verb: verb, tense: tense)
        groupKey = verbKey
        stemOrder = PracticeItem.Stem.allCases.firstIndex(of: stem) ?? 0
      case .pattern:
        var verb = patternVerb(for: item, tense: tense, from: bandVerbs, using: &generator)
        if verb == nil {
          let all = everyVerb ?? verbs(in: nil).filter { !excludedEntries.contains($0.dictionaryKey) }
          everyVerb = all
          verb = patternVerb(for: item, tense: tense, from: all, using: &generator)
        }
        guard let verb else {
          continue
        }
        question = QuizQuestion(verb: verb, tense: tense)
        groupKey = item.key
      }
      if groups[groupKey] == nil {
        groupOrder.append(groupKey)
      }
      groups[groupKey, default: []].append((stemOrder, question))
      count += 1
    }

    return groupOrder.flatMap { groupKey in
      (groups[groupKey] ?? []).sorted { $0.stem < $1.stem }.map(\.question)
    }
  }
}

extension QuizScope {
  /// Review or My Mistakes, from the Quiz tab: up to ten items, then Ten More while any remain,
  /// never ranked, and mixing in nothing.
  static func recordSession(_ session: QuizRecordSession) -> QuizScope {
    QuizScope(verbs: nil, questionCount: Quiz.questionCount, source: session.source, kind: .recordSession(session))
  }
}
