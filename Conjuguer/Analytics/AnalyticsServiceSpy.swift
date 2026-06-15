//
//  AnalyticsServiceSpy.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/25/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Foundation

class AnalyticsServiceSpy: AnalyticsService {
  var analyticsLocale: AnalyticsLocale {
    AnalyticsLocaleStub()
  }

  private var fire: (String) -> Void

  init(fire: @escaping (String) -> Void = { analytic in print(analytic) }) {
    self.fire = fire
  }

  func recordEvent(_ name: String, properties: [String: String]?) {
    var analytic = name
    if let properties = properties {
      analytic += " "
      for (key, value) in properties {
        analytic += key + ": " + value + " "
      }
    }
    fire(analytic)
  }
}
