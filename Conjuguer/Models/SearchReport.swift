//
//  SearchReport.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// Follows one verb search from its first letter until it ends, so that `finishSearch` is sent
/// once per search. A search ends when a result or the guess is opened, when the field is
/// cleared, or when the app leaves the foreground with text in the field. Returning to the
/// results and opening another verb from the same text is not a new search; editing the text is.
struct SearchTracker {
  struct Search: Equatable {
    let query: String
    let source: AnalyticsSource
  }

  private(set) var search: Search?
  private var nextSource: AnalyticsSource?

  var query: String? {
    search?.query
  }

  /// The search that this change ended by clearing the field, if it ended one.
  mutating func textChanged(to text: String) -> Search? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isEmpty else {
      search = Search(query: trimmed, source: search?.source ?? nextSource ?? .tab)
      nextSource = nil
      return nil
    }
    return finish()
  }

  /// Another surface opened the field, so the next search is that surface's. A search in
  /// progress ends here, because the text it was typed into is about to be replaced.
  mutating func fieldOpened(from source: AnalyticsSource) -> Search? {
    let ended = finish()
    nextSource = source
    return ended
  }

  /// The field closed with nothing typed, so the surface that opened it began no search.
  mutating func fieldClosed() {
    if search == nil {
      nextSource = nil
    }
  }

  mutating func finish() -> Search? {
    defer {
      search = nil
    }
    return search
  }
}

/// The parameters of one `finishSearch` signal. Every value comes from a fixed vocabulary or a
/// band, so nothing typed leaves the device.
struct SearchReport: Equatable {
  let source: AnalyticsSource
  let outcome: SearchOutcome
  let queryLength: Int
  let resultCount: Int
  let matchKind: SearchMatchKind
  let resultPosition: Int?

  /// `resultCount` counts the list's rows, so a doubled infinitive (haïr, sortir) counts twice.
  static func opened(query: String, resultCount: Int, kind: VerbSearch.MatchKind, position: Int, source: AnalyticsSource = .tab) -> SearchReport {
    SearchReport(
      source: source,
      outcome: .opened,
      queryLength: query.count,
      resultCount: resultCount,
      matchKind: kind.analyticsValue,
      resultPosition: position
    )
  }

  static func openedGuess(query: String, source: AnalyticsSource = .tab) -> SearchReport {
    SearchReport(source: source, outcome: .opened, queryLength: query.count, resultCount: 0, matchKind: .guess, resultPosition: 0)
  }

  /// A search that ended without a verb opened. Its match kind is the top result's, which says
  /// what the learner saw first and passed over.
  static func ended(query: String, matches: [VerbSearch.Match], source: AnalyticsSource = .tab) -> SearchReport {
    SearchReport(
      source: source,
      outcome: matches.isEmpty ? .noResult : .abandoned,
      queryLength: query.count,
      resultCount: matches.count,
      matchKind: matches.first?.kind.analyticsValue ?? .none,
      resultPosition: nil
    )
  }

  var parameters: [String: String] {
    [
      ParameterKey.source.rawValue: source.rawValue,
      ParameterKey.outcome.rawValue: outcome.rawValue,
      ParameterKey.queryLength.rawValue: AnalyticsBand.queryLength(queryLength),
      ParameterKey.resultCount.rawValue: AnalyticsBand.resultCount(resultCount),
      ParameterKey.matchKind.rawValue: matchKind.rawValue,
      ParameterKey.resultPosition.rawValue: AnalyticsBand.resultPosition(resultPosition)
    ]
  }
}

extension VerbSearch.MatchKind {
  var analyticsValue: SearchMatchKind {
    switch self {
    case .exactInfinitive:
      return .exactInfinitive
    case .exactFoldedInfinitive:
      return .exactFoldedInfinitive
    case .conjugation:
      return .conjugation
    case .infinitivePrefix:
      return .infinitivePrefix
    case .glossMeaning:
      return .glossMeaning
    case .foldedConjugation:
      return .foldedConjugation
    case .foldedInfinitivePrefix:
      return .foldedInfinitivePrefix
    case .wholeWordGloss:
      return .wholeWordGloss
    case .infinitiveSubstring:
      return .infinitiveSubstring
    case .foldedInfinitiveSubstring:
      return .foldedInfinitiveSubstring
    case .glossSubstring:
      return .glossSubstring
    }
  }
}
