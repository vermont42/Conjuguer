//
//  URLExtensions.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/20/21.
//

import Foundation

extension URL {
  var isDeeplink: Bool {
    scheme == "conjuguer"
  }

  var hasExpectedNumberOfDeeplinkComponents: Bool {
    pathComponents.count == 2
  }

  static let conjuguerUrlPrefix = "conjuguer://"
  static let verbHost = "verb"
  static let verbModelHost = "model"
  static let infoHost = "info"
}
