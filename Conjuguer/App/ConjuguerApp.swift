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
      let participe: String
      let participeResult = Conjugator.conjugate(infinitive: verb, tense: .participePassé, personNumber: nil)
      switch participeResult {
      case .success(let value):
        participe = value
      default:
        fatalError()
      }

      let je: String
      let jeResult = Conjugator.conjugate(infinitive: verb, tense: .indicatifPrésent, personNumber: .firstSingular)
      switch jeResult {
      case .success(let value):
        je = value
      default:
        fatalError()
      }

      let tu: String
      let tuResult = Conjugator.conjugate(infinitive: verb, tense: .indicatifPrésent, personNumber: .secondSingular)
      switch tuResult {
      case .success(let value):
        tu = value
      default:
        fatalError()
      }

      let il: String
      let ilResult = Conjugator.conjugate(infinitive: verb, tense: .indicatifPrésent, personNumber: .thirdSingular)
      switch ilResult {
      case .success(let value):
        il = value
      default:
        fatalError()
      }

      let nous: String
      let nousResult = Conjugator.conjugate(infinitive: verb, tense: .indicatifPrésent, personNumber: .firstPlural)
      switch nousResult {
      case .success(let value):
        nous = value
      default:
        fatalError()
      }

      let vous: String
      let vousResult = Conjugator.conjugate(infinitive: verb, tense: .indicatifPrésent, personNumber: .secondPlural)
      switch vousResult {
      case .success(let value):
        vous = value
      default:
        fatalError()
      }

      let ils: String
      let ilsResult = Conjugator.conjugate(infinitive: verb, tense: .indicatifPrésent, personNumber: .thirdPlural)
      switch ilsResult {
      case .success(let value):
        ils = value
      default:
        fatalError()
      }

      print("\(verb) \(participe) \(je) \(tu) \(il) \(nous) \(vous) \(ils)\n")
    }
  }
}
