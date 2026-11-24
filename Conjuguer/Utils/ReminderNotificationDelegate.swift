//
//  ReminderNotificationDelegate.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation
import UserNotifications

/// Opens a tapped reminder's link. A reminder due while the app is open shows nothing, since the
/// hub already offers the session.
final class ReminderNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
  static let shared = ReminderNotificationDelegate()

  nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    guard
      let link = response.notification.request.content.userInfo[ReminderSchedulerReal.deeplinkKey] as? String,
      let url = URL(string: link)
    else {
      return
    }
    await MainActor.run {
      Current.handleURL(url)
    }
  }

  nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    []
  }
}
