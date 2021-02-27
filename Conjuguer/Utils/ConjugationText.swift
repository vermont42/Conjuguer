//
//  ConjugationText.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/11/21.
//

import SwiftUI

extension Text {
  init(mixedCaseString: String) {
    self.init("")

    enum ColorParsingState {
      case notStarted
      case inRegularPart
      case inIrregularPart
    }

    var state = ColorParsingState.notStarted
    var currentRegularPart = ""
    var currentIrregularPart = ""

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
          self = self + Text(currentRegularPart).foregroundColor(.blue)
          currentRegularPart = ""
          currentIrregularPart = canonicalChar
          state = .inIrregularPart
        }
      case .inIrregularPart:
        if isRegular {
          self = self + Text(currentIrregularPart).foregroundColor(.red)
          currentRegularPart = canonicalChar
          currentIrregularPart = ""
          state = .inRegularPart
        } else {
          currentIrregularPart += canonicalChar
        }
      }
    }

    self = self + Text(currentRegularPart).foregroundColor(.blue)
    self = self + Text(currentIrregularPart).foregroundColor(.red)
  }
}
