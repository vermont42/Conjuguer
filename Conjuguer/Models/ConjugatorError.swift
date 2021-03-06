//
//  ConjugatorError.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/2/21.
//

import Foundation

enum ConjugatorError: Error {
  case verbModelNotRecognized
  case verbNotRecognized
  case verbTooShort
  case infinitifEndingInvalid
  case defectiveForPersonNumber(PersonNumber)
}
