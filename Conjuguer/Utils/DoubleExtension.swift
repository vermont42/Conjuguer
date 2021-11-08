//
//  DoubleExtension.swift
//  Conjuguer
//
//  Created by Joshua Adams on 11/7/21.
//

import Foundation

extension Double {
  func asFormattedNumberCorrect(locale: Locale = .current) -> String {
    let formatter = NumberFormatter()
    formatter.locale = locale
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 1
    let number = NSNumber(value: self)
    let formattedValue = formatter.string(from: number) ?? ""
    return formattedValue
  }
}
