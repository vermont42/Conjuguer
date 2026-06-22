//
//  RichTextTests.swift
//  ConjuguerTests
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct RichTextTests {
  // MARK: - Block splitting

  @Test func testPlainTextIsASingleBodyBlock() {
    #expect("hello world".richTextBlocks == [.body([.plain("hello world")])])
  }

  @Test func testSubheadingSplitsFromBody() {
    #expect(
      "`Heading`body text".richTextBlocks ==
      [.subheading("Heading"), .body([.plain("body text")])]
    )
  }

  @Test func testSubheadingIsTrimmed() {
    #expect("`  Heading  `".richTextBlocks == [.subheading("Heading")])
  }

  @Test func testEmptySubheadingIsDropped() {
    #expect("``body".richTextBlocks == [.body([.plain("body")])])
  }

  @Test func testLeadingNewlinesAfterSubheadingAreTrimmed() {
    #expect(
      "`Head`\n\nBody".richTextBlocks ==
      [.subheading("Head"), .body([.plain("Body")])]
    )
  }

  @Test func testTrailingNewlinesBeforeSubheadingAreTrimmed() {
    #expect(
      "a\n\nb\n\n`Head`".richTextBlocks ==
      [.body([.plain("a\n\nb")]), .subheading("Head")]
    )
  }

  @Test func testInternalParagraphBreaksArePreserved() {
    #expect("first\n\nsecond".richTextBlocks == [.body([.plain("first\n\nsecond")])])
  }

  // MARK: - Inline segments

  @Test func testBoldSegment() {
    #expect("a ~b~ c".bodySegments == [.plain("a "), .bold("b"), .plain(" c")])
  }

  @Test func testLinkSegment() {
    guard case let .link(text, url) = "‡jouer‡".bodySegments.first else {
      Issue.record("Expected a link segment.")
      return
    }
    #expect(text == "jouer")
    #expect(url.absoluteString.removingPercentEncoding == "jouer")
  }

  @Test func testHttpLinkKeepsScheme() {
    guard case let .link(_, url) = "‡https://example.com‡".bodySegments.first else {
      Issue.record("Expected a link segment.")
      return
    }
    #expect(url.absoluteString == "https://example.com")
  }

  @Test func testConjugationSegmentEmbedsInPlainText() {
    #expect(
      "x $vaUX$ y".bodySegments ==
      [.plain("x "), .conjugation([.regular("va"), .irregular("ux")]), .plain(" y")]
    )
  }

  @Test func testConjugationContiguousUppercase() {
    #expect("SUIs".conjugationParts == [.irregular("sui"), .regular("s")])
  }

  @Test func testConjugationNonContiguousUppercaseSplitsIntoRuns() {
    #expect(
      "devIenDr".conjugationParts ==
      [.regular("dev"), .irregular("i"), .regular("en"), .irregular("d"), .regular("r")]
    )
  }

  @Test func testConjugationAllRegular() {
    #expect("joue".conjugationParts == [.regular("joue")])
  }

  // MARK: - Graceful handling of authoring errors

  @Test func testUnterminatedBoldRendersAsPlain() {
    #expect("a ~b".bodySegments == [.plain("a "), .plain("b")])
  }
}
