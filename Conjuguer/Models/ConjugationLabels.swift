//
//  ConjugationLabels.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation
import os

// The conjugation core's display members: pronouns, localized names, and the model page's
// verb links. They read `Current.settings` or `L`, which ConjugationMapTool, a macOS tool
// that compiles the core, does not have, so they live in this app-only file rather than
// beside the types they extend. See ConjugationMapTool/main.swift.

extension PersonNumber {
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
}

extension Tense {
  @MainActor var pronounWithGender: String {
    personNumber?.pronounWithGender ?? L.QuizView.none
  }

  @MainActor var pronoun: String {
    personNumber?.pronoun ?? L.QuizView.none
  }

  @MainActor var gender: String {
    personNumber?.gender ?? L.QuizView.none
  }

  @MainActor var pronounDecorator: String {
    guard let personNumber else {
      return ""
    }
    return " - \(personNumber.pronounWithGender)"
  }
}

extension PronounGender {
  var localizedGender: String {
    switch self {
    case .feminine:
      return L.PronounGender.feminine
    case .masculine:
      return L.PronounGender.masculine
    case .both:
      return L.PronounGender.both
    }
  }
}

extension VerbModel {
  var description: String {
    switch id {
    case "1-1":
      return "\(L.ModelView.regular) -er"
    case "2-1":
      return "\(L.ModelView.regular) -ir"
    case "5-1A":
      return "\(L.ModelView.regular) -re"
    default:
      return "\(irregularity)% \(L.ModelView.irregular)"
    }
  }

  func verbsWithDeepLinks() -> AttributedString {
    do {
      return try AttributedString(markdown: verbs.map {
        let encodedVerb = $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        return "[\($0)](\(URL.conjuguerUrlPrefix + URL.verbHost)/\(encodedVerb))"
      }
        .joined(separator: ", ")
      )
    } catch {
      Log.verbModel.error("Could not build deep-linked verb list for model \(id, privacy: .public): \(error.localizedDescription, privacy: .public)")
      return AttributedString("")
    }
  }
}

extension Conjugator {
  // The app's entry points, which agree a compound tense's participle with the pronoun-gender
  // setting unless told otherwise. The core's own versions take the gender explicitly, so that
  // ConjugationMapTool must choose one.
  static func conjugate(infinitif: String, tense: Tense, extraLetters: String?, pronounGender: PronounGender? = nil) -> Result<String, ConjugatorError> {
    conjugate(infinitif: infinitif, tense: tense, extraLetters: extraLetters, pronounGender: pronounGender ?? Current.settings.pronounGender)
  }

  static func conjugatedString(infinitif: String, tense: Tense, extraLetters: String?, pronounGender: PronounGender? = nil) -> String? {
    conjugatedString(infinitif: infinitif, tense: tense, extraLetters: extraLetters, pronounGender: pronounGender ?? Current.settings.pronounGender)
  }
}
