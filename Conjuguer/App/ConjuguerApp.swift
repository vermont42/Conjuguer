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
    }
  }

  static var compoundPersonNumbersIndex = 0
  static var compoundImpératifPersonNumbersIndex = 0

  init() {
    Modifiers.setTitleAttributes()

    Verb.verbs = VerbParser().parse()
    VerbModel.models = VerbModelParser().parse()
    VerbModel.computeIrregularities()

    let totalVerbs = 6444
    let fraction = Double(Verb.verbs.count) / Double(totalVerbs)
    let percent = Int(fraction * 100)
    print("verb count: \(Verb.verbs.count)   verbs left: \(totalVerbs - Verb.verbs.count)   percent done: \(percent)%   model count: \(VerbModel.models.count)\n")

//    let verbArray = Verb.verbs.values.sorted { lhs, rhs in
//      lhs.infinitif.compare(rhs.infinitif, locale: Util.french) == .orderedAscending
//    }
//
//    for verb in verbArray {
//      let infinitif = verb.infinitif
//      var output = "\(infinitif)"
//
//      output += "  •  \(verb.translation)  •  PRESENT: "
//
//      let personNumbers: [PersonNumber] = PersonNumber.allCases
//
//      for personNumber in personNumbers {
//        let présentResult = Conjugator.conjugate(infinitif: infinitif, tense: .indicatifPrésent(personNumber))
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
//        let imparfaitResult = Conjugator.conjugate(infinitif: infinitif, tense: .imparfait(personNumber))
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
//        let futurResult = Conjugator.conjugate(infinitif: infinitif, tense: .futurSimple(personNumber))
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
//        let conditionnelResult = Conjugator.conjugate(infinitif: infinitif, tense: .conditionnelPrésent(personNumber))
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
//        let passéSimpleResult = Conjugator.conjugate(infinitif: infinitif, tense: .passéSimple(personNumber))
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
//        let subjonctifPrésentResult = Conjugator.conjugate(infinitif: infinitif, tense: .subjonctifPrésent(personNumber))
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
//        let subjonctifImparfaitResult = Conjugator.conjugate(infinitif: infinitif, tense: .subjonctifImparfait(personNumber))
//        switch subjonctifImparfaitResult {
//        case .success(let value):
//          output += "\(value) "
//        default:
//          fatalError()
//        }
//      }
//
//      let participePassé: String
//      let participePasséResult = Conjugator.conjugate(infinitif: infinitif, tense: .participePassé)
//      switch participePasséResult {
//      case .success(let value):
//        participePassé = value
//      default:
//        fatalError()
//      }
//      output += "  •  PAST PARTICIPLE: \(participePassé) "
//
//      let participePrésent: String
//      let participePrésentResult = Conjugator.conjugate(infinitif: infinitif, tense: .participePrésent)
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
//        let impératifResult = Conjugator.conjugate(infinitif: infinitif, tense: .impératif(personNumber))
//        switch impératifResult {
//        case .success(let value):
//          output += "\(value) "
//        default:
//          fatalError()
//        }
//      }
//
//      let radicalFuturResult = Conjugator.conjugate(infinitif: infinitif, tense: .radicalFutur)
//      switch radicalFuturResult {
//      case .success(let value):
//        output += " •  FUTURE STEM: \(value) "
//      default:
//        fatalError()
//      }

//      let personNumber = PersonNumber.allCases[ConjuguerApp.compoundPersonNumbersIndex]
//      [
//        Tense.passéComposé(personNumber),
//        Tense.plusQueParfait(personNumber),
//        Tense.passéAntérieur(personNumber),
//        Tense.passéSurcomposé(personNumber),
//        Tense.futurAntérieur(personNumber),
//        Tense.conditionnelPassé(personNumber),
//        Tense.subjonctifPassé(personNumber),
//        Tense.subjonctifPlusQueParfait(personNumber)
//      ].forEach {
//        let compoundResult = Conjugator.conjugate(infinitif: verb, tense: $0)
//        switch compoundResult {
//        case .success(let value):
//          let pronoun: String
//          switch $0 {
//          case .passéComposé(let personNumber), .plusQueParfait(let personNumber), .passéAntérieur(let personNumber), .passéSurcomposé(let personNumber), .futurAntérieur(let personNumber), .conditionnelPassé(let personNumber), .subjonctifPassé(let personNumber), .subjonctifPlusQueParfait(let personNumber):
//            pronoun = personNumber.pronoun
//          default:
//            fatalError()
//          }
//          output += " •  \($0.displayName): \(pronoun) \(value) "
//        default:
//          fatalError()
//        }
//      }
//      ConjuguerApp.compoundPersonNumbersIndex += 1
//      ConjuguerApp.compoundPersonNumbersIndex %= PersonNumber.allCases.count
//
//      output += "  •  impératif passé: "
//
//      let personNumberImpératif = PersonNumber.impératifPersonNumbers[ConjuguerApp.compoundImpératifPersonNumbersIndex]
//      let compoundResult = Conjugator.conjugate(infinitif: verb, tense: .impératifPassé(personNumberImpératif))
//      switch compoundResult {
//      case .success(let value):
//        output += "\(personNumberImpératif.pronoun) \(value) "
//      default:
//        fatalError()
//      }
//      ConjuguerApp.compoundImpératifPersonNumbersIndex += 1
//      ConjuguerApp.compoundImpératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count

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
