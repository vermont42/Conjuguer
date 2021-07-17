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
          setPersonNumberDefectivity(personNumber: PersonNumber.personNumberForShortDisplayName(doesnt), defective: true)
        case "r1s":
          defects[.indicatifPrésent(.firstSingular)] = true
        case "r2s":
          defects[.indicatifPrésent(.secondSingular)] = true
        case "r3s":
          defects[.indicatifPrésent(.thirdSingular)] = true
        case "r1p":
          defects[.indicatifPrésent(.firstPlural)] = true
        case "r2p":
          defects[.indicatifPrésent(.secondPlural)] = true
        case "r3p":
          defects[.indicatifPrésent(.thirdPlural)] = true
        case "b1s":
          defects[.subjonctifPrésent(.firstSingular)] = true
        case "b2s":
          defects[.subjonctifPrésent(.secondSingular)] = true
        case "b3s":
          defects[.subjonctifPrésent(.thirdSingular)] = true
        case "b3p":
          defects[.subjonctifPrésent(.thirdPlural)] = true
        case "h1p":
          defects[.impératif(.firstPlural)] = true
          defects[.impératifPassé(.firstPlural)] = true
        case "h2p":
          defects[.impératif(.secondPlural)] = true
          defects[.impératifPassé(.firstPlural)] = true
        case "rr":
          defects[.participePrésent] = true
        case "pp":
          defects[.participePassé] = true
        case "fA":
          PersonNumber.allCases.forEach {
            defects[.futurSimple($0)] = true
          }
        case "cA":
          PersonNumber.allCases.forEach {
            defects[.conditionnelPrésent($0)] = true
          }
        case "xA":
          PersonNumber.allCases.forEach {
            defects[.passéSimple($0)] = true
          }
        case "iA":
          PersonNumber.allCases.forEach {
            defects[.imparfait($0)] = true
          }
        case "qA":
          PersonNumber.allCases.forEach {
            defects[.subjonctifImparfait($0)] = true
          }
        case "hA":
          PersonNumber.impératifPersonNumbers.forEach {
            defects[.impératif($0)] = true
            defects[.impératifPassé($0)] = true
          }
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
        case "r1s":
          defects[.indicatifPrésent(.firstSingular)] = false
        case "r2s":
          defects[.indicatifPrésent(.secondSingular)] = false
        case "r3s":
          defects[.indicatifPrésent(.thirdSingular)] = false
        case "r3p":
          defects[.indicatifPrésent(.thirdPlural)] = false
        case "h2s":
          defects[.impératif(.secondSingular)] = false
        case "h2p":
          defects[.impératif(.secondPlural)] = false
        case "3s":
          setPersonNumberDefectivity(personNumber: .thirdSingular, defective: false)
        case "3p":
          setPersonNumberDefectivity(personNumber: .thirdPlural, defective: false)
        case "rA":
          PersonNumber.allCases.forEach {
            defects[.indicatifPrésent($0)] = false
          }
        case "iA":
          PersonNumber.allCases.forEach {
            defects[.imparfait($0)] = false
          }
        case "fA":
          PersonNumber.allCases.forEach {
            defects[.futurSimple($0)] = false
          }
        case "cA":
          PersonNumber.allCases.forEach {
            defects[.conditionnelPrésent($0)] = false
          }
        default:
          fatalError("Unrecognized usesOnly \(uses) found.")
        }
      }
    }
  }

  func isDefectiveForTense(_ tense: Tense) -> Bool {
    defects[tense] ?? false
  }

  func description(preferredLanguage: String? = nil) -> String {
    let languageCode = preferredLanguage ?? Locale.preferredLanguages.first ?? Util.english.languageCode ?? "en-US"

    if languageCode.contains(Util.french.languageCode ?? "🥐") {
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

  private mutating func setPersonNumberDefectivity(personNumber: PersonNumber, defective: Bool) {
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
      defects[$0] = defective
    }
  }
}
