//
//  Verb.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

struct Verb {
  static var verbs: [String: Verb] = [:]
  static let minVerbLength = 4

  let infinitive: String
  let translation: String
  let model: String
  let auxiliary: Auxiliary

  var infinitiveStem: String {
    let index = infinitive.index(infinitive.endIndex, offsetBy: -1 * 2)
    return String(infinitive[..<index])
  }

  static func endingIsValid(infinitive: String) -> Bool {
    let frenchVerbEndingLength = 2
    let validFrenchVerbEndings = ["er", "ir", "re", "ïr"]
    let index = infinitive.index(infinitive.endIndex, offsetBy: -1 * frenchVerbEndingLength)
    let ending = String(infinitive[index...])
    return validFrenchVerbEndings.contains(ending)
  }
}
