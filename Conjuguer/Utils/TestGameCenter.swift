//
//  TestGameCenter.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/24/21.
//

import UIKit

class TestGameCenter: GameCenterable {
  var isAuthenticated: Bool

  init(isAuthenticated: Bool = false) {
    self.isAuthenticated = isAuthenticated
  }

  func authenticate(onViewController: UIViewController, completion: ((Bool) -> Void)?) {
    if !isAuthenticated {
      isAuthenticated = true
      completion?(true)
    } else {
      completion?(false)
    }
  }

  func reportScore(_ score: Int) {
    print("Pretending to report score \(score).")
  }

  func showLeaderboard() {
    print("Pretending to show leaderboard.")
  }
}
