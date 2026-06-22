//
//  DefectGroupTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct DefectGroupTests {
  private func group(doesntUse: String) -> DefectGroup {
    DefectGroup(id: "test", descriptionEn: "en", descriptionFr: "fr", usesOnly: nil, doesntUse: doesntUse)
  }

  private func group(usesOnly: String) -> DefectGroup {
    DefectGroup(id: "test", descriptionEn: "en", descriptionFr: "fr", usesOnly: usesOnly, doesntUse: nil)
  }

  @Test func testH2PMarksSecondPluralImpératifPassé() {
    let defectGroup = group(doesntUse: "h2p")
    #expect(
      defectGroup.isDefectiveForTense(.impératifPassé(.secondPlural)),
      "h2p must mark the second-plural (vous) impératif passé defective."
    )
    #expect(
      !defectGroup.isDefectiveForTense(.impératifPassé(.firstPlural)),
      "h2p must not mark the first-plural (nous) impératif passé — that's h1p's row."
    )
  }

  @Test func testH2PMarksSecondPluralImpératif() {
    let defectGroup = group(doesntUse: "h2p")
    #expect(defectGroup.isDefectiveForTense(.impératif(.secondPlural)))
  }

  @Test func testH1PMarksFirstPlural() {
    let defectGroup = group(doesntUse: "h1p")
    #expect(defectGroup.isDefectiveForTense(.impératif(.firstPlural)))
    #expect(defectGroup.isDefectiveForTense(.impératifPassé(.firstPlural)))
    #expect(!defectGroup.isDefectiveForTense(.impératifPassé(.secondPlural)))
  }

  @Test func testClorePatternStrikesBothImpératifPasséPlurals() {
    let defectGroup = group(doesntUse: "h1p,h2p")
    #expect(defectGroup.isDefectiveForTense(.impératifPassé(.firstPlural)))
    #expect(defectGroup.isDefectiveForTense(.impératifPassé(.secondPlural)))
  }

  @Test func testFAMarksEveryFuturSimplePerson() {
    let defectGroup = group(doesntUse: "fA")
    for personNumber in PersonNumber.allCases {
      #expect(defectGroup.isDefectiveForTense(.futurSimple(personNumber)))
    }
    #expect(!defectGroup.isDefectiveForTense(.indicatifPrésent(.firstSingular)))
  }

  @Test func testBarePersonCodeMarksEveryTenseForThatPerson() {
    let defectGroup = group(doesntUse: "1s")
    #expect(defectGroup.isDefectiveForTense(.indicatifPrésent(.firstSingular)))
    #expect(defectGroup.isDefectiveForTense(.passéComposé(.firstSingular)))
    #expect(!defectGroup.isDefectiveForTense(.indicatifPrésent(.secondSingular)))
  }

  @Test func testUsesOnlyImpératifDoesNotMirrorToPassé() {
    let defectGroup = group(usesOnly: "h2p")
    #expect(!defectGroup.isDefectiveForTense(.impératif(.secondPlural)))
    #expect(defectGroup.isDefectiveForTense(.impératifPassé(.secondPlural)))
  }
}
