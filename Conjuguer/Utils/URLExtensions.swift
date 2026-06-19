//
//  URLExtensions.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/20/21.
//

import Foundation

extension URL {
  var isDeeplink: Bool {
    scheme == URL.deeplinkScheme
  }

  var hasExpectedNumberOfDeeplinkComponents: Bool {
    pathComponents.count == URL.deeplinkComponentCount
  }

  static let deeplinkScheme = "conjuguer"
  static let conjuguerUrlPrefix = deeplinkScheme + "://"
  static let verbHost = "verb"
  static let verbModelHost = "model"
  static let infoHost = "info"
  static let quizHost = "quiz"
  static let randomVerbPath = "random"
  private static let deeplinkComponentCount = 2
}
