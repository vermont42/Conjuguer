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
    case .participePrésent, .imparfait(_):
      if let imparfaitStem = model.imparfaitStem {
        stem = imparfaitStem
      } else {
        let nousPrésentConjugationResult = Conjugator.conjugate(infinitive: infinitive, tense: .indicatifPrésent(.firstPlural))
        switch nousPrésentConjugationResult {
        case .success(let value):
          let index = value.index(value.endIndex, offsetBy: -1 * Tense.onsLength)
          stem = String(value[..<index])
        default:
          return .failure(.noNousPrésent(infinitive))
        }
      }
    case .passéSimple(_), .subjonctifImparfait(_):
      if let passéSimpleStem = model.passéSimpleStem {
        stem = passéSimpleStem
      } else {
        isConjugatingPasséSimple = true
        if model.usesParticipeStemForPasséSimple {
          stem = model.participeStem(verb: verb)
        } else {
          stem = verb.infinitiveStem
        }
      }
    case .subjonctifPrésent(let personNumber):
      if let subjonctifStem = model.subjonctifStem {
        stem = subjonctifStem
      } else {
        stem = verb.infinitiveStem
        if let stemAlterations = model.stemAlterations {
          let subjonctifPersonNumber: PersonNumber
          switch personNumber {
          case .firstSingular, .secondSingular, .thirdSingular, .thirdPlural:
            subjonctifPersonNumber = .thirdPlural
          case .firstPlural, .secondPlural:
            subjonctifPersonNumber = .firstPlural
          }
          for alteration in stemAlterations {
            if alteration.appliesTo.contains(.indicatifPrésent(subjonctifPersonNumber)) {
              stem.modifyStem(alteration: alteration)
              break
            }
          }
        }
      }
    default:
      return .failure(.tenseNotImplemented(tense)) // TODO: Fix this.
    }

    if let stemAlterations = model.stemAlterations {
      for alteration in stemAlterations {
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
      var ending = model.passéSimpleGroupRecursive.passéSimpleEndingForPersonNumber(personNumber)
      moveCircumflexIfNeeded(stem: &stem, ending: &ending)
      return .success(stem + ending)
    case .subjonctifImparfait(let personNumber):
      var ending = model.passéSimpleGroupRecursive.subjonctifImparfaitEndingForPersonNumber(personNumber)
      moveCircumflexIfNeeded(stem: &stem, ending: &ending)
      return .success(stem + ending)
    case .imparfait(let personNumber):
      return .success(stem + Imparfait.endingForPersonNumber(personNumber))
    case .subjonctifPrésent(let personNumber):
      return .success(stem + model.subjonctifPrésentGroupRecursive.endingForPersonNumber(personNumber))
    case .participePassé:
      return .success(stem + model.participeEndingRecursive)
    case .participePrésent:
      return .success(stem + Tense.participePrésentEnding)
    default:
      return .failure(.tenseNotImplemented(tense)) // TODO: Fix this.
    }
  }

  static func moveCircumflexIfNeeded(stem: inout String, ending: inout String) {
    guard ending.first == "^" else {
      return
    }

    guard let stemLast = stem.last else {
      fatalError("Attempted to add a circumflex to an empty String.")
    }

    ending = String(ending.dropFirst())
    for tuple in [("a","â"), ("e","ê"), ("i","î"), ("o","ô"), ("u","û"), ("A","Â"), ("E","Ê"), ("I","Î"), ("O","Ô"), ("U","Û")] {
      if String(stemLast) == tuple.0 {
        stem = String(stem.dropLast()) + tuple.1
      }
    }
  }
}

extension String {
  mutating func modifyStem(alteration: StemAlteration) {
    if alteration.startIndexFromLast == 0 {
      self = self + alteration.charsToUse.uppercased()
    } else {
      let repStartIndex = index(startIndex, offsetBy: count - 1)
      let repEndIndex = index(startIndex, offsetBy: (count - 1) + alteration.charsToReplaceCount - 1)
      replaceSubrange(repStartIndex ... repEndIndex, with: alteration.charsToUse.uppercased())
    }
  }
}
