//
//  Fonts.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/8/21.
//

import SwiftUI
import UIKit

let workSansRegular = "WorkSans-Regular"
let workSansSemiBold = "WorkSans-SemiBold"

let bodyFont = Font.custom(workSansRegular, size: 20.0)
let headingFont = Font.custom(workSansSemiBold, size: 24.0)
let subheadingFont = Font.custom(workSansSemiBold, size: 18.0)
let boldBodyFont = Font.custom(workSansSemiBold, size: 16.0)

func displayFontFamilyNames() {
  for family: String in UIFont.familyNames {
    print("\(family)")
    for names: String in UIFont.fontNames(forFamilyName: family) {
      print("== \(names)")
    }
  }
}

enum Fonts {
  static let heading = UIFont(name: workSansSemiBold, size: 24.0) ?? safeFont
  static let subheading = UIFont(name: workSansSemiBold, size: 18.0) ?? safeFont
  static let body = UIFont(name: workSansRegular, size: 16.0) ?? safeFont
  static let boldBody = UIFont(name: workSansSemiBold, size: 16.0) ?? safeFont
  private static let safeFont = UIFont.systemFont(ofSize: 18.0)
}
