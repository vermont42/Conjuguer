//
//  GameState+Ball.swift
//  Conjuguer
//
//  Mechanic 2 — Le Ballon des Bleus. A ⚽ enters from the top and ricochets off
//  all four walls (speeding up 1.08× per bounce), destroying any enemy it
//  strikes (Breakout-style) and damaging the player on contact — the shield does
//  NOT protect, to keep it scary. The player can re-aim it by shooting it. It
//  self-expires after ~15 s.
//

import UIKit

extension GameState {
  func spawnBall() {
    let angle = CGFloat.random(in: 0.3 ... 0.8) * (Bool.random() ? 1 : -1)
    ball = GameBall(
      x: screenSize.width / 2,
      y: Self.ballSize,
      velocityX: Self.ballBaseSpeed * angle,
      velocityY: Self.ballBaseSpeed * abs(1 - abs(angle)),
      remainingTime: Self.ballDuration
    )
    Current.soundPlayer.play(.soccerKick, shouldDebounce: false)
  }

  func updateBall(dt: CGFloat) {
    if ballInvulnerabilityTimer > 0 {
      ballInvulnerabilityTimer -= dt
    }

    guard var current = ball else {
      return
    }
    current.remainingTime -= dt
    if current.remainingTime <= 0 {
      clearBall()
      return
    }

    current.x += current.velocityX * dt
    current.y += current.velocityY * dt

    let half = Self.ballSize / 2
    var bounced = false
    if current.x <= half {
      current.x = half
      current.velocityX = abs(current.velocityX)
      bounced = true
    } else if current.x >= screenSize.width - half {
      current.x = screenSize.width - half
      current.velocityX = -abs(current.velocityX)
      bounced = true
    }
    if current.y <= half {
      current.y = half
      current.velocityY = abs(current.velocityY)
      bounced = true
    } else if current.y >= screenSize.height - half {
      current.y = screenSize.height - half
      current.velocityY = -abs(current.velocityY)
      bounced = true
    }

    if bounced {
      current = speedUp(current)
      Current.soundPlayer.play(.soccerKick, shouldDebounce: true)
      HapticPlayer.playImpact(.medium)
    }

    ball = current
  }

  func collideBall() {
    guard var current = ball else {
      return
    }

    // Bricks: any enemy the ball touches is destroyed and deflects it.
    if let index = targets.firstIndex(where: { target in
      Self.intersects(
        a: CGPoint(x: current.x, y: current.y),
        aSize: Self.ballSize,
        b: CGPoint(x: target.x, y: target.y),
        bSize: Self.targetSize * target.renderScale
      )
    }) {
      let target = targets[index]
      deathEffects.append(DeathEffect(x: target.x, y: target.y, assetName: target.kind.assetName))
      targets.remove(at: index)
      score += Self.scorePerKill
      current.velocityY = -current.velocityY
      current = speedUp(current)
      Current.soundPlayer.play(.soccerKick, shouldDebounce: true)
      HapticPlayer.playImpact(.medium)
    }

    // Player bullets re-aim the ball (random horizontal kick).
    if let bulletIndex = bullets.firstIndex(where: { bullet in
      Self.intersects(
        a: CGPoint(x: bullet.x, y: bullet.y),
        aSize: Self.bulletSize,
        b: CGPoint(x: current.x, y: current.y),
        bSize: Self.ballSize
      )
    }) {
      bullets.remove(at: bulletIndex)
      current.velocityY = -abs(current.velocityY)
      current.velocityX += CGFloat.random(in: -80 ... 80)
      Current.soundPlayer.play(.soccerKick, shouldDebounce: false)
      HapticPlayer.playImpact(.medium)
    }

    // Striking the player hurts, but the cheese shield protects (like every
    // other threat). A brief post-hit invulnerability to the ball keeps a single
    // overlap (which can span several frames at speed) from registering more than
    // one 25% hit.
    if ballInvulnerabilityTimer <= 0, Self.intersects(
      a: CGPoint(x: current.x, y: current.y),
      aSize: Self.ballSize,
      b: CGPoint(x: playerX, y: playerY),
      bSize: Self.playerSize
    ) {
      registerPlayerHit()
      ballInvulnerabilityTimer = Self.ballInvulnerabilityDuration
      Current.soundPlayer.play(.playerHit, shouldDebounce: false)
      current.velocityY = -abs(current.velocityY)
    }

    ball = current
  }

  private func speedUp(_ ball: GameBall) -> GameBall {
    var updated = ball
    let speed = hypot(updated.velocityX, updated.velocityY)
    if speed < Self.ballMaxSpeed {
      updated.velocityX *= Self.ballSpeedUpPerBounce
      updated.velocityY *= Self.ballSpeedUpPerBounce
    }
    return updated
  }

  private func clearBall() {
    ball = nil
    if activeSpecial == .ball {
      activeSpecial = nil
    }
  }
}
