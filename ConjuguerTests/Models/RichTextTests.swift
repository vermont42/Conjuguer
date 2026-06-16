//
//  RichTextTests.swift
//  ConjuguerTests
//

@testable import Conjuguer
import XCTest

class RichTextTests: XCTestCase {
  // MARK: - Block splitting

  func testPlainTextIsASingleBodyBlock() {
    XCTAssertEqual("hello world".richTextBlocks, [.body([.plain("hello world")])])
  }

  func testSubheadingSplitsFromBody() {
    XCTAssertEqual(
      "`Heading`body text".richTextBlocks,
      [.subheading("Heading"), .body([.plain("body text")])]
    )
  }

  func testSubheadingIsTrimmed() {
    XCTAssertEqual("`  Heading  `".richTextBlocks, [.subheading("Heading")])
  }

  func testEmptySubheadingIsDropped() {
    XCTAssertEqual("``body".richTextBlocks, [.body([.plain("body")])])
  }

  func testLeadingNewlinesAfterSubheadingAreTrimmed() {
    XCTAssertEqual(
      "`Head`\n\nBody".richTextBlocks,
      [.subheading("Head"), .body([.plain("Body")])]
    )
  }

  func testInternalParagraphBreaksArePreserved() {
    XCTAssertEqual("first\n\nsecond".richTextBlocks, [.body([.plain("first\n\nsecond")])])
  }

  // MARK: - Inline segments

  func testBoldSegment() {
    XCTAssertEqual("a ~b~ c".bodySegments, [.plain("a "), .bold("b"), .plain(" c")])
  }

  func testLinkSegment() {
    guard case let .link(text, url) = "%jouer%".bodySegments.first else {
      return XCTFail("Expected a link segment.")
    }
    XCTAssertEqual(text, "jouer")
    XCTAssertEqual(url.absoluteString.removingPercentEncoding, "jouer")
  }

  func testHttpLinkKeepsScheme() {
    guard case let .link(_, url) = "%https://example.com%".bodySegments.first else {
      return XCTFail("Expected a link segment.")
    }
    XCTAssertEqual(url.absoluteString, "https://example.com")
  }

  func testConjugationSegmentEmbedsInPlainText() {
    XCTAssertEqual(
      "x $vaUX$ y".bodySegments,
      [.plain("x "), .conjugation([.regular("va"), .irregular("ux")]), .plain(" y")]
    )
  }

  func testConjugationContiguousUppercase() {
    XCTAssertEqual("SUIs".conjugationParts, [.irregular("sui"), .regular("s")])
  }

  func testConjugationNonContiguousUppercaseSplitsIntoRuns() {
    XCTAssertEqual(
      "devIenDr".conjugationParts,
      [.regular("dev"), .irregular("i"), .regular("en"), .irregular("d"), .regular("r")]
    )
  }

  func testConjugationAllRegular() {
    XCTAssertEqual("joue".conjugationParts, [.regular("joue")])
  }

  // MARK: - Graceful handling of authoring errors

  func testUnterminatedBoldRendersAsPlain() {
    XCTAssertEqual("a ~b".bodySegments, [.plain("a "), .plain("b")])
  }
}
