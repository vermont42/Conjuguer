//
//  Conjugator.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

struct Conjugator {
  static func conjugate(infinitif: String, tense: Tense) -> Result<String, ConjugatorError> {
    guard infinitif.count >= Verb.minVerbLength else {
      return .failure(.verbTooShort)
    }

    guard Verb.endingIsValid(infinitif: infinitif) else {
      return .failure(.infinitifEndingInvalid)
    }

    guard let verb = Verb.verbs[infinitif] else {
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
    var isConjugatingSubjonctifImparfait = true
    var isConjugatingImpératif = false
    var isUsingFuturStem = false
    var impératifPersonNumber: PersonNumber = .secondSingular
    var passéSimplePersonNumber: PersonNumber = .secondSingular

    switch tense {
    case .indicatifPrésent(_):
      stem = verb.infinitifStem

    case .participePassé, .passéComposé(_), .plusQueParfait(_), .passéAntérieur(_), .passéSurcomposé(_), .futurAntérieur(_), .conditionnelPassé(_), .subjonctifPassé(_), .subjonctifPlusQueParfait(_), .impératifPassé(_):
      stem = model.participePasséStem(verb: verb)

    case .participePrésent:
      if let participePrésentStem = model.participePrésentStem {
        stem = participePrésentStem
      } else {
        if let nousPrésentConjugation = nousPrésentConjugation(infinitif: infinitif) {
          stem = nousPrésentConjugation
        } else {
          return .failure(.noNousPrésent(infinitif))
        }
      }

    case .imparfait(_):
      if let imparfaitStem = model.imparfaitStem {
        stem = imparfaitStem
      } else {
        if let nousPrésentConjugation = nousPrésentConjugation(infinitif: infinitif) {
          stem = nousPrésentConjugation
        } else {
          return .failure(.noNousPrésent(infinitif))
        }
      }

    case .passéSimple(let personNumber):
      if let passéSimpleStem = model.passéSimpleStem {
        stem = passéSimpleStem
      } else {
        isConjugatingPasséSimple = true
        passéSimplePersonNumber = personNumber
        if model.usesParticipePasséStemForPasséSimple {
          stem = model.participePasséStem(verb: verb)
        } else {
          stem = verb.infinitifStem
        }
      }

    case .subjonctifImparfait(let personNumber):
      if let passéSimpleStem = model.passéSimpleStem {
        stem = passéSimpleStem
      } else {
        isConjugatingSubjonctifImparfait = true
        passéSimplePersonNumber = personNumber
        if model.usesParticipePasséStemForPasséSimple {
          stem = model.participePasséStem(verb: verb)
        } else {
          stem = verb.infinitifStem
        }
      }

    case .subjonctifPrésent(let personNumber):
      if let subjonctifStem = model.subjonctifStem {
        stem = subjonctifStem
      } else {
        stem = verb.infinitifStem
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

    case .futurSimple(_), .conditionnelPrésent(_), .radicalFutur:
      isUsingFuturStem = true
      stem = model.futurStemRecursive(infinitif: infinitif)

    case .impératif(let personNumber):
      if !personNumber.isValidForImperatif {
        return .failure(.defectiveForPersonNumber(personNumber))
      }
      isConjugatingImpératif = true
      impératifPersonNumber = personNumber
      stem = verb.infinitifStem
    }

    let isUsingTenseThatUsesPasséSimpleStem = isConjugatingPasséSimple && isConjugatingSubjonctifImparfait

    if let stemAlterations = model.stemAlterations {
      for alteration in stemAlterations {
        if
          (alteration.appliesTo.contains(tense) || alteration.appliesTo.contains(.passéSimple(passéSimplePersonNumber))) ||
          (isUsingTenseThatUsesPasséSimpleStem &&
          (isUsingTenseThatUsesPasséSimpleStem && alteration.appliesTo.contains(.participePassé) && model.usesParticipePasséStemForPasséSimple) ||
          (isConjugatingImpératif && alteration.appliesTo.contains(.indicatifPrésent(impératifPersonNumber))) ||
          (tense.isCompound && alteration.appliesTo.contains(.participePassé))) && !isUsingFuturStem
        {
          stem.modifyStem(alteration: alteration)
        }
      }
    }

    switch tense {
    case .indicatifPrésent(let personNumber):
      return .success(stem + model.indicatifPrésentGroupRecursive.présentEndingForPersonNumber(personNumber))
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
    case .futurSimple(let personNumber):
      return .success(stem + FuturSimple.endingForPersonNumber(personNumber))
    case .conditionnelPrésent(let personNumber):
      return .success(stem + ConditionnelPrésent.endingForPersonNumber(personNumber))
    case .participePassé:
      return .success(stem + model.participeEndingRecursive)
    case .participePrésent:
      return .success(stem + Tense.participePrésentEnding)
    case .radicalFutur:
      return .success(stem)
    case .impératif(let personNumber):
      return .success(stem + model.indicatifPrésentGroupRecursive.impératifEndingForPersonNumber(personNumber))
    case .passéComposé(let personNumber), .plusQueParfait(let personNumber), .passéAntérieur(let personNumber), .passéSurcomposé(let personNumber), .futurAntérieur(let personNumber), .conditionnelPassé(let personNumber), .subjonctifPassé(let personNumber), .subjonctifPlusQueParfait(let personNumber), .impératifPassé(let personNumber):
      return .success(tense.conjugatedAuxilliary(personNumber: personNumber, auxiliary: verb.auxiliary) + " " + stem + model.participeEndingRecursive)
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

  static func nousPrésentConjugation(infinitif: String) -> String? {
    let nousPrésentConjugationResult = Conjugator.conjugate(infinitif: infinitif, tense: .indicatifPrésent(.firstPlural))
    switch nousPrésentConjugationResult {
    case .success(let value):
      let index = value.index(value.endIndex, offsetBy: -1 * Tense.onsLength)
      return String(value[..<index])
    default:
      return nil
    }
  }
}

extension String {
  mutating func modifyStem(alteration: StemAlteration) {
    if alteration.startIndexFromLast == 0 {
      self = self + alteration.charsToUse.uppercased()
    } else {
      let start = index(startIndex, offsetBy: count - alteration.startIndexFromLast)
      let end = index(startIndex, offsetBy: (count - alteration.startIndexFromLast) + alteration.charsToReplaceCount)
      replaceSubrange(start ..< end, with: alteration.charsToUse)
    }
  }
}

//let startIndexFromLast: Int
//let charsToReplaceCount: Int
//let charsToUse: String


//let start = value.index(value.startIndex, offsetBy: 6);
//let end = value.index(value.startIndex, offsetBy: 6 + 3);
//value.replaceSubrange(start..<end, with: "yellow")
//print(value)
//green red blue
//green yellow blue
