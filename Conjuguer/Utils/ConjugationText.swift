//
//  ConjugationText.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/11/21.
//

import SwiftUI

extension Text {
  init(verb: Verb, tense: Tense) {
    let conjugation: String
    switch Conjugator.conjugate(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters) {
    case .success(let value):
      conjugation = value
    default:
      fatalError("Could not conjugate \(verb.infinitif) for \(tense.displayName).")
    }

    switch tense {
    case .participePassé, .participePrésent, .radicalFutur:
      self.init(mixedCaseString: conjugation)
      return
    default:
      self.init("")

// TODO: Build mixedCaseString with subject pronoun and reflexive pronoun.
// TODO: For all verbs, use .strikeThrough() if conjugation is defective.

//    case .indicatifPrésent(_):
//      <#code#>
//    case .passéSimple(_):
//      <#code#>
//    case .imparfait(_):
//      <#code#>
//    case .futurSimple(_):
//      <#code#>
//    case .conditionnelPrésent(_):
//      <#code#>
//    case .subjonctifPrésent(_):
//      <#code#>
//    case .subjonctifImparfait(_):
//      <#code#>
//    case .impératif(_):
//      <#code#>
//    case .passéComposé(_):
//      <#code#>
//    case .plusQueParfait(_):
//      <#code#>
//    case .passéAntérieur(_):
//      <#code#>
//    case .passéSurcomposé(_):
//      <#code#>
//    case .futurAntérieur(_):
//      <#code#>
//    case .conditionnelPassé(_):
//      <#code#>
//    case .subjonctifPassé(_):
//      <#code#>
//    case .subjonctifPlusQueParfait(_):
//      <#code#>
//    case .impératifPassé(_):
//      <#code#>
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
          self = self + Text(currentRegularPart).foregroundColor(.blue)
          currentRegularPart = ""
          currentIrregularPart = canonicalChar
          state = .inIrregularPart
        }
      case .inIrregularPart:
        if isRegular {
          self = self + Text(currentIrregularPart).foregroundColor(.red)
          currentRegularPart = canonicalChar
          currentIrregularPart = ""
          state = .inRegularPart
        } else {
          currentIrregularPart += canonicalChar
        }
      }
    }

    self = self + Text(currentRegularPart).foregroundColor(.blue)
    self = self + Text(currentIrregularPart).foregroundColor(.red)
  }
}
