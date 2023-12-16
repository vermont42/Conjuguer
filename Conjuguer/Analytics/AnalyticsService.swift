//
//  AnalyticsService.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import UIKit

protocol AnalyticsService {
  var analyticsLocale: AnalyticsLocale { get }
  func recordEvent(_ name: String, properties: [String: String]?)
  func recordBecameActive()
  func recordViewAppeared(_ viewName: String)
  func recordQuizStart(difficulty: QuizDifficulty)
  func recordQuizQuit(difficulty: QuizDifficulty, lastQuestionIndex: Int, elapsedTime: Int)
  func recordQuizCompletion(difficulty: QuizDifficulty, elapsedTime: Int, score: Int)
  func recordGameCenterAuthSucceeded()
  func recordGameCenterAuthFailed()
}

extension AnalyticsService {
  func recordEvent(_ name: String) {
    recordEvent(name, properties: nil)
  }

  func recordBecameActive() {
    let becameActiveName = "becameActive"
    let modelKey = "model"
    let localeKey = "locale"

    let modelName = UIDevice.current.modelName
    let locale = analyticsLocale.locale

    recordEvent(becameActiveName, properties: [modelKey: modelName, localeKey: locale])
  }

  func recordViewAppeared(_ viewName: String) {
    let viewAppearedName = "viewAppeared"
    let viewNameKey = "viewName"
    recordEvent(viewAppearedName, properties: [viewNameKey: viewName])
  }

  var difficultyKey: String {
    "difficulty"
  }

  func recordQuizStart(difficulty: QuizDifficulty) {
    let quizStartName = "quizStart"
    recordEvent(quizStartName, properties: [difficultyKey: difficulty.rawValue])
  }

  var elapsedTimeKey: String {
    "elapsedTime"
  }

  func recordQuizQuit(difficulty: QuizDifficulty, lastQuestionIndex: Int, elapsedTime: Int) {
    let quizQuitName = "quizQuit"
    let lastQuestionIndexKey = "lastQuestionIndex"
    recordEvent(quizQuitName, properties: [difficultyKey: difficulty.rawValue, lastQuestionIndexKey: "\(lastQuestionIndex)", elapsedTimeKey: "\(elapsedTime)"])
  }

  var scoreKey: String {
    "score"
  }

  func recordQuizCompletion(difficulty: QuizDifficulty, elapsedTime: Int, score: Int) {
    let quizCompletionName = "quizCompletion"
    recordEvent(quizCompletionName, properties: [difficultyKey: difficulty.rawValue, scoreKey: "\(score)", elapsedTimeKey: "\(elapsedTime)"])
  }

  func recordGameCenterAuthSucceeded() {
    let gameCenterAuthSucceededName = "gameCenterAuthSucceeded"
    recordEvent(gameCenterAuthSucceededName)
  }

  func recordGameCenterAuthFailed() {
    let gameCenterAuthFailedName = "gameCenterAuthFailed"
    recordEvent(gameCenterAuthFailedName)
  }
}
