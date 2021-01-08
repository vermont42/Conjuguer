//
//  Alteration.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

// "1,1,ç,r1p,x1s,x2s,x3s,x1p,x2p" = replace last letter with ç for six conjugations
// "0,1,l," = add an l at the end (second number is irrelevant)
// "2,1,eu" = mov -> meuv

fileprivate let xmlSeparator = ","
fileprivate let startIndexOfAlterationsInXml = 3

struct PartialAlteration {
  let startIndexFromLast: Int
  let charsToReplaceCount: Int
  let charsToUse: String
  let appliesTo: Set<Tense>

  init(xmlString: String) {
    let components = xmlString.components(separatedBy: xmlSeparator)

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

    for index in startIndexOfAlterationsInXml ..< components.count {
      let alteration = components[index]
      switch alteration {
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

      case "pp":
        set.insert(.participePassé)

      default:
        fatalError("Unrecognized partial alteration \(alteration) found.")
      }
    }

    appliesTo = set
  }
}

struct CompleteAlteration {
  let conjugation: String
  let appliesTo: Tense

  static func alterationsFromXmlString(_ xmlString: String) -> [CompleteAlteration] {
    let components = xmlString.components(separatedBy: xmlSeparator)

    guard components.count >= 2 else {
      fatalError("Complete-alteration XML string \(xmlString) did not have enough components.")
    }

    guard components.count.isMultiple(of: 2) else {
      fatalError("Complete-alteration XML string \(xmlString) had an odd number of components.")
    }

    let alterationCount = components.count / 2

    var alterations: [CompleteAlteration] = []

    for i in 0 ..< alterationCount {
      let tense: Tense
      switch components[i * 2] {
      case "r1s":
        tense = .indicatifPrésent(.firstSingular)
      case "r2s":
        tense = .indicatifPrésent(.secondSingular)
      case "r3s":
        tense = .indicatifPrésent(.thirdSingular)
      case "r1p":
        tense = .indicatifPrésent(.firstPlural)
      case "r2p":
        tense = .indicatifPrésent(.secondPlural)
      case "r3p":
        tense = .indicatifPrésent(.thirdPlural)

      case "pp":
        tense = .participePassé

      default:
        fatalError("Unrecognized total alteration \(components[i * 2]) found.")
      }
      alterations.append(CompleteAlteration(conjugation: components[(i * 2) + 1], appliesTo: tense))
    }

    return alterations
  }
}
