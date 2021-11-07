//
//  PronounGender.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/6/21.
//

import Foundation

enum PronounGender: String, CaseIterable {
  case feminine = "Feminine"
  case masculine = "Masculine"
  case both = "Both"

  var localizedGender: String {
    switch self {
    case .feminine:
      return L.PronounGender.feminine
    case .masculine:
      return L.PronounGender.masculine
    case .both:
      return L.PronounGender.both
    }
  }

  func participePasséEndingForPersonNumber(_ personNumber: PersonNumber) -> String {
    let ending: String
    switch self {
    case .feminine:
      switch personNumber {
      case .firstSingular, .secondSingular, .thirdSingular:
        ending = "e"
      case .firstPlural, .secondPlural, .thirdPlural:
        ending = "es"
      }
    case .masculine:
      switch personNumber {
      case .firstSingular, .secondSingular, .thirdSingular:
        ending = ""
      case .firstPlural, .secondPlural, .thirdPlural:
        ending = "s"
      }
    case .both:
      switch personNumber {
      case .firstSingular, .secondSingular, .thirdSingular:
        ending = "e"
      case .firstPlural, .secondPlural, .thirdPlural:
        ending = "s"
      }
    }
    return ending
  }

  var thirdSingular: String {
    switch self {
    case .feminine, .both:
      return "elle"
    case .masculine:
      return "il"
    }
  }

  var thirdPlural: String {
    switch self {
    case .masculine, .both:
      return "ils"
    case .feminine:
      return "elles"
    }
  }
}
