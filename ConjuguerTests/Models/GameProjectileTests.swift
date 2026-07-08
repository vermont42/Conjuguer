//
//  GameProjectileTests.swift
//  ConjuguerTests
//
//  Characterization tests for the minigame's projectile behaviors that finding
//  #37 flags as duplicated: the integrate-and-cull loops (player bullets,
//  enemy bullets, robot bullets) and the homing-fire vector (enemy fire, robot
//  fire). These pin the CURRENT behavior exactly so the planned extraction of a
//  shared MovingProjectile helper + homing-vector helper can be verified as
//  behavior-preserving — a green suite before and after the refactor.
//
//  Like GameMechanicsTests, these drive the per-behavior helpers directly with
//  explicit dt values and hand-placed entities rather than the nondeterministic
//  time-stepped update(currentTime:).
//

@testable import Conjuguer
import CoreGraphics
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct GameProjectileTests {
  private func makeGame() -> GameState {
    let game = GameState()
    game.configure(screenSize: CGSize(width: 400, height: 800))
    return game
  }

  private func magnitude(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
    hypot(x, y)
  }

  private func isClose(_ a: CGFloat, _ b: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
    abs(a - b) < tolerance
  }

  // MARK: Integrate-and-cull — player bullets

  @Test func playerBulletsMoveStraightUp() {
    let game = makeGame()
    game.bullets = [Bullet(x: 100, y: 500)]

    game.updateBullets(dt: 0.5) // bulletSpeed 620 * 0.5 = 310 upward

    #expect(game.bullets.count == 1)
    #expect(game.bullets.first?.x == 100) // no horizontal drift
    #expect(game.bullets.first?.y == 190) // 500 - 310
  }

  @Test func playerBulletsCullPastTopEdgeOnly() {
    let game = makeGame()
    // -bulletSize is -36: y = -40 is culled, y = -30 survives.
    game.bullets = [Bullet(x: 100, y: -40), Bullet(x: 100, y: -30)]

    game.updateBullets(dt: 0) // no movement — exercise the cull predicate alone

    #expect(game.bullets.count == 1)
    #expect(game.bullets.first?.y == -30)
  }

  // MARK: Integrate-and-cull — enemy bullets

  @Test func enemyBulletsIntegrateByVelocity() {
    let game = makeGame()
    game.enemyBullets = [EnemyBullet(x: 100, y: 100, velocityX: 200, velocityY: 300)]

    game.updateEnemyBullets(dt: 0.5)

    #expect(game.enemyBullets.first?.x == 200) // 100 + 200 * 0.5
    #expect(game.enemyBullets.first?.y == 250) // 100 + 300 * 0.5
  }

  @Test func enemyBulletsCullOnAllFourEdges() {
    let game = makeGame()
    // enemyBulletSize 30 in a 400x800 field: bounds are x < -30, x > 430,
    // y < -30, y > 830. One bullet just past each edge, plus one in-bounds.
    game.enemyBullets = [
      EnemyBullet(x: 200, y: -31, velocityX: 0, velocityY: 0),  // past top
      EnemyBullet(x: 200, y: 831, velocityX: 0, velocityY: 0),  // past bottom
      EnemyBullet(x: -31, y: 400, velocityX: 0, velocityY: 0),  // past left
      EnemyBullet(x: 431, y: 400, velocityX: 0, velocityY: 0),  // past right
      EnemyBullet(x: 200, y: 400, velocityX: 0, velocityY: 0)   // in bounds
    ]

    game.updateEnemyBullets(dt: 0)

    #expect(game.enemyBullets.count == 1)
    #expect(game.enemyBullets.first?.x == 200)
    #expect(game.enemyBullets.first?.y == 400)
  }

  // MARK: Integrate-and-cull — robot bullets (same logic, robotBulletSize 16)

  @Test func robotBulletsIntegrateByVelocity() {
    let game = makeGame()
    game.robotBullets = [RobotBullet(x: 100, y: 100, velocityX: 200, velocityY: 300, isRed: true)]

    game.updateRobotBullets(dt: 0.5)

    #expect(game.robotBullets.first?.x == 200)
    #expect(game.robotBullets.first?.y == 250)
  }

  @Test func robotBulletsCullOnAllFourEdges() {
    let game = makeGame()
    // robotBulletSize 16: bounds are x < -16, x > 416, y < -16, y > 816.
    game.robotBullets = [
      RobotBullet(x: 200, y: -17, velocityX: 0, velocityY: 0, isRed: true),  // past top
      RobotBullet(x: 200, y: 817, velocityX: 0, velocityY: 0, isRed: true),  // past bottom
      RobotBullet(x: -17, y: 400, velocityX: 0, velocityY: 0, isRed: true),  // past left
      RobotBullet(x: 417, y: 400, velocityX: 0, velocityY: 0, isRed: true),  // past right
      RobotBullet(x: 200, y: 400, velocityX: 0, velocityY: 0, isRed: true)   // in bounds
    ]

    game.updateRobotBullets(dt: 0)

    #expect(game.robotBullets.count == 1)
    #expect(game.robotBullets.first?.x == 200)
    #expect(game.robotBullets.first?.y == 400)
  }

  // MARK: Homing fire — enemy fire

  @Test func enemyFireAimsAtPlayerFromNearestCandidate() throws {
    let game = makeGame()
    // Player sits at screen center: playerX 200, playerY 800 - 112 = 688.
    // Two top-half candidates; the one nearer the player's column fires.
    let near = Target(kind: .rooster, x: 260, y: 100) // |260 - 200| = 60
    let far = Target(kind: .beret, x: 100, y: 100)    // |100 - 200| = 100
    game.targets = [far, near]

    // Cooldown starts at enemyFireInterval, so one call with that dt fires.
    game.attemptEnemyFire(dt: GameState.enemyFireInterval)

    #expect(game.enemyBullets.count == 1)
    let bullet = try #require(game.enemyBullets.first)
    #expect(bullet.x == near.x) // originates from the nearer shooter
    #expect(bullet.y == near.y)

    // Velocity is normalize(player - shooter) * enemyBulletSpeed.
    let dx = game.playerX - near.x
    let dy = game.playerY - near.y
    let length = max(1, hypot(dx, dy))
    #expect(isClose(bullet.velocityX, dx / length * GameState.enemyBulletSpeed))
    #expect(isClose(bullet.velocityY, dy / length * GameState.enemyBulletSpeed))
    // Independent sanity check on the speed constant.
    #expect(isClose(magnitude(bullet.velocityX, bullet.velocityY), GameState.enemyBulletSpeed))
  }

  @Test func enemyFireIgnoresBottomHalfTargets() {
    let game = makeGame()
    // Only candidate is in the bottom half (y > height / 2 = 400), so no shot.
    game.targets = [Target(kind: .rooster, x: 200, y: 600)]

    game.attemptEnemyFire(dt: GameState.enemyFireInterval)

    #expect(game.enemyBullets.isEmpty)
  }

  // MARK: Homing fire — robot fire

  @Test func robotFireAimsAtPlayerWithAlternatingColor() throws {
    let game = makeGame()
    let minion = RobotMinion(x: 200, y: 100, homeX: 200, homeY: 100, assetName: "RoosterIconPreview")

    game.fireRobotBullet(from: minion) // count 0 -> isRed true
    game.fireRobotBullet(from: minion) // count 1 -> isRed false

    #expect(game.robotBullets.count == 2)
    #expect(game.robotBullets[0].isRed == true)
    #expect(game.robotBullets[1].isRed == false)

    let first = try #require(game.robotBullets.first)
    #expect(first.x == minion.x)
    #expect(first.y == minion.y)
    // Straight down the column toward the player: no horizontal component.
    #expect(isClose(first.velocityX, 0))
    #expect(first.velocityY > 0)
    #expect(isClose(magnitude(first.velocityX, first.velocityY), GameState.robotBulletSpeed))
  }

  @Test func robotFireVelocityIsNormalizedTimesSpeed() throws {
    let game = makeGame()
    // Off-axis minion so both velocity components are non-trivial.
    let minion = RobotMinion(x: 100, y: 100, homeX: 100, homeY: 100, assetName: "RoosterIconPreview")

    game.fireRobotBullet(from: minion)

    let bullet = try #require(game.robotBullets.first)
    let dx = game.playerX - minion.x
    let dy = game.playerY - minion.y
    let length = max(1, hypot(dx, dy))
    #expect(isClose(bullet.velocityX, dx / length * GameState.robotBulletSpeed))
    #expect(isClose(bullet.velocityY, dy / length * GameState.robotBulletSpeed))
    #expect(isClose(magnitude(bullet.velocityX, bullet.velocityY), GameState.robotBulletSpeed))
  }
}
