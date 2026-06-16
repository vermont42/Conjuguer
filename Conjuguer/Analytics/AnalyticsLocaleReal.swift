//
//  AnalyticsLocaleReal.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/15/20.
//  Copyright © 2020 Josh Adams. All rights reserved.
//

import Foundation

struct AnalyticsLocaleReal: AnalyticsLocale {
  private static let unknown = "none"

  var languageCode: String {
    NSLocale.current.language.languageCode?.identifier ?? Self.unknown
  }

  var regionCode: String {
    NSLocale.current.region?.identifier ?? Self.unknown
  }
}
