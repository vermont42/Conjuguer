//
//  QuizActivityAttributes.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import ActivityKit
import Foundation

// Live Activity payload for an in-progress quiz (Lock Screen + Dynamic Island).
nonisolated struct QuizActivityAttributes: ActivityAttributes {
  let level: String

  struct ContentState: Codable, Hashable, Sendable {
    let currentQuestion: Int
    // In the state, not the attributes, since a re-ask lengthens the round while it runs. It
    // counts the session so far, so the second round of ten reads 11/20.
    let totalQuestions: Int
    let score: Int
    let correctCount: Int
    // The instant the quiz timer started, so the Lock Screen / Dynamic Island can render
    // `Text(_, style: .timer)` and let the OS animate the elapsed time between updates
    // instead of freezing on a String pushed per answer. Nil while the quiz clock is hidden.
    let startDate: Date?
    // The frozen final elapsed time, shown once the quiz is finished (the live timer would
    // otherwise keep counting up after completion). Nil while the quiz clock is hidden.
    let elapsedTime: String?
    let isFinished: Bool
  }
}
