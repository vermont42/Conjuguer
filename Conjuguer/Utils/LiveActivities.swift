//
//  LiveActivities.swift
//  Conjuguer
//

import ActivityKit

/// A started quiz Live Activity. `LiveActivitiesReal` wraps the system's `Activity`, which nothing
/// outside ActivityKit can make, so `LiveActivitiesSpy`'s handles wrap none.
struct LiveActivity {
  let id: String
  let activity: Activity<QuizActivityAttributes>?
}

/// Starts, updates, and ends the quiz's Live Activity. `LiveActivitiesReal` uses ActivityKit, and
/// `LiveActivitiesSpy` records under unit tests, whose quizzes would otherwise request real
/// activities until the system refuses them (`targetMaximumExceeded`) partway through a run.
protocol LiveActivities {
  /// Nil when the learner has turned Live Activities off, or the system refuses one.
  func start(attributes: QuizActivityAttributes, initialState: QuizActivityAttributes.ContentState) -> LiveActivity?
  func update(_ liveActivity: LiveActivity, state: QuizActivityAttributes.ContentState)
  func end(_ liveActivity: LiveActivity, finalState: QuizActivityAttributes.ContentState)
  /// Ends every quiz activity, which a launch does, since none survives its quiz.
  func endAll()
}
