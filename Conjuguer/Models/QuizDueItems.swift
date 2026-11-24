//
//  QuizDueItems.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// How a default session mixes in items the practice record says are due, so that a learner who
/// never opens a review still relearns.
extension QuizDraw {
  static let dueItemLimit = 3

  /// A question for each due item that the slots ask and the band holds, in the record's order,
  /// most overdue first, and at most `limit`. A key conjugation asks its own cell of its
  /// verb. A pattern asks its cell of a verb from the band that shares the pattern. An item the
  /// level does not ask, such as a passé simple below Advanced, or a looked-up verb beyond the band,
  /// waits, so that the default quiz stays within its level.
  @MainActor static func dueQuestions(
    for items: [PracticeItem],
    slots: [QuizTenseSlot],
    band: FrequencyBand?,
    limit: Int = dueItemLimit, // swiftlint:disable:this function_default_parameter_at_end
    using generator: inout some RandomNumberGenerator
  ) -> [QuizQuestion] {
    let bandVerbs = verbs(in: band).filter { !excludedEntries.contains($0.dictionaryKey) }
    let bandKeys = Set(bandVerbs.map(\.dictionaryKey))
    let askedSlots = Set(slots)
    var questions: [QuizQuestion] = []

    for item in items where questions.count < limit {
      guard let tense = item.tense, let slot = QuizTenseSlot(tense: tense), askedSlots.contains(slot) else {
        continue
      }
      switch item {
      case .keyConjugation:
        guard let verb = item.verb, bandKeys.contains(verb.dictionaryKey), verb.hasCell(tense) else {
          continue
        }
        questions.append(QuizQuestion(verb: verb, tense: tense))
      case .pattern:
        guard let verb = patternVerb(for: item, tense: tense, from: bandVerbs, using: &generator) else {
          continue
        }
        questions.append(QuizQuestion(verb: verb, tense: tense))
      }
    }
    return questions
  }

  /// A verb of `verbs` whose `tense` exercises the pattern `item`, drawn at random.
  static func patternVerb(
    for item: PracticeItem,
    tense: Tense,
    from verbs: [Verb],
    using generator: inout some RandomNumberGenerator
  ) -> Verb? {
    patternVerbs(for: item, tense: tense, from: verbs).randomElement(using: &generator)
  }

  /// The verbs of `verbs` whose `tense` exercises the pattern `item`. A base's own verbs share
  /// every cell of its pattern and need no conjugating to check, so the rest of its family,
  /// manger's verbs for parler's, is searched only when none fits.
  static func patternVerbs(for item: PracticeItem, tense: Tense, from verbs: [Verb]) -> [Verb] {
    guard case let .pattern(model, _, _, _) = item else {
      return []
    }
    func fits(_ verb: Verb) -> Bool {
      verb.hasCell(tense) && PracticeItem.exercised(by: tense, of: verb) == item
    }
    var fitting = verbs.filter { $0.model == model && fits($0) }
    if fitting.isEmpty, PracticeItem.patternBases.contains(model) {
      fitting = verbs.filter { $0.model != model && PracticeItem.patternBase(of: $0) == model && fits($0) }
    }
    return fitting
  }

  /// The drawn questions with the due ones placed among them at random.
  static func mixing(_ due: [QuizQuestion], into drawn: [QuizQuestion], using generator: inout some RandomNumberGenerator) -> [QuizQuestion] {
    var questions = drawn
    for question in due {
      questions.insert(question, at: Int.random(in: 0 ... questions.count, using: &generator))
    }
    return questions
  }
}
