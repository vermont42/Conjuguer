//
//  ConjugationResult.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/31/21.
//

import SwiftUI

enum ConjugationResult {
  case totalMatch
  case partialMatch
  case noMatch

  private static let circumflexes: [Character: Character] = ["â": "a", "ê": "e", "î": "i", "ô": "o", "û": "u"]

  private static func strippingCircumflexes(_ string: String) -> String {
    String(string.map { circumflexes[$0] ?? $0 })
  }

  static func score(correctAnswers: String, proposedAnswer: String) -> ConjugationResult {
    let correctAnswersLowercased = correctAnswers.lowercased()
    let proposedAnswerLowercased = proposedAnswer.lowercased()
    for correctAnswer in correctAnswersLowercased.components(separatedBy: Tense.alternateConjugationSeparator) {
      if correctAnswer == proposedAnswerLowercased {
        return .totalMatch
      }
      if strippingCircumflexes(correctAnswer) == strippingCircumflexes(proposedAnswerLowercased) {
        return .totalMatch
      }
      let foldOptions: String.CompareOptions = .diacriticInsensitive
      if
        correctAnswer.folding(options: foldOptions, locale: Util.french) ==
        proposedAnswerLowercased.folding(options: foldOptions, locale: Util.french)
      {
        return .partialMatch
      }
    }
    return .noMatch
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
