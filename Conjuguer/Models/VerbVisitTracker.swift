//
//  VerbVisitTracker.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import SwiftUI

/// When a verb page's visits begin and end, and what each beginning records. A visit lasts while
/// the page is on screen, the app is out of the background, and no sheet of the page's own (Test
/// Me or a tense's article) covers it. Each event sets one condition and reconciles, so no order
/// of events can send a `leaveVerbView` without a `viewAppeared` before it, or two `viewAppeared`s
/// in a row. The page's first visit carries the way the learner reached it and records the open;
/// every later one is a `resume`, which records nothing.
///
/// The page performs the effects an event returns, so a test can drive the rules without a view.
/// A class in `@State` rather than an observable value, since the page draws nothing from it and a
/// change must not rebuild the page.
final class VerbVisitTracker {
  enum Effect: Equatable {
    case signal(AnalyticsName, parameters: [String: String])
    case recordOpen(source: AnalyticsSource)
  }

  private(set) var visit: VerbVisit?
  private var hasVisited = false
  private var isOnScreen = false
  private var isInBackground = false
  private var isCovered = false
  private var visibleSections: Set<VerbPageSection> = []
  private let source: AnalyticsSource
  private let now: () -> Date

  init(source: AnalyticsSource, now: @escaping () -> Date = { .now }) {
    self.source = source
    self.now = now
  }

  func pageAppeared() -> [Effect] {
    isOnScreen = true
    return update()
  }

  func pageDisappeared() -> [Effect] {
    isOnScreen = false
    return update()
  }

  /// Only the background ends a visit. An inactive scene, under Control Center or the app
  /// switcher, is still the page on screen.
  func scenePhaseChanged(to scenePhase: ScenePhase) -> [Effect] {
    switch scenePhase {
    case .background:
      isInBackground = true
    case .active:
      isInBackground = false
    default:
      return []
    }
    return update()
  }

  func coverChanged(isCovered: Bool) -> [Effect] {
    self.isCovered = isCovered
    return update()
  }

  /// A section on screen when a visit begins counts as reached by it.
  func sectionVisibilityChanged(_ section: VerbPageSection, isVisible: Bool) {
    if isVisible {
      visibleSections.insert(section)
      visit?.reach(section)
    } else {
      visibleSections.remove(section)
    }
  }

  private func update() -> [Effect] {
    if isOnScreen, !isInBackground, !isCovered {
      return begin()
    } else {
      return end()
    }
  }

  private func begin() -> [Effect] {
    guard visit == nil else {
      return []
    }
    let source = hasVisited ? AnalyticsSource.resume : self.source
    let newVisit = VerbVisit(source: source, start: now(), visibleSections: visibleSections)
    visit = newVisit
    hasVisited = true
    let view = Effect.signal(.viewAppeared, parameters: newVisit.viewParameters)
    return source == .resume ? [view] : [view, .recordOpen(source: source)]
  }

  private func end() -> [Effect] {
    guard let visit else {
      return []
    }
    self.visit = nil
    return [.signal(.leaveVerbView, parameters: visit.leaveParameters(end: now()))]
  }
}
