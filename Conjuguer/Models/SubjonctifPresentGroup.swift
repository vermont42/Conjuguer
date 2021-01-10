//
//  SubjonctifPresentGroup.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/9/21.
//

import Foundation

enum SubjonctifPrésentGroup {
  case e
  case s

  static func groupForXmlString(_ xmlString: String) -> SubjonctifPrésentGroup {
    switch xmlString {
    case "e":
      return .e
    case "s":
      return .s
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
    case .s:
      switch personNumber {
      case .firstSingular:
        return "isse"
      case .secondSingular:
        return "isses"
      case .thirdSingular:
        return "isse"
      case .firstPlural:
        return "issions"
      case .secondPlural:
        return "issiez"
      case .thirdPlural:
        return "issent"
      }
    }
  }
}
