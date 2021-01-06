//
//  Tense.swift
//  Conjuguer
//
//  Created by Joshua Adams on 3/31/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

enum Tense: String, CaseIterable {
  case infinitif = "in"
  case translation = "tn"
  case participePassé = "pe"
  case participePrésent = "pp"
  case radicalFutur = "rf"

  case indicatifPrésent = "pr"
  case passéSimple = "pt"
  case imparfait = "ii"
  case futurSimple = "fu"
  case conditionelPrésent = "co"
  case subjonctifPrésent = "pb"
  case subjonctifImparfait = "sb"
  case impératif = "im"

  // TODO: Add compound tenses.

  func conjugationCount() -> Int {
    switch self {
    case .infinitif, .translation, .participePassé, .participePrésent, .radicalFutur:
      return 0
    case .indicatifPrésent, .passéSimple, .imparfait, .futurSimple, .conditionelPrésent, .subjonctifPrésent, .subjonctifImparfait:
      return 6
    case .impératif:
      return 3
    }
  }

  var displayName: String {
    switch self {
    case .infinitif:
      return "infinitif"
    case .translation:
      return "" // UI uses localized String.
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
    case .conditionelPrésent:
      return "conditionel présent"
    case .subjonctifPrésent:
      return "subjonctif présent"
    case .subjonctifImparfait:
      return "subjonctif imparfait"
    case .impératif:
      return "impératif"
    }
  }

  var titleCaseName: String {
    switch self {
    case .infinitif:
      return "Infinitif"
    case .translation:
      return "" // UI uses localized String.
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
    case .conditionelPrésent:
      return "Conditionel Présent"
    case .subjonctifPrésent:
      return "Subjonctif Présent"
    case .subjonctifImparfait:
      return "Subjonctif Imparfait"
    case .impératif:
      return "Impératif"
    }
  }

    // TODO: Implement this.
//  func auxilliaryTenseForCompoundTense() -> Result<Tense, AuxiliaryError> {
//    switch self {
//    case .perfectoDeIndicativo:
//      return .success(.presenteDeIndicativo)
//    case .pretéritoAnterior:
//      return .success(.pretérito)
//    case .pluscuamperfectoDeIndicativo:
//      return .success(.imperfectoDeIndicativo)
//    case .futuroPerfecto:
//      return .success(.futuroDeIndicativo)
//    case .condicionalCompuesto:
//      return .success(.condicional)
//    case .perfectoDeSubjuntivo:
//      return .success(.presenteDeSubjuntivo)
//    case .pluscuamperfectoDeSubjuntivo1:
//      return .success(.imperfectoDeSubjuntivo1)
//    case .pluscuamperfectoDeSubjuntivo2:
//      return .success(.imperfectoDeSubjuntivo2)
//    case .futuroPerfectoDeSubjuntivo:
//      return .success(.futuroDeSubjuntivo)
//    default:
//      return .failure(.noHaberForm(self))
//    }
//  }
}
