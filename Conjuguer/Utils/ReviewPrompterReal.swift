//
//  ReviewPrompterReal.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/5/18.
//

import StoreKit

struct ReviewPrompterReal: ReviewPrompter {
  static let promptModulo = 10
  static let promptInterval: TimeInterval = 60 * 60 * 24 * 180
  private let settings: Settings
  private let now: () -> Date
  private let requestReview: () -> Void
  private static let defaultRequestReview: () -> Void = {
    if let scene = UIApplication.shared.connectedScenes.first(
      where: { $0.activationState == .foregroundActive }
    ) as? UIWindowScene {
      Task { @MainActor in
        AppStore.requestReview(in: scene)
      }
    }
  }

  init(settings: Settings, now: @escaping () -> Date = Date.init, requestReview: @escaping () -> Void = ReviewPrompterReal.defaultRequestReview) {
    self.settings = settings
    self.now = now
    self.requestReview = requestReview
  }

  func promptableActionHappened() {
    var actionCount = settings.promptActionCount
    actionCount += 1
    settings.promptActionCount = actionCount
    let lastReviewPromptDate = settings.lastReviewPromptDate
    let currentDate = now()
    if actionCount % ReviewPrompterReal.promptModulo == 0 && currentDate.timeIntervalSince(lastReviewPromptDate) >= ReviewPrompterReal.promptInterval {
      requestReview()
      settings.lastReviewPromptDate = currentDate
    }
  }
}
