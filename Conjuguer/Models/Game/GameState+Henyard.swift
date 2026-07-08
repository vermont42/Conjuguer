//
//  GameState+Henyard.swift
//  Conjuguer
//
//  Mechanic 4 — La Basse-Cour. A 🐔 hen (la poule, distinct from the 🐓 rooster
//  enemy) waddles across the screen horizontally, zig-zagging and laying 🥚 eggs
//  that fall and bounce with gravity. An egg left unshot hatches into a 🐣
//  poussin that chases the player along the ground and costs health on contact —
//  so the player must clear eggs before they hatch. Threats arrive from the side
//  and below, breaking the "everything comes from the top" pattern.
//

import UIKit

extension GameState {
  func spawnHen() {
    let fromLeft = Bool.random()
    hen = Hen(
      x: fromLeft ? -Self.henSize : screenSize.width + Self.henSize,
      y: screenSize.height * 0.22,
      movingRight: fromLeft
    )
    Current.soundPlayer.play(.cluck, shouldDebounce: false)
  }

  func updateHenyard(dt: CGFloat) {
    updateHen(dt: dt)
    updateEggs(dt: dt)
    updateChicks(dt: dt)
    clearHenyardIfDone()
  }

  private func updateHen(dt: CGFloat) {
    guard var current = hen else {
      return
    }
    current.x += (current.movingRight ? 1 : -1) * Self.henSpeedH * dt
    // Vertical zig-zag.
    current.y += CGFloat(sin(sineTime * 1.5)) * Self.henSpeedV * dt

    current.layTimer += dt
    if current.layTimer >= Self.henLayInterval {
      current.layTimer = 0
      eggs.append(Egg(x: current.x, y: current.y, velocityY: Self.eggInitialFallSpeed))
      Current.soundPlayer.play(.cluck, shouldDebounce: true)
    }

    let exited = current.movingRight
      ? current.x > screenSize.width + Self.henSize
      : current.x < -Self.henSize
    if exited {
      hen = nil
    } else {
      hen = current
    }
  }

  private func updateEggs(dt: CGFloat) {
    var hatched: [Chick] = []
    eggs = eggs.compactMap { egg in
      var current = egg
      current.hatchTimer += dt
      current.velocityY += Self.eggGravity * dt
      current.y += current.velocityY * dt

      if current.hatchTimer >= Self.eggHatchTime {
        // The chick hatches at the player's level and chases horizontally; it
        // cannot be shot, so the player must flee off-screen to escape it.
        hatched.append(Chick(x: current.x, y: playerY))
        Current.soundPlayer.play(.eggCrack, shouldDebounce: false)
        return nil
      }

      // The hen-yard "ground" is the player's row, not the screen bottom.
      let floor = playerY
      if current.y >= floor {
        current.y = floor
        current.velocityY = -abs(current.velocityY) * Self.eggBounceRestitution
        if abs(current.velocityY) < 20 {
          current.velocityY = 0
        }
      }
      return current
    }
    chicks.append(contentsOf: hatched)
  }

  private func updateChicks(dt: CGFloat) {
    // Chase the player horizontally along its row. The player is faster, so it
    // can outrun a chick to the screen edge and wrap around to escape.
    for index in chicks.indices {
      let direction: CGFloat = playerX > chicks[index].x ? 1 : -1
      chicks[index].x += direction * Self.chickSpeed * dt
      chicks[index].y = playerY
    }
  }

  private func clearHenyardIfDone() {
    if hen == nil && eggs.isEmpty && chicks.isEmpty && activeSpecial == .henyard {
      activeSpecial = nil
    }
  }

  func collideHenyard() {
    shootHen()
    shootEggs()
    // Chicks cannot be shot — the player escapes them by fleeing off-screen.
    collideChicksWithPlayer()
  }

  private func shootHen() {
    guard let current = hen else {
      return
    }
    guard let bulletIndex = firstBulletIndex(
      hitting: CGPoint(x: current.x, y: current.y),
      size: Self.henSize
    ) else {
      return
    }
    bullets.remove(at: bulletIndex)
    hen = nil
    score += Self.scorePerKill
    Current.soundPlayer.play(.chomp, shouldDebounce: false, volume: 0.5)
    HapticPlayer.playImpact(.light)
  }

  private func shootEggs() {
    guard let bulletIndex = bullets.firstIndex(where: { bullet in
      eggs.contains { egg in
        Self.intersects(
          a: CGPoint(x: bullet.x, y: bullet.y),
          aSize: Self.bulletSize,
          b: CGPoint(x: egg.x, y: egg.y),
          bSize: Self.eggSize
        )
      }
    }) else {
      return
    }
    let bullet = bullets[bulletIndex]
    if let eggIndex = eggs.firstIndex(where: { egg in
      Self.intersects(
        a: CGPoint(x: bullet.x, y: bullet.y),
        aSize: Self.bulletSize,
        b: CGPoint(x: egg.x, y: egg.y),
        bSize: Self.eggSize
      )
    }) {
      eggs.remove(at: eggIndex)
      bullets.remove(at: bulletIndex)
      score += Self.eggScore
      Current.soundPlayer.play(.chime, shouldDebounce: false)
      HapticPlayer.playImpact(.light)
    }
  }

  private func collideChicksWithPlayer() {
    if removeOverlappingPlayer(&chicks, size: Self.chickSize) {
      registerPlayerHit()
      Current.soundPlayer.play(.playerHit, shouldDebounce: false)
    }
  }
}
