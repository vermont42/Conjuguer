//
//  ReminderScheduler.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation

protocol ReminderScheduler {
  /// The system asks the learner only once. False when permission was refused, now or before.
  func requestAuthorization() async -> Bool
  /// The learner can turn notifications off in the Settings app while the reminder is on.
  func isAuthorized() async -> Bool
  /// Replaces every scheduled reminder with these.
  func schedule(_ reminders: [ScheduledReminder])
}
