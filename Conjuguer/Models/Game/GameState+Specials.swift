//
//  GameState+Specials.swift
//  Conjuguer
//
//  Schedules the cyclic "special" mechanics (Mechanic 2 ball, Mechanic 3 ghost
//  hunt, Mechanic 4 hen-yard). Only one runs at a time: every specialInterval a
//  fresh one is drawn from a shuffled bag, but only while none is active. Each
//  mechanic clears `activeSpecial` itself when it finishes. The dive-bombers
//  (Mechanic 1) and the robot boss (Mechanic 5) schedule independently.
//

import CoreGraphics

extension GameState {
  func updateSpecials(dt: CGFloat) {
    guard activeSpecial == nil else {
      return
    }
    specialCooldown -= dt
    guard specialCooldown <= 0 else {
      return
    }
    specialCooldown = Self.specialInterval

    if specialBag.isEmpty {
      specialBag = SpecialMechanic.allCases.shuffled()
    }
    let mechanic = specialBag.removeLast()
    activeSpecial = mechanic
    switch mechanic {
    case .ball:
      spawnBall()
    case .ghosts:
      spawnGhosts()
    case .henyard:
      spawnHen()
    }
  }

  /// Called once per frame after the standard bullet/player collisions. Each
  /// mechanic resolves its own bullet/player interactions here.
  func resolveMechanicCollisions() {
    collideBall()
    collideGhosts()
    collideHenyard()
    collideRobot()
  }
}
