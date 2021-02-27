//
//  PersonNumber.swift
//  Conjuguer
//
//  Created by Josh Adams on 3/31/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

enum PersonNumber: String, CaseIterable {
  case firstSingular = "fs"
  case secondSingular = "ss"
  case thirdSingular = "ts"
  case firstPlural = "fp"
  case secondPlural = "sp"
  case thirdPlural = "tp"

  static let impératifPersonNumbers: [PersonNumber] = [.secondSingular, .firstPlural, .secondPlural]

  var pronoun: String {
    switch self {
    case .firstSingular:
      return "je"
    case .secondSingular:
      return "tu"
    case .thirdSingular:
      return "il"
    case .firstPlural:
      return "nous"
    case .secondPlural:
      return "vous"
    case .thirdPlural:
      return "elles"
    }
  }

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
}
