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

  func isFeminine(_ personNumber: PersonNumber) -> Bool {
    switch self {
    case .feminine:
      return true
    case .masculine:
      return false
    case .both:
      switch personNumber {
      case .firstSingular, .secondSingular, .thirdSingular:
        return true
      case .firstPlural, .secondPlural, .thirdPlural:
        return false
      }
    }
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
