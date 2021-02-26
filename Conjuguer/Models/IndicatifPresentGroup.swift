//
//  IndicatifPresentGroup.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/8/21.
//

import Foundation

enum IndicatifPrésentGroup: Hashable {
  case e(appliesToErVerb: Bool) // parler (true) / couvrir (false)
  case extendedS(appliesToIrVerb: Bool) // finir (true) / maudire (false)
  case s // voir
  case ï // haïr
  case r // rendre

  static func groupForXmlString(_ xmlString: String) -> IndicatifPrésentGroup {
    switch xmlString {
    case "e":
      return .e(appliesToErVerb: true)
    case "E":
      return .e(appliesToErVerb: false)
    case "x":
      return .extendedS(appliesToIrVerb: true)
    case "X":
      return .extendedS(appliesToIrVerb: false)
    case "s":
      return .s
    case "ï":
      return .ï
    case "r":
      return .r
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
    case .extendedS(let appliesToIrVerb):
      switch personNumber {
      case .firstSingular:
        return appliesToIrVerb ? "is" : "Is"
      case .secondSingular:
        return appliesToIrVerb ? "is" : "Is"
      case .thirdSingular:
        return appliesToIrVerb ? "it" : "It"
      case .firstPlural:
        return appliesToIrVerb ? "issons" : "ISSons"
      case .secondPlural:
        return appliesToIrVerb ? "issez" : "ISSez"
      case .thirdPlural:
        return appliesToIrVerb ? "issent" : "ISSent"
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
    case .r:
      switch personNumber {
      case .firstSingular:
        return "s"
      case .secondSingular:
        return "s"
      case .thirdSingular:
        return ""
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

  var endings: String {
    var output = ""
    for personNumber in PersonNumber.allCases {
      output += présentEndingForPersonNumber(personNumber) + " "
    }
    return output
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
    case .extendedS(let appliesToIrVerb):
      switch personNumber {
      case .secondSingular:
        return appliesToIrVerb ? "is" : "Is"
      case .firstPlural:
        return appliesToIrVerb ? "issons" : "ISSons"
      case .secondPlural:
        return appliesToIrVerb ? "issez" : "ISSez"
      default:
        return ""
      }
    case .s, .r:
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

  var impératifEndings: String {
    var output = ""
    for personNumber in PersonNumber.impératifPersonNumbers {
      output += impératifEndingForPersonNumber(personNumber) + " "
    }
    return output
  }
}
