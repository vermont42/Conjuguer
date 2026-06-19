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
  let difficulty: String
  let totalQuestions: Int

  struct ContentState: Codable, Hashable, Sendable {
    let currentQuestion: Int
    let score: Int
    let correctCount: Int
    let elapsedTime: String
    let isFinished: Bool
  }
}
