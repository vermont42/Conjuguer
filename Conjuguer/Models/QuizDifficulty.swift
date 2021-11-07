//
//  QuizDifficulty.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/6/21.
//

import Foundation

enum QuizDifficulty: String, CaseIterable {
  case regular = "Regular"
  case ridiculous = "Ridiculous"

  var scoreModifier: Double {
    switch self {
    case .regular:
      return 1.0
    case .ridiculous:
      return 2.0
    }
  }

  var localizedDifficulty: String {
    switch self {
    case .regular:
      return L.QuizDifficulty.regular
    case .ridiculous:
      return L.QuizDifficulty.ridiculous
    }
  }
}
