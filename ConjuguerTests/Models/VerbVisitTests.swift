//
//  VerbVisitTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct VerbVisitTests {
  private let start = Date(timeIntervalSinceReferenceDate: 0)

  @Test func testAVisitBeginsAtTheHeader() {
    let visit = VerbVisit(source: .search, start: start)
    #expect(visit.deepestSection == .header)
    #expect(visit.viewParameters == ["viewName": "VerbView", "source": "search"])
  }

  @Test func testScrollingBackUpKeepsTheDeepestSection() {
    var visit = VerbVisit(source: .browse, start: start)
    visit.reach(.simple)
    visit.reach(.etymology)
    visit.reach(.compound)
    #expect(visit.deepestSection == .etymology)
  }

  @Test func testAResumedVisitStartsFromWhatIsAlreadyOnScreen() {
    let visit = VerbVisit(source: .resume, start: start, visibleSections: [.etymology, .example])
    #expect(visit.deepestSection == .example)
  }

  @Test func testLeaveParametersBandTheDwell() {
    var visit = VerbVisit(source: .widget, start: start)
    visit.reach(.compound)
    #expect(visit.leaveParameters(end: start.addingTimeInterval(20)) == [
      "deepestSection": "compound",
      "dwell": "15-60s"
    ])
  }

  @Test func testEveryParameterValueComesFromAVocabulary() {
    let vocabulary = Set(
      AnalyticsSource.allCases.map(\.rawValue)
        + VerbPageSection.allCases.map(\.rawValue)
        + ["VerbView", "0-5s", "5-15s", "15-60s", "60s+"]
    )
    for source in AnalyticsSource.allCases {
      var visit = VerbVisit(source: source, start: start)
      visit.reach(.example)
      let values = Array(visit.viewParameters.values) + Array(visit.leaveParameters(end: start.addingTimeInterval(90)).values)
      #expect(Set(values).isSubset(of: vocabulary))
    }
  }
}
