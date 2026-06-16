//
//  StemAlteration.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/2/21.
//

import Foundation

nonisolated struct StemAlteration: Hashable {
  let type: StemAlterationType
  let charsToUse: String
  let appliesTo: Set<Tense>
  let isAdditive: Bool // example: tu payes/paies
  let isInherited: Bool // example: vous dîtes/prédisez (false in that case)
  static let capitalizedFirstLetter = "@" // example: devoir -> Du

  init?(xmlString: String) {
    let components = xmlString.components(separatedBy: VerbModelParser.xmlSeparator)

    guard components.count >= 3 else {
      print("Skipping partial alteration: XML string \(xmlString) did not have enough components.")
      return nil
    }

    let startIndexOfAlterationsInXml: Int
    if let convertedStartIndexFromLast = Int(components[0]) {
      guard let convertedCharsToReplaceCount = Int(components[1]) else {
        print("Skipping partial alteration \(xmlString): \(components[1]) is not a valid Int.")
        return nil
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

      switch alteration {
      case "A":
        isAdditiveAlteration = true
      case "N":
        isInheritedAlteration = false
      default:
        guard let tenses = Tense.tensesForShorthand(alteration) else {
          print("Skipping partial alteration \(xmlString): unrecognized component \(alteration).")
          return nil
        }
        set.formUnion(tenses)
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
    xmlString
      .components(separatedBy: VerbModelParser.alterationSeparator)
      .compactMap { StemAlteration(xmlString: $0) }
  }
}

nonisolated enum StemAlterationType: Hashable {
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
