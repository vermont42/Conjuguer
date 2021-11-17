//
//  StubAnalyticsLocale.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/15/20.
//  Copyright © 2020 Josh Adams. All rights reserved.
//

import Foundation

struct StubAnalyticsLocale: AnalyticsLocale {
  var languageCode: String
  var regionCode: String
  private static let english = "en"
  private static let america = "US"

  init(languageCode: String = StubAnalyticsLocale.english, regionCode: String = StubAnalyticsLocale.america) {
    self.languageCode = languageCode
    self.regionCode = regionCode
  }
}
