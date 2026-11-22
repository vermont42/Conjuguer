//
//  AnalyticsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct AnalyticsTests {
  @Test(arguments: zip([1, 2, 3, 5, 6, 9, 10, 40], ["1-2", "1-2", "3-5", "3-5", "6-9", "6-9", "10+", "10+"]))
  func testQueryLengthBands(length: Int, band: String) {
    #expect(AnalyticsBand.queryLength(length) == band)
  }

  @Test(arguments: zip([0, 1, 2, 10, 11, 6_330], ["0", "1", "2-10", "2-10", "11+", "11+"]))
  func testResultCountBands(count: Int, band: String) {
    #expect(AnalyticsBand.resultCount(count) == band)
  }

  @Test(arguments: zip([0, 1, 4, 5, 100], ["1", "2-5", "2-5", "6+", "6+"]))
  func testResultPositionBandsCountFromOne(index: Int, band: String) {
    #expect(AnalyticsBand.resultPosition(index) == band)
  }

  @Test func testNoPositionHasItsOwnBand() {
    #expect(AnalyticsBand.resultPosition(nil) == "none")
  }

  @Test(arguments: zip(
    [0.0, 4.9, 5.0, 14.9, 15.0, 59.9, 60.0, 3_600.0],
    ["0-5s", "0-5s", "5-15s", "5-15s", "15-60s", "15-60s", "60s+", "60s+"]
  ))
  func testDwellBands(seconds: Double, band: String) {
    #expect(AnalyticsBand.dwell(seconds) == band)
  }

  @Test func testSectionsRunTopToBottom() {
    #expect(VerbPageSection.allCases.shuffled().sorted() == [.header, .simple, .compound, .etymology, .example])
  }

  @Test func testEverySearchMatchKindHasItsOwnAnalyticsValue() {
    let values = Set(VerbSearch.MatchKind.allCases.map(\.analyticsValue))
    #expect(values.count == VerbSearch.MatchKind.allCases.count)
    #expect(!values.contains(.none))
    #expect(!values.contains(.guess))
  }

  // TelemetryDeck's history of verb pages is `viewAppeared` with this name, so the visit must
  // keep it.
  @Test func testVerbPageKeepsItsScreenName() {
    #expect(VerbVisit.viewName == "\(VerbView.self)")
  }
}
