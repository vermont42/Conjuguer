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

  @MainActor var pronoun: String {
    let pronounGender = Current.settings.pronounGender
    let singular = " singulier" // Intentionally not localizing this.
    let plural = " pluriel"

    switch self {
    case .firstSingular:
      return "je"
    case .secondSingular:
      return "tu"
    case .thirdSingular:
      switch pronounGender {
      case .feminine, .both:
        return "elle" + singular
      case .masculine:
        return "il" + singular
      }
    case .firstPlural:
      return "nous"
    case .secondPlural:
      return "vous"
    case .thirdPlural:
      switch pronounGender {
      case .masculine, .both:
        return "ils" + plural
      case .feminine:
        return "elles" + plural
      }
    }
  }

  @MainActor var pronounWithGender: String {
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

  @MainActor var gender: String {
    let pronounGender = Current.settings.pronounGender
    let masc = L.PronounGender.masculine
    let fem = L.PronounGender.feminine

    switch self {
    case .firstSingular:
      switch pronounGender {
      case .feminine, .both:
        return fem
      case .masculine:
        return masc
      }
    case .secondSingular:
      switch pronounGender {
      case .feminine, .both:
        return fem
      case .masculine:
        return masc
      }
    case .thirdSingular:
      return "" // Gender is implied by pronoun itself.
    case .firstPlural:
      switch pronounGender {
      case .masculine, .both:
        return masc
      case .feminine:
        return fem
      }
    case .secondPlural:
      switch pronounGender {
      case .masculine, .both:
        return masc
      case .feminine:
        return fem
      }
    case .thirdPlural:
      return "" // Gender is implied by pronoun lui-même.
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

  // The subject (+ reflexive) pronoun that precedes a conjugation, including any elision
  // (j'/m'/t'/s') implied by the conjugation's first letter.
  @MainActor func preamble(forConjugation conjugation: String, isReflexive: Bool, hasAspiratedH: Bool) -> String {
    let normalizedFirstLetter = String(conjugation.first ?? Character(" "))
      .folding(options: .diacriticInsensitive, locale: Util.french)
      .lowercased(with: Util.french)
    let firstLetterIsVowel = ["a", "e", "i", "o", "u"].contains(normalizedFirstLetter)
    let firstLetterIsUnaspiratedH = normalizedFirstLetter == "h" && !hasAspiratedH
    let firstLetterImpliesLiaison = firstLetterIsVowel || firstLetterIsUnaspiratedH

    let thirdSingular = Current.settings.pronounGender.thirdSingular
    let thirdPlural = Current.settings.pronounGender.thirdPlural

    if isReflexive {
      switch self {
      case .firstSingular:
        return firstLetterImpliesLiaison ? "je m'" : "je me "
      case .secondSingular:
        return firstLetterImpliesLiaison ? "tu t'" : "tu te "
      case .thirdSingular:
        return firstLetterImpliesLiaison ? "\(thirdSingular) s'" : "\(thirdSingular) se "
      case .firstPlural:
        return "nous nous "
      case .secondPlural:
        return "vous vous "
      case .thirdPlural:
        return firstLetterImpliesLiaison ? "\(thirdPlural) s'" : "\(thirdPlural) se "
      }
    } else {
      switch self {
      case .firstSingular:
        return firstLetterImpliesLiaison ? "j'" : "je "
      case .secondSingular:
        return "tu "
      case .thirdSingular:
        return "\(thirdSingular) "
      case .firstPlural:
        return "nous "
      case .secondPlural:
        return "vous "
      case .thirdPlural:
        return "\(thirdPlural) "
      }
    }
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
