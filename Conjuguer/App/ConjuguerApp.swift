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

    for verb in ["arriver", "colorer", "finir", "lancer", "parler"] {
      var output = "\(verb) "

      let participe: String
      let participeResult = Conjugator.conjugate(infinitive: verb, tense: .participePassé, personNumber: nil)
      switch participeResult {
      case .success(let value):
        participe = value
      default:
        fatalError()
      }
      output += "\(participe) "

      for personNumber in [PersonNumber.firstSingular, .secondSingular, .thirdSingular, .firstPlural, .secondPlural, .thirdPlural] {
        let présentResult = Conjugator.conjugate(infinitive: verb, tense: .indicatifPrésent, personNumber: personNumber)
        switch présentResult {
        case .success(let value):
          output += "\(value) "
        default:
          fatalError()
        }
      }
      print("\(output)\n")
    }
  }
}
