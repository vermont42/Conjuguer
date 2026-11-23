//
//  QuizResult.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/8/21.
//

import Foundation

struct QuizResult: Hashable, Identifiable {
  let id = UUID()
  let infinitif: String
  let tense: Tense
  let conjugationResult: ConjugationResult
  let correctAnswer: String
  let actualAnswer: String
  var shownSpelling: String?
  /// The slip that earned a second attempt. `actualAnswer` is the second attempt.
  var firstAttempt: String?
  var isReask = false

  /// A right re-ask earns half points on either attempt, as a right second attempt does.
  var points: Int {
    guard isReask, conjugationResult != .noMatch else {
      return conjugationResult.score
    }
    return ConjugationResult.secondAttemptMatch.score
  }
}
