//
//  Auxiliary.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/2/21.
//

import Foundation

enum Auxiliary: String {
  case avoir = "a"
  case être = "e"

  var verb: String {
    switch self {
    case .avoir:
      return "avoir"
    case .être:
      return "être"
    }
  }
}
