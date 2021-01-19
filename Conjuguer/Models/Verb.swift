//
//  Verb.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/2/21.
//

import Foundation

struct Verb {
  static var verbs: [String: Verb] = [:]
  static let minVerbLength = 4

  let infinitif: String
  let translation: String
  let model: String
  let auxiliary: Auxiliary

  var infinitifStem: String {
    let length = infinitif.hasSuffix("ire") ? 3 : 2
    let index = infinitif.index(infinitif.endIndex, offsetBy: -1 * length)
    return String(infinitif[..<index])
  }

  static func endingIsValid(infinitif: String) -> Bool {
    let frenchVerbEndingLength = 2
    let validFrenchVerbEndings = ["er", "ir", "re", "ïr"]
    let index = infinitif.index(infinitif.endIndex, offsetBy: -1 * frenchVerbEndingLength)
    let ending = String(infinitif[index...])
    return validFrenchVerbEndings.contains(ending)
  }
}
