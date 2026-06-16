//
//  DoubleExtension.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/7/21.
//

import Foundation

extension Double {
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
