//
//  GameState+RobotBoss.swift
//  Conjuguer
//
//  Mechanic 5 — Robot (converter robot mini-boss). Once the player crosses a
//  score threshold a 🧠 brain-core appears, drifts, locks onto an on-screen
//  enemy (charging ⚡), and converts it into a 🤖 robot minion flanked by two 🦾
//  arms. The arms must be shot off (left/right hit zones) before the body is
//  vulnerable; the minion periodically dive-bombs and fires fast red/yellow
//  rectangle bullets. Defeating the whole unit is a climax that ends with a
//  reward shower of drops.
//

import UIKit

extension GameState {
  func updateRobot(dt: CGFloat) {
    spawnRobotIfDue()
    updateRobotBrain(dt: dt)
    updateRobotMinion(dt: dt)
    updateRobotBullets(dt: dt)
  }

  private func spawnRobotIfDue() {
    guard robotBrain == nil, robotMinion == nil, score >= nextBossScore else {
      return
    }
    // Lock onto the topmost enemy and freeze it so the whole fight stays near the
    // top of the screen, well away from the player.
    guard let hostIndex = topmostHostIndex() else {
      return // No eligible enemy yet; try again next frame.
    }
    nextBossScore = score + Self.bossScoreStep
    targets[hostIndex].isFrozen = true
    let host = targets[hostIndex]
    robotBrain = RobotBrain(
      // Enter from the side opposite the host and drift across to it, near the top.
      x: host.x < screenSize.width / 2 ? screenSize.width : 0,
      y: brainHoverY(for: host.y),
      targetTargetID: host.id
    )
    Current.soundPlayer.play(.brainLockOn, shouldDebounce: false)
  }

  /// The highest on-screen enemy that can host the conversion.
  private func topmostHostIndex() -> Int? {
    targets.indices
      .filter { !targets[$0].isDiving && !targets[$0].isFrozen && targets[$0].y >= 0 }
      .min(by: { targets[$0].y < targets[$1].y })
  }

  /// Keeps the brain just above its host but always on-screen.
  private func brainHoverY(for hostY: CGFloat) -> CGFloat {
    max(hostY - Self.brainSize, Self.brainSize / 2)
  }

  private func updateRobotBrain(dt: CGFloat) {
    guard var brain = robotBrain else {
      return
    }

    // Re-acquire if the player shot the host (or it otherwise vanished).
    guard let hostIndex = targets.firstIndex(where: { $0.id == brain.targetTargetID }) else {
      if let newHostIndex = topmostHostIndex() {
        targets[newHostIndex].isFrozen = true
        brain.targetTargetID = targets[newHostIndex].id
        brain.phase = .ascending
        brain.showBolt = false
        robotBrain = brain
      } else {
        robotBrain = nil
      }
      return
    }
    let host = targets[hostIndex]

    switch brain.phase {
    case .ascending:
      // Drift horizontally toward the frozen host, then lock on.
      let dx = host.x - brain.x
      let step = Self.brainDriftSpeed * dt
      if step >= abs(dx) {
        brain.x = host.x
        brain.phase = .lockedOn
        brain.lockOnTimer = 0
        Current.soundPlayer.play(.brainLockOn, shouldDebounce: false)
      } else {
        brain.x += (dx >= 0 ? 1 : -1) * step
      }
      brain.y = brainHoverY(for: host.y)

    case .lockedOn:
      brain.x = host.x
      brain.y = brainHoverY(for: host.y)
      brain.lockOnTimer += dt
      if brain.lockOnTimer >= Self.boltAppearDelay {
        brain.showBolt = true
      }
      if brain.lockOnTimer >= Self.boltAppearDelay + Self.conversionDelay {
        brain.phase = .converting
      }

    case .converting:
      deathEffects.append(DeathEffect(x: host.x, y: host.y, assetName: host.kind.assetName))
      // Rest at the horizontal center (keeping the host's row) so the minion sits
      // clear of the corner score/health labels.
      let restX = screenSize.width / 2
      robotMinion = RobotMinion(
        x: restX,
        y: host.y,
        homeX: restX,
        homeY: host.y,
        assetName: host.kind.assetName
      )
      targets.remove(at: hostIndex)
      Current.soundPlayer.play(.brainConvert, shouldDebounce: false)
      HapticPlayer.playImpact(.heavy)
      triggerScreenShake()
      robotBrain = nil
      return
    }

    robotBrain = brain
  }

  private func updateRobotMinion(dt: CGFloat) {
    if minionInvulnerabilityTimer > 0 {
      minionInvulnerabilityTimer -= dt
    }

    guard var minion = robotMinion else {
      return
    }

    if minion.isDiving {
      minion.diveProgress += dt / Self.robotDiveDuration
      let t = minion.diveProgress
      if t >= 1.0 {
        minion.x = minion.homeX
        minion.y = minion.homeY
        minion.isDiving = false
        minion.diveProgress = 0
        minion.divePauseTimer = 0
      } else {
        // Swoop down toward the player and back up to the home row.
        let point = Self.diveArc(
          t: t,
          startY: minion.diveStartY,
          endY: minion.homeY,
          depth: screenSize.height * Self.diveDepthFactor,
          homeX: minion.homeX
        )
        minion.x = point.x
        minion.y = point.y
      }
    } else {
      minion.divePauseTimer += dt
      if minion.divePauseTimer >= Self.robotDivePause {
        minion.isDiving = true
        minion.diveProgress = 0
        minion.diveStartY = minion.y
      }
    }

    minion.fireTimer += dt
    if minion.fireTimer >= Self.robotFireInterval {
      minion.fireTimer = 0
      fireRobotBullet(from: minion)
    }

    robotMinion = minion
  }

