//
//  CompleteAlteration.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/13/21.
//

import Foundation

struct CompleteAlteration {
  let conjugation: String
  let appliesTo: Tense

  static func alterationsFromXmlString(_ xmlString: String) -> [CompleteAlteration] {
    let components = xmlString.components(separatedBy: VerbModelParser.xmlSeparator)

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
      case "pp":
        tense = .participePassé

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

      case "b1s":
        tense = .subjonctifPrésent(.firstSingular)
      case "b2s":
        tense = .subjonctifPrésent(.secondSingular)
      case "b3s":
        tense = .subjonctifPrésent(.thirdSingular)
      case "b1p":
        tense = .subjonctifPrésent(.firstPlural)
      case "b2p":
        tense = .subjonctifPrésent(.secondPlural)
      case "b3p":
        tense = .subjonctifPrésent(.thirdPlural)

      case "x1s":
        tense = .passéSimple(.firstSingular)
      case "x2s":
        tense = .passéSimple(.secondSingular)
      case "x3s":
        tense = .passéSimple(.thirdSingular)
      case "x1p":
        tense = .passéSimple(.firstPlural)
      case "x2p":
        tense = .passéSimple(.secondPlural)
      case "x3p":
        tense = .passéSimple(.thirdPlural)

      case "m2s":
        tense = .impératif(.secondSingular)
      case "m1p":
        tense = .impératif(.firstPlural)
      case "m2p":
        tense = .impératif(.secondPlural)

      default:
        fatalError("Unrecognized total alteration \(components[i * 2]) found.")
      }
      alterations.append(CompleteAlteration(conjugation: components[(i * 2) + 1], appliesTo: tense))
    }

    return alterations
  }
}
