//
//  AWSAnalyticsService.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/8/18.
//  Copyright © 2018 Joshua Adams. All rights reserved.
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

//import AWSPinpoint
//import Foundation
//
//class AWSAnalyticsService: NSObject, AnalyticsService {
//  var pinpoint: AWSPinpoint
//
//  override init() {
//    let config = AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: nil)
//    pinpoint = AWSPinpoint(configuration: config)
//    super.init()
//    recordCustomProfileDemographics()
////    AWSDDLog.sharedInstance.logLevel = .verbose
////    AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
//  }
//
//  func recordEvent(_ eventName: String, parameters: [String: String]? = nil, metrics: [String: Double]? = nil) {
//    let event = pinpoint.analyticsClient.createEvent(withEventType: eventName)
//    if let parameters = parameters {
//      for (key, value) in parameters {
//        event.addAttribute(value, forKey: key)
//      }
//    }
//    if let metrics = metrics {
//      for (key, value) in metrics {
//        event.addMetric(NSNumber(value: value), forKey: key)
//      }
//    }
//    pinpoint.analyticsClient.record(event)
//    pinpoint.analyticsClient.submitEvents()
//  }
//
//  private func recordCustomProfileDemographics() {
//    let profile: AWSPinpointEndpointProfile = (pinpoint.targetingClient.currentEndpointProfile())
//    profile.demographic?.model = UIDevice.current.modelName
//    profile.demographic?.platformVersion = UIDevice.current.systemVersion
//    pinpoint.targetingClient.update(profile)
//  }
//}
