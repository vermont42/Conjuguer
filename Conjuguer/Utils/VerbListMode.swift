//
//  VerbListMode.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import Foundation

/// What the verb list shows while its search field is empty: every verb in a sort order, or My
/// Verbs. Only the sort order is remembered across launches.
enum VerbListMode: Hashable {
  case sorted(VerbSort)
  case myVerbs

  static let allCases = VerbSort.allCases.map(Self.sorted) + [.myVerbs]

  var displayName: String {
    switch self {
    case .sorted(let sort):
      return sort.displayName
    case .myVerbs:
      return L.MyVerbs.title
    }
  }
}
