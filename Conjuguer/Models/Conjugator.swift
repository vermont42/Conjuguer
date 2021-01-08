//
//  Conjugator.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

struct Conjugator {
  static func conjugate(infinitive: String, tense: Tense) -> Result<String, ConjugatorError> {
    guard infinitive.count >= Verb.minVerbLength else {
      return .failure(.verbTooShort)
    }

    guard Verb.endingIsValid(infinitive: infinitive) else {
      return .failure(.infinitiveEndingInvalid)
    }

    guard let verb = Verb.verbs[infinitive] else {
      return .failure(.verbNotRecognized)
    }

    guard let model = VerbModel.models[verb.model] else {
      return .failure(.verbModelNotRecognized)
    }

    if let completeAlterations = model.completeAlterations {
      for alteration in completeAlterations {
        if alteration.appliesTo == tense {
          return .success(alteration.conjugation.uppercased())
        }
      }
    }

    var stem: String
    switch tense {
    case .indicatifPrésent(_):
      stem = verb.infinitiveStem
    case .participePassé, .passéSimple(_):
      stem = model.participeStem(verb: verb)
    default:
      return .failure(.tenseNotImplemented(tense)) // TODO: Fix this.
    }

    if let partialAlterations = model.partialAlterations {
      for alteration in partialAlterations {
        if alteration.appliesTo.contains(tense) {
          stem.modifyStem(alteration: alteration)
          break
        }
      }
    }

    switch tense {
    case .indicatifPrésent(let personNumber):
      return .success(stem + model.indicatifPrésentGroupRecursive.endingForPersonNumber(personNumber))
    case .passéSimple(let personNumber):
      return .success(stem + model.passéSimpleGroupRecursive.endingForPersonNumber(personNumber))
    case .participePassé:
      return .success(stem + model.participeEndingRecursive)
    default:
      return .failure(.tenseNotImplemented(tense)) // TODO: Fix this.
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
