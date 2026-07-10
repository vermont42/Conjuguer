//
//  GameDiveArcTests.swift
//  ConjuguerTests
//
//  Characterization tests for the sine-modulated dive-arc that finding #37
//  flags as duplicated between the dive-bombers (Mechanic 1, GameState+Divers)
//  and the robot minion's swoop (Mechanic 5, GameState+RobotBoss). Both trace
//  the same arc — a linearly-interpolated baseline Y plus a 4·depth·t·(1−t)
//  parabolic dip, with x = homeX + diveWidthAmplitude·sin(t·4π) — differing only
//  in the baseline's end point and the parabola's depth.
//
//  These pin the CURRENT arc so the planned shared diveArc(...) helper can be
//  verified behavior-preserving. Positions are asserted within a tiny tolerance
//  (the two call sites spell the linear interpolation differently — a + (b−a)·t
//  vs a·(1−t) + b·t — which can differ by a sub-ULP; anything a player could see
//  is orders of magnitude larger).
//

@testable import Conjuguer
import CoreGraphics
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct GameDiveArcTests {
  private func makeGame() -> GameState {
    let game = GameState()
    game.configure(screenSize: CGSize(width: 400, height: 800))
    return game
  }

  private func isClose(_ a: CGFloat, _ b: CGFloat, tolerance: CGFloat = 0.0001) -> Bool {
    abs(a - b) < tolerance
  }

  private func expectedArc(
    t: CGFloat,
    startY: CGFloat,
    endY: CGFloat,
    depth: CGFloat,
    homeX: CGFloat
  ) -> CGPoint {
    let baselineY = startY + (endY - startY) * t
    let dip = 4 * depth * t * (1 - t)
    let x = homeX + GameState.diveWidthAmplitude * CGFloat(sin(Double(t) * .pi * 4))
    return CGPoint(x: x, y: baselineY + dip)
  }

  @Test func diverTracesSineParabolaArc() throws {
    let game = makeGame()
    var diver = Target(kind: .rooster, x: 250, y: 100)
    diver.isDiving = true
    diver.diveWarningTimer = -1 // past the telegraph window
    diver.diveStartY = 100
    diver.homeX = 250
    diver.diveProgress = 0.3
    game.targets = [diver]
    game.diveCooldown = GameState.diveInterval // keep launchDiveIfDue dormant

    let dt: CGFloat = 0.024 // t advances by dt / diveDuration = 0.01 -> t = 0.31
    game.updateDivers(dt: dt)

    let t = 0.3 + dt / GameState.diveDuration
    let expected = expectedArc(
      t: t,
      startY: 100,
      endY: game.screenSize.height + GameState.targetSize,
      depth: GameState.diveDepthFactor * GameState.targetSize,
      homeX: 250
    )
    let moved = try #require(game.targets.first { $0.isDiving })
    #expect(isClose(moved.x, expected.x))
    #expect(isClose(moved.y, expected.y))
  }

  @Test func diverIsRemovedWhenArcCompletes() {
    let game = makeGame()
    var diver = Target(kind: .beret, x: 200, y: 300)
    diver.isDiving = true
    diver.diveWarningTimer = -1
    diver.diveStartY = 100
    diver.homeX = 200
    diver.diveProgress = 0.999
    game.targets = [diver]
    game.diveCooldown = GameState.diveInterval

    game.updateDivers(dt: 0.1) // pushes diveProgress past 1.0

    #expect(game.targets.isEmpty)
  }

  @Test func robotMinionTracesSineParabolaArc() throws {
    let game = makeGame()
    var minion = RobotMinion(x: 200, y: 90, homeX: 200, homeY: 90, assetName: "RoosterIconPreview")
    minion.isDiving = true
    minion.diveStartY = 90
    minion.diveProgress = 0.3
    game.robotMinion = minion
    game.score = 0 // below nextBossScore, so no new brain spawns

    let dt: CGFloat = 0.037 // t advances by dt / robotDiveDuration = 0.01 -> t = 0.31
    game.updateRobot(dt: dt)

    let t = 0.3 + dt / GameState.robotDiveDuration
    let expected = expectedArc(
      t: t,
      startY: 90,
      endY: 90,
      depth: game.screenSize.height * GameState.diveDepthFactor,
      homeX: 200
    )
    let moved = try #require(game.robotMinion)
    #expect(isClose(moved.x, expected.x))
    #expect(isClose(moved.y, expected.y))
  }

  @Test func robotMinionReturnsHomeWhenArcCompletes() throws {
    let game = makeGame()
    var minion = RobotMinion(x: 320, y: 500, homeX: 200, homeY: 90, assetName: "RoosterIconPreview")
    minion.isDiving = true
    minion.diveStartY = 90
    minion.diveProgress = 0.999
    game.robotMinion = minion
    game.score = 0

    game.updateRobot(dt: 0.2) // pushes diveProgress past 1.0

    let landed = try #require(game.robotMinion)
    #expect(landed.isDiving == false)
    #expect(landed.x == 200)
    #expect(landed.y == 90)
  }
}
