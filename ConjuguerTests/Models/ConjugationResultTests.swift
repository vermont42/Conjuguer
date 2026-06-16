//
//  ConjugationResultTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import XCTest

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

  func testAccentStrippingDoesNotLeakAcrossAlternates() {
    XCTAssertEqual(
      ConjugationResult.score(correctAnswers: "paye/paie", proposedAnswer: "pàie"),
      .partialMatch,
      "A dropped grave accent must remain partial credit even when an earlier alternate triggered stripping."
    )
  }

  func testExactMatchAgainstSecondAlternateIsTotal() {
    XCTAssertEqual(ConjugationResult.score(correctAnswers: "paye/paie", proposedAnswer: "paie"), .totalMatch)
  }

  func testDroppedCedillaIsPartial() {
    XCTAssertEqual(ConjugationResult.score(correctAnswers: "plaça", proposedAnswer: "placa"), .partialMatch)
  }

  func testDroppedDiaeresisIsPartial() {
    XCTAssertEqual(ConjugationResult.score(correctAnswers: "haïs", proposedAnswer: "hais"), .partialMatch)
  }
}
