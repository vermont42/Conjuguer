//
//  VerbVisit.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// A verb page to push, with the way the learner reached it and the cells a search matched.
struct VerbDestination: Hashable {
  let verb: Verb
  let source: AnalyticsSource
  var marks: MarkedConjugations?
}

/// One stretch of time during which a verb page is on screen, uncovered by a sheet of its own,
/// with the app in the foreground. It begins with `viewAppeared` and ends with exactly one
/// `leaveVerbView`, whether the page was pushed or presented as a sheet. A page that leaves the
/// screen or the foreground and then returns begins a new visit whose source is `resume`,
/// because the alternatives either count time spent in another app as reading or send a
/// `leaveVerbView` that no `viewAppeared` preceded.
struct VerbVisit {
  static let viewName = "VerbView"

  let source: AnalyticsSource
  let start: Date
  private(set) var deepestSection: VerbPageSection

  init(source: AnalyticsSource, start: Date, visibleSections: Set<VerbPageSection> = []) {
    self.source = source
    self.start = start
    deepestSection = visibleSections.max() ?? .header
  }

  mutating func reach(_ section: VerbPageSection) {
    deepestSection = max(deepestSection, section)
  }

  var viewParameters: [String: String] {
    [
      ParameterKey.viewName.rawValue: Self.viewName,
      ParameterKey.source.rawValue: source.rawValue
    ]
  }

  func leaveParameters(end: Date) -> [String: String] {
    [
      ParameterKey.deepestSection.rawValue: deepestSection.rawValue,
      ParameterKey.dwell.rawValue: AnalyticsBand.dwell(end.timeIntervalSince(start))
    ]
  }
}
