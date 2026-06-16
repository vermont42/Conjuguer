//
//  ModelSort.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/17/21.
//

import Foundation

enum ModelSort: String, CaseIterable {
  case irregularity = "Irregularity"
  case alphabetical = "Alphabetical"
  case identifier = "Identifier"

  var displayName: String {
    switch self {
    case .irregularity:
      return L.ModelSort.irregularity
    case .alphabetical:
      return L.ModelSort.alphabetical
    case .identifier:
      return L.ModelSort.identifier
    }
  }
}
