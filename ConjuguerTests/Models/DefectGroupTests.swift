//
//  DefectGroupTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import XCTest

@MainActor
class DefectGroupTests: XCTestCase {
  private func group(doesntUse: String) -> DefectGroup {
    DefectGroup(id: "test", descriptionEn: "en", descriptionFr: "fr", usesOnly: nil, doesntUse: doesntUse)
  }

  func testH2PMarksSecondPluralImpératifPassé() {
    let defectGroup = group(doesntUse: "h2p")
    XCTAssertTrue(
      defectGroup.isDefectiveForTense(.impératifPassé(.secondPlural)),
      "h2p must mark the second-plural (vous) impératif passé defective."
    )
    XCTAssertFalse(
      defectGroup.isDefectiveForTense(.impératifPassé(.firstPlural)),
      "h2p must not mark the first-plural (nous) impératif passé — that's h1p's row."
    )
  }

  func testH2PMarksSecondPluralImpératif() {
    let defectGroup = group(doesntUse: "h2p")
    XCTAssertTrue(defectGroup.isDefectiveForTense(.impératif(.secondPlural)))
  }

  func testH1PMarksFirstPlural() {
    let defectGroup = group(doesntUse: "h1p")
    XCTAssertTrue(defectGroup.isDefectiveForTense(.impératif(.firstPlural)))
    XCTAssertTrue(defectGroup.isDefectiveForTense(.impératifPassé(.firstPlural)))
    XCTAssertFalse(defectGroup.isDefectiveForTense(.impératifPassé(.secondPlural)))
  }

  // The clore data combines both codes; both vous and nous impératif passé must be struck.
  func testClorePatternStrikesBothImpératifPasséPlurals() {
    let defectGroup = group(doesntUse: "h1p,h2p")
    XCTAssertTrue(defectGroup.isDefectiveForTense(.impératifPassé(.firstPlural)))
    XCTAssertTrue(defectGroup.isDefectiveForTense(.impératifPassé(.secondPlural)))
  }
}
