//
//  GameState.swift
//  Conjuguer
//

import Observation
import SwiftUI

@MainActor
@Observable
final class GameState {
  static let playerSize: CGFloat = 64.0
  static let playerBottomInset: CGFloat = 112.0
  static let playerSpeed: CGFloat = 320.0
  static let bulletSize: CGFloat = 36.0
  static let bulletSpeed: CGFloat = 620.0
  static let fireInterval: CGFloat = 0.3
  static let targetSize: CGFloat = 52.0
  static let scrollSpeed: CGFloat = 90.0
  static let spawnInterval: CGFloat = 0.7
  static let starCount = 60

  static let scorePerKill = 5
  static let healthLossPerHit: CGFloat = 0.25
  static let healthRestoreAmount: CGFloat = 0.25

  static let enemyFireInterval: CGFloat = 6.0
  static let enemyBulletSpeed: CGFloat = 320.0
  static let enemyBulletSize: CGFloat = 30.0

  static let dropIntervalRange: ClosedRange<CGFloat> = 10.0 ... 30.0
  static let dropFallSpeed: CGFloat = 200.0
  static let dropSize: CGFloat = 40.0

  static func randomDropInterval() -> CGFloat {
    CGFloat.random(in: dropIntervalRange)
  }

  static let shieldDuration: CGFloat = 6.0
  static let autofireDuration: CGFloat = 5.0
  static let autofireInterval: CGFloat = 0.3
  static let autofireVolume: Float = 0.5

  var screenSize: CGSize = .zero
  var playerX: CGFloat = 0.0
  var playerHealth: CGFloat = 1.0
  var phase: GamePhase = .playing
  var bullets: [Bullet] = []
  var enemyBullets: [EnemyBullet] = []
  var targets: [Target] = []
  var drops: [Drop] = []
  var deathEffects: [DeathEffect] = []
  var stars: [Star] = []
  var score = 0
  var finalScore = 0
  var highScore = 0
  var isNewHighScore = false

  var shieldActive = false
  var autofireActive = false
  var sineTime: Double = 0.0

  var movingLeft = false
  var movingRight = false

  private var lastUpdateTime: Date?
  private var fireCooldown: CGFloat = 0.0
  private var spawnCooldown: CGFloat = 0.0
  private var enemyFireCooldown: CGFloat = GameState.enemyFireInterval
  private var baguetteCooldown: CGFloat = GameState.randomDropInterval()
  private var grapeCooldown: CGFloat = GameState.randomDropInterval()
  private var cheeseCooldown: CGFloat = GameState.randomDropInterval()
  private var shieldTimer: CGFloat = 0.0
  private var autofireTimer: CGFloat = 0.0
  private var autofireCooldown: CGFloat = 0.0
  private var autofireSound: Sound = .longFire1
  private var didConfigure = false

  var playerY: CGFloat {
    screenSize.height - Self.playerBottomInset
  }

  func configure(screenSize: CGSize) {
    self.screenSize = screenSize
    guard !didConfigure, screenSize.width > 0, screenSize.height > 0 else {
      return
    }
    didConfigure = true
    highScore = Current.settings.gameHighScore
    seedWorld()
    Current.soundPlayer.startMusic()
  }

  func restart() {
    seedWorld()
    Current.soundPlayer.startMusic()
  }

  func stopMusic() {
    Current.soundPlayer.stopMusic()
  }

