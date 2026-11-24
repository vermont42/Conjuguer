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
        self.loadReportedAchievements()
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

  // What Game Center holds for the signed-in player, by achievement ID, once loaded. Until then,
  // reports wait in `pendingAchievements`. The handler may run again for another player, so each
  // sign-in loads afresh.
  private var reportedAchievements: [String: Double]?
  private var pendingAchievements: [Achievement: Double] = [:]

  private func loadReportedAchievements() {
    reportedAchievements = nil
    GKAchievement.loadAchievements { [weak self] achievements, error in
      let failure = error?.localizedDescription
      let loaded = Dictionary((achievements ?? []).map { ($0.identifier, $0.percentComplete) }, uniquingKeysWith: max)
      Task { @MainActor in
        if let failure {
          Log.gameCenter.error("Could not load achievements: \(failure, privacy: .public)")
        }
        self?.reportedAchievements = loaded
        self?.sendPendingAchievements()
      }
    }
  }

  func reportAchievementProgress(_ percentComplete: [Achievement: Double]) {
    pendingAchievements.merge(percentComplete, uniquingKeysWith: max)
    sendPendingAchievements()
  }

  // The practice record can fall, a wrong answer sending an item down the ladder, but an
  // achievement once earned stays earned, so only progress that has risen is sent.
  private func sendPendingAchievements() {
    guard isAuthenticated, let reported = reportedAchievements else {
      return
    }
    let risen = pendingAchievements.filter { achievement, percent in
      percent > (reported[achievement.identifier] ?? 0)
    }
    pendingAchievements = [:]
    guard !risen.isEmpty else {
      return
    }

    let achievements = risen.map { achievement, percent in
      let gkAchievement = GKAchievement(identifier: achievement.identifier)
      gkAchievement.percentComplete = percent
      gkAchievement.showsCompletionBanner = true
      return gkAchievement
    }
    let sent = Dictionary(uniqueKeysWithValues: risen.map { ($0.key.identifier, $0.value) })
    GKAchievement.report(achievements) { [weak self] error in
      let failure = error?.localizedDescription
      Task { @MainActor in
        if let failure {
          Log.gameCenter.error("Could not report achievements: \(failure, privacy: .public)")
          return
        }
        self?.reportedAchievements?.merge(sent, uniquingKeysWith: max)
      }
    }
  }

  func showAchievements() {
    guard isAuthenticated else {
      return
    }
    GKAccessPoint.shared.trigger(state: .achievements) { }
  }

  func showLeaderboard(level: QuizLevel) {
    guard isAuthenticated else {
      return
    }
    GKAccessPoint.shared.trigger(leaderboardID: level.leaderboardID, playerScope: .global, timeScope: .allTime) { }
  }
}
