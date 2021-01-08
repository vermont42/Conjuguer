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
          return .success(alteration.conjugation)
        }
      }
    }

    var stem: String
    var isConjugatingPasséSimple = false
    switch tense {
    case .indicatifPrésent(_):
      stem = verb.infinitiveStem
    case .participePassé:
      stem = model.participeStem(verb: verb)
    case .participePrésent:
      let nousPrésentConjugationResult = Conjugator.conjugate(infinitive: infinitive, tense: .indicatifPrésent(.firstPlural))
      switch nousPrésentConjugationResult {
      case .success(let value):
        let index = value.index(value.endIndex, offsetBy: -1 * Tense.onsLength)
        stem = String(value[..<index])
      default:
        // TODO: This doesn't work for verbs that have participePrésents but not nous présent conjugations.
        // Example: pleuvoir. The stem is pleuv, not pleuvo. One solution might be to chop off, for
        // infinitive stem, the last 3, rather than 2, letters for -oir verbs. Another solution would
        // be to do a complete replacement of pleuvoir's participe présent with pleuvant, as with savoir.
        stem = verb.infinitiveStem
      }


    case .passéSimple(_):
      isConjugatingPasséSimple = true
      if model.usesParticipeStemForPasséSimple {
        stem = model.participeStem(verb: verb)
      } else {
        stem = verb.infinitiveStem
      }
    default:
      return .failure(.tenseNotImplemented(tense)) // TODO: Fix this.
    }

    if let partialAlterations = model.partialAlterations {
      for alteration in partialAlterations {
        if
          alteration.appliesTo.contains(tense) ||
          (isConjugatingPasséSimple && alteration.appliesTo.contains(.participePassé) && model.usesParticipeStemForPasséSimple)
        {
          stem.modifyStem(alteration: alteration)
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
    case .participePrésent:
      return .success(stem + Tense.participePrésentEnding)
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
