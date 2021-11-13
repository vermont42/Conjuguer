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

  var scoreModifier: Int {
    switch self {
    case .regular:
      return 1
    case .ridiculous:
      return 2
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

  var localizedDifficultyWithLabel: String {
    switch self {
    case .regular:
      return L.QuizDifficulty.regularDifficulty
    case .ridiculous:
      return L.QuizDifficulty.ridiculousDifficulty
    }
  }
}
