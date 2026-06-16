//
//  EndingDisplay.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/15/26.
//

import Foundation

nonisolated enum EndingDisplay {
  static func markedEndings(
    personNumbers: [PersonNumber],
    tense: (PersonNumber) -> Tense,
    ending: (PersonNumber) -> String,
    stemAlterations: [StemAlteration]?
  ) -> [PersonNumber: String] {
    var result: [PersonNumber: String] = [:]
    for personNumber in personNumbers {
      let isStarred = stemAlterations?.contains { alteration in
        alteration.charsToUse.hasSuffix(Tense.irregularEndingMarker) && alteration.appliesTo.contains(tense(personNumber))
      } ?? false
      result[personNumber] = isStarred ? Tense.irregularEndingMarker : ending(personNumber)
    }
    return result
  }
}
