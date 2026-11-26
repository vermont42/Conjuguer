//
//  ReviewCardModel.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import Foundation
import Observation

/// The review card's offer and what each tap does to the practice record. Each launch, and each
/// return from the background, offers the irregular verb whose key conjugation is longest overdue,
/// if any. The choice is made once per opening, so revealing a card does not swap it for the next
/// one, and a return from a pushed page keeps it.
@Observable
final class ReviewCardModel {
  struct Card: Equatable {
    let offer: PracticeStore.CardOffer
    var isRevealed = false
  }

  private(set) var card: Card?

  @ObservationIgnored private let practice: PracticeStore
  @ObservationIgnored private let analytics: Analytics
  @ObservationIgnored private let gameCenter: GameCenter
  @ObservationIgnored private let now: () -> Date
  @ObservationIgnored private var hasChosen = false
  @ObservationIgnored private var wasSignaled = false
  @ObservationIgnored private var wasInBackground = false

  init(practice: PracticeStore, analytics: Analytics, gameCenter: GameCenter, now: @escaping () -> Date = { .now }) {
    self.practice = practice
    self.analytics = analytics
    self.gameCenter = gameCenter
    self.now = now
  }

  func listAppeared(isSuppressed: Bool) {
    guard !hasChosen else {
      return
    }
    choose(isSuppressed: isSuppressed)
  }

  func appEnteredBackground() {
    wasInBackground = true
  }

  func appBecameActive(isSuppressed: Bool) {
    guard wasInBackground else {
      return
    }
    wasInBackground = false
    choose(isSuppressed: isSuppressed)
  }

  func suppressionChanged(isSuppressed: Bool) {
    if isSuppressed {
      card = nil
    } else if card == nil {
      choose(isSuppressed: false)
    }
  }

  /// The card came into view. It is signalled once per offer, and an offer that no longer holds
  /// goes unsignalled.
  func shown() {
    dropIfStale()
    guard card != nil, !wasSignaled else {
      return
    }
    wasSignaled = true
    analytics.signal(name: .viewReviewCard)
  }

  func reveal() {
    dropIfStale()
    guard let card, !card.isRevealed else {
      return
    }
    practice.recordReview(card.offer, at: now())
    gameCenter.reportAchievements(in: practice.record)
    analytics.signal(name: .tapRevealReviewCard)
    self.card?.isRevealed = true
  }

  func open() -> VerbDestination? {
    card.map { VerbDestination(verb: $0.offer.verb, source: .reviewCard) }
  }

  /// A card dismissed before its conjugations were seen was no review, so its verb's due key
  /// conjugations return tomorrow in the same box.
  func dismiss() {
    guard let card else {
      return
    }
    if !card.isRevealed {
      practice.snooze(card.offer, at: now())
    }
    self.card = nil
  }

  /// The record changed under the card: the verb looked up from search, a quiz answer, or Reset
  /// Practice. A revealed card stays, since its own reveal rescheduled what it showed.
  func recordChanged() {
    dropIfStale()
  }

  private func choose(isSuppressed: Bool) {
    hasChosen = true
    wasSignaled = false
    card = isSuppressed ? nil : practice.cardOffer(at: now()).map { Card(offer: $0) }
  }

  private func dropIfStale() {
    guard let card, !card.isRevealed, !practice.holds(card.offer, at: now()) else {
      return
    }
    self.card = nil
  }
}
