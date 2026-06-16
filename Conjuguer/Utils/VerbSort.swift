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
