//
//  DefectGroup.swift
//  Conjuguer
//
//  Created by Joshua Adams on 7/3/21.
//

import Foundation

struct DefectGroup {
  static var defectGroups: [String: DefectGroup] = [:]

  let id: String
  let descriptionEn: String
  let descriptionFr: String
  private var defects: [Tense: Bool] = [:]

  init(id: String, descriptionEn: String, descriptionFr: String, usesOnly: String?, doesntUse: String?) {
    guard
      !(usesOnly != nil && doesntUse != nil)
    else {
      fatalError("usesOnly and doesntUse were both non-nil.")
    }

    self.id = id
    self.descriptionEn = descriptionEn
    self.descriptionFr = descriptionFr

    let defectSeparator = ","

    if doesntUse == nil && usesOnly == nil {
      setAllDefectsTo(true)
    } else if let doesntUse = doesntUse {
      setAllDefectsTo(false)
      let doesntUseArray = doesntUse.components(separatedBy: defectSeparator)
      for doesnt in doesntUseArray {
        switch doesnt {
        case "1s", "2s", "3s", "1p", "2p", "3p":
          defectifyPersonNumber(PersonNumber.personNumberForShortDisplayName(doesnt))
        default:
          fatalError("Unrecognized doesntUse \(doesnt) found.")
        }
      }
    } else if let usesOnly = usesOnly {
      setAllDefectsTo(true)
      let usesOnlyArray = usesOnly.components(separatedBy: defectSeparator)
      for uses in usesOnlyArray {
        switch uses {
        case "pp":
          defects[.participePassé] = false
        case "rr":
          defects[.participePrésent] = false
        default:
          fatalError("Unrecognized usesOnly \(uses) found.")
        }
      }
    }
  }

  func isDefectiveForTense(_ tense: Tense) -> Bool {
    defects[tense] ?? false
  }

  func description(locale: Locale = Locale.current) -> String {
    if locale.languageCode == Util.french.languageCode {
      return descriptionFr
    } else {
      return descriptionEn
    }
  }

  private mutating func setAllDefectsTo(_ value: Bool) {
    [
      .participePassé, .participePrésent, .radicalFutur,
      .indicatifPrésent(.firstSingular), .indicatifPrésent(.secondSingular), .indicatifPrésent(.thirdSingular), .indicatifPrésent(.firstPlural), .indicatifPrésent(.secondPlural), .indicatifPrésent(.thirdPlural),
      .passéSimple(.firstSingular), .passéSimple(.secondSingular), .passéSimple(.thirdSingular), .passéSimple(.firstPlural), .passéSimple(.secondPlural), .passéSimple(.thirdPlural),
      .imparfait(.firstSingular), .imparfait(.secondSingular), .imparfait(.thirdSingular), .imparfait(.firstPlural), .imparfait(.secondPlural), .imparfait(.thirdPlural),
      .futurSimple(.firstSingular), .futurSimple(.secondSingular), .futurSimple(.thirdSingular), .futurSimple(.firstPlural), .futurSimple(.secondPlural), .futurSimple(.thirdPlural),
      .conditionnelPrésent(.firstSingular), .conditionnelPrésent(.secondSingular), .conditionnelPrésent(.thirdSingular), .conditionnelPrésent(.firstPlural), .conditionnelPrésent(.secondPlural), .conditionnelPrésent(.thirdPlural),
      .subjonctifPrésent(.firstSingular), .subjonctifPrésent(.secondSingular), .subjonctifPrésent(.thirdSingular), .subjonctifPrésent(.firstPlural), .subjonctifPrésent(.secondPlural), .subjonctifPrésent(.thirdPlural),
      .subjonctifImparfait(.firstSingular), .subjonctifImparfait(.secondSingular), .subjonctifImparfait(.thirdSingular), .subjonctifImparfait(.firstPlural), .subjonctifImparfait(.secondPlural), .subjonctifImparfait(.thirdPlural),
      .impératif(.secondSingular), .impératif(.firstPlural), .impératif(.secondPlural),
      .passéComposé(.firstSingular), .passéComposé(.secondSingular), .passéComposé(.thirdSingular), .passéComposé(.firstPlural), .passéComposé(.secondPlural), .passéComposé(.thirdPlural),
      .plusQueParfait(.firstSingular), .plusQueParfait(.secondSingular), .plusQueParfait(.thirdSingular), .plusQueParfait(.firstPlural), .plusQueParfait(.secondPlural), .plusQueParfait(.thirdPlural),
      .passéAntérieur(.firstSingular), .passéAntérieur(.secondSingular), .passéAntérieur(.thirdSingular), .passéAntérieur(.firstPlural), .passéAntérieur(.secondPlural), .passéAntérieur(.thirdPlural),
      .passéSurcomposé(.firstSingular), .passéSurcomposé(.secondSingular), .passéSurcomposé(.thirdSingular), .passéSurcomposé(.firstPlural), .passéSurcomposé(.secondPlural), .passéSurcomposé(.thirdPlural),
      .futurAntérieur(.firstSingular), .futurAntérieur(.secondSingular), .futurAntérieur(.thirdSingular), .futurAntérieur(.firstPlural), .futurAntérieur(.secondPlural), .futurAntérieur(.thirdPlural),
      .conditionnelPassé(.firstSingular), .conditionnelPassé(.secondSingular), .conditionnelPassé(.thirdSingular), .conditionnelPassé(.firstPlural), .conditionnelPassé(.secondPlural), .conditionnelPassé(.thirdPlural),
      .subjonctifPassé(.firstSingular), .subjonctifPassé(.secondSingular), .subjonctifPassé(.thirdSingular), .subjonctifPassé(.firstPlural), .subjonctifPassé(.secondPlural), .subjonctifPassé(.thirdPlural),
      .subjonctifPlusQueParfait(.firstSingular), .subjonctifPlusQueParfait(.secondSingular), .subjonctifPlusQueParfait(.thirdSingular), .subjonctifPlusQueParfait(.firstPlural), .subjonctifPlusQueParfait(.secondPlural), .subjonctifPlusQueParfait(.thirdPlural),
      .impératifPassé(.secondSingular), .impératifPassé(.firstPlural), .impératifPassé(.secondPlural)
    ].forEach {
      defects[$0] = value
    }
  }

  private mutating func defectifyPersonNumber(_ personNumber: PersonNumber) {
    [
      .indicatifPrésent(personNumber),
      .passéSimple(personNumber),
      .imparfait(personNumber),
      .futurSimple(personNumber),
      .conditionnelPrésent(personNumber),
      .subjonctifPrésent(personNumber),
      .subjonctifImparfait(personNumber),
      .impératif(personNumber),
      .passéComposé(personNumber),
      .plusQueParfait(personNumber),
      .passéAntérieur(personNumber),
      .passéSurcomposé(personNumber),
      .futurAntérieur(personNumber),
      .conditionnelPassé(personNumber),
      .subjonctifPassé(personNumber),
      .subjonctifPlusQueParfait(personNumber),
      .impératifPassé(personNumber)
    ].forEach {
      defects[$0] = true
    }
  }
}
