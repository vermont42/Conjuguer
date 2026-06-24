//
//  GameState.swift
//  Conjuguer
//

import Observation
import SwiftUI

@MainActor
@Observable
final class GameState {
  static let playerSize: CGFloat = 64.0
  static let playerBottomInset: CGFloat = 96.0
  static let playerSpeed: CGFloat = 320.0
  static let bulletSize: CGFloat = 36.0
  static let bulletSpeed: CGFloat = 620.0
  static let fireInterval: CGFloat = 0.3
  static let targetSize: CGFloat = 52.0
  static let scrollSpeed: CGFloat = 90.0
  static let spawnInterval: CGFloat = 0.7
  static let starCount = 60

  var screenSize: CGSize = .zero
  var playerX: CGFloat = 0.0
  var bullets: [Bullet] = []
  var targets: [Target] = []
  var stars: [Star] = []
  var score = 0

  var movingLeft = false
  var movingRight = false

  private var lastUpdateTime: Date?
  private var fireCooldown: CGFloat = 0.0
  private var spawnCooldown: CGFloat = 0.0
  private var didConfigure = false

  var playerY: CGFloat {
    screenSize.height - Self.playerBottomInset
  }

  /// Called once the view knows its size. Centers the player and seeds the world.
  func configure(screenSize: CGSize) {
    self.screenSize = screenSize
    guard !didConfigure, screenSize.width > 0, screenSize.height > 0 else {
      return
    }
    didConfigure = true
    playerX = screenSize.width / 2

    stars = (0 ..< Self.starCount).map { _ in
      Star(
        x: CGFloat.random(in: 0 ... screenSize.width),
        y: CGFloat.random(in: 0 ... screenSize.height),
        size: CGFloat.random(in: 1.0 ... 2.5),
        opacity: Double.random(in: 0.15 ... 0.5)
      )
    }

    // Seed a few targets already on screen so it isn't empty at launch.
    for _ in 0 ..< 5 {
      targets.append(
        Target(
          kind: Target.Kind.allCases.randomElement() ?? .rooster,
          x: CGFloat.random(in: Self.targetSize ... (screenSize.width - Self.targetSize)),
          y: CGFloat.random(in: 0 ... (screenSize.height / 2))
        )
      )
    }
  }

  func fire() {
    guard fireCooldown <= 0 else {
      return
    }
    bullets.append(Bullet(x: playerX, y: playerY - Self.playerSize / 2))
    fireCooldown = Self.fireInterval
  }

  func update(currentTime: Date) {
    let dt: CGFloat
    if let last = lastUpdateTime {
      dt = CGFloat(currentTime.timeIntervalSince(last))
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime

    // Skip the first frame and any large hitch (e.g. returning from background).
    guard dt > 0, dt < 1, didConfigure else {
      return
    }

    updateCooldowns(dt: dt)
    updatePlayer(dt: dt)
    updateBullets(dt: dt)
    updateStars(dt: dt)
    updateTargets(dt: dt)
    spawnTargets(dt: dt)
    resolveCollisions()
  }

  private func updateCooldowns(dt: CGFloat) {
    if fireCooldown > 0 {
      fireCooldown -= dt
    }
  }

  private func updatePlayer(dt: CGFloat) {
    let step = Self.playerSpeed * dt

    if movingLeft && !movingRight {
      playerX -= step
    } else if movingRight && !movingLeft {
      playerX += step
    } else {
      // Neither (or both) held: ease back toward horizontal center.
      let center = screenSize.width / 2
      if abs(playerX - center) <= step {
        playerX = center
      } else {
        playerX += playerX < center ? step : -step
      }
    }

    // Wrap horizontally around the screen edges.
    if playerX < 0 {
      playerX += screenSize.width
    } else if playerX > screenSize.width {
      playerX -= screenSize.width
    }
  }

  private func updateBullets(dt: CGFloat) {
    let distance = Self.bulletSpeed * dt
    for index in bullets.indices {
      bullets[index].y -= distance
    }
    bullets.removeAll { $0.y < -Self.bulletSize }
  }

  private func updateStars(dt: CGFloat) {
    let distance = Self.scrollSpeed * dt
    for index in stars.indices {
      stars[index].y += distance
      if stars[index].y > screenSize.height {
        stars[index].y -= screenSize.height
        stars[index].x = CGFloat.random(in: 0 ... screenSize.width)
      }
    }
  }

  private func updateTargets(dt: CGFloat) {
    let distance = Self.scrollSpeed * dt
    for index in targets.indices {
      targets[index].y += distance
    }
    targets.removeAll { $0.y > screenSize.height + Self.targetSize }
  }

  private func spawnTargets(dt: CGFloat) {
    spawnCooldown -= dt
    guard spawnCooldown <= 0 else {
      return
    }
    spawnCooldown = Self.spawnInterval
    targets.append(
      Target(
        kind: Target.Kind.allCases.randomElement() ?? .rooster,
        x: CGFloat.random(in: Self.targetSize ... (screenSize.width - Self.targetSize)),
        y: -Self.targetSize
      )
    )
  }

  private func resolveCollisions() {
    var survivingBullets: [Bullet] = []
    var hitTargetIDs: Set<UUID> = []

    for bullet in bullets {
      var hit = false
      for target in targets where !hitTargetIDs.contains(target.id) {
        if Self.intersects(
          a: CGPoint(x: bullet.x, y: bullet.y),
          aSize: Self.bulletSize,
          b: CGPoint(x: target.x, y: target.y),
          bSize: Self.targetSize
        ) {
          hitTargetIDs.insert(target.id)
          hit = true
          score += 1
          break
        }
      }
      if !hit {
        survivingBullets.append(bullet)
      }
    }

    if !hitTargetIDs.isEmpty {
      bullets = survivingBullets
      targets.removeAll { hitTargetIDs.contains($0.id) }
    }
  }

  private static func intersects(
    a: CGPoint,
    aSize: CGFloat,
    b: CGPoint,
    bSize: CGFloat
  ) -> Bool {
    abs(a.x - b.x) < (aSize + bSize) / 2 && abs(a.y - b.y) < (aSize + bSize) / 2
  }
}
