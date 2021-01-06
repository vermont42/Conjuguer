//
//  Alteration.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

struct PartialAlteration {
  let startIndexFromLast: Int
  let endIndexFromLast: Int
  let alteredChars: String
  let appliesTo: Set<String>
}

struct CompleteAlteration {
  let conjugation: String
  let appliesTo: Set<String>
}
