//
//  VerbVisitTrackerTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/26/26.
//

@testable import Conjuguer
import Foundation
import SwiftUI
import Testing

@MainActor
struct VerbVisitTrackerTests {
  @MainActor
  private enum Event: CaseIterable {
    case appear
    case disappear
    case background
    case inactive
    case active
    case cover
    case uncover

    func send(to tracker: VerbVisitTracker) -> [VerbVisitTracker.Effect] {
      switch self {
      case .appear:
        return tracker.pageAppeared()
      case .disappear:
        return tracker.pageDisappeared()
      case .background:
        return tracker.scenePhaseChanged(to: .background)
      case .inactive:
        return tracker.scenePhaseChanged(to: .inactive)
      case .active:
        return tracker.scenePhaseChanged(to: .active)
      case .cover:
        return tracker.coverChanged(isCovered: true)
      case .uncover:
        return tracker.coverChanged(isCovered: false)
      }
    }
  }

  private func view(_ source: AnalyticsSource) -> VerbVisitTracker.Effect {
    .signal(.viewAppeared, parameters: ["viewName": "VerbView", "source": source.rawValue])
  }

  private func leave(_ section: VerbPageSection = .header, dwell: String = "0-5s") -> VerbVisitTracker.Effect {
    .signal(.leaveVerbView, parameters: ["deepestSection": section.rawValue, "dwell": dwell])
  }

  @Test func theFirstVisitCarriesItsSourceAndRecordsTheOpen() {
    let tracker = VerbVisitTracker(source: .search)
    #expect(tracker.pageAppeared() == [view(.search), .recordOpen(source: .search)])
    #expect(tracker.pageDisappeared() == [leave()])
  }

  @Test func aPageThatReturnsResumesWithoutRecordingAnOpen() {
    let tracker = VerbVisitTracker(source: .browse)
    _ = tracker.pageAppeared()
    _ = tracker.pageDisappeared()
    #expect(tracker.pageAppeared() == [view(.resume)])
  }

  @Test func theBackgroundEndsAVisitAndTheReturnResumesIt() {
    let tracker = VerbVisitTracker(source: .widget)
    _ = tracker.pageAppeared()
    #expect(tracker.scenePhaseChanged(to: .inactive).isEmpty)
    #expect(tracker.scenePhaseChanged(to: .background) == [leave()])
    #expect(tracker.scenePhaseChanged(to: .inactive).isEmpty)
    #expect(tracker.scenePhaseChanged(to: .active) == [view(.resume)])
  }

  @Test func thePagesOwnSheetEndsAVisitAndClosingItResumes() {
    let tracker = VerbVisitTracker(source: .lookup)
    _ = tracker.pageAppeared()
    #expect(tracker.coverChanged(isCovered: true) == [leave()])
    #expect(tracker.scenePhaseChanged(to: .active).isEmpty)
    #expect(tracker.coverChanged(isCovered: false) == [view(.resume)])
  }

  @Test func aReturnToTheForegroundUnderTheSheetBeginsNothing() {
    let tracker = VerbVisitTracker(source: .lookup)
    _ = tracker.pageAppeared()
    _ = tracker.coverChanged(isCovered: true)
    _ = tracker.scenePhaseChanged(to: .background)
    #expect(tracker.scenePhaseChanged(to: .active).isEmpty)
    #expect(tracker.coverChanged(isCovered: false) == [view(.resume)])
  }

  @Test func aVisitReportsTheDeepestSectionAndItsDwell() {
    var now = Date(timeIntervalSinceReferenceDate: 0)
    let tracker = VerbVisitTracker(source: .search) { now }
    _ = tracker.pageAppeared()
    tracker.sectionVisibilityChanged(.compound, isVisible: true)
    tracker.sectionVisibilityChanged(.simple, isVisible: true)
    now = now.addingTimeInterval(20)
    #expect(tracker.pageDisappeared() == [leave(.compound, dwell: "15-60s")])
  }

  @Test func aResumedVisitStartsFromTheSectionsStillOnScreen() {
    let tracker = VerbVisitTracker(source: .search)
    _ = tracker.pageAppeared()
    tracker.sectionVisibilityChanged(.etymology, isVisible: true)
    tracker.sectionVisibilityChanged(.related, isVisible: true)
    tracker.sectionVisibilityChanged(.related, isVisible: false)
    _ = tracker.coverChanged(isCovered: true)
    _ = tracker.coverChanged(isCovered: false)
    #expect(tracker.pageDisappeared() == [leave(.etymology)])
  }

  /// Every order of five events, each from the start: the signals alternate, a view first, and
  /// only the first view records an open.
  @Test func everyViewPairsWithOneLeave() {
    let events = Event.allCases
    var sequences: [[Event]] = [[]]
    for _ in 0..<5 {
      sequences = sequences.flatMap { sequence in events.map { sequence + [$0] } }
    }
    for sequence in sequences {
      let tracker = VerbVisitTracker(source: .browse)
      let effects = sequence.flatMap { $0.send(to: tracker) }
      var isVisiting = false
      var views = 0
      var openIndices: [Int] = []
      for effect in effects {
        switch effect {
        case let .signal(name, _) where name == .viewAppeared:
          #expect(!isVisiting, "\(sequence)")
          isVisiting = true
          views += 1
        case let .signal(name, _):
          #expect(name == .leaveVerbView)
          #expect(isVisiting, "\(sequence)")
          isVisiting = false
        case .recordOpen:
          openIndices.append(views)
        }
      }
      #expect(openIndices == (views > 0 ? [1] : []), "\(sequence)")
      #expect((tracker.visit != nil) == isVisiting)
    }
  }
}
