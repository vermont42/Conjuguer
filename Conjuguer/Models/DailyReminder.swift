//
//  DailyReminder.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation

/// Off by default: notification permission is asked for only when the learner turns it on.
enum DailyReminder: String, CaseIterable {
  case off
  case on

  var localizedDailyReminder: String {
    switch self {
    case .off:
      return L.DailyReminder.off
    case .on:
      return L.DailyReminder.on
    }
  }
}

/// Fully worded, since a local notification's text is fixed when it is scheduled.
struct ScheduledReminder: Equatable {
  let identifier: String
  let date: Date
  let title: String
  let body: String
}

/// Each day's reminder is its own notification rather than one that repeats, so that each can say
/// what that day will have due and whether its streak needs repair, and so that a day whose
/// session is done gets none.
enum DailyReminderPlan {
  static let identifierPrefix = "dailyReminder."
  /// A learner who does not open the app for two weeks stops being reminded.
  static let dayCount = 14
  /// 18:00, in minutes after midnight.
  static let defaultMinutes = 18 * 60

  /// The reminders from `now` on, at `minutes` after midnight of each day, as the record and the
  /// streak would stand then were nothing more practiced. Today's is left out once its time has
  /// passed or its session is done.
  static func reminders(record: PracticeRecord, streak: DailyStreak, minutes: Int, now: Date, calendar: Calendar = .current) -> [ScheduledReminder] {
    let today = calendar.startOfDay(for: now)
    return (0 ..< dayCount).compactMap { offset in
      guard
        let day = calendar.date(byAdding: .day, value: offset, to: today),
        let date = calendar.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: day),
        date > now
      else {
        return nil
      }
      let status = streak.status(at: date, calendar: calendar)
      if case .active(_, isDoneToday: true) = status {
        return nil
      }
      return ScheduledReminder(
        identifier: identifierPrefix + DailyStreak.dayKey(date, calendar: calendar),
        date: date,
        title: L.DailyReminder.title,
        body: body(status: status, dueCount: record.dueItems(at: date).filter(\.isAskable).count)
      )
    }
  }

  private static func body(status: DailyStreak.Status, dueCount: Int) -> String {
    if case .repairable = status {
      return status.hubDetail
    }
    return dueCount > 0 ? L.DailyReminder.bodyDue(dueCount) : L.DailyReminder.body
  }
}

extension World {
  /// Called when the reminder's setting changes, when a daily session finishes, when the practice
  /// record is reset, and as the app comes and goes, since what is due and the day itself have
  /// moved. Before the verbs load, nothing could be counted as askable, so the reminders already
  /// scheduled stay.
  func rescheduleReminders(now: Date = .now) {
    guard settings.dailyReminder == .on else {
      reminderScheduler.schedule([])
      return
    }
    guard !Verb.verbs.isEmpty else {
      return
    }
    reminderScheduler.schedule(DailyReminderPlan.reminders(record: practice.record, streak: practice.dailyStreak, minutes: settings.dailyReminderMinutes, now: now))
  }
}
