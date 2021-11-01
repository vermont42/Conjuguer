//
//  Verb.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/2/21.
//

import Foundation

struct Verb: Identifiable, Hashable {
  static var verbs: [String: Verb] = [:]
  static let minVerbLength = 4

  let id = UUID()
  let infinitif: String
  let translation: String
  let model: String
  let auxiliary: Auxiliary
  let isReflexive: Bool
  let hasAspiratedH: Bool
  var frequency: Int?
  let extraLetters: String?
  let example: String?
  let source: String?
  let defectGroupId: String?

  var infinitifStem: String {
    let endingLength: Int
    if infinitif.hasSuffix("oir") {
      endingLength = 3
    } else if infinitif != "fiche" {
      endingLength = 2
    } else {
      endingLength = 1
    }
    let index = infinitif.index(infinitif.endIndex, offsetBy: -1 * endingLength)
    return String(infinitif[..<index])
  }

  var infinitifWithPossibleExtraLetters: String {
    if let extraLetters = extraLetters {
      return infinitif + " (" + extraLetters + ")"
    } else {
      return infinitif
    }
  }

  static func endingIsValid(infinitif: String) -> Bool {
    let frenchVerbEndingLength = 2
    let validFrenchVerbEndings = ["er", "ir", "re", "ïr"]
    let index = infinitif.index(infinitif.endIndex, offsetBy: -1 * frenchVerbEndingLength)
    let ending = String(infinitif[index...])
    return validFrenchVerbEndings.contains(ending) || infinitif == "fiche"
  }

  static func verbForInfinitif(_ infinitif: String) -> Verb {
    if let verb = verbs[infinitif] {
      return verb
    } else {
      fatalError("Could not retrieve verb for \(infinitif).")
    }
  }
}
