//
//  Alteration.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

// "1,1,ç" = lanc -> lanç
// "0,1,l" = apel -> apell (second number is irrelevant)
// "2,1,eu" = mov -> meuv

struct PartialAlteration {
  let startIndexFromLast: Int
  let charactersToReplaceCount: Int
  let alteredChars: String
  let appliesTo: Set<PersonNumber>
}

struct CompleteAlteration {
  let conjugation: String
  let appliesTo: Set<String>
}
