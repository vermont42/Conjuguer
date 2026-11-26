//
//  VerbListContent.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import Foundation

/// What the Verbs tab's list shows. A search outranks everything, and the recent verbs, which an
/// empty focused field offers, outrank the list mode. The review card shows only above all verbs.
enum VerbListContent: Equatable {
  case all
  case results
  case noResults
  case recents
  case myVerbs

  init(isSearching: Bool, hasFailed: Bool, isEngaged: Bool, hasRecents: Bool, mode: VerbListMode) {
    if isSearching {
      self = hasFailed ? .noResults : .results
    } else if isEngaged && hasRecents {
      self = .recents
    } else if mode == .myVerbs {
      self = .myVerbs
    } else {
      self = .all
    }
  }

  var showsReviewCard: Bool {
    self == .all
  }
}
