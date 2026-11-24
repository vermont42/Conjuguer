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
  /// Set for a Name the Conjugation question, whose prompt is a conjugation of `tense` and whose
  /// answer is a verb and a cell rather than a conjugation.
  var recognition: RecognitionQuestion?
  /// Set for a Phrases à trous question, whose blank stands in an authored sentence.
  var sentence: GapSentence?
  /// Set for a choice question, whose answer is one of two sentences.
  var choice: ChoicePrompt?

  /// The gender the answer agrees in: a sentence's subject's where it fixes one, and otherwise
  /// the learner's setting, which an impersonal verb overrides.
  var pronounGender: PronounGender {
    sentence?.pronounGender ?? verb.pronounGender
  }

  var reasked: QuizQuestion {
    reasked(stepID: nil)
  }

  func reasked(stepID: UUID?) -> QuizQuestion {
    QuizQuestion(verb: verb, tense: tense, isReask: true, stepID: stepID, recognition: recognition, sentence: sentence, choice: choice)
  }
}
