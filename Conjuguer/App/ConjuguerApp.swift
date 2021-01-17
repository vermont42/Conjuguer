//
//  ConjuguerApp.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/1/21.
//

import SwiftUI

@main
struct ConjuguerApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }

  static let compoundPersonNumbers: [PersonNumber] = [.firstSingular, .secondSingular, .thirdSingular, .firstPlural, .secondPlural, .thirdPlural]
  static var compoundPersonNumbersIndex = 0
  static let compoundImpératifPersonNumbers: [PersonNumber] = [.secondSingular, .firstPlural, .secondPlural]
  static var compoundImpératifPersonNumbersIndex = 0

  init() {
    Verb.verbs = VerbParser().parse()
    VerbModel.models = VerbModelParser().parse()

    print("verb count: \(Verb.verbs.count)  model count: \(VerbModel.models.count)\n")

    for verb in [
      "accueillir",
      "aller",
      "amorcer",
      "appeler",
      "arriver",
      "assaillir",
      "avoir",
      "bouillir",
      "colorer",
      "couvrir",
      "cueillir",
      "défaillir",
      "être",
      "fabriquer",
      "fatiguer",
      "finir",
      "jeter",
      "lancer",
      "manger",
      "offrir",
      "ouvrir",
      "parler",
      "prier",
      "recueillir",
      "souffrir",
      "submerger",
      "tressaillir",
      "voleter"
    ] {
      var output = "\(verb) • "
      let participePassé: String
      let participePasséResult = Conjugator.conjugate(infinitif: verb, tense: .participePassé)
      switch participePasséResult {
      case .success(let value):
        participePassé = value
      default:
        fatalError()
      }
      output += "participe passé: \(participePassé)"

      let participePrésent: String
      let participePrésentResult = Conjugator.conjugate(infinitif: verb, tense: .participePrésent)
      switch participePrésentResult {
      case .success(let value):
        participePrésent = value
      default:
        fatalError()
      }
      output += " • participe présent: \(participePrésent) • indicatif présent: "

      let personNumbers: [PersonNumber] = [.firstSingular, .secondSingular, .thirdSingular, .firstPlural, .secondPlural, .thirdPlural]

      for personNumber in personNumbers {
        let présentResult = Conjugator.conjugate(infinitif: verb, tense: .indicatifPrésent(personNumber))
        switch présentResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }

      output += "• passé simple: "

      for personNumber in personNumbers {
        let passéSimpleResult = Conjugator.conjugate(infinitif: verb, tense: .passéSimple(personNumber))
        switch passéSimpleResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }

      output += "• imparfait: "

      for personNumber in personNumbers {
        let imparfaitResult = Conjugator.conjugate(infinitif: verb, tense: .imparfait(personNumber))
        switch imparfaitResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }

      output += "• subjonctif présent: "

      for personNumber in personNumbers {
        let subjonctifPrésentResult = Conjugator.conjugate(infinitif: verb, tense: .subjonctifPrésent(personNumber))
        switch subjonctifPrésentResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }

      output += "• subjonctif imparfait: "

      for personNumber in personNumbers {
        let subjonctifImparfaitResult = Conjugator.conjugate(infinitif: verb, tense: .subjonctifImparfait(personNumber))
        switch subjonctifImparfaitResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }

      output += "• futur simple: "

      for personNumber in personNumbers {
        let futurResult = Conjugator.conjugate(infinitif: verb, tense: .futurSimple(personNumber))
        switch futurResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }

      output += "• conditionnel présent: "

      for personNumber in personNumbers {
        let conditionnelResult = Conjugator.conjugate(infinitif: verb, tense: .conditionnelPrésent(personNumber))
        switch conditionnelResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }

      output += "• imperatif: "

      for personNumber in personNumbers {
        if personNumber.isValidForImperatif {
          let impératifResult = Conjugator.conjugate(infinitif: verb, tense: .impératif(personNumber))
          switch impératifResult {
          case .success(let value):
            output += "\(value) "
          default:
            fatalError()
          }
        }
      }

      let personNumber = ConjuguerApp.compoundPersonNumbers[ConjuguerApp.compoundPersonNumbersIndex]
      [
        Tense.passéComposé(personNumber),
        Tense.plusQueParfait(personNumber),
        Tense.passéAntérieur(personNumber),
        Tense.passéSurcomposé(personNumber),
        Tense.futurAntérieur(personNumber),
        Tense.conditionnelPassé(personNumber),
        Tense.subjonctifPassé(personNumber),
        Tense.subjonctifPlusQueParfait(personNumber),
      ].forEach {
        let compoundResult = Conjugator.conjugate(infinitif: verb, tense: $0)
        switch compoundResult {
        case .success(let value):
          let pronoun: String
          switch $0 {
          case .passéComposé(let personNumber), .plusQueParfait(let personNumber), .passéAntérieur(let personNumber), .passéSurcomposé(let personNumber), .futurAntérieur(let personNumber), .conditionnelPassé(let personNumber), .subjonctifPassé(let personNumber), .subjonctifPlusQueParfait(let personNumber):
            pronoun = personNumber.pronoun
          default:
            fatalError()
          }
          output += "• \($0.displayName): \(pronoun) \(value) "
        default:
          fatalError()
        }
      }
      ConjuguerApp.compoundPersonNumbersIndex += 1
      ConjuguerApp.compoundPersonNumbersIndex %= ConjuguerApp.compoundPersonNumbers.count

      output += " • impératif passé: "

      let personNumberImpératif = ConjuguerApp.compoundImpératifPersonNumbers[ConjuguerApp.compoundImpératifPersonNumbersIndex]
      let compoundResult = Conjugator.conjugate(infinitif: verb, tense: .impératifPassé(personNumberImpératif))
      switch compoundResult {
      case .success(let value):
        output += "\(personNumberImpératif.pronoun) \(value) "
      default:
        fatalError()
      }
      ConjuguerApp.compoundImpératifPersonNumbersIndex += 1
      ConjuguerApp.compoundImpératifPersonNumbersIndex %= ConjuguerApp.compoundImpératifPersonNumbers.count

      if
        let actualVerb = Verb.verbs[verb],
        actualVerb.auxiliary == .être
      {
        output += "• auxiliary: être "
      }

      if
        let actualVerb = Verb.verbs[verb],
        let verbModel = VerbModel.models[actualVerb.model],
        !verbModel.usesParticipePasséStemForPasséSimple
      {
        output += "• passé simple does not use participe stem"
      }

      let radicalFuturResult = Conjugator.conjugate(infinitif: verb, tense: .radicalFutur)
      switch radicalFuturResult {
      case .success(let value):
        output += " • radical futur: \(value) "
      default:
        fatalError()
      }

      print("\(output)\n\n")
    }
  }
}
