//
//  OpenQuizIntent.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import AppIntents

/// The Quick Quiz control's action.
struct OpenQuizIntent: PendingDeeplinkIntent {
  // AppIntents requires a literal / initializer call here, so it can't use WidgetL. The
  // defaultValue gives a graceful English fallback when resolved in the app bundle (which
  // lacks the widget's catalog); the French translation lives in the widget catalog.
  static let title = LocalizedStringResource("Widget.intentOpenQuiz", defaultValue: "Open Quiz")
  static let openAppWhenRun = true
  static let pendingDeeplink = WidgetDeeplink.quiz
}
