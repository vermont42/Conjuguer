//
//  QuizClock.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// Whether a quiz shows the time spent answering. Hidden by default, since a clock turns practice
/// into a race.
enum QuizClock: String, CaseIterable {
  case hide
  case show

  var localizedQuizClock: String {
    switch self {
    case .hide:
      return L.QuizClock.hide
    case .show:
      return L.QuizClock.show
    }
  }
}
