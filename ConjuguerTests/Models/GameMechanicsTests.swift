//
//  GameMechanicsTests.swift
//  ConjuguerTests
//
//  Exercises the five minigame mechanics added on top of the base vertical
//  shooter: dive-bombers, the bouncing ball, the ghost hunt, the hen-yard, and
//  the robot boss. The time-stepped scheduling in update(currentTime:) is hard
//  to drive deterministically, so these tests call the per-mechanic update and
//  collision helpers directly with explicit dt values and hand-placed entities.
//

@testable import Conjuguer
import CoreGraphics
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct GameMechanicsTests {
  private func makeGame() -> GameState {
    let game = GameState()
    game.configure(screenSize: CGSize(width: 400, height: 800))
    return game
  }

  // MARK: Mechanic 1 — dive-bombers

  @Test func diveLaunchesAndChargesUp() throws {
    let game = makeGame()
    game.targets = [Target(kind: .rooster, x: 200, y: 100)]
    game.diveCooldown = 0

    game.updateDivers(dt: 0.016)
    #expect(game.targets.contains { $0.isDiving })

    // After the telegraph window the diver loses its warning and scales up.
    game.updateDivers(dt: GameState.diveWarningDuration + 0.1)
    let diver = try #require(game.targets.first { $0.isDiving })
    #expect(diver.diveWarningTimer <= 0)
    #expect(diver.renderScale == 1.3)
  }

  @Test func diversLeaveSmokeTrail() {
    let game = makeGame()
    game.targets = [Target(kind: .croissant, x: 200, y: 100)]
    game.diveCooldown = 0
    game.updateDivers(dt: 0.016)
    // Push past the warning so the dive (and its trail) is active.
    game.smokeCooldown = 0
    game.updateDivers(dt: GameState.diveWarningDuration + 0.1)
    #expect(!game.smoke.isEmpty)
  }

  // MARK: Mechanic 2 — bouncing ball

  @Test func ballBouncesOffWalls() {
    let game = makeGame()
    game.ball = GameBall(x: 1, y: 400, velocityX: -100, velocityY: 60, remainingTime: 10)
    game.updateBall(dt: 0.1)
    #expect((game.ball?.velocityX ?? 0) > 0) // reflected off the left wall
  }

  @Test func ballDestroysTargets() {
    let game = makeGame()
    game.targets = [Target(kind: .beret, x: 200, y: 300)]
    game.ball = GameBall(x: 200, y: 300, velocityX: 50, velocityY: 50, remainingTime: 10)
    let before = game.score
    game.collideBall()
    #expect(game.targets.isEmpty)
    #expect(game.score > before)
  }

  @Test func ballRespectsShield() {
    let game = makeGame()
    game.shieldActive = true
    game.playerHealth = 1.0
    game.ball = GameBall(x: game.playerX, y: game.playerY, velocityX: 0, velocityY: 50, remainingTime: 10)
    game.collideBall()
    #expect(game.playerHealth == 1.0) // the cheese shield blocks the ball
  }

  @Test func ballHurtsUnshieldedPlayer() {
    let game = makeGame()
    game.shieldActive = false
    game.playerHealth = 1.0
    game.ball = GameBall(x: game.playerX, y: game.playerY, velocityX: 0, velocityY: 50, remainingTime: 10)
    game.collideBall()
    #expect(game.playerHealth < 1.0)
  }

  @Test func ballExpires() {
    let game = makeGame()
    game.activeSpecial = .ball
    game.ball = GameBall(x: 200, y: 200, velocityX: 10, velocityY: 10, remainingTime: 0.05)
    game.updateBall(dt: 0.1)
    #expect(game.ball == nil)
    #expect(game.activeSpecial == nil)
  }

  // MARK: Mechanic 3 — ghost hunt

  @Test func ghostsSpawnWithChandelier() {
    let game = makeGame()
    game.spawnGhosts()
    #expect(!game.ghosts.isEmpty)
    #expect(game.chandelier != nil)
  }

  @Test func shootingChandelierTriggersFright() throws {
    let game = makeGame()
    game.spawnGhosts()
    let chandelier = try #require(game.chandelier)
    game.bullets = [Bullet(x: chandelier.x, y: chandelier.y)]
    game.collideGhosts()
    #expect(game.frightActive)
    #expect(game.chandelier == nil)
    #expect(game.ghosts.allSatisfy { $0.phase == .fleeing })
  }

  @Test func devouringFleeingGhostScores() {
    let game = makeGame()
    game.ghosts = [Ghost(x: game.playerX, y: game.playerY, phase: .fleeing)]
    let before = game.score
    game.collideGhosts()
    #expect(game.score == before + GameState.ghostDevourScore)
    #expect(game.ghosts.first?.phase == .devoured)
  }

  @Test func chasingGhostHurtsPlayer() {
    let game = makeGame()
    game.playerHealth = 1.0
    game.ghosts = [Ghost(x: game.playerX, y: game.playerY, phase: .chasing)]
    game.collideGhosts()
    #expect(game.playerHealth < 1.0)
  }

  // MARK: Mechanic 4 — hen, eggs, hatchlings

  @Test func henLaysEggs() {
    let game = makeGame()
    game.spawnHen()
    game.updateHenyard(dt: GameState.henLayInterval + 0.1)
    #expect(!game.eggs.isEmpty)
  }

  @Test func eggHatchesIntoChick() {
    let game = makeGame()
    game.hen = nil
    game.eggs = [Egg(x: 200, y: 400, velocityY: 0, hatchTimer: GameState.eggHatchTime - 0.01)]
    game.updateHenyard(dt: 0.1)
    #expect(game.eggs.isEmpty)
    #expect(!game.chicks.isEmpty)
  }

  @Test func chickHatchesAtPlayerLevel() {
    let game = makeGame()
    game.hen = nil
    game.eggs = [Egg(x: 200, y: 200, velocityY: 0, hatchTimer: GameState.eggHatchTime - 0.01)]
    game.updateHenyard(dt: 0.05)
    #expect(game.chicks.first?.y == game.playerY)
  }

  @Test func chicksCannotBeShot() {
    let game = makeGame()
    // Away from the player (which sits at screen center) so only the bullet, not
    // a player collision, could remove it.
    game.chicks = [Chick(x: 350, y: game.playerY)]
    game.bullets = [Bullet(x: 350, y: game.playerY)]
    game.collideHenyard()
    #expect(game.chicks.count == 1) // a bullet on a chick does nothing
  }

  @Test func playerEscapesChicksByWrapping() {
    let game = makeGame()
    game.chicks = [Chick(x: 100, y: game.playerY), Chick(x: 300, y: game.playerY)]
    // Put the player past the right edge so the next frame wraps it; fleeing off
    // an edge leaves the chicks behind.
    game.playerX = game.screenSize.width + 5
    game.update(currentTime: .now) // first frame just seeds the clock (dt = 0)
    game.update(currentTime: Date(timeIntervalSinceNow: 0.05))
    #expect(game.chicks.isEmpty)
    #expect(game.playerX <= game.screenSize.width) // wrapped back on-screen
  }

  @Test func chickHurtsPlayer() {
    let game = makeGame()
    game.playerHealth = 1.0
    game.chicks = [Chick(x: game.playerX, y: game.playerY)]
    game.collideHenyard()
    #expect(game.playerHealth < 1.0)
    #expect(game.chicks.isEmpty)
  }

  // MARK: Mechanic 5 — robot boss

  @Test func bossSpawnsAtScoreThreshold() {
    let game = makeGame()
    game.targets = [Target(kind: .rooster, x: 200, y: 100)]
    game.nextBossScore = GameState.bossScoreThreshold
    game.score = GameState.bossScoreThreshold + 10
    game.updateRobot(dt: 0.016)
    #expect(game.robotBrain != nil)
  }

  @Test func bossLocksOntoTopmostEnemyAndFreezesIt() {
    let game = makeGame()
    let top = Target(kind: .rooster, x: 120, y: 60)
    let low = Target(kind: .beret, x: 280, y: 600)
    game.targets = [low, top]
    game.nextBossScore = GameState.bossScoreThreshold
    game.score = GameState.bossScoreThreshold + 10
    game.updateRobot(dt: 0.016)
    #expect(game.robotBrain?.targetTargetID == top.id) // the higher enemy, not the low one
    #expect(game.targets.first { $0.id == top.id }?.isFrozen == true)
    #expect(game.targets.first { $0.id == low.id }?.isFrozen == false)
  }

  @Test func convertedMinionRestsAtHorizontalCenter() throws {
    let game = makeGame()
    // Host is off-center (near the right), but the minion should still rest center.
    game.targets = [Target(kind: .rooster, x: 300, y: 80)]
    game.nextBossScore = GameState.bossScoreThreshold
    game.score = GameState.bossScoreThreshold + 10
    var iterations = 0
    while game.robotMinion == nil && iterations < 40 {
      game.updateRobot(dt: 0.5)
      iterations += 1
    }
    let minion = try #require(game.robotMinion)
    #expect(minion.homeX == game.screenSize.width / 2)
    #expect(minion.homeY == 80) // vertical position unchanged
  }

  @Test func frozenHostDoesNotScroll() {
    let game = makeGame()
    var host = Target(kind: .rooster, x: 200, y: 80)
    host.isFrozen = true
    game.targets = [host]
    game.update(currentTime: .now) // seeds the clock
    game.update(currentTime: Date(timeIntervalSinceNow: 0.1))
    #expect(game.targets.first { $0.id == host.id }?.y == 80)
  }

  @Test func minionArmsMustBeShotOffFirst() {
    let game = makeGame()
    game.robotMinion = RobotMinion(x: 200, y: 300, homeX: 200, homeY: 300, assetName: "RoosterIconPreview")
    // A bullet in the left hit-zone removes the left arm, not the body.
    game.bullets = [Bullet(x: 200 - (GameState.robotArmHitZone + 6), y: 300)]
    game.collideRobot()
    #expect(game.robotMinion?.hasLeftArm == false)
    #expect(game.robotMinion != nil)
  }

  @Test func disarmedMinionIsDefeatedWithRewardShower() {
    let game = makeGame()
    var minion = RobotMinion(x: 200, y: 300, homeX: 200, homeY: 300, assetName: "RoosterIconPreview")
    minion.hasLeftArm = false
    minion.hasRightArm = false
    game.robotMinion = minion
    game.drops = []
    game.bullets = [Bullet(x: 200, y: 300)]
    let before = game.score
    game.collideRobot()
    #expect(game.robotMinion == nil)
    #expect(game.score > before)
    #expect(!game.drops.isEmpty) // the climax reward shower
  }
}
