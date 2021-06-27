//
//  PasseSimpleGroup.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/6/21.
//

import Foundation

enum PasséSimpleGroup {
  case bare // exclure
  case a // parler
  case i // finir
  case u // devoir
  case ï // haïr

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
    case "ï":
      return  .ï
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
    case .ï:
      switch personNumber {
      case .firstSingular:
        return "ïs"
      case .secondSingular:
        return "ïs"
      case .thirdSingular:
        return "ït"
      case .firstPlural:
        return "ïmes"
      case .secondPlural:
        return "ïtes"
      case .thirdPlural:
        return "ïrent"
      }
    }
  }

  var endings: String {
    var output = ""
    for personNumber in PersonNumber.allCases {
      output += passéSimpleEndingForPersonNumber(personNumber) + " "
    }
    return output
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
    case .ï:
      switch personNumber {
      case .firstSingular:
        return "ïsse"
      case .secondSingular:
        return "ïsses"
      case .thirdSingular:
        return "ït"
      case .firstPlural:
        return "ïssions"
      case .secondPlural:
        return "ïssiez"
      case .thirdPlural:
        return "ïssent"
      }
    }
  }

  var subjonctifImparfaitEndings: String {
    var output = ""
    for personNumber in PersonNumber.allCases {
      output += subjonctifImparfaitEndingForPersonNumber(personNumber) + " "
    }
    return output
  }
}
