//
//  AnalyticsLocale.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/15/20.
//  Copyright © 2020 Josh Adams. All rights reserved.
//

import Foundation

protocol AnalyticsLocale {
  var locale: String { get }
  var languageCode: String { get }
  var regionCode: String { get }
}

extension AnalyticsLocale {
  var locale: String {
    languageCode + regionCode
  }
}
