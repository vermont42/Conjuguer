//
//  SearchEngagement.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import Observation

// Hack: on iPad, a tap outside an empty search field ends the search at touch-down, before the
// tap completes. Views that followed the focus (the recent verbs, the letter row) vanished under
// the finger, so tapping a recent verb or é did nothing (Konjugieren, iPadOS 26.3). They follow
// `isEngaged` instead, which lets go of the focus a moment later. A push from that tap would
// arrive while the search is still animating away, and UIKit drops such a push (see
// ViewControllerTransitions), so it waits for the dismissal. So does a letter, since the search
// clears its text as it goes: it is set once the search is gone, and the field is focused again,
// as a search request from outside the app does. Both browse tabs use one of these.
@Observable
final class SearchEngagement {
  /// True while the field is focused, and for a moment after it lets go.
  private(set) var isEngaged = false
  private(set) var isFocused = false

  @ObservationIgnored private let lingering: Duration
  @ObservationIgnored private let waitForDismissal: () async -> Void
  @ObservationIgnored private var lingerTask: Task<Void, Never>?
  @ObservationIgnored private var pushTask: Task<Void, Never>?
  @ObservationIgnored private(set) var letterTask: Task<Void, Never>?
  @ObservationIgnored private var pendingLetters = ""
  @ObservationIgnored private var focusTask: Task<Void, Never>?
  @ObservationIgnored private var popEnds: ContinuousClock.Instant?

  init(lingering: Duration = .milliseconds(700), waitForDismissal: @escaping () async -> Void = ViewControllerTransitions.waitUntilIdle) {
    self.lingering = lingering
    self.waitForDismissal = waitForDismissal
  }

  /// From the loss of focus until the lingering views let go: the moment in which a tap that
  /// ended the search is still being dismissed.
  var isLingering: Bool {
    isEngaged && !isFocused
  }

  /// Each loss of focus starts the linger afresh, so focus lost, regained, and lost again lets
  /// go only a full linger after the last loss. A letter still waiting holds the linger until
  /// it lands, so that what it begins is still the search the field was opened for.
  func focusChanged(to isFocused: Bool) {
    self.isFocused = isFocused
    lingerTask?.cancel()
    lingerTask = nil
    guard !isFocused else {
      isEngaged = true
      return
    }
    let lingering = self.lingering
    lingerTask = Task {
      try? await Task.sleep(for: lingering)
      await letterTask?.value
      guard !Task.isCancelled, !self.isFocused else {
        return
      }
      isEngaged = false
    }
  }

  /// Pushes at once, unless the tap that asked is ending an empty search, in which case the
  /// push waits for the search to be gone. A later push replaces one still waiting. A typed
  /// search does not end on that tap, and on iPhone nothing is animating.
  func push(fieldIsEmpty: Bool, _ push: @escaping () -> Void) {
    pushTask?.cancel()
    pushTask = nil
    guard fieldIsEmpty, isLingering else {
      push()
      return
    }
    pushTask = Task {
      await waitForDismissal()
      guard !Task.isCancelled else {
        return
      }
      push()
    }
  }

  /// Appends at once while the field is focused. Otherwise the letter waits for the search to be
  /// gone, with any tapped after it, and then they are appended together and the field focused.
  func insert(_ letter: String, append: @escaping (String) -> Void, focus: @escaping () -> Void) {
    guard !isFocused || letterTask != nil else {
      append(letter)
      return
    }
    pendingLetters.append(letter)
    guard letterTask == nil else {
      return
    }
    letterTask = Task {
      await waitForDismissal()
      append(pendingLetters)
      pendingLetters = ""
      letterTask = nil
      focus()
    }
  }

  // Hack: focus requested while a pop animates sets the focus state without making the field
  // first responder, so typing goes nowhere (Konjugieren). The focus waits out the animation,
  // and a second request during it waits for the same end rather than focusing mid-pop.
  func focus(afterPopping didPop: Bool, _ focus: @escaping () -> Void) {
    focusTask?.cancel()
    let now = ContinuousClock.now
    if didPop {
      popEnds = now + Self.popDuration
    }
    guard let popEnds, popEnds > now else {
      popEnds = nil
      focusTask = nil
      focus()
      return
    }
    focusTask = Task {
      try? await Task.sleep(until: popEnds, clock: .continuous)
      guard !Task.isCancelled else {
        return
      }
      focus()
    }
  }

  static let popDuration = Duration.milliseconds(500)
}
