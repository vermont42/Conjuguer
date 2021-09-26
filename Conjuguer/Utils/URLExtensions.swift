//
//  URLExtensions.swift
//  Conjuguer
//
//  Created by Joshua Adams on 9/20/21.
//

import Foundation

extension URL {
  var isDeeplink: Bool {
    scheme == "conjuguer"
  }

  var hasExpectedNumberOfDeeplinkComponents: Bool {
    pathComponents.count == 2
  }

//  var tabIdentifier: TabIdentifier? {
//    guard isDeeplink else {
//      return nil
//    }
//
//    switch host {
//    case "verb":
//      return .verbs
//    case "model":
//      return .models
//    case "info":
//      return .info
//    default:
//      return nil
//    }
//  }

  static let conjuguerUrlPrefix = "conjuguer://"
  static let verbHost = "verb"
  static let verbModelHost = "model"
  static let infoHost = "info"
}
