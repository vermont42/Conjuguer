//
//  GameCenterReal.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/26/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import GameKit

class GameCenterReal: NSObject, GameCenter {
  static let shared = GameCenterReal()
  var isAuthenticated = false
  private let localPlayer = GKLocalPlayer.local
  private var leaderboardIdentifier: String?

  private override init() {}

  func authenticate(onViewController: UIViewController, completion: ((Bool) -> Void)? = nil) {
    localPlayer.authenticateHandler = { viewController, _ in
      if let viewController = viewController {
        onViewController.present(viewController, animated: true, completion: nil)
      } else if self.localPlayer.isAuthenticated {
        self.isAuthenticated = true
        Current.soundPlayer.play(.randomApplause)
        self.localPlayer.loadDefaultLeaderboardIdentifier { identifier, _ in
          Task { @MainActor in
            self.leaderboardIdentifier = identifier
          }
        }
        Current.analytics.recordGameCenterAuthSucceeded()
        completion?(true)
      } else {
        self.isAuthenticated = false
        Current.analytics.recordGameCenterAuthFailed()
        completion?(false)
      }
    }
  }

  func reportScore(_ score: Int) {
    guard isAuthenticated, let leaderboardIdentifier else {
      return
    }

    GKLeaderboard.submitScore(score, context: 0, player: localPlayer, leaderboardIDs: [leaderboardIdentifier], completionHandler: { _ in })
  }

  func showLeaderboard() {
    guard isAuthenticated, let leaderboardIdentifier else {
      return
    }
    GKAccessPoint.shared.trigger(leaderboardID: leaderboardIdentifier, playerScope: .global, timeScope: .allTime) { }
  }
}
