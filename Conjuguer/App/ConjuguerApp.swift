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

  init() {
    Verb.verbs = VerbParser().parse()
    VerbModel.models = VerbModelParser().parse()

    print("verb count: \(Verb.verbs.count)  model count: \(VerbModel.models.count)\n")

    for verb in [
      "aller",
      "apeler",
      "arriver",
      "avoir",
      "colorer",
      "couvrir",
      "être",
      "finir",
      "lancer",
      "offrir",
      "parler",
      "souffrir",
    ] {
      var output = "\(verb)   "

      let participePassé: String
      let participePasséResult = Conjugator.conjugate(infinitive: verb, tense: .participePassé)
      switch participePasséResult {
      case .success(let value):
        participePassé = value
      default:
        fatalError()
      }
      output += "participe passé: \(participePassé)"

      let participePrésent: String
      let participePrésentResult = Conjugator.conjugate(infinitive: verb, tense: .participePrésent)
      switch participePrésentResult {
      case .success(let value):
        participePrésent = value
      default:
        fatalError()
      }
      output += "   participe présent: \(participePrésent)   indicatif présent: "

      let personNumbers: [PersonNumber] = [.firstSingular, .secondSingular, .thirdSingular, .firstPlural, .secondPlural, .thirdPlural]

      for personNumber in personNumbers {
        let présentResult = Conjugator.conjugate(infinitive: verb, tense: .indicatifPrésent(personNumber))
        switch présentResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }

      output += "  passé simple: "

      for personNumber in personNumbers {
        let passéSimpleResult = Conjugator.conjugate(infinitive: verb, tense: .passéSimple(personNumber))
        switch passéSimpleResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }

      output += "  imparfait: "

      for personNumber in personNumbers {
        let imparfaitResult = Conjugator.conjugate(infinitive: verb, tense: .imparfait(personNumber))
        switch imparfaitResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }

      if
        let actualVerb = Verb.verbs[verb],
        actualVerb.auxiliary == .être
      {
        output += "  auxiliary: être"
      }

      if
        let actualVerb = Verb.verbs[verb],
        let verbModel = VerbModel.models[actualVerb.model],
        !verbModel.usesParticipeStemForPasséSimple
      {
        output += "  passé simple does not use participe stem"
      }

      print("\(output)\n")
    }
  }
}