  // internal (not private) so GameProjectileTests can characterize the homing
  // fire vector directly. The vector math and the integrate-and-cull are shared
  // with enemy fire via GameState.homingVelocityTowardPlayer / advanceAndCull
  // (finding #37).
  func fireRobotBullet(from minion: RobotMinion) {
    let velocity = homingVelocityTowardPlayer(
      from: CGPoint(x: minion.x, y: minion.y),
      speed: Self.robotBulletSpeed
    )
    let isRed = robotBullets.count.isMultiple(of: 2)
    robotBullets.append(
      RobotBullet(
        x: minion.x,
        y: minion.y,
        velocityX: velocity.dx,
        velocityY: velocity.dy,
        isRed: isRed
      )
    )
    Current.soundPlayer.play(.robotWeapon, shouldDebounce: true, volume: 0.6)
  }

  func updateRobotBullets(dt: CGFloat) {
    advanceAndCull(&robotBullets, size: Self.robotBulletSize, dt: dt)
  }

  func collideRobot() {
    collideBulletWithBrain()
    collideBulletWithMinion()
    collideMinionWithPlayer()
    collideRobotBulletsWithPlayer()
  }

  private func collideBulletWithBrain() {
    guard var brain = robotBrain else {
      return
    }
    guard let bulletIndex = firstBulletIndex(
      hitting: CGPoint(x: brain.x, y: brain.y),
      size: Self.brainSize
    ) else {
      return
    }
    bullets.remove(at: bulletIndex)
    brain.hitsRemaining -= 1
    if brain.hitsRemaining <= 0 {
      // Releasing the brain unfreezes its host, which resumes falling.
      if let hostIndex = targets.firstIndex(where: { $0.id == brain.targetTargetID }) {
        targets[hostIndex].isFrozen = false
      }
      deathEffects.append(DeathEffect(x: brain.x, y: brain.y, assetName: nil))
      score += Self.brainScore
      robotBrain = nil
    } else {
      robotBrain = brain
    }
    Current.soundPlayer.play(.pop, shouldDebounce: false)
    HapticPlayer.playImpact(.medium)
  }

  private func collideBulletWithMinion() {
    guard var minion = robotMinion else {
      return
    }
    guard let bulletIndex = firstBulletIndex(
      hitting: CGPoint(x: minion.x, y: minion.y),
      size: Self.robotMinionSize
    ) else {
      return
    }
    let bullet = bullets[bulletIndex]
    bullets.remove(at: bulletIndex)

    let offset = bullet.x - minion.x
    var destroyed = false
    if offset < -Self.robotArmHitZone && minion.hasLeftArm {
      minion.hasLeftArm = false
    } else if offset > Self.robotArmHitZone && minion.hasRightArm {
      minion.hasRightArm = false
    } else if !minion.isArmed {
      destroyed = true
    } else if minion.hasLeftArm {
      minion.hasLeftArm = false
    } else {
      minion.hasRightArm = false
    }

    deathEffects.append(DeathEffect(x: minion.x, y: minion.y, assetName: minion.assetName))
    if destroyed {
      score += Self.robotMinionScore
      robotMinion = nil
      robotBullets = []
      defeatBoss(at: CGPoint(x: minion.x, y: minion.y))
    } else {
      robotMinion = minion
      Current.soundPlayer.play(.pop, shouldDebounce: false)
      HapticPlayer.playImpact(.medium)
    }
  }

  private func defeatBoss(at point: CGPoint) {
    Current.soundPlayer.play(.randomApplause, shouldDebounce: false)
    HapticPlayer.playImpact(.heavy)
    triggerScreenShake()
    showerDrops(at: point, kinds: [.baguette, .grape, .cheese])
  }

  private func collideMinionWithPlayer() {
    guard minionInvulnerabilityTimer <= 0 else {
      return
    }
    guard let minion = robotMinion, minion.isDiving else {
      return
    }
    guard Self.intersects(
      a: CGPoint(x: minion.x, y: minion.y),
      aSize: Self.robotMinionSize,
      b: CGPoint(x: playerX, y: playerY),
      bSize: Self.playerSize
    ) else {
      return
    }
    registerPlayerHit()
    minionInvulnerabilityTimer = Self.minionInvulnerabilityDuration
    Current.soundPlayer.play(.playerHit, shouldDebounce: false)
  }

  private func collideRobotBulletsWithPlayer() {
    if removeOverlappingPlayer(&robotBullets, size: Self.robotBulletSize) {
      registerPlayerHit()
      Current.soundPlayer.play(.playerHit, shouldDebounce: false)
    }
  }
}
