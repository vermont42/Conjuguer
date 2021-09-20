//
//  ConjuguerApp.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/1/21.
//

import SwiftUI

@main
struct ConjuguerApp: App {
  var body: some Scene {
    WindowGroup {
      MainTabView()
        .environmentObject(Current)
        .onOpenURL(perform: Current.handleURL(_:))
    }
  }

  static var compoundPersonNumbersIndex = 0
  static var compoundImpératifPersonNumbersIndex = 0

  init() {
    Modifiers.setTitleAttributes()

    VerbModel.models = VerbModelParser().parse()
    Verb.verbs = VerbParser().parse()
    VerbModel.computeIrregularities()
    VerbModel.sortVerbs()
    DefectGroup.defectGroups = DefectGroupParser().parse()

//    let verbArray = Verb.verbs.values.sorted { lhs, rhs in
//      lhs.infinitif.compare(rhs.infinitif, locale: Util.french) == .orderedAscending
//    }
//
//    let verbArray = [Verb.verbs["parler"]!]
//
//    for verb in verbArray {
//      let infinitif = verb.infinitif
//      var output = "\(infinitif)"
//
//      output += "  •  \(verb.translation)  •  PRESENT: "
//
//      let personNumbers: [PersonNumber] = PersonNumber.allCases
//
//      let extraLetters = verb.extraLetters
//
//      for personNumber in personNumbers {
//        let présentResult = Conjugator.conjugate(infinitif: infinitif, tense: .indicatifPrésent(personNumber), extraLetters: extraLetters)
//        switch présentResult {
//        case .success(let value):
//          output += "\(value) "
//        default:
//          fatalError()
//        }
//      }
//
//      output += " •  IMPERFECT: "
//
//      for personNumber in personNumbers {
//        let imparfaitResult = Conjugator.conjugate(infinitif: infinitif, tense: .imparfait(personNumber), extraLetters: extraLetters)
//        switch imparfaitResult {
//        case .success(let value):
//          output += "\(value) "
//        default:
//          fatalError()
//        }
//      }
//
//      output += " •  FUTURE: "
//
//      for personNumber in personNumbers {
//        let futurResult = Conjugator.conjugate(infinitif: infinitif, tense: .futurSimple(personNumber), extraLetters: extraLetters)
//        switch futurResult {
//        case .success(let value):
//          output += "\(value) "
//        default:
//          fatalError()
//        }
//      }
//
//      output += " •  CONDITIONAL: "
//
//      for personNumber in personNumbers {
//        let conditionnelResult = Conjugator.conjugate(infinitif: infinitif, tense: .conditionnelPrésent(personNumber), extraLetters: extraLetters)
//        switch conditionnelResult {
//        case .success(let value):
//          output += "\(value) "
//        default:
//          fatalError()
//        }
//      }
//
//      output += " •  SIMPLE PAST: "
//
//      for personNumber in personNumbers {
//        let passéSimpleResult = Conjugator.conjugate(infinitif: infinitif, tense: .passéSimple(personNumber), extraLetters: extraLetters)
//        switch passéSimpleResult {
//        case .success(let value):
//          output += "\(value) "
//        default:
//          fatalError()
//        }
//      }
//
//      output += " •  SUBJ. PRESENT: "
//
//      for personNumber in personNumbers {
//        let subjonctifPrésentResult = Conjugator.conjugate(infinitif: infinitif, tense: .subjonctifPrésent(personNumber), extraLetters: extraLetters)
//        switch subjonctifPrésentResult {
//        case .success(let value):
//          output += "\(value) "
//        default:
//          fatalError()
//        }
//      }
//
//      output += " •  SUBJ. IMPERFECT: "
//
//      for personNumber in personNumbers {
//        let subjonctifImparfaitResult = Conjugator.conjugate(infinitif: infinitif, tense: .subjonctifImparfait(personNumber), extraLetters: extraLetters)
//        switch subjonctifImparfaitResult {
//        case .success(let value):
//          output += "\(value) "
//        default:
//          fatalError()
//        }
//      }
//
//      let participePassé: String
//      let participePasséResult = Conjugator.conjugate(infinitif: infinitif, tense: .participePassé, extraLetters: extraLetters)
//      switch participePasséResult {
//      case .success(let value):
//        participePassé = value
//      default:
//        fatalError()
//      }
//      output += "  •  PAST PARTICIPLE: \(participePassé) "
//
//      let participePrésent: String
//      let participePrésentResult = Conjugator.conjugate(infinitif: infinitif, tense: .participePrésent, extraLetters: extraLetters)
//      switch participePrésentResult {
//      case .success(let value):
//        participePrésent = value
//      default:
//        fatalError()
//      }
//      output += " •  PRESENT PARTICIPLE: \(participePrésent) "
//
//      output += " •  IMPERATIVE: "
//
//      for personNumber in PersonNumber.impératifPersonNumbers {
//        let impératifResult = Conjugator.conjugate(infinitif: infinitif, tense: .impératif(personNumber), extraLetters: extraLetters)
//        switch impératifResult {
//        case .success(let value):
//          output += "\(value) "
//        default:
//          fatalError()
//        }
//      }
//
//      let radicalFuturResult = Conjugator.conjugate(infinitif: infinitif, tense: .radicalFutur, extraLetters: extraLetters)
//      switch radicalFuturResult {
//      case .success(let value):
//        output += " •  FUTURE STEM: \(value) "
//      default:
//        fatalError()
//      }
//
//      if
//        let actualVerb = Verb.verbs[infinitif],
//        actualVerb.auxiliary == .être
//      {
//        output += " •  AUXILIARY: ÊTRE "
//      }
//
//      if
//        let actualVerb = Verb.verbs[infinitif],
//        let frequency = actualVerb.frequency
//      {
//        output += " •  FREQUENCY: \(frequency) "
//      }
//
//      print("\(output)\n\n")
//    }
  }
}