  private func seedWorld() {
    phase = .playing
    playerX = screenSize.width / 2
    playerHealth = 1.0
    score = 0
    finalScore = 0
    isNewHighScore = false

    bullets = []
    enemyBullets = []
    targets = []
    drops = []
    deathEffects = []

    shieldActive = false
    autofireActive = false
    shieldTimer = 0
    autofireTimer = 0
    autofireCooldown = 0

    fireCooldown = 0
    spawnCooldown = 0
    enemyFireCooldown = Self.enemyFireInterval
    baguetteCooldown = Self.randomDropInterval()
    grapeCooldown = Self.randomDropInterval()
    cheeseCooldown = Self.randomDropInterval()
    lastUpdateTime = nil

    stars = (0 ..< Self.starCount).map { _ in
      Star(
        x: CGFloat.random(in: 0 ... screenSize.width),
        y: CGFloat.random(in: 0 ... screenSize.height),
        size: CGFloat.random(in: 1.0 ... 2.5),
        opacity: Double.random(in: 0.15 ... 0.5)
      )
    }

    for _ in 0 ..< 5 {
      targets.append(
        Target(
          kind: Target.Kind.allCases.randomElement() ?? .rooster,
          x: CGFloat.random(in: Self.targetSize ... (screenSize.width - Self.targetSize)),
          y: CGFloat.random(in: 0 ... (screenSize.height / 2))
        )
      )
    }
  }

  func fire() {
    guard phase == .playing, fireCooldown <= 0 else {
      return
    }
    bullets.append(Bullet(x: playerX, y: playerY - Self.playerSize / 2))
    fireCooldown = Self.fireInterval
    Current.soundPlayer.play(.pop, shouldDebounce: false)
  }

