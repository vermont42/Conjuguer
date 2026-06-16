//
//  ConditionnelPresent.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/11/21.
//

import Foundation

enum ConditionnelPrésent {
  static func endingForPersonNumber(_ personNumber: PersonNumber) -> String {
    Imparfait.endingForPersonNumber(personNumber)
  }
}
