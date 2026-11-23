//
//  QuizQuestion.swift
//  Conjuguer
//

struct QuizQuestion {
  let verb: Verb
  let tense: Tense
  /// A missed question asked once more, a few questions after the miss.
  var isReask = false

  var reasked: QuizQuestion {
    QuizQuestion(verb: verb, tense: tense, isReask: true)
  }
}
