//
//  AWSAnalyticsService.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/8/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Amplify
import AWSCognitoAuthPlugin
import AWSPinpointAnalyticsPlugin
import Foundation

class AWSAnalyticsService: NSObject, AnalyticsService {
  var analyticsLocale: AnalyticsLocale {
    RealAnalyticsLocale()
  }

  override init() {
    do {
      try Amplify.add(plugin: AWSCognitoAuthPlugin())
      try Amplify.add(plugin: AWSPinpointAnalyticsPlugin())
      try Amplify.configure()
      print("Amplify configured with Auth and Analytics plugins")
    } catch {
      print("Failed to initialize Amplify with \(error)")
    }
    super.init()
  }

  func recordEvent(_ name: String, properties: [String: String]?) {
    let event = BasicAnalyticsEvent(name: name, properties: properties)
    Amplify.Analytics.record(event: event)
  }
}
