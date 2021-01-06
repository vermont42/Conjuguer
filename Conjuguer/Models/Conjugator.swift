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
    var stem = String(infinitive[..<index])

    switch tense {
    case .indicatifPrésent(let personNumber):
      if let partialAlterations = model.partialAlterations {
        for alteration in partialAlterations {
          if alteration.appliesTo.contains(.indicatifPrésent(personNumber)) {
            stem.modifyStem(alteration: alteration)
            break
          }
        }
      }
      return .success(stem + model.présentEnding(personNumber: personNumber))
    case .passéSimple(let personNumber):
      if let partialAlterations = model.partialAlterations {
        for alteration in partialAlterations {
          if alteration.appliesTo.contains(.passéSimple(personNumber)) {
            stem.modifyStem(alteration: alteration)
            break
          }
        }
      }
      return .success(stem + model.passéSimpleEnding(personNumber: personNumber))
    case .participePassé:
      return .success(stem + model.participeEndingRecursive)
    default:
      return .failure(.tenseNotImplemented(tense))
    }
  }
}

extension String {
  mutating func modifyStem(alteration: PartialAlteration) {
    if alteration.startIndexFromLast == 0 {
      self = self + alteration.charsToUse.uppercased()
    } else {
      let repStartIndex = index(startIndex, offsetBy: count - 1)
      let repEndIndex = index(startIndex, offsetBy: (count - 1) + alteration.charsToReplaceCount - 1)
      replaceSubrange(repStartIndex ... repEndIndex, with: alteration.charsToUse.uppercased())
    }
  }
}
