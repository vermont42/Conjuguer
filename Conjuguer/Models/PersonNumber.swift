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
      return "ils"
    }
  }

  var pronounWithGender: String {
    let pronounGender = Current.settings.pronounGender
    let masc = L.PronounGender.masculineAbbreviation
    let fem = L.PronounGender.feminineAbbreviation

    switch self {
    case .firstSingular:
      switch pronounGender {
      case .feminine, .both:
        return "je (\(fem))"
      case .masculine:
        return "je (\(masc))"
      }
    case .secondSingular:
      switch pronounGender {
      case .feminine, .both:
        return "tu (\(fem))"
      case .masculine:
        return "tu (\(masc))"
      }
    case .thirdSingular:
      switch pronounGender {
      case .feminine, .both:
        return "elle"
      case .masculine:
        return "il"
      }
    case .firstPlural:
      switch pronounGender {
      case .masculine, .both:
        return "nous (\(masc))"
      case .feminine:
        return "nous (\(fem))"
      }
    case .secondPlural:
      switch pronounGender {
      case .masculine, .both:
        return "vous (\(masc))"
      case .feminine:
        return "vous (\(fem))"
      }
    case .thirdPlural:
      switch pronounGender {
      case .masculine, .both:
        return "ils"
      case .feminine:
        return "elles"
      }
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

    let thirdSingular = Current.settings.pronounGender.thirdSingular
    let thirdPlural = Current.settings.pronounGender.thirdPlural

    let preamble: String
    if isReflexive {
      switch self {
      case .firstSingular:
        preamble = firstLetterImpliesLiaison ? "je m'" : "je me "
      case .secondSingular:
        preamble = firstLetterImpliesLiaison ? "tu t'" : "tu te "
      case .thirdSingular:
        preamble = firstLetterImpliesLiaison ? "\(thirdSingular) s'" : "\(thirdSingular) se "
      case .firstPlural:
        preamble = "nous nous "
      case .secondPlural:
        preamble = "vous vous "
      case .thirdPlural:
        preamble = firstLetterImpliesLiaison ? "\(thirdPlural) s'" : "\(thirdPlural) se "
      }
    } else {
      switch self {
      case .firstSingular:
        preamble = firstLetterImpliesLiaison ? "j'" : "je "
      case .secondSingular:
        preamble = "tu "
      case .thirdSingular:
        preamble = "\(thirdSingular) "
      case .firstPlural:
        preamble = "nous "
      case .secondPlural:
        preamble = "vous "
      case .thirdPlural:
        preamble = "\(thirdPlural) "
      }
    }

    return preamble + conjugation
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

  static func personNumberForShortDisplayName(_ shortDisplayName: String) -> PersonNumber {
    switch shortDisplayName {
    case "1s":
      return .firstSingular
    case "2s":
      return .secondSingular
    case "3s":
      return .thirdSingular
    case "1p":
      return .firstPlural
    case "2p":
      return .secondPlural
    case "3p":
      return .thirdPlural
    default:
      fatalError("Could not derive PersonNumber from shortDisplayName \(shortDisplayName).")
    }
  }
}
