//
//  ConjugatorError.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

enum ConjugatorError: Error {
  case verbModelNotRecognized
  case verbNotRecognized
  case tooShort
  case invalidEnding(String)
  case tenseNotImplemented(Tense)
  case noSuchConjugation(PersonNumber)
  case personNumberAbsent(Tense)
  case defectiveForPersonNumber(PersonNumber)
}
