//
//  ReminderNotificationDelegate.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation
import UIKit
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
    // The window the reminder was tapped toward, which UIKit gives only on the main actor. The
    // response is immutable, so carrying it there is safe though it is not marked Sendable.
    nonisolated(unsafe) let response = response
    await MainActor.run {
      SceneRouter.deliver(url, to: response.targetScene)
    }
  }

  nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    []
  }
}
