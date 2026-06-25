//
//  GameState+Ghosts.swift
//  Conjuguer
//
//  Mechanic 3 — Le Fantôme de l'Opéra. 2–3 👻 drift down dropping a trail of
//  🎵 dots (caught for small points). On reaching the player's row they switch
//  to chasing horizontally. A 🔮 chandelier floats among them; shooting it flips
//  every ghost to 😱 fright mode for 5 s, so touching one devours it (💨) for a
//  fat bonus. Ignored ghosts eventually exit the top.
//

import UIKit

extension GameState {
  func spawnGhosts() {
    let count = Int.random(in: Self.ghostCountRange)
    let spacing = screenSize.width / CGFloat(count + 1)
    ghosts = (0 ..< count).map { index in
      Ghost(x: spacing * CGFloat(index + 1), y: Self.ghostSize)
    }
    noteDots = []
    chandelier = nil
    frightActive = false
    frightTimer = 0
    // The chandelier appears partway through the descent.
    chandelier = Chandelier(x: screenSize.width / 2, y: Self.ghostSize)
    Current.soundPlayer.play(.ghostSpooky, shouldDebounce: false)
  }

  func updateGhosts(dt: CGFloat) {
    updateFrightTimer(dt: dt)
    updateChandelier(dt: dt)
    moveGhosts(dt: dt)
    updateNoteDots(dt: dt)
    reapGhosts()
  }

  private func updateFrightTimer(dt: CGFloat) {
    guard frightActive else {
      return
    }
    frightTimer -= dt
    if frightTimer <= 0 {
      frightActive = false
      frightTimer = 0
      for index in ghosts.indices where ghosts[index].phase == .fleeing {
        ghosts[index].phase = .exiting
      }
    }
  }

  private func updateChandelier(dt: CGFloat) {
    guard var item = chandelier else {
      return
    }
    item.y += Self.chandelierFallSpeed * dt
    if item.y > screenSize.height + Self.chandelierSize {
      chandelier = nil
    } else {
      chandelier = item
    }
  }

  private func moveGhosts(dt: CGFloat) {
    var newDots: [NoteDot] = []
    for index in ghosts.indices {
      switch ghosts[index].phase {
      case .descending:
        ghosts[index].y += Self.ghostDescentSpeed * dt
        ghosts[index].dotTimer += dt
        if ghosts[index].dotTimer >= Self.dotDropInterval {
          newDots.append(NoteDot(x: ghosts[index].x, y: ghosts[index].y))
          ghosts[index].dotTimer = 0
        }
        if ghosts[index].y >= playerY {
          ghosts[index].phase = .chasing
        }
      case .chasing:
        let direction: CGFloat = playerX > ghosts[index].x ? 1 : -1
        ghosts[index].x += direction * Self.ghostChaseSpeed * dt
      case .fleeing:
        let direction: CGFloat = ghosts[index].x > playerX ? 1 : -1
        ghosts[index].x += direction * Self.ghostFleeSpeed * dt
        ghosts[index].x = max(Self.ghostSize / 2, min(screenSize.width - Self.ghostSize / 2, ghosts[index].x))
      case .devoured:
        ghosts[index].devourTimer += dt
      case .exiting:
        ghosts[index].y -= Self.ghostExitSpeed * dt
      }
    }
    noteDots.append(contentsOf: newDots)
  }

  private func updateNoteDots(dt: CGFloat) {
    for index in noteDots.indices {
      noteDots[index].y += Self.dropFallSpeed * dt
    }
    noteDots.removeAll { $0.y > screenSize.height + Self.dotSize }
  }

  private func reapGhosts() {
    ghosts.removeAll { ghost in
      switch ghost.phase {
      case .devoured:
        return ghost.devourTimer >= Self.devourDuration
      case .exiting:
        return ghost.y < -Self.ghostSize
      default:
        return false
      }
    }

    if ghosts.isEmpty && !frightActive && activeSpecial == .ghosts {
      activeSpecial = nil
      noteDots = []
      chandelier = nil
    }
  }

  func collideGhosts() {
    collectNoteDots()
    shootChandelier()
    collideGhostsWithPlayer()
  }

  private func collectNoteDots() {
    let caught = noteDots.filter { dot in
      Self.intersects(
        a: CGPoint(x: dot.x, y: dot.y),
        aSize: Self.dotSize,
        b: CGPoint(x: playerX, y: playerY),
        bSize: Self.playerSize
      )
    }
    guard !caught.isEmpty else {
      return
    }
    let caughtIDs = Set(caught.map(\.id))
    noteDots.removeAll { caughtIDs.contains($0.id) }
    score += caught.count * Self.dotScore
    Current.soundPlayer.play(.chirp, shouldDebounce: false)
    HapticPlayer.playImpact(.light)
  }

  private func shootChandelier() {
    guard let item = chandelier else {
      return
    }
    guard let bulletIndex = bullets.firstIndex(where: { bullet in
      Self.intersects(
        a: CGPoint(x: bullet.x, y: bullet.y),
        aSize: Self.bulletSize,
        b: CGPoint(x: item.x, y: item.y),
        bSize: Self.chandelierSize
      )
    }) else {
      return
    }
    bullets.remove(at: bulletIndex)
    chandelier = nil
    frightActive = true
    frightTimer = Self.frightDuration
    for index in ghosts.indices where ghosts[index].phase == .descending || ghosts[index].phase == .chasing {
      ghosts[index].phase = .fleeing
    }
    Current.soundPlayer.play(.magicActivate, shouldDebounce: false)
    HapticPlayer.playImpact(.medium)
  }

  private func collideGhostsWithPlayer() {
    for index in ghosts.indices {
      guard Self.intersects(
        a: CGPoint(x: ghosts[index].x, y: ghosts[index].y),
        aSize: Self.ghostSize,
        b: CGPoint(x: playerX, y: playerY),
        bSize: Self.playerSize
      ) else {
        continue
      }
      switch ghosts[index].phase {
      case .chasing, .descending:
        ghosts[index].phase = .exiting
        registerPlayerHit()
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
      case .fleeing:
        ghosts[index].phase = .devoured
        ghosts[index].devourTimer = 0
        score += Self.ghostDevourScore
        Current.soundPlayer.play(.chomp, shouldDebounce: false, volume: 0.5)
        HapticPlayer.playImpact(.medium)
      default:
        break
      }
    }
  }
}
