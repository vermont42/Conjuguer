//
//  QuizQuestion.swift
//  Conjuguer
//

import Foundation

struct QuizQuestion {
  let verb: Verb
  let tense: Tense
  /// A missed question asked once more, a few questions after the miss.
  var isReask = false
  /// The questions shown together on one screen, such as a verb's three key conjugations in Verb
  /// Essentials, share a step. Nil for a question shown alone.
  var stepID: UUID?

  var reasked: QuizQuestion {
    reasked(stepID: nil)
  }

  func reasked(stepID: UUID?) -> QuizQuestion {
    QuizQuestion(verb: verb, tense: tense, isReask: true, stepID: stepID)
  }
}
