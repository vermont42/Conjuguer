//
//  OpenRandomVerbControlIntent.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import AppIntents

/// The Random Verb control's action. It differs from `OpenRandomVerbIntent` only in the source
/// its link names. Hidden from Shortcuts, which already offers `OpenRandomVerbIntent`.
struct OpenRandomVerbControlIntent: PendingDeeplinkIntent {
  // A literal, as in OpenRandomVerbIntent: AppIntents cannot read a WidgetL accessor here.
  static let title = LocalizedStringResource("Widget.intentOpenRandomVerb", defaultValue: "Open Random Verb")
  static let openAppWhenRun = true
  static let isDiscoverable = false
  static let pendingDeeplink = WidgetDeeplink.randomVerbFromControl
}
