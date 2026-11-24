//
//  GameCenterSpy.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/24/21.
//

import UIKit

class GameCenterSpy: GameCenter {
  struct Report: Equatable {
    let score: Int
    let level: QuizLevel
  }

  var isAuthenticated: Bool
  private(set) var reports: [Report] = []
  private(set) var shownLeaderboardLevels: [QuizLevel] = []
  private(set) var achievementReports: [[Achievement: Double]] = []
  private(set) var achievementsShowCount = 0

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

  func reportScore(_ score: Int, level: QuizLevel) {
    reports.append(Report(score: score, level: level))
  }

  func showLeaderboard(level: QuizLevel) {
    shownLeaderboardLevels.append(level)
  }

  func reportAchievementProgress(_ percentComplete: [Achievement: Double]) {
    achievementReports.append(percentComplete)
  }

  func showAchievements() {
    achievementsShowCount += 1
  }
}
