//
//  ReviewCardHost.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import SwiftUI

/// The review card above the list it wraps, and the events that choose, reveal, and drop it. The
/// rules are `ReviewCardModel`'s; this view only reports what happened.
struct ReviewCardHost<Content: View>: View {
  let isShown: Bool
  let open: (VerbDestination) -> Void
  @ViewBuilder let content: () -> Content

  @Environment(World.self) private var world
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.scenePhase) private var scenePhase
  @State private var model: ReviewCardModel?

  private var isSuppressed: Bool {
    world.settings.reviewCardSuppression != .off
  }

  var body: some View {
    VStack {
      if isShown, let model, let card = model.card {
        ReviewCardView(
          verb: card.offer.verb,
          caption: L.ReviewCard.caption(daysAgo: card.offer.daysSinceActivity, wasLookedUp: card.offer.wasLookedUp),
          isRevealed: card.isRevealed,
          reveal: {
            withAnimation {
              model.reveal()
            }
          },
          open: {
            if let destination = model.open() {
              open(destination)
            }
          },
          dismiss: {
            withAnimation {
              model.dismiss()
            }
          }
        )
        .frame(maxWidth: horizontalSizeClass == .regular ? reviewCardMaxWidth : .infinity)
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity)
        .onAppear {
          withAnimation {
            model.shown()
          }
        }
      }

      content()
    }
    .onAppear {
      let model = model ?? ReviewCardModel(practice: world.practice, analytics: world.analytics, gameCenter: world.gameCenter)
      self.model = model
      model.listAppeared(isSuppressed: isSuppressed)
    }
    .onChange(of: scenePhase) {
      switch scenePhase {
      case .background:
        model?.appEnteredBackground()
      case .active:
        model?.appBecameActive(isSuppressed: isSuppressed)
      default:
        break
      }
    }
    .onChange(of: world.settings.reviewCardSuppression) {
      model?.suppressionChanged(isSuppressed: isSuppressed)
    }
    .onChange(of: world.practice.record) {
      withAnimation {
        model?.recordChanged()
      }
    }
  }
}

private let reviewCardMaxWidth: CGFloat = 560
