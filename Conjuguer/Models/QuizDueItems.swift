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
  /// most overdue first, and at most `dueItemLimit`. A key conjugation asks its own cell of its
  /// verb. A pattern asks its cell of a verb from the band that shares the pattern. An item the
  /// level does not ask, such as a passé simple below Advanced, or a looked-up verb beyond the band,
  /// waits, so that the default quiz stays within its level.
  @MainActor static func dueQuestions(
    for items: [PracticeItem],
    slots: [QuizTenseSlot],
    band: FrequencyBand?,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizQuestion] {
    let bandVerbs = verbs(in: band).filter { !excludedEntries.contains($0.dictionaryKey) }
    let bandKeys = Set(bandVerbs.map(\.dictionaryKey))
    let askedSlots = Set(slots)
    var questions: [QuizQuestion] = []

    for item in items where questions.count < dueItemLimit {
      guard let tense = item.tense, let slot = QuizTenseSlot(tense: tense), askedSlots.contains(slot) else {
        continue
      }
      switch item {
      case .keyConjugation:
        guard let verb = item.verb, bandKeys.contains(verb.dictionaryKey), verb.hasCell(tense) else {
          continue
        }
        questions.append(QuizQuestion(verb: verb, tense: tense))
      case let .pattern(model, _, _, _):
        func fits(_ verb: Verb) -> Bool {
          verb.hasCell(tense) && PracticeItem.exercised(by: tense, of: verb) == item
        }
        // A base's own verbs share every cell of its pattern and need no conjugating to check, so
        // the rest of its family, manger's verbs for parler's, is searched only when none fits.
        var fitting = bandVerbs.filter { $0.model == model && fits($0) }
        if fitting.isEmpty, PracticeItem.patternBases.contains(model) {
          fitting = bandVerbs.filter { $0.model != model && PracticeItem.patternBase(of: $0) == model && fits($0) }
        }
        guard let verb = fitting.randomElement(using: &generator) else {
          continue
        }
        questions.append(QuizQuestion(verb: verb, tense: tense))
      }
    }
    return questions
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
