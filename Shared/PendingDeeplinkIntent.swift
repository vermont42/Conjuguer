//
//  PendingDeeplinkIntent.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import AppIntents

/// An intent that opens the app on a link. It leaves the link in the App Group's defaults, and
/// the first window to become active follows it (`SceneRoot`).
///
/// `nonisolated` because the app's default isolation is the main actor: an adopter would
/// otherwise become main-actor-isolated, and its `title` could not satisfy `AppIntent`'s
/// nonisolated requirement (seen in Konjugieren, 2026-11-26).
nonisolated protocol PendingDeeplinkIntent: AppIntent {
  static var pendingDeeplink: WidgetDeeplink { get }
}

extension PendingDeeplinkIntent {
  func perform() async throws -> some IntentResult {
    let deeplink = Self.pendingDeeplink.url?.absoluteString
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set(deeplink, forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
