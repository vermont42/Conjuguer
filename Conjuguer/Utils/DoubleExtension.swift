//
//  DoubleExtension.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/7/21.
//

import Foundation

extension Double {
  // Reuse one formatter rather than allocating per call; its locale is set each time so the
  // caller-supplied locale (defaulting to .current) is still honored.
  private static let numberCorrectFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 1
    return formatter
  }()

  func asFormattedNumberCorrect(locale: Locale = .current) -> String {
    let formatter = Double.numberCorrectFormatter
    formatter.locale = locale
    return formatter.string(from: NSNumber(value: self)) ?? ""
  }
}
