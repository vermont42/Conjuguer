//
//  DeeplinkTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 5/31/26.
//

@testable import Conjuguer
import XCTest

// Verifies that external deep links switch tabs while in-app links (tapped from within an
// already-presented detail sheet, e.g. ModelView's verb list or InfoView's text) are
// handled in place: no tab switch and no clearing of the sibling entity that drives the
// underlying sheet.
@MainActor
class DeeplinkTests: XCTestCase {
  private func url(_ string: String) -> URL {
    guard let url = URL(string: string) else {
      fatalError("Invalid test URL: \(string)")
    }
    return url
  }

  override func setUp() {
    super.setUp()
    Current.verb = nil
    Current.verbModel = nil
    Current.info = nil
  }

  // External deep links should activate the relevant tab so its browse view can present.
  func testHandleURLSwitchesTab() {
    Current.selectedTab = .settings
    Current.handleURL(url("conjuguer://verb/parler"))
    XCTAssertEqual(Current.verb?.infinitif, "parler")
    XCTAssertEqual(Current.selectedTab, .verbs)

    Current.selectedTab = .settings
    Current.handleURL(url("conjuguer://info/2"))
    XCTAssertEqual(Current.info, Info.infos[2])
    XCTAssertEqual(Current.selectedTab, .info)
  }

  // In-app verb links must not switch tabs (the reported bug: tapping a verb in ModelView's
  // "Verbs Using This Model" then dismissing left the user on the Verbs tab).
  func testHandleInAppURLDoesNotSwitchTab() {
    Current.selectedTab = .models
    Current.handleInAppURL(url("conjuguer://verb/parler"))
    XCTAssertEqual(Current.verb?.infinitif, "parler")
    XCTAssertEqual(Current.selectedTab, .models, "In-app verb link must not change the tab.")

    Current.selectedTab = .info
    Current.handleInAppURL(url("conjuguer://info/3"))
    XCTAssertEqual(Current.info, Info.infos[3])
    XCTAssertEqual(Current.selectedTab, .info, "In-app info link must not change the tab.")
  }

  // In the Models tab, ModelView is driven by Current.verbModel. Handling a verb link from
  // its text in place must not clear verbModel, or the underlying ModelView sheet blanks out.
  func testHandleInAppURLPreservesSiblingEntity() {
    let model = VerbModel.models["4-2B"]
    XCTAssertNotNil(model)
    Current.verbModel = model
    Current.selectedTab = .models

    Current.handleInAppURL(url("conjuguer://verb/parler"))

    XCTAssertEqual(Current.verb?.infinitif, "parler")
    XCTAssertEqual(Current.verbModel?.id, model?.id, "In-app link must not clear the sibling verbModel.")
    XCTAssertEqual(Current.selectedTab, .models)
  }
}
