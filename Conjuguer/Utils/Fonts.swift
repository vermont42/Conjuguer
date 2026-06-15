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

// `relativeTo:` keeps the base sizes unchanged but scales each font on the matching Dynamic Type
// curve (e.g. headings on .title rather than the default .body curve).
let bodyFont = Font.custom(workSansRegular, size: 20.0, relativeTo: .body)
// Bold counterpart to bodyFont at matching metrics, for inline `~bold~` runs (e.g. etymologies).
let bodyBoldFont = Font.custom(workSansSemiBold, size: 20.0, relativeTo: .body)
let headingFont = Font.custom(workSansSemiBold, size: 24.0, relativeTo: .title)
let subheadingFont = Font.custom(workSansSemiBold, size: 18.0, relativeTo: .title3)
let boldBodyFont = Font.custom(workSansSemiBold, size: 16.0, relativeTo: .callout)

enum Fonts {
  static let heading = UIFont(name: workSansSemiBold, size: 24.0) ?? safeFont
  static let subheading = UIFont(name: workSansSemiBold, size: 18.0) ?? safeFont
  static let body = UIFont(name: workSansRegular, size: 16.0) ?? safeFont
  static let boldBody = UIFont(name: workSansSemiBold, size: 16.0) ?? safeFont
  private static let safeFont = UIFont.systemFont(ofSize: 18.0)
}
