//
//  LiveActivityManager.swift
//  Conjuguer
//

import ActivityKit
import Foundation

enum LiveActivityManager {
  static func startQuizActivity(
    difficulty: String,
    totalQuestions: Int
  ) -> Activity<QuizActivityAttributes>? {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      return nil
    }

    let attributes = QuizActivityAttributes(difficulty: difficulty, totalQuestions: totalQuestions)
    let initialState = QuizActivityAttributes.ContentState(
      currentQuestion: 1,
      score: 0,
      correctCount: 0,
      elapsedTime: "0:00",
      isFinished: false
    )
    let content = ActivityContent(state: initialState, staleDate: nil)

    do {
      return try Activity.request(attributes: attributes, content: content, pushType: nil)
    } catch {
      return nil
    }
  }

  static func updateQuizActivity(
    _ activity: Activity<QuizActivityAttributes>,
    state: QuizActivityAttributes.ContentState
  ) {
    let content = ActivityContent(state: state, staleDate: nil)
    Task { @MainActor in
      await activity.update(content)
    }
  }

  static func endQuizActivity(
    _ activity: Activity<QuizActivityAttributes>,
    finalState: QuizActivityAttributes.ContentState
  ) {
    let content = ActivityContent(state: finalState, staleDate: nil)
    Task { @MainActor in
      await activity.end(content, dismissalPolicy: .immediate)
    }
  }

  static func endAllActivities() {
    Task { @MainActor in
      for activity in Activity<QuizActivityAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }
}
