//
//  ConjugationText.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/11/21.
//

import SwiftUI

extension AttributedString {
  // Builds a colored attributed string from a mixed-case conjugation: lowercase letters and
  // non-letters are "regular" (blue), uppercase letters are "irregular" (red). The output is
  // normalized to lowercase. Color building is the expensive, character-by-character work that
  // VerbConjugations precomputes off `body`.
  init(mixedCaseString: String) {
    enum ColorParsingState {
      case notStarted
      case inRegularPart
      case inIrregularPart
    }

    var state = ColorParsingState.notStarted
    var currentRegularPart = ""
    var currentIrregularPart = ""
    var attributedString = AttributedString()

    func appendRegular() {
      var part = AttributedString(currentRegularPart)
      part.foregroundColor = Color.customBlue
      attributedString += part
    }

    func appendIrregular() {
      var part = AttributedString(currentIrregularPart)
      part.foregroundColor = Color.customRed
      attributedString += part
    }

    for char in mixedCaseString {
      let isRegular = char.isLowercase || !char.isLetter
      let canonicalChar = char.lowercased()
      switch state {
      case .notStarted:
        if isRegular {
          currentRegularPart = canonicalChar
          state = .inRegularPart
        } else {
          currentIrregularPart = canonicalChar
          state = .inIrregularPart
        }
      case .inRegularPart:
        if isRegular {
          currentRegularPart += canonicalChar
        } else {
          appendRegular()
          currentRegularPart = ""
          currentIrregularPart = canonicalChar
          state = .inIrregularPart
        }
      case .inIrregularPart:
        if isRegular {
          appendIrregular()
          currentRegularPart = canonicalChar
          currentIrregularPart = ""
          state = .inRegularPart
        } else {
          currentIrregularPart += canonicalChar
        }
      }
    }

    appendRegular()
    appendIrregular()

    self = attributedString
  }
}

extension Text {
  init(mixedCaseString: String) {
    self.init(AttributedString(mixedCaseString: mixedCaseString))
  }
}
