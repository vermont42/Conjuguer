//
//  StemAlteration.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/2/21.
//

import Foundation

struct StemAlteration: Hashable {
  let type: StemAlterationType
  let charsToUse: String
  let appliesTo: Set<Tense>
  let isAdditive: Bool // example: tu payes/paies
  let isInherited: Bool // example: vous dîtes/prédisez (false in that case)
  static let capitalizedFirstLetter = "@" // example: devoir -> Du

  init(xmlString: String) {
    let components = xmlString.components(separatedBy: VerbModelParser.xmlSeparator)

    guard components.count >= 3 else {
      fatalError("Partial-alteration XML string \(xmlString) did not have enough components.")
    }

    let startIndexOfAlterationsInXml: Int
    if let convertedStartIndexFromLast = Int(components[0]) {
      guard let convertedCharsToReplaceCount = Int(components[1]) else {
        fatalError(components[1] + " is not a valid Int.")
      }
      type = .indexBased(startIndexFromLast: convertedStartIndexFromLast, charsToReplaceCount: convertedCharsToReplaceCount)
      charsToUse = components[2]
      startIndexOfAlterationsInXml = 3
    } else {
      type = .letterBased(letterToReplace: components[0])
      charsToUse = components[1]
      startIndexOfAlterationsInXml = 2
    }

    var set: Set<Tense> = Set()
    var isAdditiveAlteration = false
    var isInheritedAlteration = true

    for index in startIndexOfAlterationsInXml ..< components.count {
      let alteration = components[index]
      // TODO: Don't switch. Instead, handle "A" and "N". Then use Tense.tensesFor(shorthand to figure out what to insert.

      switch alteration {
      case "A":
        isAdditiveAlteration = true

      case "N":
        isInheritedAlteration = false

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
      case "rA":
        PersonNumber.allCases.forEach {
          set.insert(.indicatifPrésent($0))
        }

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
      case "iA":
        PersonNumber.allCases.forEach {
          set.insert(.imparfait($0))
        }

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

      case "h2s":
        set.insert(.impératif(.secondSingular))
      case "h1p":
        set.insert(.impératif(.firstPlural))
      case "h2p":
        set.insert(.impératif(.secondPlural))
      default:
        fatalError("Unrecognized partial alteration \(alteration) found.")
      }
    }

    appliesTo = set
    isAdditive = isAdditiveAlteration
    isInherited = isInheritedAlteration
  }

  var toString: String {
    switch type {
    case .indexBased(let startIndexFromLast, let charsToReplaceCount):
      var output = "\(startIndexFromLast)"
      if startIndexFromLast > 0 {
        output += ", \(charsToReplaceCount)"
      }
      if charsToUse == "" {
        output += ", Ø"
      } else {
        output += ", " + charsToUse
      }
      return output
    case .letterBased(let letterToReplace):
      return letterToReplace + " ➡️ " + charsToUse
    }
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

enum StemAlterationType: Hashable {
  case indexBased(startIndexFromLast: Int, charsToReplaceCount: Int)
  case letterBased(letterToReplace: String)
}

extension String {
  mutating func modifyStem(alteration: StemAlteration) {
    switch alteration.type {
    case .indexBased(let startIndexFromLast, let charsToReplaceCount):
      if startIndexFromLast == 0 {
        self += alteration.charsToUse
      } else {
        let start = index(startIndex, offsetBy: count - startIndexFromLast)
        let end = index(startIndex, offsetBy: (count - startIndexFromLast) + charsToReplaceCount)
        if alteration.charsToUse == StemAlteration.capitalizedFirstLetter {
          replaceSubrange(start ..< end, with: self[start].uppercased())
        } else {
          replaceSubrange(start ..< end, with: alteration.charsToUse)
        }
      }
    case .letterBased(let letterToReplace):
      if let range = range(of: letterToReplace, options: [.backwards], range: nil, locale: nil) {
        self = replacingCharacters(in: range, with: alteration.charsToUse)
      }
    }
  }
}
