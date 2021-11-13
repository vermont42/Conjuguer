//
//  GameCenterable.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/24/21.
//

import UIKit

protocol GameCenterable {
  var isAuthenticated: Bool { get set }
  func authenticate(onViewController: UIViewController, completion: ((Bool) -> Void)?)
  func reportScore(_ score: Int)
  func showLeaderboard()
}

extension GameCenterable {
  func authenticate(onViewController: UIViewController) {
    authenticate(onViewController: onViewController, completion: nil)
  }
}
