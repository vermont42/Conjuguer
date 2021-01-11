//
//  PasseSimpleGroup.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/6/21.
//

import Foundation

enum PasséSimpleGroup {
  case bare
  case a
  case i
  case u

  static func groupForXmlString(_ xmlString: String) -> PasséSimpleGroup {
    switch xmlString {
    case "b":
      return .bare
    case "a":
      return .a
    case "i":
      return .i
    case "u":
      return .u
    default:
      fatalError("Attempted to construct PasséSimpleGroup from invalid xmlString \(xmlString).")
    }
  }

  func passéSimpleEndingForPersonNumber(_ personNumber: PersonNumber) -> String {
    switch self {
    case .bare:
      switch personNumber {
      case .firstSingular:
        return "s"
      case .secondSingular:
        return "s"
      case .thirdSingular:
        return "t"
      case .firstPlural:
        return "^mes"
      case .secondPlural:
        return "^tes"
      case .thirdPlural:
        return "rent"
      }
    case .a:
      switch personNumber {
      case .firstSingular:
        return "ai"
      case .secondSingular:
        return "as"
      case .thirdSingular:
        return "a"
      case .firstPlural:
        return "âmes"
      case .secondPlural:
        return "âtes"
      case .thirdPlural:
        return "èrent"
      }
    case .i:
      switch personNumber {
      case .firstSingular:
        return "is"
      case .secondSingular:
        return "is"
      case .thirdSingular:
        return "it"
      case .firstPlural:
        return "îmes"
      case .secondPlural:
        return "îtes"
      case .thirdPlural:
        return "irent"
      }
    case .u:
      switch personNumber {
      case .firstSingular:
        return "us"
      case .secondSingular:
        return "us"
      case .thirdSingular:
        return "ut"
      case .firstPlural:
        return "ûmes"
      case .secondPlural:
        return "ûtes"
      case .thirdPlural:
        return "urent"
      }
    }
  }

  func subjonctifImparfaitEndingForPersonNumber(_ personNumber: PersonNumber) -> String {
    switch self {
    case .bare:
      switch personNumber {
      case .firstSingular:
        return "sse"
      case .secondSingular:
        return "sses"
      case .thirdSingular:
        return "^t"
      case .firstPlural:
        return "ssions"
      case .secondPlural:
        return "ssiez"
      case .thirdPlural:
        return "ssent"
      }
    case .a:
      switch personNumber {
      case .firstSingular:
        return "asse"
      case .secondSingular:
        return "asses"
      case .thirdSingular:
        return "ât"
      case .firstPlural:
        return "assions"
      case .secondPlural:
        return "assiez"
      case .thirdPlural:
        return "assent"
      }
    case .i:
      switch personNumber {
      case .firstSingular:
        return "isse"
      case .secondSingular:
        return "isses"
      case .thirdSingular:
        return "ît"
      case .firstPlural:
        return "issions"
      case .secondPlural:
        return "issiez"
      case .thirdPlural:
        return "issent"
      }
    case .u:
      switch personNumber {
      case .firstSingular:
        return "usse"
      case .secondSingular:
        return "usses"
      case .thirdSingular:
        return "ût"
      case .firstPlural:
        return "ussions"
      case .secondPlural:
        return "ussiez"
      case .thirdPlural:
        return "ussent"
      }
    }
  }
}