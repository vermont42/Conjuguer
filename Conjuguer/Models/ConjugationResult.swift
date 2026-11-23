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
  case partialMatch
  case noMatch

  /// Grades a typed answer to `tense` of `verb`, whose "/"-separated conjugations the conjugator
  /// wrote as `correctAnswers`. A subject pronoun of the asked person is ignored, and so is a
  /// pronominal verb's reflexive pronoun (`AnswerSpelling.candidates`). An answer spelled as a
  /// `StandardVariants` variant is a total match whose `shownSpelling` is the conjugator's. An
  /// answer that differs only in accents, cedillas, or the diaeresis is a partial match.
  static func grade(proposedAnswer: String, correctAnswers: String, verb: Verb, tense: Tense) -> AnswerGrade {
    let alternates = correctAnswers.components(separatedBy: Tense.alternateConjugationSeparator)
    let conjugations = alternates.map { $0.lowercased() }
    let candidates = AnswerSpelling.candidates(for: proposedAnswer, tense: tense, isReflexive: verb.isReflexive)

    if candidates.contains(where: conjugations.contains) {
      return AnswerGrade(result: .totalMatch, shownSpelling: nil)
    }

    var spellings = conjugations
    for (alternate, conjugation) in zip(alternates, conjugations) {
      let variants = StandardVariants.variants(of: conjugation, verb: verb, tense: tense)
      if candidates.contains(where: variants.contains) {
        return AnswerGrade(result: .totalMatch, shownSpelling: alternate)
      }
      spellings += variants
    }

    let foldedSpellings = Set(spellings.map(folded))
    if candidates.contains(where: { foldedSpellings.contains(folded($0)) }) {
      return AnswerGrade(result: .partialMatch, shownSpelling: nil)
    }
    return AnswerGrade(result: .noMatch, shownSpelling: nil)
  }

  private static func folded(_ text: String) -> String {
    text.folding(options: .diacriticInsensitive, locale: Util.french)
  }

  var sound: Sound {
    switch self {
    case .totalMatch:
      return .chime
    case .partialMatch:
      return .chirp
    case .noMatch:
      return .buzz
    }
  }

  var score: Int {
    switch self {
    case .totalMatch:
      return 10
    case .partialMatch:
      return 5
    case .noMatch:
      return 0
    }
  }

  var percentCorrect: Double {
    switch self {
    case .totalMatch:
      return 1.0
    case .partialMatch:
      return 0.5
    case .noMatch:
      return 0.0
    }
  }

  var feedbackIconString: String {
    switch self {
    case .totalMatch:
      return "checkmark.circle.fill"
    case .partialMatch:
      return "circle.bottomhalf.fill"
    case .noMatch:
      return "xmark.circle.fill"
    }
  }

  var feedbackColor: Color {
    switch self {
    case .totalMatch:
      return .customGreen
    case .partialMatch:
      return .customBlue
    case .noMatch:
      return .customRed
    }
  }
}