  func update(currentTime: Date) {
    let dt: CGFloat
    if let last = lastUpdateTime {
      dt = CGFloat(currentTime.timeIntervalSince(last))
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime

    // Skip the first frame and any large hitch (e.g. returning from background).
    guard dt > 0, dt < 1, didConfigure, phase == .playing else {
      return
    }

    sineTime += Double(dt) * 3.0

    updateCooldowns(dt: dt)
    updatePlayer(dt: dt)
    updateBullets(dt: dt)
    updateEnemyBullets(dt: dt)
    updateStars(dt: dt)
    updateTargets(dt: dt)
    spawnTargets(dt: dt)
    updateDrops(dt: dt)
    updateDeathEffects(dt: dt)
    updateShieldAndAutofire(dt: dt)
    attemptEnemyFire(dt: dt)
    attemptDrops(dt: dt)
    resolveBulletHits()
    resolvePlayerHits()
    collectDrops()
    checkGameOver()
  }

  private func updateCooldowns(dt: CGFloat) {
    if fireCooldown > 0 {
      fireCooldown -= dt
    }
  }

  private func updatePlayer(dt: CGFloat) {
    let step = Self.playerSpeed * dt

    if movingLeft && !movingRight {
      playerX -= step
    } else if movingRight && !movingLeft {
      playerX += step
    }

    // Wrap horizontally around the screen edges.
    if playerX < 0 {
      playerX += screenSize.width
    } else if playerX > screenSize.width {
      playerX -= screenSize.width
    }
  }

  private func updateBullets(dt: CGFloat) {
    let distance = Self.bulletSpeed * dt
    for index in bullets.indices {
      bullets[index].y -= distance
    }
    bullets.removeAll { $0.y < -Self.bulletSize }
  }

  private func updateEnemyBullets(dt: CGFloat) {
    for index in enemyBullets.indices {
      enemyBullets[index].x += enemyBullets[index].velocityX * dt
      enemyBullets[index].y += enemyBullets[index].velocityY * dt
    }
    enemyBullets.removeAll {
      $0.y > screenSize.height + Self.enemyBulletSize
        || $0.y < -Self.enemyBulletSize
        || $0.x < -Self.enemyBulletSize
        || $0.x > screenSize.width + Self.enemyBulletSize
    }
  }

  private func updateStars(dt: CGFloat) {
    let distance = Self.scrollSpeed * dt
    for index in stars.indices {
      stars[index].y += distance
      if stars[index].y > screenSize.height {
        stars[index].y -= screenSize.height
        stars[index].x = CGFloat.random(in: 0 ... screenSize.width)
      }
    }
  }

  private func updateTargets(dt: CGFloat) {
    let distance = Self.scrollSpeed * dt
    for index in targets.indices {
      targets[index].y += distance
    }
    targets.removeAll { $0.y > screenSize.height + Self.targetSize }
  }

  private func spawnTargets(dt: CGFloat) {
    spawnCooldown -= dt
    guard spawnCooldown <= 0 else {
      return
    }
    spawnCooldown = Self.spawnInterval
    targets.append(
      Target(
        kind: Target.Kind.allCases.randomElement() ?? .rooster,
        x: CGFloat.random(in: Self.targetSize ... (screenSize.width - Self.targetSize)),
        y: -Self.targetSize
      )
    )
  }

  private func updateDrops(dt: CGFloat) {
    let distance = Self.dropFallSpeed * dt
    for index in drops.indices {
      drops[index].y += distance
    }
    drops.removeAll { $0.y > screenSize.height + Self.dropSize }
  }

  private func updateDeathEffects(dt: CGFloat) {
    for index in deathEffects.indices {
      deathEffects[index].age += dt
    }
    deathEffects.removeAll { $0.progress >= 1.0 }
  }

  private func updateShieldAndAutofire(dt: CGFloat) {
    if shieldActive {
      shieldTimer -= dt
      if shieldTimer <= 0 {
        shieldActive = false
        shieldTimer = 0
      }
    }

    if autofireActive {
      autofireTimer -= dt
      if autofireTimer <= 0 {
        autofireActive = false
        autofireTimer = 0
      }
      autofireCooldown -= dt
      if autofireCooldown <= 0 {
        bullets.append(Bullet(x: playerX, y: playerY - Self.playerSize / 2))
        Current.soundPlayer.play(autofireSound, shouldDebounce: false, volume: Self.autofireVolume)
        autofireCooldown = Self.autofireInterval
      }
    }
  }

  /// Indices of targets currently in the top half of the screen.
  private var topHalfTargetIndices: [Int] {
    targets.indices.filter { targets[$0].y > 0 && targets[$0].y <= screenSize.height / 2 }
  }

  private func attemptEnemyFire(dt: CGFloat) {
    enemyFireCooldown -= dt
    guard enemyFireCooldown <= 0 else {
      return
    }
    enemyFireCooldown = Self.enemyFireInterval

    let candidates = topHalfTargetIndices
    guard let shooterIndex = candidates.min(by: { abs(targets[$0].x - playerX) < abs(targets[$1].x - playerX) }) else {
      return
    }

    let shooter = targets[shooterIndex]
    let dx = playerX - shooter.x
    let dy = playerY - shooter.y
    let length = max(1, hypot(dx, dy))
    enemyBullets.append(
      EnemyBullet(
        x: shooter.x,
        y: shooter.y,
        velocityX: dx / length * Self.enemyBulletSpeed,
        velocityY: dy / length * Self.enemyBulletSpeed
      )
    )
    Current.soundPlayer.play(.enemyFire, shouldDebounce: false)
  }

  private func attemptDrops(dt: CGFloat) {
    baguetteCooldown -= dt
    if baguetteCooldown <= 0 {
      baguetteCooldown = Self.randomDropInterval()
      spawnDrop(kind: .baguette)
    }

    grapeCooldown -= dt
    if grapeCooldown <= 0 {
      grapeCooldown = Self.randomDropInterval()
      spawnDrop(kind: .grape)
    }

    cheeseCooldown -= dt
    if cheeseCooldown <= 0 {
      cheeseCooldown = Self.randomDropInterval()
      spawnDrop(kind: .cheese)
    }
  }

  private func spawnDrop(kind: DropKind) {
    guard let dropperIndex = topHalfTargetIndices.randomElement() else {
      return
    }
    let dropper = targets[dropperIndex]
    drops.append(Drop(x: dropper.x, y: dropper.y, kind: kind))
  }

  private func resolveBulletHits() {
    var survivingBullets: [Bullet] = []
    var hitTargetIDs: Set<UUID> = []

    for bullet in bullets {
      var hit = false
      for target in targets where !hitTargetIDs.contains(target.id) {
        if Self.intersects(
          a: CGPoint(x: bullet.x, y: bullet.y),
          aSize: Self.bulletSize,
          b: CGPoint(x: target.x, y: target.y),
          bSize: Self.targetSize
        ) {
          hitTargetIDs.insert(target.id)
          deathEffects.append(DeathEffect(x: target.x, y: target.y, assetName: target.kind.assetName))
          hit = true
          score += Self.scorePerKill
          break
        }
      }
      if !hit {
        survivingBullets.append(bullet)
      }
    }

    if !hitTargetIDs.isEmpty {
      bullets = survivingBullets
      targets.removeAll { hitTargetIDs.contains($0.id) }
      Current.soundPlayer.play(.chomp, shouldDebounce: false, volume: 0.5)
      HapticPlayer.playImpact(.medium)
    }
  }

  private func resolvePlayerHits() {
    // Enemy bullets striking the player.
    let bulletCountBefore = enemyBullets.count
    enemyBullets.removeAll { bullet in
      Self.intersects(
        a: CGPoint(x: bullet.x, y: bullet.y),
        aSize: Self.enemyBulletSize,
        b: CGPoint(x: playerX, y: playerY),
        bSize: Self.playerSize
      )
    }
    if enemyBullets.count != bulletCountBefore {
      registerPlayerHit()
    }

    // Enemies striking the player.
    let targetCountBefore = targets.count
    targets.removeAll { target in
      Self.intersects(
        a: CGPoint(x: target.x, y: target.y),
        aSize: Self.targetSize,
        b: CGPoint(x: playerX, y: playerY),
        bSize: Self.playerSize
      )
    }
    if targets.count != targetCountBefore {
      registerPlayerHit()
    }
  }

  private func registerPlayerHit() {
    deathEffects.append(DeathEffect(x: playerX, y: playerY, assetName: nil))
    if shieldActive {
      HapticPlayer.playImpact(.light)
    } else {
      playerHealth -= Self.healthLossPerHit
      HapticPlayer.playImpact(.heavy)
    }
  }

  private func collectDrops() {
    let caught = drops.filter { drop in
      Self.intersects(
        a: CGPoint(x: drop.x, y: drop.y),
        aSize: Self.dropSize,
        b: CGPoint(x: playerX, y: playerY),
        bSize: Self.playerSize
      )
    }
    guard !caught.isEmpty else {
      return
    }
    let caughtIDs = Set(caught.map(\.id))
    drops.removeAll { caughtIDs.contains($0.id) }
    for drop in caught {
      applyDrop(drop.kind)
    }
  }

  private func applyDrop(_ kind: DropKind) {
    switch kind {
    case .baguette:
      playerHealth = min(1.0, playerHealth + Self.healthRestoreAmount)
    case .grape:
      autofireActive = true
      autofireTimer = Self.autofireDuration
      autofireCooldown = 0
      autofireSound = Sound.randomLongFire
      Current.soundPlayer.play(autofireSound, shouldDebounce: false, volume: Self.autofireVolume)
    case .cheese:
      shieldActive = true
      shieldTimer = Self.shieldDuration
      Current.soundPlayer.play(.shieldActivate, shouldDebounce: false)
    }
    HapticPlayer.playImpact(.light)
  }

  private func checkGameOver() {
    guard playerHealth <= 0, phase == .playing else {
      return
    }
    phase = .gameOver
    finalScore = score
    if finalScore > highScore {
      highScore = finalScore
      isNewHighScore = true
      Current.settings.gameHighScore = finalScore
    }
    Current.soundPlayer.stopMusic()
    Current.soundPlayer.play(.randomSadTrombone, shouldDebounce: false)
  }

  private static func intersects(
    a: CGPoint,
    aSize: CGFloat,
    b: CGPoint,
    bSize: CGFloat
  ) -> Bool {
    abs(a.x - b.x) < (aSize + bSize) / 2 && abs(a.y - b.y) < (aSize + bSize) / 2
  }
}
