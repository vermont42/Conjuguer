//
//  VerbSort.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/16/21.
//

import Foundation

enum VerbSort: String, CaseIterable {
  case frequency
  case alphabetic

  var displayName: String {
    switch self {
    case .frequency:
      return "Frequency"
    case .alphabetic:
      return "Alphabetic"
    }
  }
}
