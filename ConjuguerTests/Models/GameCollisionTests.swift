//
//  GameCollisionTests.swift
//  ConjuguerTests
//
//  Characterization tests for the three collision shapes finding #37 flags as
//  duplicated across the mechanics:
//    A. shoot-one-entity  — the first player bullet overlapping a single entity
//       removes that bullet and triggers an effect (brain, minion, chandelier,
//       hen, ball re-aim).
//    B. player-hit sweep  — remove every element overlapping the player and, if
//       any were removed, register one player hit (enemy bullets, falling
//       enemies, robot bullets, chicks).
//    C. collect-caught    — the player catches (removes) every overlapping
//       pickup and an effect is applied per catch (drops, note dots).
//
//  These complement the sites GameMechanicsTests already covers (chandelier,
//  ghosts, ball, chicks, minion arms) so every shape has a net before the shared
//  collision helpers are extracted. Like the sibling suites, they drive the
//  internal collide*/resolve* helpers directly with hand-placed entities.
//

@testable import Conjuguer
import CoreGraphics
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct GameCollisionTests {
  private func makeGame() -> GameState {
    let game = GameState()
    game.configure(screenSize: CGSize(width: 400, height: 800))
    return game
  }

  @Test func bulletShootingHenClearsItAndScores() {
    let game = makeGame()
    game.hen = Hen(x: 100, y: 100, movingRight: true)
    game.bullets = [Bullet(x: 100, y: 100)]
    let before = game.score

    game.collideHenyard()

    #expect(game.hen == nil)
    #expect(game.bullets.isEmpty)
    #expect(game.score == before + GameState.scorePerKill)
  }

  @Test func bulletHittingBrainRemovesBulletAndReducesHits() {
    let game = makeGame()
    game.robotBrain = RobotBrain(x: 150, y: 100, targetTargetID: nil) // hitsRemaining defaults to 3
    game.bullets = [Bullet(x: 150, y: 100)]

    game.collideRobot()

    #expect(game.bullets.isEmpty)
    #expect(game.robotBrain?.hitsRemaining == 2)
  }

  @Test func enemyBulletSweepHurtsPlayerAndClears() {
    let game = makeGame()
    game.targets = [] // isolate from the enemy-vs-player half of the sweep
    game.playerHealth = 1.0
    game.enemyBullets = [EnemyBullet(x: game.playerX, y: game.playerY, velocityX: 0, velocityY: 0)]

    game.resolvePlayerHits()

    #expect(game.enemyBullets.isEmpty)
    #expect(game.playerHealth < 1.0)
  }

  @Test func fallingEnemyHitsPlayerAndClears() {
    let game = makeGame()
    game.enemyBullets = []
    game.targets = [Target(kind: .rooster, x: game.playerX, y: game.playerY)]
    game.playerHealth = 1.0

    game.resolvePlayerHits()

    #expect(game.targets.isEmpty)
    #expect(game.playerHealth < 1.0)
  }

  @Test func robotBulletSweepHurtsPlayerAndClears() {
    let game = makeGame()
    game.robotMinion = nil
    game.robotBullets = [RobotBullet(x: game.playerX, y: game.playerY, velocityX: 0, velocityY: 0, isRed: true)]
    game.playerHealth = 1.0

    game.collideRobot()

    #expect(game.robotBullets.isEmpty)
    #expect(game.playerHealth < 1.0)
  }

  @Test func collectingDropRestoresHealth() {
    let game = makeGame()
    game.playerHealth = 0.5
    game.drops = [Drop(x: game.playerX, y: game.playerY, kind: .baguette)]

    game.collectDrops()

    #expect(game.drops.isEmpty)
    #expect(game.playerHealth > 0.5) // the baguette healed the player
  }

  @Test func collectingNoteDotScores() {
    let game = makeGame()
    game.noteDots = [NoteDot(x: game.playerX, y: game.playerY)]
    let before = game.score

    game.collideGhosts()

    #expect(game.noteDots.isEmpty)
    #expect(game.score == before + GameState.dotScore)
  }
}
