//
//  SubjonctifPresentGroup.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/9/21.
//

import Foundation

enum SubjonctifPrésentGroup {
  case e
  case s(appliesToReVerb: Bool)
  case ï

  static func groupForXmlString(_ xmlString: String) -> SubjonctifPrésentGroup {
    switch xmlString {
    case "e":
      return .e
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
    case .e:
      switch personNumber {
      case .firstSingular:
        return "e"
      case .secondSingular:
        return "es"
      case .thirdSingular:
        return "e"
      case .firstPlural:
        return "ions"
      case .secondPlural:
        return "iez"
      case .thirdPlural:
        return "ent"
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
}
