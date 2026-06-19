//
//  WidgetConstants.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import Foundation

// App-group plumbing shared by the app (producer) and widget extension (consumer):
// a JSON snapshot file in the group container, plus a UserDefaults suite for the
// interactive quiz's answer state and the pending widget/control deeplink.
enum WidgetConstants {
  static let appGroupID = "group.software.racecondition.Conjuguer"
  static let snapshotFilename = "widget-snapshot.json"
  static let quizAnsweredKey = "widgetQuizAnswered"
  static let quizCorrectKey = "widgetQuizCorrect"
  static let quizQuestionIDKey = "widgetQuizQuestionID"
  static let pendingDeeplinkKey = "widgetPendingDeeplink"

  static var sharedContainerURL: URL? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
  }

  static var snapshotURL: URL? {
    sharedContainerURL?.appendingPathComponent(snapshotFilename)
  }

  static var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: appGroupID)
  }
}
