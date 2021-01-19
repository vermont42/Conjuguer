//
//  IndicatifPresentGroup.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/8/21.
//

import Foundation

enum IndicatifPrésentGroup {
  case e(appliesToErVerb: Bool)
  case extendedS(appliesToReVerb: Bool)
  case s
  case ï

  static func groupForXmlString(_ xmlString: String) -> IndicatifPrésentGroup {
    switch xmlString {
    case "e":
      return .e(appliesToErVerb: true)
    case "E":
      return .e(appliesToErVerb: false)
    case "x":
      return .extendedS(appliesToReVerb: false)
    case "X":
      return .extendedS(appliesToReVerb: true)
    case "s":
      return .s
    case "ï":
      return .ï
    default:
      fatalError("Attempted to construct IndicatifPrésentGroup from invalid xmlString \(xmlString).")
    }
  }

  func présentEndingForPersonNumber(_ personNumber: PersonNumber) -> String {
    switch self {
    case .e(let appliesToErVerb):
      var ending: String
      switch personNumber {
      case .firstSingular:
        ending = "e"
      case .secondSingular:
        ending = "es"
      case .thirdSingular:
        ending = "e"
      case .firstPlural:
        ending = "ons"
      case .secondPlural:
        ending = "ez"
      case .thirdPlural:
        ending = "ent"
      }
      if !appliesToErVerb {
        ending = ending.uppercased()
      }
      return ending
    case .extendedS(let appliesToReVerb):
      switch personNumber {
      case .firstSingular:
        return appliesToReVerb ? "Is" : "is"
      case .secondSingular:
        return appliesToReVerb ? "Is" : "is"
      case .thirdSingular:
        return appliesToReVerb ? "It" : "it"
      case .firstPlural:
        return appliesToReVerb ? "ISSons" : "issons"
      case .secondPlural:
        return appliesToReVerb ? "ISSez" : "issez"
      case .thirdPlural:
        return appliesToReVerb ? "ISSent" : "issent"
      }
    case .s:
      switch personNumber {
      case .firstSingular:
        return "s"
      case .secondSingular:
        return "s"
      case .thirdSingular:
        return "t"
      case .firstPlural:
        return "ons"
      case .secondPlural:
        return "ez"
      case .thirdPlural:
        return "ent"
      }
    case .ï:
      switch personNumber {
      case .firstSingular:
        return "Is"
      case .secondSingular:
        return "Is"
      case .thirdSingular:
        return "It"
      case .firstPlural:
        return "ïssons"
      case .secondPlural:
        return "ïssez"
      case .thirdPlural:
        return "ïssent"
      }
    }
  }

  func impératifEndingForPersonNumber(_ personNumber: PersonNumber) -> String {
    switch self {
    case .e(let appliesToErVerb):
      switch personNumber {
      case .secondSingular:
        return appliesToErVerb ? "e" : "E"
      case .firstPlural:
        return appliesToErVerb ? "ons" : "Ons"
      case .secondPlural:
        return appliesToErVerb ? "ez" : "Ez"
      default:
        return ""
      }
    case .extendedS(let appliesToReVerb):
      switch personNumber {
      case .secondSingular:
        return appliesToReVerb ? "Is" : "is"
      case .firstPlural:
        return appliesToReVerb ? "ISSons" : "issons"
      case .secondPlural:
        return appliesToReVerb ? "ISSez" : "issez"
      default:
        return ""
      }
    case .s:
      switch personNumber {
      case .secondSingular:
        return "s"
      case .firstPlural:
        return "ons"
      case .secondPlural:
        return "ez"
      default:
        return ""
      }
    case .ï:
      switch personNumber {
      case .secondSingular:
        return "Is"
      case .firstPlural:
        return "ïssons"
      case .secondPlural:
        return "ïssez"
      default:
        return ""
      }
    }
  }
}
