//
//  LiveActivityManager.swift
//  Conjuguer
//

import ActivityKit
import Foundation

enum LiveActivityManager {
  // A force-quit mid-quiz leaves a frozen "in-progress" activity on the Lock Screen
  // until the system cap; a rolling staleDate lets the system mark it stale instead.
  // Refreshed on every update so an actively-answered quiz never reads as stale.
  private static let staleInterval: TimeInterval = 300

  // How long the finished results state lingers on the Lock Screen before the system
  // dismisses it, instead of vanishing the instant the quiz completes.
  private static let finishedLingerInterval: TimeInterval = 8

  // Serial tail so ActivityKit calls apply in submission order: unstructured Tasks
  // carry no ordering guarantee across suspension points, so two rapid answers could
  // otherwise apply out of order and `end` could race a pending `update`.
  private static var activityChain: Task<Void, Never>?

  static func startQuizActivity(
    difficulty: String,
    totalQuestions: Int,
    startDate: Date
  ) -> Activity<QuizActivityAttributes>? {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      return nil
    }

    let attributes = QuizActivityAttributes(difficulty: difficulty, totalQuestions: totalQuestions)
    let initialState = QuizActivityAttributes.ContentState(
      currentQuestion: 1,
      score: 0,
      correctCount: 0,
      startDate: startDate,
      elapsedTime: "0:00",
      isFinished: false
    )
    let content = ActivityContent(state: initialState, staleDate: Date.now.addingTimeInterval(staleInterval))

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
    let content = ActivityContent(state: state, staleDate: Date.now.addingTimeInterval(staleInterval))
    enqueue {
      await activity.update(content)
    }
  }

  static func endQuizActivity(
    _ activity: Activity<QuizActivityAttributes>,
    finalState: QuizActivityAttributes.ContentState
  ) {
    let content = ActivityContent(state: finalState, staleDate: nil)
    let dismissalDate = Date.now.addingTimeInterval(finishedLingerInterval)
    enqueue {
      // Let the finished results state linger briefly instead of dismissing the instant
      // the quiz completes, so the final score is actually visible on the Lock Screen.
      await activity.end(content, dismissalPolicy: .after(dismissalDate))
    }
  }

  static func endAllActivities() {
    enqueue {
      for activity in Activity<QuizActivityAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }

  // Chains work onto the serial tail, so each ActivityKit call awaits the previous one.
  private static func enqueue(_ operation: @escaping @MainActor () async -> Void) {
    let previous = activityChain
    activityChain = Task { @MainActor in
      await previous?.value
      await operation()
    }
  }
}
