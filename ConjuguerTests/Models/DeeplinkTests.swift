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
}
