//
//  ConjugationResult.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/31/21.
//

import Foundation

enum ConjugationResult {
  case totalMatch
  case partialMatch
  case noMatch

  static func score(correctAnswer: String, proposedAnswer: String) -> ConjugationResult {
    let correctAnswerCount = correctAnswer.count
    let proposedAnswerCount = proposedAnswer.count
    if correctAnswerCount != proposedAnswerCount || correctAnswerCount == 0 {
      return .noMatch
    }
    var correctAnswerClean = correctAnswer.lowercased()
    var proposedAnswerClean = proposedAnswer.lowercased()
    if correctAnswerClean == proposedAnswerClean {
      return .totalMatch
    }
    [("â", "a"), ("ê", "e"), ("î", "i"), ("ô", "o"), ("û", "u")].forEach {
      correctAnswerClean = correctAnswerClean.replacingOccurrences(of: $0.0, with: $0.1)
      proposedAnswerClean = proposedAnswerClean.replacingOccurrences(of: $0.0, with: $0.1)
    }
    if correctAnswerClean == proposedAnswerClean {
      return .totalMatch
    }
    [
      ("à", "a"), ("è", "e"), ("ì", "i"), ("ò", "o"), ("ù", "u"),
      ("á", "a"), ("é", "e"), ("í", "i"), ("ó", "o"), ("ú", "u")
    ].forEach {
      correctAnswerClean = correctAnswerClean.replacingOccurrences(of: $0.0, with: $0.1)
      proposedAnswerClean = proposedAnswerClean.replacingOccurrences(of: $0.0, with: $0.1)
    }
    if correctAnswerClean == proposedAnswerClean {
      return .partialMatch
    } else {
      return .noMatch
    }
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
}
