//
//  Tense.swift
//  Conjuguer
//
//  Created by Josh Adams on 3/31/17.
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
  static let alternateConjugationSeparator = "/"
  static let irregularEndingIndicator = "*"

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
    case .passéComposé:
      return "passé composé"
    case .plusQueParfait:
      return "plus-que-parfait"
    case .passéAntérieur:
      return "passé antérieur"
    case .passéSurcomposé:
      return "passé surcomposé"
    case .futurAntérieur:
      return "futur antérieur"
    case .conditionnelPassé:
      return "conditionnel passé"
    case .subjonctifPassé:
      return "subjonctif passé"
    case .subjonctifPlusQueParfait:
      return "subjonctif plus-que-parfait"
    case .impératifPassé:
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
    case .passéComposé:
      return "Passé Composé"
    case .plusQueParfait:
      return "Plus-que-parfait"
    case .passéAntérieur:
      return "Passé Antérieur"
    case .passéSurcomposé:
      return "Passé Surcomposé"
    case .futurAntérieur:
      return "Futur Antérieur"
    case .conditionnelPassé:
      return "Conditionnel Passé"
    case .subjonctifPassé:
      return "Subjonctif Passé"
    case .subjonctifPlusQueParfait:
      return "Subjonctif Plus-que-parfait"
    case .impératifPassé:
      return "Impératif Passé"
    }
  }

  var isCompound: Bool {
    switch self {
    case .passéComposé, .plusQueParfait, .passéAntérieur, .passéSurcomposé, .futurAntérieur, .conditionnelPassé, .subjonctifPassé, .subjonctifPlusQueParfait, .impératifPassé:
      return true
    default:
      return false
    }
  }

  func conjugatedAuxilliary(personNumber: PersonNumber, auxiliary: Auxiliary) -> String {
    let verb = auxiliary.verb
    let tense: Tense
    switch self {
    case .passéComposé:
      tense = .indicatifPrésent(personNumber)
    case .plusQueParfait:
      tense = .imparfait(personNumber)
    case .passéAntérieur:
      tense = .passéSimple(personNumber)
    case .passéSurcomposé:
      tense = .passéComposé(personNumber)
    case .futurAntérieur:
      tense = .futurSimple(personNumber)
    case .conditionnelPassé:
      tense = .conditionnelPrésent(personNumber)
    case .subjonctifPassé:
      tense = .subjonctifPrésent(personNumber)
    case .subjonctifPlusQueParfait:
      tense = .subjonctifImparfait(personNumber)
    case .impératifPassé:
      tense = .impératif(personNumber)
    default:
      return ""
    }

    let result = Conjugator.conjugate(infinitif: verb, tense: tense)
    switch result {
    case .success(let value):
      return value
    case .failure:
      return ""
    }
  }
}
