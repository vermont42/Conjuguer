//
//  GameCenter.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/24/21.
//

import UIKit

protocol GameCenter {
  var isAuthenticated: Bool { get set }
  func authenticate(onViewController: UIViewController, completion: ((Bool) -> Void)?)
  func reportScore(_ score: Int, level: QuizLevel)
  func showLeaderboard(level: QuizLevel)
}

extension GameCenter {
  func authenticate(onViewController: UIViewController) {
    authenticate(onViewController: onViewController, completion: nil)
  }
}

extension QuizLevel {
  // Leaderboard IDs are permanent in App Store Connect, so these must match
  // docs/game_center_setup.md exactly and never change, even if a level is renamed.
  var leaderboardID: String {
    switch self {
    case .beginner:
      return "conjuguer.level.beginner"
    case .elementary:
      return "conjuguer.level.elementary"
    case .intermediate:
      return "conjuguer.level.intermediate"
    case .advanced:
      return "conjuguer.level.advanced"
    }
  }
}
