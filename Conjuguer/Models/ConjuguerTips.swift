//
//  ConjuguerTips.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/25/26.
//

import SwiftUI
import TipKit

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

struct TryQuizTip: Tip {
  var title: Text {
    Text(L.Tips.tryQuizTitle)
  }

  var message: Text? {
    Text(L.Tips.tryQuizMessage)
  }

  var image: Image? {
    Image(systemName: "pencil.circle.fill")
  }

  var options: [TipOption] {
    MaxDisplayCount(1)
  }
}

struct ExploreModelsTip: Tip {
  var title: Text {
    Text(L.Tips.exploreModelsTitle)
  }

  var message: Text? {
    Text(L.Tips.exploreModelsMessage)
  }

  var image: Image? {
    Image(systemName: "square.stack.3d.up.fill")
  }

  var options: [TipOption] {
    MaxDisplayCount(1)
  }
}

struct ChangeDifficultyTip: Tip {
  static let quizCompleted = Event(id: "quizCompleted")

  var title: Text {
    Text(L.Tips.changeDifficultyTitle)
  }

  var message: Text? {
    Text(L.Tips.changeDifficultyMessage)
  }

  var image: Image? {
    Image(systemName: "slider.horizontal.3")
  }

  var rules: [Rule] {
    #Rule(Self.quizCompleted) {
      $0.donations.count >= 1
    }
  }

  var options: [TipOption] {
    MaxDisplayCount(1)
  }
}

struct PlayGameTip: Tip {
  var title: Text {
    Text(L.Tips.playGameTitle)
  }

  var message: Text? {
    Text(L.Tips.playGameMessage)
  }

  var options: [TipOption] {
    MaxDisplayCount(1)
  }
}
