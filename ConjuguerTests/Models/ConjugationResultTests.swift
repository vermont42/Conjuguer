//
//  ConjugationResultTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import XCTest

// Table-driven coverage of ConjugationResult.score: exact matches, circumflex-only
// (still total), grave/acute (partial), and junk. Includes the multi-form paye/paie case
// that locks in Batch 0 item 3 — proposedAnswerClean must be re-derived per alternate
// answer, or accent-stripping from an earlier alternate leaks into a later exact-match
// check and inflates the score.
@MainActor
class ConjugationResultTests: XCTestCase {
  func testExactMatchIsTotal() {
    XCTAssertEqual(ConjugationResult.score(correctAnswers: "parle", proposedAnswer: "parle"), .totalMatch)
  }

  func testCaseInsensitiveExactMatchIsTotal() {
    XCTAssertEqual(ConjugationResult.score(correctAnswers: "parle", proposedAnswer: "Parle"), .totalMatch)
  }

  func testDroppedCircumflexIsTotal() {
    XCTAssertEqual(ConjugationResult.score(correctAnswers: "être", proposedAnswer: "etre"), .totalMatch)
  }

  func testDroppedGraveIsPartial() {
    XCTAssertEqual(ConjugationResult.score(correctAnswers: "achète", proposedAnswer: "achete"), .partialMatch)
  }

  func testWrongAnswerIsNoMatch() {
    XCTAssertEqual(ConjugationResult.score(correctAnswers: "parle", proposedAnswer: "xyz"), .noMatch)
  }

  // Item 3 regression: with the per-iteration reset missing, the first alternate ("paye")
  // strips the proposed answer's grave accent, so the second alternate's exact-match check
  // sees "paie" == "paie" and wrongly returns .totalMatch. The dropped accent should be
  // partial credit.
  func testAccentStrippingDoesNotLeakAcrossAlternates() {
    XCTAssertEqual(
      ConjugationResult.score(correctAnswers: "paye/paie", proposedAnswer: "pàie"),
      .partialMatch,
      "A dropped grave accent must remain partial credit even when an earlier alternate triggered stripping."
    )
  }

  // An exact match against the second alternate stays total.
  func testExactMatchAgainstSecondAlternateIsTotal() {
    XCTAssertEqual(ConjugationResult.score(correctAnswers: "paye/paie", proposedAnswer: "paie"), .totalMatch)
  }
}
