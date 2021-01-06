//
//  Conjugator.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

struct Conjugator {
  static func conjugate(infinitive: String, tense: Tense, personNumber: PersonNumber?) -> Result<String, ConjugatorError> {
    guard let verb = Verb.verbs[infinitive] else {
      return .failure(.verbNotRecognized)
    }

    guard let model = VerbModel.models[verb.model] else {
      return .failure(.verbModelNotRecognized)
    }

    let index = infinitive.index(infinitive.endIndex, offsetBy: -1 * 2)
    let stem = String(infinitive[..<index])

    switch tense {
    case .indicatifPrésent:
      if let personNumber = personNumber {
        return .success(stem + model.présentEnding(personNumber: personNumber))
      } else {
        return .failure(.personNumberNoneForConjugatedTense)
      }
    case .participePassé:
      if personNumber != nil {
        return .failure(.personNumberForNonConjugatedTense)
      } else {
        return .success(stem + model.participeEndingRecursive)
      }
    default:
      return .failure(.tenseNotImplemented(tense))
    }
  }
}


