//
//  SubjonctifPresentGroup.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/9/21.
//

import Foundation

enum SubjonctifPrésentGroup: Hashable {
  case e(appliesToIrVerb: Bool)
  case s(appliesToReVerb: Bool)
  case ï

  static func groupForXmlString(_ xmlString: String) -> SubjonctifPrésentGroup {
    switch xmlString {
    case "e":
      return .e(appliesToIrVerb: false)
    case "E":
      return .e(appliesToIrVerb: true)
    case "s":
      return .s(appliesToReVerb: false)
    case "S":
      return .s(appliesToReVerb: true)
    case "ï":
      return .ï
    default:
      fatalError("Attempted to construct SubjonctifPrésentGroup from invalid xmlString \(xmlString).")
    }
  }

  func endingForPersonNumber(_ personNumber: PersonNumber) -> String {
    switch self {
    case .e(let appliesToIrVerb):
      switch personNumber {
      case .firstSingular:
        return appliesToIrVerb ? "E" : "e"
      case .secondSingular:
        return appliesToIrVerb ? "ES" : "es"
      case .thirdSingular:
        return appliesToIrVerb ? "E" : "e"
      case .firstPlural:
        return appliesToIrVerb ? "IONS" : "ions"
      case .secondPlural:
        return appliesToIrVerb ? "IEZ" : "iez"
      case .thirdPlural:
        return appliesToIrVerb ? "ENT" : "ent"
      }
    case .s(let appliesToReVerb):
      switch personNumber {
      case .firstSingular:
        return appliesToReVerb ? "ISSe" : "isse"
      case .secondSingular:
        return appliesToReVerb ? "ISSes" : "isses"
      case .thirdSingular:
        return appliesToReVerb ? "ISSe" : "isse"
      case .firstPlural:
        return appliesToReVerb ? "ISSions" : "issions"
      case .secondPlural:
        return appliesToReVerb ? "ISSiez" : "issiez"
      case .thirdPlural:
        return appliesToReVerb ? "ISSent" : "issent"
      }
    case .ï:
      switch personNumber {
      case .firstSingular:
        return "ïsse"
      case .secondSingular:
        return "ïsses"
      case .thirdSingular:
        return "ïsse"
      case .firstPlural:
        return "ïssions"
      case .secondPlural:
        return "ïssiez"
      case .thirdPlural:
        return "ïssent"
      }
    }
  }

  func endings(stemAlterations: [StemAlteration]?) -> String {
    var alterationsWithStar: Set<Tense> = Set()
    if let stemAlterations = stemAlterations {
      for stemAlteration in stemAlterations {
        for personNumber in PersonNumber.allCases {
          let lastChar = String(stemAlteration.charsToUse.last ?? Character(" "))
          if lastChar == Tense.irregularEndingMarker && stemAlteration.appliesTo.contains(.subjonctifPrésent(personNumber)) {
            alterationsWithStar.insert(.subjonctifPrésent(personNumber))
          }
        }
      }
    }

    var output = ""
    for personNumber in PersonNumber.allCases {
      if alterationsWithStar.contains(.subjonctifPrésent(personNumber)) {
        output += Tense.irregularEndingMarker + " "
      } else {
        output += endingForPersonNumber(personNumber) + " "
      }
    }
    return output
  }
}
