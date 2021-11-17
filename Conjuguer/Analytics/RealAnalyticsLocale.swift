//
//  RealAnalyticsLocale.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/15/20.
//  Copyright © 2020 Josh Adams. All rights reserved.
//

import Foundation

struct RealAnalyticsLocale: AnalyticsLocale {
  private let none = "none"
  private let NONE = "NONE"

  var languageCode: String {
    NSLocale.current.languageCode ?? none
  }

  var regionCode: String {
    NSLocale.current.regionCode ?? NONE
  }
}
