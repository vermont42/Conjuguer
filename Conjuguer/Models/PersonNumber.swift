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

  static let count = 6

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
      return "1S"
    case .secondSingular:
      return "2S"
    case .thirdSingular:
      return "3S"
    case .firstPlural:
      return "1P"
    case .secondPlural:
      return "2P"
    case .thirdPlural:
      return "3P"
    }
  }

  var isValidForImperatif: Bool {
    [.secondSingular, .firstPlural, .secondPlural].contains(self)
  }
}
