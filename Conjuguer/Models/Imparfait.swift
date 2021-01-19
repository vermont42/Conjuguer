//
//  Imparfait.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/9/21.
//

import Foundation

enum Imparfait {
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
