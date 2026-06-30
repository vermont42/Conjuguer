//
//  Analytics.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

enum ParameterKey: String {
  case viewName
  case difficulty
  case lastQuestionIndex
  case elapsedTime
  case score
}

enum AnalyticsName: String {
  case viewAppeared
  case quizStart
  case quizQuit
  case quizCompletion
  case gameCenterAuthSucceeded
  case gameCenterAuthFailed
  case tapPlayGame
  case tapShowOnboarding
}

protocol Analytics {
  func initialize(appID: String)
  func signal(name: AnalyticsName, parameters: [String: String])
}

extension Analytics {
  func signal(name: AnalyticsName) {
    signal(name: name, parameters: [:])
  }
}
