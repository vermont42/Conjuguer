//
//  ColorExtension.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/4/21.
//

import SwiftUI

extension Color {
  static let customForeground = Color("customForeground")
  static let customBackground = Color("customBackground")
  static let customSurface = Color("customSurface")
  static let customGray = Color("customGray")
  static let customRed = Color("customRed")
  static let customGreen = Color("customGreen")
  static let customBlue = Color("customBlue")

  // A highlighter's yellow, because the cells it marks already use the palette's blue and red
  // for regular and irregular letters.
  static let markedConjugation = Color.yellow.opacity(0.3)
}
