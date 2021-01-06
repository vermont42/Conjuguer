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

    for verb in ["aller", "apeler", "arriver", "colorer", "finir", "lancer", "parler"] {
      var output = "\(verb)   "

      let participe: String
      let participeResult = Conjugator.conjugate(infinitive: verb, tense: .participePassé)
      switch participeResult {
      case .success(let value):
        participe = value
      default:
        fatalError()
      }
      output += "participe: \(participe)   présent: "

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

      if
        let actualVerb = Verb.verbs[verb],
        actualVerb.auxiliary == .être
      {
        output += "  auxiliary: être"
      }

      print("\(output)\n")
    }
  }
}
