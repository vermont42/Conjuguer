//
//  OpenRandomVerbIntent.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import AppIntents

// Backs the "Random Verb" Control Center control. Stashes a deeplink the app drains on
// its next activation, then opens the app.
struct OpenRandomVerbIntent: AppIntent {
  // AppIntents requires a literal / initializer call here, so it can't use WidgetL. The
  // defaultValue gives a graceful English fallback when resolved in the app bundle (which
  // lacks the widget's catalog); the French translation lives in the widget catalog.
  static let title = LocalizedStringResource("Widget.intentOpenRandomVerb", defaultValue: "Open Random Verb")
  static let openAppWhenRun = true

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set("conjuguer://verb/random", forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
