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
      return "Frequency"
    case .alphabetical:
      return "Alphabetical"
    }
  }
}
