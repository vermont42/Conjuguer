//
//  OpenVerbSearchIntent.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import AppIntents

/// The Find a Verb control's action: the verb list, with the search field focused for typing.
/// Hidden from Shortcuts, which offers Look Up a Verb instead. Stashes a deeplink the app drains
/// on its next activation, then opens the app.
struct OpenVerbSearchIntent: AppIntent {
  // A literal, as in OpenRandomVerbIntent: AppIntents cannot read a WidgetL accessor here.
  static let title = LocalizedStringResource("Widget.intentOpenVerbSearch", defaultValue: "Find a Verb")
  static let openAppWhenRun = true
  static let isDiscoverable = false
  static let pendingDeeplink = "conjuguer://search?source=control"

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set(Self.pendingDeeplink, forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
