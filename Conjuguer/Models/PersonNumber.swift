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

  func pronounAndConjugation(_ conjugation: String, isReflexive: Bool, hasAspiratedH: Bool) -> String {
    let normalizedFirstLetter = String(conjugation.first ?? Character(" "))
      .folding(options: .diacriticInsensitive, locale: Util.french)
      .lowercased(with: Util.french)
    let firstLetterIsVowel = ["a", "e", "i", "o", "u"].contains(normalizedFirstLetter)
    let firstLetterIsUnaspiratedH = normalizedFirstLetter == "h" && !hasAspiratedH
    let firstLetterImpliesLiaison = firstLetterIsVowel || firstLetterIsUnaspiratedH

    let preamble: String
    if isReflexive {
      switch self {
      case .firstSingular:
        preamble = firstLetterImpliesLiaison ? "je m'" : "je me "
      case .secondSingular:
        preamble = firstLetterImpliesLiaison ? "tu t'" : "tu te "
      case .thirdSingular:
        preamble = firstLetterImpliesLiaison ? "il s'" : "il se "
      case .firstPlural:
        preamble = "nous nous "
      case .secondPlural:
        preamble = "vous vous "
      case .thirdPlural:
        preamble = firstLetterImpliesLiaison ? "ils s'" : "ils se "
      }
    } else {
      switch self {
      case .firstSingular:
        preamble = firstLetterImpliesLiaison ? "j'" : "je "
      case .secondSingular:
        preamble = "tu "
      case .thirdSingular:
        preamble = "il "
      case .firstPlural:
        preamble = "nous "
      case .secondPlural:
        preamble = "vous "
      case .thirdPlural:
        preamble = "ils "
      }
    }

    return preamble + conjugation
  }
}
