//
//  SearchReportTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct SearchReportTests {
  private static let frequencyVerbs = Verb.verbs.values.sorted { ($0.frequency, $0.id) < ($1.frequency, $1.id) }

  private func matches(_ query: String) -> [VerbSearch.Match] {
    VerbSearch.matches(for: query, in: Self.frequencyVerbs, includeGlosses: true)
  }

  private func openedFirst(_ query: String) throws -> SearchReport {
    let found = matches(query)
    let kind = try #require(found.first?.kind)
    return SearchReport.opened(query: query, resultCount: found.count, kind: kind, position: 0)
  }

  @Test func testTypingBeginsASearchWithoutEndingOne() {
    var tracker = SearchTracker()
    #expect(tracker.textChanged(to: "v") == nil)
    #expect(tracker.textChanged(to: "ven") == nil)
    #expect(tracker.query == "ven")
  }

  @Test func testClearingTheFieldEndsTheSearch() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "ven")
    #expect(tracker.textChanged(to: "")?.query == "ven")
    #expect(tracker.query == nil)
  }

  @Test func testWhitespaceAloneIsNoSearch() {
    var tracker = SearchTracker()
    #expect(tracker.textChanged(to: "  ") == nil)
    #expect(tracker.query == nil)
  }

  @Test func testTheTrackerKeepsTheTrimmedQuery() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: " venir  ")
    #expect(tracker.finish()?.query == "venir")
  }

  @Test func testAFinishedSearchIsNotFinishedAgain() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "ven")
    #expect(tracker.finish()?.query == "ven")
    #expect(tracker.finish() == nil)
    #expect(tracker.textChanged(to: "") == nil)
  }

  @Test func testEditingAfterAnOpenBeginsANewSearch() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "ven")
    _ = tracker.finish()
    _ = tracker.textChanged(to: "veni")
    #expect(tracker.finish()?.query == "veni")
  }

  @Test func testASearchBegunInTheTabNamesTheTab() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "ven")
    #expect(tracker.finish()?.source == .tab)
  }

  // The control, the quick action, and Look Up a Verb open the field, and the search typed or
  // carried into it is theirs. The next one, typed after it ends, is the tab's again.
  @Test func testASearchBegunElsewhereNamesWhereItBegan() {
    var tracker = SearchTracker()
    #expect(tracker.fieldOpened(from: .control) == nil)
    _ = tracker.textChanged(to: "v")
    _ = tracker.textChanged(to: "ven")
    #expect(tracker.finish() == SearchTracker.Search(query: "ven", source: .control))
    _ = tracker.textChanged(to: "veni")
    #expect(tracker.finish()?.source == .tab)
  }

  @Test func testOpeningTheFieldEndsTheSearchInProgress() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "ven")
    #expect(tracker.fieldOpened(from: .lookup) == SearchTracker.Search(query: "ven", source: .tab))
    _ = tracker.textChanged(to: "suis")
    #expect(tracker.finish()?.source == .lookup)
  }

  @Test func testClosingAnUntouchedFieldForgetsWhoOpenedIt() {
    var tracker = SearchTracker()
    _ = tracker.fieldOpened(from: .quickAction)
    tracker.fieldClosed()
    _ = tracker.textChanged(to: "ven")
    #expect(tracker.finish()?.source == .tab)
  }

  @Test func testTheReportCarriesTheSource() {
    let report = SearchReport.ended(query: "ven", matches: matches("ven"), source: .control)
    #expect(report.parameters["source"] == "control")
  }

  @Test func testOpenedReportNamesTheOpenedResultsKind() throws {
    let report = try openedFirst("venir")
    #expect(report.outcome == .opened)
    #expect(report.matchKind == .exactInfinitive)
    #expect(report.parameters == [
      "source": "tab",
      "outcome": "opened",
      "queryLength": "3-5",
      "resultCount": AnalyticsBand.resultCount(matches("venir").count),
      "matchKind": "exactInfinitive",
      "resultPosition": "1"
    ])
  }

  @Test(arguments: zip(
    ["etre", "go", "manoeuvrer", "ven", "mater", "pecher"],
    [SearchMatchKind.exactFoldedInfinitive, .glossMeaning, .exactFoldedInfinitive, .infinitivePrefix, .exactInfinitive, .exactFoldedInfinitive]
  ))
  func testOpeningTheTopResultReportsItsKind(query: String, kind: SearchMatchKind) throws {
    #expect(try openedFirst(query).matchKind == kind)
  }

  @Test func testOpeningALowerResultBandsItsPosition() {
    let report = SearchReport.opened(query: "ven", resultCount: 40, kind: .infinitivePrefix, position: 2)
    #expect(report.parameters["resultCount"] == "11+")
    #expect(report.parameters["resultPosition"] == "2-5")
  }

  @Test func testASearchWithResultsAndNoOpenIsAbandoned() {
    let report = SearchReport.ended(query: "ven", matches: matches("ven"))
    #expect(report.outcome == .abandoned)
    #expect(report.matchKind == .infinitivePrefix)
    #expect(report.parameters["resultPosition"] == "none")
  }

  @Test func testASearchWithNoResultsIsNoResult() {
    let report = SearchReport.ended(query: "xyzzyq", matches: matches("xyzzyq"))
    #expect(report.outcome == .noResult)
    #expect(report.matchKind == SearchMatchKind.none)
    #expect(report.parameters["resultCount"] == "0")
  }

  @Test func testOpeningTheGuessIsAnOpenWithNoResults() {
    let report = SearchReport.openedGuess(query: "venier")
    #expect(report.parameters == [
      "source": "tab",
      "outcome": "opened",
      "queryLength": "6-9",
      "resultCount": "0",
      "matchKind": "guess",
      "resultPosition": "1"
    ])
  }

  // The privacy policy promises that nothing typed is sent. A report keeps no text, which
  // `testAReportKeepsNoText` pins, but its parameters are strings, so this checks that each is a
  // word of the vocabulary or a band: an unbanded length would send "14" for Constantinople.
  @Test(arguments: ["venir", "a", "1", "10+", "opened", "none", "se souvenir", "Constantinople"])
  func testEveryParameterValueIsAWordOfTheVocabularyOrABand(query: String) {
    let vocabulary = Set(
      SearchOutcome.allCases.map(\.rawValue)
        + SearchMatchKind.allCases.map(\.rawValue)
        + AnalyticsSource.allCases.map(\.rawValue)
        + ["1-2", "3-5", "6-9", "10+", "0", "1", "2-10", "11+", "2-5", "6+", "none"]
    )
    let found = matches(query)
    let reports = [
      SearchReport.ended(query: query, matches: found),
      SearchReport.opened(query: query, resultCount: found.count, kind: found.first?.kind ?? .glossSubstring, position: 0),
      SearchReport.openedGuess(query: query)
    ]
    for report in reports {
      #expect(Set(report.parameters.keys) == ["source", "outcome", "queryLength", "resultCount", "matchKind", "resultPosition"])
      #expect(Set(report.parameters.values).isSubset(of: vocabulary))
    }
  }

  @Test func testAReportKeepsNoText() {
    let reports = [
      SearchReport.ended(query: "venir", matches: matches("venir")),
      SearchReport.opened(query: "venir", resultCount: 3, kind: .exactInfinitive, position: 0),
      SearchReport.openedGuess(query: "venier")
    ]
    for report in reports {
      let stored = Mirror(reflecting: report).children
      #expect(!stored.isEmpty)
      #expect(stored.allSatisfy { !($0.value is any StringProtocol) && !($0.value is Character) })
    }
  }
}
