//
//  DailyStreak.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation

/// The days on which the learner finished a daily session, and how many each day, from which the
/// streak is computed. It is kept on the device beside the practice record and sent only as a
/// band.
///
/// A streak broken by one missed day is repaired by two daily sessions the day after, since a
/// broken streak lowers later engagement unless it can be repaired (Silverman and Barasch 2023).
/// The missed day does not count toward the length, which is the days practiced.
nonisolated struct DailyStreak: Codable, Equatable, Sendable {
  enum Status: Equatable, Sendable {
    /// Nothing finished yesterday or today, and nothing to repair.
    case none
    case active(length: Int, isDoneToday: Bool)
    /// Yesterday was missed. Two sessions today keep `length`, and `sessionsToday` are finished.
    case repairable(length: Int, sessionsToday: Int)

    /// The streak kept, or the one at stake.
    var length: Int {
      switch self {
      case .none:
        return 0
      case let .active(length, _), let .repairable(length, _):
        return length
      }
    }
  }

  static let storageKey = "dailyStreak"
  static let repairSessionCount = 2

  /// Keyed `2026-11-24`, in the learner's calendar.
  private(set) var sessions: [String: Int] = [:]

  init() {}

  var isEmpty: Bool {
    sessions.isEmpty
  }

  /// Days that can no longer change the streak are dropped.
  mutating func recordSession(at date: Date, calendar: Calendar = .current) {
    sessions[Self.dayKey(date, calendar: calendar), default: 0] += 1
    prune(calendar: calendar)
  }

  func status(at date: Date, calendar: Calendar = .current) -> Status {
    let today = Self.dayNumber(date, calendar: calendar)
    let sessionsSoFar = sessions.filter { (Self.dayNumber(key: $0.key, calendar: calendar) ?? .max) <= today }
    let runs = Self.runs(of: sessionsSoFar, calendar: calendar)
    guard let last = runs.last, let lastDay = last.days.last else {
      return .none
    }
    switch today - lastDay {
    case 0:
      // One session on the day after a missed day starts a run of its own, until a second
      // joins it to the run before.
      let countToday = sessions[Self.dayKey(date, calendar: calendar)] ?? 0
      if last.length == 1, countToday < Self.repairSessionCount, runs.count > 1, let previousDay = runs[runs.count - 2].days.last, today - previousDay == 2 {
        return .repairable(length: runs[runs.count - 2].length, sessionsToday: countToday)
      }
      return .active(length: last.length, isDoneToday: true)
    case 1:
      return .active(length: last.length, isDoneToday: false)
    case 2:
      return .repairable(length: last.length, sessionsToday: 0)
    default:
      return .none
    }
  }

  private struct Run {
    var days: [Int]
    var length: Int
  }

  /// Oldest first. A day joins the run before it when it follows that run's last day, or follows a
  /// missed day with two sessions.
  private static func runs(of sessions: [String: Int], calendar: Calendar) -> [Run] {
    let days = sessions
      .compactMap { key, count in
        dayNumber(key: key, calendar: calendar).map { (day: $0, sessionCount: count) }
      }
      .sorted { $0.day < $1.day }
    var runs: [Run] = []
    for entry in days where entry.sessionCount > 0 {
      if var run = runs.last, let lastDay = run.days.last {
        let gap = entry.day - lastDay
        if gap == 1 || (gap == 2 && entry.sessionCount >= repairSessionCount) {
          run.days.append(entry.day)
          run.length += 1
          runs[runs.count - 1] = run
          continue
        }
      }
      runs.append(Run(days: [entry.day], length: 1))
    }
    return runs
  }

  /// Keeps the last two runs, since a run can join only the one just before it.
  private mutating func prune(calendar: Calendar) {
    let runs = Self.runs(of: sessions, calendar: calendar)
    guard runs.count > 2, let firstKept = runs[runs.count - 2].days.first else {
      return
    }
    sessions = sessions.filter { (Self.dayNumber(key: $0.key, calendar: calendar) ?? .min) >= firstKept }
  }

  static func dayKey(_ date: Date, calendar: Calendar = .current) -> String {
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
  }

  /// Counted in the calendar's days, not in hours, so that a day of 23 or 25 hours is one day.
  private static func dayNumber(_ date: Date, calendar: Calendar) -> Int {
    calendar.dateComponents([.day], from: epoch(calendar), to: calendar.startOfDay(for: date)).day ?? 0
  }

  private static func dayNumber(key: String, calendar: Calendar) -> Int? {
    let parts = key.split(separator: "-").compactMap { Int($0) }
    guard parts.count == 3, let date = calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2])) else {
      return nil
    }
    return dayNumber(date, calendar: calendar)
  }

  private static func epoch(_ calendar: Calendar) -> Date {
    calendar.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? Date(timeIntervalSince1970: 946_684_800)
  }
}
