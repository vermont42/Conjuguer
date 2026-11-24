//
//  ReminderSchedulerSpy.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation

final class ReminderSchedulerSpy: ReminderScheduler {
  var grantsAuthorization = true
  private(set) var authorizationRequestCount = 0
  /// Each call's reminders, the last being what is scheduled now.
  private(set) var schedules: [[ScheduledReminder]] = []

  var scheduled: [ScheduledReminder] {
    schedules.last ?? []
  }

  func requestAuthorization() async -> Bool {
    authorizationRequestCount += 1
    return grantsAuthorization
  }

  func isAuthorized() async -> Bool {
    grantsAuthorization
  }

  func schedule(_ reminders: [ScheduledReminder]) {
    schedules.append(reminders)
  }
}
