//
//  GameCenterReal.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/26/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import GameKit
import os

class GameCenterReal: NSObject, GameCenter {
  static let shared = GameCenterReal()
  var isAuthenticated = false
  private let localPlayer = GKLocalPlayer.local

  private override init() {}

  func authenticate(onViewController: UIViewController, completion: ((Bool) -> Void)? = nil) {
    localPlayer.authenticateHandler = { viewController, _ in
      if let viewController = viewController {
        onViewController.present(viewController, animated: true, completion: nil)
      } else if self.localPlayer.isAuthenticated {
        self.isAuthenticated = true
        Current.soundPlayer.play(.randomApplause)
        Current.analytics.signal(name: .gameCenterAuthSucceeded)
        completion?(true)
      } else {
        self.isAuthenticated = false
        Current.analytics.signal(name: .gameCenterAuthFailed)
        completion?(false)
      }
    }
  }

  func reportScore(_ score: Int, level: QuizLevel) {
    guard isAuthenticated else {
      return
    }
    let leaderboardID = level.leaderboardID
    GKLeaderboard.submitScore(score, context: 0, player: localPlayer, leaderboardIDs: [leaderboardID]) { error in
      if let error {
        Log.gameCenter.error("Could not report a score to \(leaderboardID, privacy: .public): \(error.localizedDescription, privacy: .public)")
      }
    }
  }

  func showLeaderboard(level: QuizLevel) {
    guard isAuthenticated else {
      return
    }
    GKAccessPoint.shared.trigger(leaderboardID: level.leaderboardID, playerScope: .global, timeScope: .allTime) { }
  }
}
