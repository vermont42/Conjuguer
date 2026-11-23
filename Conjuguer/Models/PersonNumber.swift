//
//  PersonNumber.swift
//  Conjuguer
//
//  Created by Josh Adams on 3/31/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import Foundation

nonisolated enum PersonNumber: String, CaseIterable {
  case firstSingular = "fs"
  case secondSingular = "ss"
  case thirdSingular = "ts"
  case firstPlural = "fp"
  case secondPlural = "sp"
  case thirdPlural = "tp"

  static let impératifPersonNumbers: [PersonNumber] = [.secondSingular, .firstPlural, .secondPlural]

  var shortDisplayName: String {
    switch self {
    case .firstSingular:
      return "1s"
    case .secondSingular:
      return "2s"
    case .thirdSingular:
      return "3s"
    case .firstPlural:
      return "1p"
    case .secondPlural:
      return "2p"
    case .thirdPlural:
      return "3p"
    }
  }

  var isValidForImperatif: Bool {
    PersonNumber.impératifPersonNumbers.contains(self)
  }

  func impératifAndPossibleReflexivePronoun(_ conjugation: String, isReflexive: Bool) -> String {
    let suffix: String
    if isReflexive {
      switch self {
      case .secondSingular:
        suffix = "-toi"
      case .firstPlural:
        suffix = "-nous"
      case .secondPlural:
        suffix = "-vous"
      default:
        fatalError("Attempted to call impératifAndPossibleReflexivePronoun for \(shortDisplayName).")
      }
    } else {
      suffix = ""
    }

    return conjugation + suffix
  }

  static let byShortDisplayName: [String: PersonNumber] = [
    "1s": .firstSingular,
    "2s": .secondSingular,
    "3s": .thirdSingular,
    "1p": .firstPlural,
    "2p": .secondPlural,
    "3p": .thirdPlural
  ]

  static func personNumberForShortDisplayName(_ shortDisplayName: String) -> PersonNumber {
    guard let personNumber = byShortDisplayName[shortDisplayName] else {
      fatalError("Could not derive PersonNumber from shortDisplayName \(shortDisplayName).")
    }
    return personNumber
  }
}
