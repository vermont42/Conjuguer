//
//  FuturSimple.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/11/21.
//

import Foundation

enum FuturSimple {
  static func endingForPersonNumber(_ personNumber: PersonNumber) -> String {
    switch personNumber {
    case .firstSingular:
      return "ai"
    case .secondSingular:
      return "as"
    case .thirdSingular:
      return "a"
    case .firstPlural:
      return "ons"
    case .secondPlural:
      return "ez"
    case .thirdPlural:
      return "ont"
    }
  }
}
