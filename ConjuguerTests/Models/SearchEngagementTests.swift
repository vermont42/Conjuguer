//
//  SearchEngagementTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/26/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct SearchEngagementTests {
  private func waitUntil(_ condition: () -> Bool, within limit: Duration = .seconds(3)) async {
    let deadline = ContinuousClock.now + limit
    while !condition(), ContinuousClock.now < deadline {
      try? await Task.sleep(for: .milliseconds(20))
    }
  }

  @Test func theFieldStaysEngagedForAMomentAfterItLetsGo() async {
    let engagement = SearchEngagement(lingering: .milliseconds(50))
    engagement.focusChanged(to: true)
    #expect(engagement.isEngaged)
    engagement.focusChanged(to: false)
    #expect(engagement.isEngaged)
    #expect(engagement.isLingering)
    await waitUntil { !engagement.isEngaged }
    #expect(!engagement.isEngaged)
    #expect(!engagement.isLingering)
  }

  @Test func aSecondLossOfFocusLingersAFullMoment() async throws {
    let engagement = SearchEngagement(lingering: .milliseconds(600))
    engagement.focusChanged(to: true)
    engagement.focusChanged(to: false)
    engagement.focusChanged(to: true)
    try await Task.sleep(for: .milliseconds(300))
    engagement.focusChanged(to: false)
    try await Task.sleep(for: .milliseconds(400))
    #expect(engagement.isEngaged, "The first loss's linger ended the second's early.")
    await waitUntil { !engagement.isEngaged }
    #expect(!engagement.isEngaged)
  }

  @Test func aPushWaitsOnlyForATapThatEndedAnEmptySearch() async {
    let engagement = SearchEngagement(lingering: .seconds(5))
    var pushes: [String] = []
    engagement.push(fieldIsEmpty: true) {
      pushes.append("unfocused")
    }
    #expect(pushes == ["unfocused"])
    engagement.focusChanged(to: true)
    engagement.focusChanged(to: false)
    engagement.push(fieldIsEmpty: false) {
      pushes.append("typed")
    }
    #expect(pushes == ["unfocused", "typed"])
    engagement.push(fieldIsEmpty: true) {
      pushes.append("lingering")
    }
    #expect(pushes == ["unfocused", "typed"])
    await waitUntil { pushes.count == 3 }
    #expect(pushes == ["unfocused", "typed", "lingering"])
  }

  @Test func aLaterPushReplacesOneStillWaiting() async throws {
    let engagement = SearchEngagement(lingering: .seconds(5)) {
      try? await Task.sleep(for: .milliseconds(100))
    }
    var pushes: [String] = []
    engagement.focusChanged(to: true)
    engagement.focusChanged(to: false)
    engagement.push(fieldIsEmpty: true) {
      pushes.append("first")
    }
    engagement.push(fieldIsEmpty: true) {
      pushes.append("second")
    }
    await waitUntil { !pushes.isEmpty }
    try await Task.sleep(for: .milliseconds(200))
    #expect(pushes == ["second"])
  }

  @Test func aLetterGoesInAtOnceWhileTheFieldIsFocused() {
    let engagement = SearchEngagement()
    var text = "p"
    var focusCount = 0
    engagement.focusChanged(to: true)
    engagement.insert("ê") { text.append($0) } focus: { focusCount += 1 }
    #expect(text == "pê")
    #expect(focusCount == 0)
  }

  @Test func lettersTappedAsTheSearchEndsWaitAndGoInTogether() async {
    let engagement = SearchEngagement {
      try? await Task.sleep(for: .milliseconds(100))
    }
    var text = ""
    var focusCount = 0
    engagement.focusChanged(to: true)
    engagement.focusChanged(to: false)
    engagement.insert("ê") { text.append($0) } focus: { focusCount += 1 }
    engagement.insert("t") { text.append($0) } focus: { focusCount += 1 }
    #expect(text.isEmpty)
    await waitUntil { focusCount > 0 }
    #expect(text == "êt")
    #expect(focusCount == 1)
  }

  // The field lets go when the linger ends, and with it the surface that opened the field, so a
  // first letter that took longer than the linger began the tab's search instead.
  @Test func theLingerHoldsUntilAWaitingLetterLands() async {
    let engagement = SearchEngagement(lingering: .milliseconds(20)) {
      try? await Task.sleep(for: .milliseconds(300))
    }
    var wasEngagedAsTheLetterLanded: Bool?
    engagement.focusChanged(to: true)
    engagement.focusChanged(to: false)
    engagement.insert("ê") { _ in
      wasEngagedAsTheLetterLanded = engagement.isEngaged
    } focus: {}
    await waitUntil { wasEngagedAsTheLetterLanded != nil }
    #expect(wasEngagedAsTheLetterLanded == true)
  }

  @Test func focusWithoutAPopIsAtOnce() {
    let engagement = SearchEngagement()
    var focusCount = 0
    engagement.focus(afterPopping: false) {
      focusCount += 1
    }
    #expect(focusCount == 1)
  }

  @Test func aSecondRequestDuringAPopWaitsForTheSameEnd() async {
    let engagement = SearchEngagement()
    var focuses: [String] = []
    engagement.focus(afterPopping: true) {
      focuses.append("first")
    }
    engagement.focus(afterPopping: false) {
      focuses.append("second")
    }
    #expect(focuses.isEmpty, "The second request focused the field mid-pop.")
    await waitUntil { !focuses.isEmpty }
    #expect(focuses == ["second"])
    engagement.focus(afterPopping: false) {
      focuses.append("third")
    }
    #expect(focuses == ["second", "third"])
  }
}
