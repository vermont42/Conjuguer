//
//  Verb.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

struct Verb {
  static var verbs: [String: Verb] = [:]

  let infinitive: String
  let translation: String
  let model: String
  let auxiliary: Auxiliary
}
