//
//  LiveActivitiesSpy.swift
//  Conjuguer
//

import Foundation

final class LiveActivitiesSpy: LiveActivities {
  /// The activities started and not yet ended, by ID.
  private(set) var activeIDs: Set<String> = []
  private(set) var startCount = 0
  private(set) var updateCount = 0
  private(set) var endCount = 0
  private(set) var endAllCount = 0
  private(set) var lastState: QuizActivityAttributes.ContentState?

  func start(attributes: QuizActivityAttributes, initialState: QuizActivityAttributes.ContentState) -> LiveActivity? {
    startCount += 1
    lastState = initialState
    let id = UUID().uuidString
    activeIDs.insert(id)
    return LiveActivity(id: id, activity: nil)
  }

  func update(_ liveActivity: LiveActivity, state: QuizActivityAttributes.ContentState) {
    updateCount += 1
    lastState = state
  }

  func end(_ liveActivity: LiveActivity, finalState: QuizActivityAttributes.ContentState) {
    endCount += 1
    lastState = finalState
    activeIDs.remove(liveActivity.id)
  }

  func endAll() {
    endAllCount += 1
    activeIDs.removeAll()
  }
}
