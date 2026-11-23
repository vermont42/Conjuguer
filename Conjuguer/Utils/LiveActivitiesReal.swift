//
//  LiveActivitiesReal.swift
//  Conjuguer
//

import ActivityKit
import Foundation

final class LiveActivitiesReal: LiveActivities {
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
  private var activityChain: Task<Void, Never>?

  func start(attributes: QuizActivityAttributes, initialState: QuizActivityAttributes.ContentState) -> LiveActivity? {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      return nil
    }

    let content = ActivityContent(state: initialState, staleDate: Date.now.addingTimeInterval(Self.staleInterval))

    do {
      let activity = try Activity.request(attributes: attributes, content: content, pushType: nil)
      return LiveActivity(id: activity.id, activity: activity)
    } catch {
      return nil
    }
  }

  func update(_ liveActivity: LiveActivity, state: QuizActivityAttributes.ContentState) {
    guard let activity = liveActivity.activity else {
      return
    }
    let content = ActivityContent(state: state, staleDate: Date.now.addingTimeInterval(Self.staleInterval))
    enqueue {
      await activity.update(content)
    }
  }

  func end(_ liveActivity: LiveActivity, finalState: QuizActivityAttributes.ContentState) {
    guard let activity = liveActivity.activity else {
      return
    }
    let content = ActivityContent(state: finalState, staleDate: nil)
    let dismissalDate = Date.now.addingTimeInterval(Self.finishedLingerInterval)
    enqueue {
      // Let the finished results state linger briefly instead of dismissing the instant
      // the quiz completes, so the final score is actually visible on the Lock Screen.
      await activity.end(content, dismissalPolicy: .after(dismissalDate))
    }
  }

  func endAll() {
    enqueue {
      for activity in Activity<QuizActivityAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }

  // Chains work onto the serial tail, so each ActivityKit call awaits the previous one.
  private func enqueue(_ operation: @escaping @MainActor () async -> Void) {
    let previous = activityChain
    activityChain = Task { @MainActor in
      await previous?.value
      await operation()
    }
  }
}
