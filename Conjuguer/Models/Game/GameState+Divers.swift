//
//  GameState+Divers.swift
//  Conjuguer
//
//  Mechanic 1 — La Patrouille de France (dive-bombers). Periodically one
//  on-screen enemy stops its straight fall and swoops in a sine-modulated
//  parabola toward the player's column, scaling up so it reads as "charged."
//  The dive is telegraphed ~0.5 s early with a ⚠️ in the target column, and a
//  Tricolore smoke trail streams behind the diver.
//

import Foundation

extension GameState {
  func updateDivers(dt: CGFloat) {
    launchDiveIfDue(dt: dt)
    advanceDivers(dt: dt)
  }

  private func launchDiveIfDue(dt: CGFloat) {
    diveCooldown -= dt
    guard diveCooldown <= 0 else {
      return
    }
    diveCooldown = Self.diveInterval

    let candidates = topHalfTargetIndices.filter { !targets[$0].isDiving }
    guard let index = candidates.randomElement() else {
      return
    }

    targets[index].isDiving = true
    targets[index].diveWarningTimer = Self.diveWarningDuration
    targets[index].diveProgress = 0
    targets[index].diveStartY = targets[index].y
    targets[index].homeX = playerX
    Current.soundPlayer.play(.buzz, shouldDebounce: false)
  }

  private func advanceDivers(dt: CGFloat) {
    let exitY = screenSize.height + Self.targetSize
    var divedOutIDs: Set<UUID> = []

    for index in targets.indices where targets[index].isDiving {
      if targets[index].diveWarningTimer > 0 {
        targets[index].diveWarningTimer -= dt
        if targets[index].diveWarningTimer <= 0 {
          targets[index].diveStartY = targets[index].y
        }
        continue
      }

      targets[index].diveProgress += dt / Self.diveDuration
      let t = targets[index].diveProgress
      if t >= 1.0 {
        divedOutIDs.insert(targets[index].id)
        continue
      }

      let point = Self.diveArc(
        t: t,
        startY: targets[index].diveStartY,
        endY: exitY,
        depth: Self.diveDepthFactor * Self.targetSize,
        homeX: targets[index].homeX
      )
      targets[index].x = point.x
      targets[index].y = point.y
    }

    if !divedOutIDs.isEmpty {
      targets.removeAll { divedOutIDs.contains($0.id) }
    }

    emitDiveSmoke(dt: dt)
  }

  private func emitDiveSmoke(dt: CGFloat) {
    let active = targets.filter { $0.isDiving && $0.diveWarningTimer <= 0 }
    guard !active.isEmpty else {
      return
    }
    smokeCooldown -= dt
    guard smokeCooldown <= 0 else {
      return
    }
    smokeCooldown = Self.smokeInterval
    for target in active {
      smoke.append(Smoke(x: target.x, y: target.y, colorIndex: smokeColorCycle % 3))
      smokeColorCycle += 1
    }
  }

  func updateSmoke(dt: CGFloat) {
    for index in smoke.indices {
      smoke[index].age += dt
    }
    smoke.removeAll { $0.progress >= 1.0 }
  }
}
