//
//  DeeplinkTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 5/31/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct DeeplinkTests {
  private func url(_ string: String) -> URL {
    guard let url = URL(string: string) else {
      fatalError("Invalid test URL: \(string)")
    }
    return url
  }

  // Swift Testing has no setUp; each serialized test clears the shared `Current` entities
  // first so a prior test's state can't leak in.
  private func resetCurrent() {
    Current.verb = nil
    Current.verbModel = nil
    Current.info = nil
  }

  @Test func testHandleURLSwitchesTab() {
    resetCurrent()
    Current.selectedTab = .settings
    Current.handleURL(url("conjuguer://verb/parler"))
    #expect(Current.verb?.infinitif == "parler")
    #expect(Current.selectedTab == .verbs)

    Current.selectedTab = .settings
    Current.handleURL(url("conjuguer://info/2"))
    #expect(Current.info == Info.infos[2])
    #expect(Current.selectedTab == .info)
  }

  @Test func testHandleInAppURLDoesNotSwitchTab() {
    resetCurrent()
    Current.selectedTab = .models
    Current.handleInAppURL(url("conjuguer://verb/parler"))
    #expect(Current.verb?.infinitif == "parler")
    #expect(Current.selectedTab == .models, "In-app verb link must not change the tab.")

    Current.selectedTab = .info
    Current.handleInAppURL(url("conjuguer://info/3"))
    #expect(Current.info == Info.infos[3])
    #expect(Current.selectedTab == .info, "In-app info link must not change the tab.")
  }

  @Test func testHandleInAppURLPreservesSiblingEntity() {
    resetCurrent()
    let model = VerbModel.models["4-2B"]
    #expect(model != nil)
    Current.verbModel = model
    Current.selectedTab = .models

    Current.handleInAppURL(url("conjuguer://verb/parler"))

    #expect(Current.verb?.infinitif == "parler")
    #expect(Current.verbModel?.id == model?.id, "In-app link must not clear the sibling verbModel.")
    #expect(Current.selectedTab == .models)
  }

  @Test func testQuizDeeplinkStartsQuizAndSwitchesTab() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("conjuguer://quiz/start"))

    #expect(Current.selectedTab == .quiz)
    #expect(Current.quiz.quizState == .inProgress)
  }

  @Test func testModelDeeplinkSelectsModel() {
    resetCurrent()
    Current.selectedTab = .verbs

    Current.handleURL(url("conjuguer://model/4-2B"))

    #expect(Current.verbModel?.id == "4-2B")
    #expect(Current.selectedTab == .models)
  }

  @Test func testRandomVerbDeeplinkSelectsSomeVerb() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("conjuguer://verb/random"))

    #expect(Current.verb != nil, "The random-verb link must resolve to a verb.")
    #expect(Current.selectedTab == .verbs)
  }

  @Test func testNegativeInfoIndexIsRejectedWithoutCrashing() {
    resetCurrent()
    Current.selectedTab = .settings

    // Finding 9: `-1` passes the upper-bound check but must be rejected by the
    // `indices.contains` guard rather than trapping on `Info.infos[-1]`.
    Current.handleURL(url("conjuguer://info/-1"))

    #expect(Current.info == nil)
    #expect(Current.selectedTab == .settings, "An out-of-range info link must not switch the tab.")
  }

  @Test func testTooLargeInfoIndexIsRejected() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("conjuguer://info/9999"))

    #expect(Current.info == nil)
    #expect(Current.selectedTab == .settings)
  }

  @Test func testNonNumericInfoIndexIsRejected() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("conjuguer://info/abc"))

    #expect(Current.info == nil)
    #expect(Current.selectedTab == .settings)
  }

  @Test func testWrongSchemeIsIgnored() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("https://verb/parler"))

    #expect(Current.verb == nil, "A non-conjuguer scheme must not resolve an entity.")
    #expect(Current.selectedTab == .settings)
  }

  @Test func testWrongComponentCountIsIgnored() {
    resetCurrent()
    Current.selectedTab = .settings

    // `conjuguer://verb` has no path component, so it fails the component-count guard.
    Current.handleURL(url("conjuguer://verb"))

    #expect(Current.verb == nil)
    #expect(Current.selectedTab == .settings)
  }

  @Test func testUnknownHostIsIgnored() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("conjuguer://bogus/thing"))

    #expect(Current.verb == nil)
    #expect(Current.verbModel == nil)
    #expect(Current.info == nil)
    #expect(Current.selectedTab == .settings, "An unknown host must not switch the tab.")
  }
}
