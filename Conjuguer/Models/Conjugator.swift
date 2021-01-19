//
//  Conjugator.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/2/21.
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
      for alteration in completeAlterations where alteration.appliesTo == tense {
        return .success(alteration.conjugation)
      }
    }

    var stems: [String] = [] // Payer has an alternate stem, so this needs to be an array.
    var isConjugatingPasséSimple = false
    var isConjugatingSubjonctifImparfait = false
    var isConjugatingImpératif = false
    var impératifPersonNumber: PersonNumber = .secondSingular
    var passéSimplePersonNumber: PersonNumber = .secondSingular

    switch tense {
    case .indicatifPrésent:
      stems.append(verb.infinitifStem)

    case .participePassé,
         .passéComposé, .plusQueParfait, .passéAntérieur, .passéSurcomposé, .futurAntérieur, .conditionnelPassé, .subjonctifPassé, .subjonctifPlusQueParfait:
      stems.append(model.participePasséStem(verb: verb))

    case .participePrésent:
      if let participePrésentStem = model.participePrésentStem {
        stems.append(participePrésentStem)
      } else {
        if let nousPrésentConjugation = nousPrésentConjugation(infinitif: infinitif) {
          stems.append(nousPrésentConjugation)
        } else {
          return .failure(.noNousPrésent(infinitif))
        }
      }

    case .imparfait:
      if let imparfaitStem = model.imparfaitStem {
        stems.append(imparfaitStem)
      } else {
        if let nousPrésentConjugation = nousPrésentConjugation(infinitif: infinitif) {
          stems.append(nousPrésentConjugation)
        } else {
          return .failure(.noNousPrésent(infinitif))
        }
      }

    case .passéSimple(let personNumber):
      if let passéSimpleStem = model.passéSimpleStem {
        stems.append(passéSimpleStem)
      } else {
        isConjugatingPasséSimple = true
        passéSimplePersonNumber = personNumber
        if model.usesParticipePasséStemForPasséSimple {
          stems.append(model.participePasséStem(verb: verb))
        } else {
          stems.append(verb.infinitifStem)
        }
      }

    case .subjonctifImparfait(let personNumber):
      if let passéSimpleStem = model.passéSimpleStem {
        stems.append(passéSimpleStem)
      } else {
        isConjugatingSubjonctifImparfait = true
        passéSimplePersonNumber = personNumber
        if model.usesParticipePasséStemForPasséSimple {
          stems.append(model.participePasséStem(verb: verb))
        } else {
          stems.append(verb.infinitifStem)
        }
      }

    case .subjonctifPrésent(let personNumber):
      if let subjonctifStem = model.subjonctifStem {
        stems.append(subjonctifStem)
      } else {
        stems.append(verb.infinitifStem)
        if let stemAlterations = model.stemAlterationsRecursive {
          let subjonctifPersonNumber: PersonNumber
          switch personNumber {
          case .firstSingular, .secondSingular, .thirdSingular, .thirdPlural:
            subjonctifPersonNumber = .thirdPlural
          case .firstPlural, .secondPlural:
            subjonctifPersonNumber = .firstPlural
          }
          for alteration in stemAlterations {
            if alteration.appliesTo.contains(.indicatifPrésent(subjonctifPersonNumber)) {
              if alteration.isAdditive {
                stems.append(stems[0])
              }
              stems[0].modifyStem(alteration: alteration)
              break
            }
          }
        }
      }

    case .futurSimple, .conditionnelPrésent, .radicalFutur:
      stems = model.futurStemsRecursive(infinitif: infinitif)

    case .impératif(let personNumber):
      if !personNumber.isValidForImperatif {
        return .failure(.defectiveForPersonNumber(personNumber))
      }
      isConjugatingImpératif = true
      impératifPersonNumber = personNumber
      stems.append(verb.infinitifStem)

    case .impératifPassé(let personNumber):
      if !personNumber.isValidForImperatif {
        return .failure(.defectiveForPersonNumber(personNumber))
      }
      stems.append(model.participePasséStem(verb: verb))
    }

    let isUsingTenseThatUsesPasséSimpleStem = isConjugatingPasséSimple || isConjugatingSubjonctifImparfait

    if let stemAlterations = model.stemAlterationsRecursive {
      for alteration in stemAlterations {
        if
          (alteration.appliesTo.contains(tense) ||
          (isUsingTenseThatUsesPasséSimpleStem && alteration.appliesTo.contains(.passéSimple(passéSimplePersonNumber)) && model.usesParticipePasséStemForPasséSimple) ||
          (isConjugatingImpératif && alteration.appliesTo.contains(.indicatifPrésent(impératifPersonNumber))) ||
          (tense.isCompound && alteration.appliesTo.contains(.participePassé))) && tense != .radicalFutur
        {
          stems[0].modifyStem(alteration: alteration)
        }
      }
    }

    switch tense {
    case .indicatifPrésent(let personNumber):
      return .success(composedConjugation(stems: stems, ending: model.indicatifPrésentGroupRecursive.présentEndingForPersonNumber(personNumber)))
    case .passéSimple(let personNumber):
      var ending = model.passéSimpleGroupRecursive.passéSimpleEndingForPersonNumber(personNumber)
      for i in 0 ..< stems.count {
        moveCircumflexIfNeeded(stem: &stems[i], ending: &ending)
      }
      return .success(composedConjugation(stems: stems, ending: ending))
    case .subjonctifImparfait(let personNumber):
      var ending = model.passéSimpleGroupRecursive.subjonctifImparfaitEndingForPersonNumber(personNumber)
      for i in 0 ..< stems.count {
        moveCircumflexIfNeeded(stem: &stems[i], ending: &ending)
      }
      return .success(composedConjugation(stems: stems, ending: ending))
    case .imparfait(let personNumber):
      return .success(composedConjugation(stems: stems, ending: Imparfait.endingForPersonNumber(personNumber)))
    case .subjonctifPrésent(let personNumber):
      return .success(composedConjugation(stems: stems, ending: model.subjonctifPrésentGroupRecursive.endingForPersonNumber(personNumber)))
    case .futurSimple(let personNumber):
      return .success(composedConjugation(stems: stems, ending: FuturSimple.endingForPersonNumber(personNumber)))
    case .conditionnelPrésent(let personNumber):
      return .success(composedConjugation(stems: stems, ending: ConditionnelPrésent.endingForPersonNumber(personNumber)))
    case .participePassé:
      return .success(stems[0] + model.participeEndingRecursive)
    case .participePrésent:
      return .success(stems[0] + Tense.participePrésentEnding)
    case .radicalFutur:
      return .success(composedConjugation(stems: stems, ending: ""))
    case .impératif(let personNumber):
      return .success(composedConjugation(stems: stems, ending: model.indicatifPrésentGroupRecursive.impératifEndingForPersonNumber(personNumber)))
    case .passéComposé(let personNumber), .plusQueParfait(let personNumber), .passéAntérieur(let personNumber), .passéSurcomposé(let personNumber), .futurAntérieur(let personNumber), .conditionnelPassé(let personNumber), .subjonctifPassé(let personNumber), .subjonctifPlusQueParfait(let personNumber), .impératifPassé(let personNumber):
      return .success(tense.conjugatedAuxilliary(personNumber: personNumber, auxiliary: verb.auxiliary) + " " + stems[0] + model.participeEndingRecursive)
    }
  }

  static func composedConjugation(stems: [String], ending: String) -> String {
    var output = ""
    var hasAppendedAtLeastOneConjugation = false
    stems.forEach {
      if hasAppendedAtLeastOneConjugation {
        output += "/"
      }
      output += $0 + ending
      hasAppendedAtLeastOneConjugation = true
    }
    return output
  }

  static func moveCircumflexIfNeeded(stem: inout String, ending: inout String) {
    guard ending.first == "^" else {
      return
    }

    guard let stemLast = stem.last else {
      fatalError("Attempted to add a circumflex to an empty String.")
    }

    ending = String(ending.dropFirst())
    for tuple in [("a", "â"), ("e", "ê"), ("i", "î"), ("o", "ô"), ("u", "û"), ("A", "Â"), ("E", "Ê"), ("I", "Î"), ("O", "Ô"), ("U", "Û")] {
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
      self += alteration.charsToUse
    } else {
      let start = index(startIndex, offsetBy: count - alteration.startIndexFromLast)
      let end = index(startIndex, offsetBy: (count - alteration.startIndexFromLast) + alteration.charsToReplaceCount)
      replaceSubrange(start ..< end, with: alteration.charsToUse)
    }
  }
}
