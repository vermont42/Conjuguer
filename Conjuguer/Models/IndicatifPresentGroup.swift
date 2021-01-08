//
//  IndicatifPresentGroup.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/8/21.
//

import Foundation

enum IndicatifPrésentGroup {
  case e
  case extendedS
  case s

  static func groupForXmlString(_ xmlString: String) -> IndicatifPrésentGroup {
    switch xmlString {
    case "e":
      return .e
    case "x":
      return .extendedS
    case "s":
      return .s
    default:
      fatalError("Attempted to construct IndicatifPrésentGroup from invalid xmlString \(xmlString).")
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
        return "ons"
      case .secondPlural:
        return "ez"
      case .thirdPlural:
        return "ent"
      }
    case .extendedS:
      switch personNumber {
      case .firstSingular:
        return "is"
      case .secondSingular:
        return "is"
      case .thirdSingular:
        return "it"
      case .firstPlural:
        return "issons"
      case .secondPlural:
        return "issez"
      case .thirdPlural:
        return "issent"
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
    }
  }
}
