//
//  ConjugationText.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/11/21.
//

import SwiftUI

extension Text {
  init(verb: Verb, tense: Tense, shouldShowIrregularities: Bool = true) {
    var conjugation: String
    switch Conjugator.conjugate(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters) {
    case .success(let value):
      conjugation = value
    default:
      fatalError("Could not conjugate \(verb.infinitif) for \(tense.titleCaseName).")
    }

    switch tense {
    case .participePassé:
      break
    case .participePrésent:
      break
    case .radicalFutur:
      break
    case .indicatifPrésent(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .passéSimple(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .imparfait(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .futurSimple(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .conditionnelPrésent(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .subjonctifPrésent(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .subjonctifImparfait(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .impératif(let personNumber):
      conjugation = personNumber.impératifAndPossibleReflexivePronoun(conjugation, isReflexive: verb.isReflexive)
    case .passéComposé(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .plusQueParfait(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .passéAntérieur(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .passéSurcomposé(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .futurAntérieur(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .conditionnelPassé(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .subjonctifPassé(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .subjonctifPlusQueParfait(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
    case .impératifPassé:
      break
    }

    if shouldShowIrregularities {
      self.init(mixedCaseString: conjugation)
    } else {
      self.init(conjugation.lowercased())
    }

    if
      let defectGroupId = verb.defectGroupId,
      let defectGroup = DefectGroup.defectGroups[defectGroupId],
      defectGroup.isDefectiveForTense(tense)
    {
      self = strikethrough()
    }
  }

  init(mixedCaseString: String) {
    self.init("")

    enum ColorParsingState {
      case notStarted
      case inRegularPart
      case inIrregularPart
    }

    var state = ColorParsingState.notStarted
    var currentRegularPart = ""
    var currentIrregularPart = ""

    for char in mixedCaseString {
      let isRegular = char.isLowercase || !char.isLetter
      let canonicalChar = char.lowercased()
      switch state {
      case .notStarted:
        if isRegular {
          currentRegularPart = canonicalChar
          state = .inRegularPart
        } else {
          currentIrregularPart = canonicalChar
          state = .inIrregularPart
        }
      case .inRegularPart:
        if isRegular {
          currentRegularPart += canonicalChar
        } else {
          self = self + Text(currentRegularPart).foregroundColor(.customBlue)
          currentRegularPart = ""
          currentIrregularPart = canonicalChar
          state = .inIrregularPart
        }
      case .inIrregularPart:
        if isRegular {
          self = self + Text(currentIrregularPart).foregroundColor(.customRed)
          currentRegularPart = canonicalChar
          currentIrregularPart = ""
          state = .inRegularPart
        } else {
          currentIrregularPart += canonicalChar
        }
      }
    }

    self = self + Text(currentRegularPart).foregroundColor(.customBlue)
    self = self + Text(currentIrregularPart).foregroundColor(.customRed)
  }
}
