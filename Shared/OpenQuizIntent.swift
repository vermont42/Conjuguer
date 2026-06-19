//
//  OpenQuizIntent.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import AppIntents

// Backs the "Quick Quiz" Control Center control. Stashes a deeplink the app drains on
// its next activation, then opens the app.
struct OpenQuizIntent: AppIntent {
  // AppIntents requires a literal / initializer call here, so it can't use WidgetL. The
  // defaultValue gives a graceful English fallback when resolved in the app bundle (which
  // lacks the widget's catalog); the French translation lives in the widget catalog.
  static let title = LocalizedStringResource("Widget.intentOpenQuiz", defaultValue: "Open Quiz")
  static let openAppWhenRun = true

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set("conjuguer://quiz/start", forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
