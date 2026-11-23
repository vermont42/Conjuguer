//
//  ConjuguerTips.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/25/26.
//

import SwiftUI
import TipKit

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

/// Points to the etymology and the examples at the bottom of the verb page. It waits until a page
/// visit after the color key was closed, so that the two never appear one straight after the
/// other, and the page invalidates it once the learner scrolls that far unprompted.
struct ScrollToBottomTip: Tip {
  // TipKit's @Parameter macro cannot expand without the explicit type, and it copies a trailing
  // comment into its expansion, so the lint exception brackets the declaration.
  // swiftlint:disable redundant_type_annotation
  @Parameter
  static var isUnlocked: Bool = false
  // swiftlint:enable redundant_type_annotation

  var title: Text {
    Text(L.Tips.scrollToBottomTitle)
  }

  var message: Text? {
    Text(L.Tips.scrollToBottomMessage)
  }

  var image: Image? {
    Image(systemName: "arrow.down.to.line")
  }

  var rules: [Rule] {
    #Rule(Self.$isUnlocked) {
      $0 == true
    }
  }
}
