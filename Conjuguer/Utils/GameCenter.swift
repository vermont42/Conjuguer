//
//  GameCenter.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/26/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import GameKit

class GameCenter: NSObject, GameCenterable {
  static let shared = GameCenter()
  var isAuthenticated = false
  private let localPlayer = GKLocalPlayer.local
  private var leaderboardIdentifier = ""

  private override init() {}

  func authenticate(onViewController: UIViewController, completion: ((Bool) -> Void)? = nil) {
    localPlayer.authenticateHandler = { viewController, _ in
      if let viewController = viewController {
        onViewController.present(viewController, animated: true, completion: nil)
      } else if self.localPlayer.isAuthenticated {
        // print("AUTHENTICATED displayName: \(self.localPlayer.displayName) alias: \(self.localPlayer.alias) playerID: \(self.localPlayer.playerID)")
        self.isAuthenticated = true
        SoundPlayer.play(.randomApplause)
        self.localPlayer.loadDefaultLeaderboardIdentifier { identifier, _ in
          self.leaderboardIdentifier = identifier ?? "ERROR"
          // print("identifier: \(self.leaderboardIdentifier)")
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
    guard isAuthenticated else {
      return
    }

    GKLeaderboard.submitScore(score, context: 0, player: localPlayer, leaderboardIDs: [leaderboardIdentifier], completionHandler: { _ in })
  }

  func showLeaderboard() {
    guard isAuthenticated else {
      return
    }
    GKAccessPoint.shared.trigger(leaderboardID: leaderboardIdentifier, playerScope: .global, timeScope: .allTime) { }
  }
}
