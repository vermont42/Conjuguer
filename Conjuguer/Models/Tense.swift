//
//  Tense.swift
//  Conjuguer
//
//  Created by Joshua Adams on 3/31/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

enum Tense: Hashable {
  case participePassé
  case participePrésent
  case radicalFutur

  case indicatifPrésent(_ personNumber: PersonNumber)
  case passéSimple(_ personNumber: PersonNumber)
  case imparfait(_ personNumber: PersonNumber)
  case futurSimple(_ personNumber: PersonNumber)
  case conditionnelPrésent(_ personNumber: PersonNumber)
  case subjonctifPrésent(_ personNumber: PersonNumber)
  case subjonctifImparfait(_ personNumber: PersonNumber)
  case impératif(_ personNumber: PersonNumber)

  case passéComposé(_ personNumber: PersonNumber)
  case plusQueParfait(_ personNumber: PersonNumber)
  case passéAntérieur(_ personNumber: PersonNumber)
  case passéSurcomposé(_ personNumber: PersonNumber)
  case futurAntérieur(_ personNumber: PersonNumber)
  case conditionnelPassé(_ personNumber: PersonNumber)
  case subjonctifPassé(_ personNumber: PersonNumber)
  case subjonctifPlusQueParfait(_ personNumber: PersonNumber)
  case impératifPassé(_ personNumber: PersonNumber)

  static let onsLength = 3
  static let participePrésentEnding = "ant"

  var displayName: String {
    switch self {
    case .participePassé:
      return "participe passé"
    case .participePrésent:
      return "participe présent"
    case .radicalFutur:
      return "radical futur"
    case .indicatifPrésent:
      return "indicatif présent"
    case .passéSimple:
      return "passé simple"
    case .imparfait:
      return "imparfait"
    case .futurSimple:
      return "futur simple"
    case .conditionnelPrésent:
      return "conditionnel présent"
    case .subjonctifPrésent:
      return "subjonctif présent"
    case .subjonctifImparfait:
      return "subjonctif imparfait"
    case .impératif:
      return "impératif"
    case .passéComposé(_):
      return "passé composé"
    case .plusQueParfait(_):
      return "plus-que-parfait"
    case .passéAntérieur(_):
      return "passé antérieur"
    case .passéSurcomposé(_):
      return "passé surcomposé"
    case .futurAntérieur(_):
      return "futur antérieur"
    case .conditionnelPassé(_):
      return "conditionnel passé"
    case .subjonctifPassé(_):
      return "subjonctif passé"
    case .subjonctifPlusQueParfait(_):
      return "subjonctif plus-que-parfait"
    case .impératifPassé(_):
      return "impératif passé"
    }
  }

  var titleCaseName: String {
    switch self {
    case .participePassé:
      return "Participe Passé"
    case .participePrésent:
      return "Participe Présent"
    case .radicalFutur:
      return "Radical Futur"
    case .indicatifPrésent:
      return "Indicatif Présent"
    case .passéSimple:
      return "Passé Simple"
    case .imparfait:
      return "Imparfait"
    case .futurSimple:
      return "Futur Simple"
    case .conditionnelPrésent:
      return "Conditionnel Présent"
    case .subjonctifPrésent:
      return "Subjonctif Présent"
    case .subjonctifImparfait:
      return "Subjonctif Imparfait"
    case .impératif:
      return "Impératif"
    case .passéComposé(_):
      return "Passé Composé"
    case .plusQueParfait(_):
      return "Plus-que-parfait"
    case .passéAntérieur(_):
      return "Passé Antérieur"
    case .passéSurcomposé(_):
      return "Passé Surcomposé"
    case .futurAntérieur(_):
      return "Futur Antérieur"
    case .conditionnelPassé(_):
      return "Conditionnel Passé"
    case .subjonctifPassé(_):
      return "Subjonctif Passé"
    case .subjonctifPlusQueParfait(_):
      return "Subjonctif Plus-que-parfait"
    case .impératifPassé(_):
      return "Impératif Passé"
    }
  }

  var isCompound: Bool {
    switch self {
    case .passéComposé(_), .plusQueParfait(_), .passéAntérieur(_), .passéSurcomposé(_), .futurAntérieur(_), .conditionnelPassé(_), .subjonctifPassé(_), .subjonctifPlusQueParfait(_), .impératifPassé(_):
      return true
    default:
      return false
    }
  }

  func conjugatedAuxilliary(personNumber: PersonNumber, auxiliary: Auxiliary) -> String {
    let verb = auxiliary.verb
    let tense: Tense
    switch self {
    case .passéComposé(_):
      tense = .indicatifPrésent(personNumber)
    case .plusQueParfait(_):
      tense = .imparfait(personNumber)
    case .passéAntérieur(_):
      tense = .passéSimple(personNumber)
    case .passéSurcomposé(_):
      tense = .passéComposé(personNumber)
    case .futurAntérieur(_):
      tense = .futurSimple(personNumber)
    case .conditionnelPassé(_):
      tense = .conditionnelPrésent(personNumber)
    case .subjonctifPassé(_):
      tense = .subjonctifPrésent(personNumber)
    case .subjonctifPlusQueParfait(_):
      tense = .subjonctifImparfait(personNumber)
    case .impératifPassé(_):
      tense = .impératif(personNumber)
    default:
      return ""
    }

    let result = Conjugator.conjugate(infinitif: verb, tense: tense)
    switch result {
    case .success(let value):
      return value
    case .failure(_):
      return ""
    }
  }
}
