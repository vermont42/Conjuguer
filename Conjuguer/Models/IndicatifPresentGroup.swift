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
        return "ïs"
      case .secondSingular:
        return "ïs"
      case .thirdSingular:
        return "ït"
      case .firstPlural:
        return "ïssons"
      case .secondPlural:
        return "ïssez"
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
          if lastChar == Tense.irregularEndingMarker && stemAlteration.appliesTo.contains(.indicatifPrésent(personNumber)) {
            alterationsWithStar.insert(.indicatifPrésent(personNumber))
          }
        }
      }
    }

    var output = ""
    for personNumber in PersonNumber.allCases {
      if alterationsWithStar.contains(.indicatifPrésent(personNumber)) {
        output += Tense.irregularEndingMarker + " "
      } else {
        let ending = présentEndingForPersonNumber(personNumber)
        let normalizedEnding = ending == "" ? "_" : ending
        output += normalizedEnding + " "
      }
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
        return "is"
      case .firstPlural:
        return "ïssons"
      case .secondPlural:
        return "ïssez"
      default:
        return ""
      }
    }
  }

  func impératifEndings(stemAlterations: [StemAlteration]?) -> String {
    var alterationsWithStar: Set<Tense> = Set()
    if let stemAlterations = stemAlterations {
      for stemAlteration in stemAlterations {
        for personNumber in PersonNumber.impératifPersonNumbers {
          let lastChar = String(stemAlteration.charsToUse.last ?? Character(" "))
          if lastChar == Tense.irregularEndingMarker && stemAlteration.appliesTo.contains(.impératif(personNumber)) {
            alterationsWithStar.insert(.impératif(personNumber))
          }
        }
      }
    }

    var output = ""
    for personNumber in PersonNumber.impératifPersonNumbers {
      if alterationsWithStar.contains(.impératif(personNumber)) {
        output += Tense.irregularEndingMarker + " "
      } else {
        output += impératifEndingForPersonNumber(personNumber) + " "
      }
    }
    return output
  }
}
