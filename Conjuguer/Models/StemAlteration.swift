//
//  StemAlteration.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/2/21.
//

import Foundation

struct StemAlteration {
  let startIndexFromLast: Int
  let charsToReplaceCount: Int
  let charsToUse: String
  let appliesTo: Set<Tense>
  let isAdditive: Bool // example: tu payes/paies

  init(xmlString: String) {
    let components = xmlString.components(separatedBy: VerbModelParser.xmlSeparator)

    guard components.count >= 4 else {
      fatalError("Partial-alteration XML string \(xmlString) did not have enough components.")
    }

    guard let convertedStartIndexFromLast = Int(components[0]) else {
      fatalError(components[0] + " is not a valid Int.")
    }
    startIndexFromLast = convertedStartIndexFromLast

    guard let convertedCharsToReplaceCount = Int(components[1]) else {
      fatalError(components[1] + " is not a valid Int.")
    }
    charsToReplaceCount = convertedCharsToReplaceCount

    charsToUse = components[2]

    var set: Set<Tense> = Set()
    var isAdditiveAlteration = false

    for index in VerbModelParser.startIndexOfAlterationsInXml ..< components.count {
      let alteration = components[index]
      switch alteration {
      case "A":
        isAdditiveAlteration = true

      case "pp":
        set.insert(.participePassé)
      case "rr":
        set.insert(.participePrésent)
      case "sf":
        set.insert(.radicalFutur)

      case "r1s":
        set.insert(.indicatifPrésent(.firstSingular))
      case "r2s":
        set.insert(.indicatifPrésent(.secondSingular))
      case "r3s":
        set.insert(.indicatifPrésent(.thirdSingular))
      case "r1p":
        set.insert(.indicatifPrésent(.firstPlural))
      case "r2p":
        set.insert(.indicatifPrésent(.secondPlural))
      case "r3p":
        set.insert(.indicatifPrésent(.thirdPlural))

      case "b1s":
        set.insert(.subjonctifPrésent(.firstSingular))
      case "b2s":
        set.insert(.subjonctifPrésent(.secondSingular))
      case "b3s":
        set.insert(.subjonctifPrésent(.thirdSingular))
      case "b1p":
        set.insert(.subjonctifPrésent(.firstPlural))
      case "b2p":
        set.insert(.subjonctifPrésent(.secondPlural))
      case "b3p":
        set.insert(.subjonctifPrésent(.thirdPlural))
      case "bA":
        PersonNumber.allCases.forEach {
          set.insert(.subjonctifPrésent($0))
        }

      case "x1s":
        set.insert(.passéSimple(.firstSingular))
      case "x2s":
        set.insert(.passéSimple(.secondSingular))
      case "x3s":
        set.insert(.passéSimple(.thirdSingular))
      case "x1p":
        set.insert(.passéSimple(.firstPlural))
      case "x2p":
        set.insert(.passéSimple(.secondPlural))
      case "x3p":
        set.insert(.passéSimple(.thirdPlural))
      case "xA":
        PersonNumber.allCases.forEach {
          set.insert(.passéSimple($0))
        }

      case "i1s":
        set.insert(.imparfait(.firstSingular))
      case "i2s":
        set.insert(.imparfait(.secondSingular))
      case "i3s":
        set.insert(.imparfait(.thirdSingular))
      case "i1p":
        set.insert(.imparfait(.firstPlural))
      case "i2p":
        set.insert(.imparfait(.secondPlural))
      case "i3p":
        set.insert(.imparfait(.thirdPlural))

      case "q1s":
        set.insert(.subjonctifImparfait(.firstSingular))
      case "q2s":
        set.insert(.subjonctifImparfait(.secondSingular))
      case "q3s":
        set.insert(.subjonctifImparfait(.thirdSingular))
      case "q1p":
        set.insert(.subjonctifImparfait(.firstPlural))
      case "q2p":
        set.insert(.subjonctifImparfait(.secondPlural))
      case "q3p":
        set.insert(.subjonctifImparfait(.thirdPlural))

      default:
        fatalError("Unrecognized partial alteration \(alteration) found.")
      }
    }

    appliesTo = set
    isAdditive = isAdditiveAlteration
  }

  static func alterationsFor(xmlString: String) -> [StemAlteration] {
    let separator = "|"
    let components = xmlString.components(separatedBy: separator)
    var alterations: [StemAlteration] = []
    components.forEach {
      alterations.append(StemAlteration(xmlString: $0))
    }
    return alterations
  }
}
