// Copyright © 2025 Josh Adams. All rights reserved.

enum OnboardingDisplay {
  /// Master switch for the first-launch onboarding cover. Ordinarily `true`. Set to
  /// `false` before generating screenshots or recording App Store previews (then restore
  /// to `true`) so the tour never auto-presents over the screen being captured.
  ///
  /// Only the automatic presentation in `ConjuguerApp` consults this; the Settings
  /// "Show Onboarding" button ignores it, so the flow stays manually reachable for
  /// review. Because the cover never presents when this is `false`, `hasSeenOnboarding`
  /// is left untouched rather than marked seen.
  static let onboardingEnabled = true
}

enum TipDisplay {
  /// Master switch for all TipKit tips. Ordinarily `true`. Set to `false` before
  /// generating screenshots (then restore to `true`) so no tip ever appears.
  ///
  /// When `false`, `ConjuguerApp` skips `Tips.configure()`. TipKit displays nothing
  /// until it is configured, so every `TipView` and `.popoverTip(_:)` in the app stays
  /// hidden — no per-call-site changes needed.
  static let tipsEnabled = true
}

enum TutorDisplay {
  /// Master switch for the tutor entry's *unavailability* cell, mirroring
  /// `TipDisplay.tipsEnabled`. Ordinarily `true`. Set to `false` before generating
  /// screenshots (then restore to `true`).
  ///
  /// The tutor needs Apple Intelligence, which is never available in a simulator —
  /// `World.simulator` injects the *real* service, so availability resolves against the
  /// host and fails. `InfoBrowseView` therefore renders a reason cell there ("Apple
  /// Intelligence is still getting ready…"), which is honest on a device but reads as a
  /// defect in an App Store screenshot. Only the reason cell is suppressed: when the model
  /// *is* available the entry still renders its `NavigationLink`, so this switch can never
  /// hide a working feature.
  static let tutorUnavailableRowEnabled = true
}
