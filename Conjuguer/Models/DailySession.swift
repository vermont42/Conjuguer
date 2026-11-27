//
//  DailySession.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation

extension QuizScope {
  /// Ten questions at the learner's level, filled first with the due items the level asks and then
  /// with the default quiz's draw, but no choice question, since a choice moves nothing in the
  /// record. Never ranked and never continued: a second session is a session of its own, which a
  /// repair counts.
  static func daily(source: AnalyticsSource = .daily) -> QuizScope {
    QuizScope(verbs: nil, questionCount: Quiz.questionCount, source: source, kind: .daily)
  }
}

/// A request, from the reminder, that the Quiz tab start a daily session.
struct DailySessionRequest: Equatable {
  let id = UUID()
  let source: AnalyticsSource
}

extension DailyStreak.Status {
  var hubDetail: String {
    switch self {
    case .none:
      return L.DailySession.description
    case let .active(length, isDoneToday):
      return isDoneToday ? L.DailySession.streakDoneToday(length) : L.DailySession.streakKeepGoing(length)
    case let .repairable(length, sessionsToday):
      return sessionsToday == 0 ? L.DailySession.repairTwo(length) : L.DailySession.repairOne(length)
    }
  }

  var resultsLine: String? {
    switch self {
    case .none:
      return nil
    case let .active(length, _):
      return L.DailySession.streak(length)
    case let .repairable(length, sessionsToday):
      return sessionsToday == 0 ? L.DailySession.repairTwo(length) : L.DailySession.repairOne(length)
    }
  }

  /// Whether one more session today would keep the streak, which the results offer.
  var awaitsRepairSession: Bool {
    if case let .repairable(_, sessionsToday) = self {
      return sessionsToday > 0
    }
    return false
  }
}
