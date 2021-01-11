//
//  ConditionnelPresent.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/11/21.
//

import Foundation

enum ConditionnelPrésent {
  static func endingForPersonNumber(_ personNumber: PersonNumber) -> String {
    switch personNumber {
    case .firstSingular:
      return "ais"
    case .secondSingular:
      return "ais"
    case .thirdSingular:
      return "ait"
    case .firstPlural:
      return "ions"
    case .secondPlural:
      return "iez"
    case .thirdPlural:
      return "aient"
    }
  }
}
