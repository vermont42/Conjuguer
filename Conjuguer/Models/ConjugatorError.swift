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
  case verbTooShort
  case infinitifEndingInvalid
  case invalidEnding(String)
  case noNousPrésent(String)
  case tenseNotImplemented(Tense)
  case noSuchConjugation(PersonNumber)
  case personNumberAbsent(Tense)
  case defectiveForPersonNumber(PersonNumber)
}
