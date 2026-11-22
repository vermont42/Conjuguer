//
//  OpenRandomVerbControlIntent.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import AppIntents

/// The Random Verb control's action. It differs from `OpenRandomVerbIntent` only in the source
/// its deeplink names: the control and the Shortcuts app would otherwise run one intent, and an
/// intent cannot tell which of them ran it. Hidden from Shortcuts, which already offers
/// `OpenRandomVerbIntent`.
struct OpenRandomVerbControlIntent: AppIntent {
  // A literal, as in OpenRandomVerbIntent: AppIntents cannot read a WidgetL accessor here.
  static let title = LocalizedStringResource("Widget.intentOpenRandomVerb", defaultValue: "Open Random Verb")
  static let openAppWhenRun = true
  static let isDiscoverable = false
  static let pendingDeeplink = "conjuguer://verb/random?source=control"

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set(Self.pendingDeeplink, forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
