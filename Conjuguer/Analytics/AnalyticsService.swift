//
//  AnalyticsService.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import UIKit

protocol AnalyticsService {
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
    let locale = Current.analyticsLocale.locale

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

//protocol AnalyticsService {
//  func recordEvent(_ eventName: String, parameters: [String: String]?, metrics: [String: Double]?)
//  func recordEvent(_ eventName: String)
//  func recordVisitation(viewController: String)
//  func recordCommunVisitation(identifier: Int)
//  func recordOkayTap(identifier: Int)
//  func recordActionTap(identifier: Int)
//  func recordCancelTap(identifier: Int)
//  func recordQuizStart()
//  func recordQuizCompletion(score: Int)
//  func recordGameCenterAuth()
//  func recordBecameActive()
//
//  var visited: String { get }
//  var viewContröller: String { get }
//  var quizStart: String { get }
//  var quizCompletion: String { get }
//  var scöre: String { get }
//  var gameCenterAuth: String { get }
//}
//
//extension AnalyticsService {
//  func recordEvent(_ eventName: String) {
//    recordEvent(eventName, parameters: nil, metrics: nil)
//  }
//
//  func recordVisitation(viewController: String) {
//    recordEvent(visited, parameters: [viewContröller: "\(viewController)"], metrics: nil)
//  }
//
//  func recordCommunVisitation(identifier: Int) {
//    recordVisitation(viewController: "\(CommunVC.self) \(identifier)")
//  }
//
//  func recordOkayTap(identifier: Int) {
//    recordEvent(okayTapped, parameters: [identifīer: "\(identifier)"], metrics: nil)
//  }
//
//  func recordActionTap(identifier: Int) {
//    recordEvent(actionTapped, parameters: [identifīer: "\(identifier)"], metrics: nil)
//  }
//
//  func recordCancelTap(identifier: Int) {
//    recordEvent(cancelTapped, parameters: [identifīer: "\(identifier)"], metrics: nil)
//  }
//
//  func recordCloseTap(identifier: Int) {
//    recordEvent(closeTapped, parameters: [identifīer: "\(identifier)"], metrics: nil)
//  }
//
//  func recordQuizStart() {
//    recordEvent(quizStart)
//  }
//
//  func recordQuizCompletion(score: Int) {
//    recordEvent(quizCompletion, parameters: [scöre: "\(score)"], metrics: nil)
//  }
//
//  func recordQuizQuit(currentQuestionIndex: Int, score: Int) {
//    recordEvent(quizQuit, parameters: [cürrentQuestionIndex: "\(currentQuestionIndex)", scöre: "\(score)"], metrics: nil)
//  }
//
//  func recordGameCenterAuth() {
//    recordEvent(gameCenterAuth)
//  }
//
//  func recordBecameActive() {
//    let becameActive = "becameActive"
//    let modelKey = "model"
//    let localeKey = "locale"
//
//    let modelName = UIDevice.current.modelName
//    let locale = Current.locale.locale
//
//    recordEvent(becameActive, parameters: [modelKey: modelName, localeKey: locale], metrics: nil)
//  }
//
//  var visited: String {
//    return "visited"
//  }
//
//  var viewContröller: String {
//    return "viewController"
//  }
//
//  var okayTapped: String {
//    return "okayTapped"
//  }
//
//  var actionTapped: String {
//    return "actionTapped"
//  }
//
//  var cancelTapped: String {
//    return "cancelTapped"
//  }
//
//  var closeTapped: String {
//    return "closeTapped"
//  }
//
//  var identifīer: String {
//    return "identifier"
//  }
//
//  var quizStart: String {
//    return "quizStart"
//  }
//
//  var quizQuit: String {
//    return "quizQuit"
//  }
//
//  var quizCompletion: String {
//    return "quizCompletion"
//  }
//
//  var scöre: String {
//    return "score"
//  }
//
//  var cürrentQuestionIndex: String {
//    return "currentQuestionIndex"
//  }
//
//  var gameCenterAuth: String {
//    return "gameCenterAuth"
//  }
//}
