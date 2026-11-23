//
//  ConjugationResult.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/31/21.
//

import SwiftUI

/// A graded answer. `shownSpelling` is the conjugation as the app writes it, for a right answer
/// spelled another standard way, such as connait for connaît.
struct AnswerGrade: Equatable {
  let result: ConjugationResult
  let shownSpelling: String?
}

enum ConjugationResult {
  case totalMatch
  /// Right on the second attempt that a slip earned (`AnswerSlip`). `grade` never returns it.
  case secondAttemptMatch
  case noMatch

  /// Grades a typed answer to `tense` of `verb`, whose "/"-separated conjugations the conjugator
  /// wrote as `correctAnswers`. A subject pronoun of the asked person is ignored, and so is a
  /// pronominal verb's reflexive pronoun (`AnswerSpelling.candidates`). An answer spelled as a
  /// `StandardVariants` variant is a total match whose `shownSpelling` is the conjugator's.
  static func grade(proposedAnswer: String, correctAnswers: String, verb: Verb, tense: Tense) -> AnswerGrade {
    let alternates = correctAnswers.components(separatedBy: Tense.alternateConjugationSeparator)
    let conjugations = alternates.map { $0.lowercased() }
    let candidates = AnswerSpelling.candidates(for: proposedAnswer, tense: tense, isReflexive: verb.isReflexive)

    if candidates.contains(where: conjugations.contains) {
      return AnswerGrade(result: .totalMatch, shownSpelling: nil)
    }

    for (alternate, conjugation) in zip(alternates, conjugations) {
      let variants = StandardVariants.variants(of: conjugation, verb: verb, tense: tense)
      if candidates.contains(where: variants.contains) {
        return AnswerGrade(result: .totalMatch, shownSpelling: alternate)
      }
    }
    return AnswerGrade(result: .noMatch, shownSpelling: nil)
  }

  var sound: Sound {
    switch self {
    case .totalMatch:
      return .chime
    case .secondAttemptMatch:
      return .chime
    case .noMatch:
      return .buzz
    }
  }

  var score: Int {
    switch self {
    case .totalMatch:
      return 10
    case .secondAttemptMatch:
      return 5
    case .noMatch:
      return 0
    }
  }

  var feedbackIconString: String {
    switch self {
    case .totalMatch:
      return "checkmark.circle.fill"
    case .secondAttemptMatch:
      return "checkmark.circle"
    case .noMatch:
      return "xmark.circle.fill"
    }
  }

  var feedbackColor: Color {
    switch self {
    case .totalMatch:
      return .customGreen
    case .secondAttemptMatch:
      return .secondAttempt
    case .noMatch:
      return .customRed
    }
  }
}

extension Color {
  static let secondAttempt = Color.orange
}
