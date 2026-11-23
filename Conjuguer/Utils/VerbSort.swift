//
//  VerbSort.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/16/21.
//

import Foundation

enum VerbSort: String, CaseIterable {
  case frequency
  case alphabetical

  var displayName: String {
    switch self {
    case .frequency:
      return L.VerbSort.frequency
    case .alphabetical:
      return L.VerbSort.alphabetical
    }
  }
}

/// What the verb list shows while its search field is empty: every verb in a sort order, or My
/// Verbs. Only the sort order is remembered across launches.
enum VerbListMode: Hashable, CaseIterable {
  case frequency
  case alphabetical
  case myVerbs

  init(_ sort: VerbSort) {
    switch sort {
    case .frequency:
      self = .frequency
    case .alphabetical:
      self = .alphabetical
    }
  }

  var displayName: String {
    sort?.displayName ?? L.MyVerbs.title
  }

  var sort: VerbSort? {
    switch self {
    case .frequency:
      return .frequency
    case .alphabetical:
      return .alphabetical
    case .myVerbs:
      return nil
    }
  }
}
