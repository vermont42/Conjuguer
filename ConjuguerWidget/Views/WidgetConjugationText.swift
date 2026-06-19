//
//  WidgetConjugationText.swift
//  ConjuguerWidget
//
//  Renders a mixed-case conjugation (uppercase letters mark irregular stem letters) the
//  same way the app does: regular letters blue, irregular letters red, all lowercased.
//  Colors mirror the app's customBlue / customRed assets (light + dark variants).
//

import SwiftUI
import UIKit

private func dynamicColor(
  light: (red: Double, green: Double, blue: Double),
  dark: (red: Double, green: Double, blue: Double)
) -> Color {
  Color(uiColor: UIColor { traits in
    let component = traits.userInterfaceStyle == .dark ? dark : light
    return UIColor(red: component.red, green: component.green, blue: component.blue, alpha: 1)
  })
}

private let widgetRegularColor = dynamicColor(
  light: (0x30 / 255, 0x4D / 255, 0x6D / 255),
  dark: (0x7F / 255, 0xA2 / 255, 0xC7 / 255)
)

private let widgetIrregularColor = dynamicColor(
  light: (0xED / 255, 0x25 / 255, 0x4E / 255),
  dark: (0xF3 / 255, 0x68 / 255, 0x84 / 255)
)

extension Text {
  init(mixedCase mixedCaseString: String) {
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
      part.foregroundColor = widgetRegularColor
      attributedString += part
    }

    func appendIrregular() {
      var part = AttributedString(currentIrregularPart)
      part.foregroundColor = widgetIrregularColor
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

    self.init(attributedString)
  }
}
