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

  private func group(usesOnly: String) -> DefectGroup {
    DefectGroup(id: "test", descriptionEn: "en", descriptionFr: "fr", usesOnly: usesOnly, doesntUse: nil)
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

  func testClorePatternStrikesBothImpératifPasséPlurals() {
    let defectGroup = group(doesntUse: "h1p,h2p")
    XCTAssertTrue(defectGroup.isDefectiveForTense(.impératifPassé(.firstPlural)))
    XCTAssertTrue(defectGroup.isDefectiveForTense(.impératifPassé(.secondPlural)))
  }

  func testFAMarksEveryFuturSimplePerson() {
    let defectGroup = group(doesntUse: "fA")
    for personNumber in PersonNumber.allCases {
      XCTAssertTrue(defectGroup.isDefectiveForTense(.futurSimple(personNumber)))
    }
    XCTAssertFalse(defectGroup.isDefectiveForTense(.indicatifPrésent(.firstSingular)))
  }

  func testBarePersonCodeMarksEveryTenseForThatPerson() {
    let defectGroup = group(doesntUse: "1s")
    XCTAssertTrue(defectGroup.isDefectiveForTense(.indicatifPrésent(.firstSingular)))
    XCTAssertTrue(defectGroup.isDefectiveForTense(.passéComposé(.firstSingular)))
    XCTAssertFalse(defectGroup.isDefectiveForTense(.indicatifPrésent(.secondSingular)))
  }

  func testUsesOnlyImpératifDoesNotMirrorToPassé() {
    let defectGroup = group(usesOnly: "h2p")
    XCTAssertFalse(defectGroup.isDefectiveForTense(.impératif(.secondPlural)))
    XCTAssertTrue(defectGroup.isDefectiveForTense(.impératifPassé(.secondPlural)))
  }
}
