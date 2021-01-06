//
//  Conjugator.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

struct Conjugator {
  static func conjugate(infinitive: String, tense: Tense) -> Result<String, ConjugatorError> {
    guard let verb = Verb.verbs[infinitive] else {
      return .failure(.verbNotRecognized)
    }

    guard let model = VerbModel.models[verb.model] else {
      return .failure(.verbModelNotRecognized)
    }

    let index = infinitive.index(infinitive.endIndex, offsetBy: -1 * 2)
    let stem = String(infinitive[..<index])

    switch tense {
    case .indicatifPrésent(let personNumber):
      return .success(stem + model.présentEnding(personNumber: personNumber))
    case .participePassé:
      return .success(stem + model.participeEndingRecursive)
    default:
      return .failure(.tenseNotImplemented(tense))
    }
  }
}


