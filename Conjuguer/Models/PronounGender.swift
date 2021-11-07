//
//  PronounGender.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/6/21.
//

import Foundation

enum PronounGender: String, CaseIterable {
  case feminine = "Feminine"
  case masculine = "Masculine"
  case both = "Both"

  var localizedGender: String {
    switch self {
    case .feminine:
      return L.PronounGender.feminine
    case .masculine:
      return L.PronounGender.masculine
    case .both:
      return L.PronounGender.both
    }
  }
}
