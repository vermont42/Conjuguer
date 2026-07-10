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

  static let diveInterval: CGFloat = 12.0
  static let diveWarningDuration: CGFloat = 0.5
  static let diveDuration: CGFloat = 2.4
  static let diveDepthFactor: CGFloat = 0.7
  static let diveWidthAmplitude: CGFloat = 70.0
  static let diveScoreMultiplier = 2
  static let smokeInterval: CGFloat = 0.045

  // Cyclic specials (mechanics 2–4): one at a time, picked from a shuffled bag.
  static let firstSpecialDelay: CGFloat = 10.0
  static let specialInterval: CGFloat = 18.0

  static let ballSize: CGFloat = 44.0
  static let ballBaseSpeed: CGFloat = 230.0
  static let ballDuration: CGFloat = 15.0
  static let ballSpeedUpPerBounce: CGFloat = 1.08
  static let ballMaxSpeed: CGFloat = 900.0
  // After a ball hit, the player is invulnerable to the ball (and the ball only)
  // for this long, so a single overlap can't register on multiple frames.
  static let ballInvulnerabilityDuration: CGFloat = 1.0
  // After a diving-minion hit, the player is invulnerable to the minion for this
  // long, so one dive pass (which overlaps the player's row for ~20 frames) costs
  // one 25% hit instead of instant death.
  static let minionInvulnerabilityDuration: CGFloat = 1.0

  static let ghostCountRange: ClosedRange<Int> = 2 ... 3
  static let ghostSize: CGFloat = 48.0
  static let ghostDescentSpeed: CGFloat = 55.0
  static let ghostChaseSpeed: CGFloat = 150.0
  static let ghostFleeSpeed: CGFloat = 120.0
  static let ghostExitSpeed: CGFloat = 220.0
  static let ghostDevourScore = 25
  static let dotSize: CGFloat = 24.0
  static let dotScore = 2
  static let dotDropInterval: CGFloat = 0.35
  static let chandelierSize: CGFloat = 40.0
  static let chandelierFallSpeed: CGFloat = 60.0
  static let frightDuration: CGFloat = 5.0
  static let devourDuration: CGFloat = 0.4

  static let henSize: CGFloat = 48.0
  static let henSpeedH: CGFloat = 150.0
  static let henSpeedV: CGFloat = 28.0
  static let henLayInterval: CGFloat = 1.6
  static let eggSize: CGFloat = 30.0
  static let eggInitialFallSpeed: CGFloat = 180.0
  static let eggGravity: CGFloat = 420.0
  static let eggBounceRestitution: CGFloat = 0.6
  static let eggHatchTime: CGFloat = 4.0
  static let eggScore = 5
  static let chickSize: CGFloat = 30.0
  static let chickSpeed: CGFloat = 130.0

  static let bossScoreThreshold = 200
  static let bossScoreStep = 400
  static let brainSize: CGFloat = 44.0
  static let brainDriftSpeed: CGFloat = 220.0
  static let brainScore = 25
  static let boltAppearDelay: CGFloat = 1.0
  static let conversionDelay: CGFloat = 1.0
  static let robotMinionSize: CGFloat = 56.0
  static let robotArmHitZone: CGFloat = 14.0
  static let robotMinionScore = 50
  // The whole dive arc is traversed over this duration, so a longer duration =
  // a slower swoop. 3.7 ≈ 2.6 / 0.7, i.e. 30% slower than before.
  static let robotDiveDuration: CGFloat = 3.7
  static let robotDivePause: CGFloat = 2.0
  static let robotFireInterval: CGFloat = 1.3
  static let robotBulletSize: CGFloat = 16.0
  static let robotBulletSpeed: CGFloat = 480.0
  static let screenShakeDuration: CGFloat = 0.25
  static let screenShakeMagnitude: CGFloat = 9.0

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

  var smoke: [Smoke] = []
  var ball: GameBall?
  var ghosts: [Ghost] = []
  var noteDots: [NoteDot] = []
  var chandelier: Chandelier?
  var frightActive = false
  var hen: Hen?
  var eggs: [Egg] = []
  var chicks: [Chick] = []
  var robotBrain: RobotBrain?
  var robotMinion: RobotMinion?
  var robotBullets: [RobotBullet] = []
  var screenShake: CGFloat = 0.0

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

  // Mechanic scheduling. These are accessed from the GameState+*.swift mechanic
  // extensions, so they are internal (not private) — extensions in other files
  // cannot see file-private members.
  var diveCooldown: CGFloat = GameState.diveInterval
  var smokeCooldown: CGFloat = 0.0
  var smokeColorCycle = 0
  var frightTimer: CGFloat = 0.0
  var specialCooldown: CGFloat = GameState.firstSpecialDelay
  var specialBag: [SpecialMechanic] = []
  var activeSpecial: SpecialMechanic?
  var ballInvulnerabilityTimer: CGFloat = 0.0
  var minionInvulnerabilityTimer: CGFloat = 0.0
  var nextBossScore = GameState.bossScoreThreshold

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
    warmGameGlyphs()
    Current.soundPlayer.warmUpSounds()
    Current.soundPlayer.startMusic()
  }

  // Warm the emoji glyph cache off the main thread at game start so the first
  // on-screen render of each sprite glyph doesn't stall the render thread (~0.5s
  // each, worst for the flag/tag-sequence emoji). Sizes mirror GameView's usage.
  private func warmGameGlyphs() {
    let glyphs: [(String, CGFloat)] = [
      ("🇫🇷", Self.bulletSize),
      ("🏴󠁧󠁢󠁥󠁮󠁧󠁿", Self.enemyBulletSize),
      ("⚽", Self.ballSize),
      ("👻", Self.ghostSize),
      ("😱", Self.ghostSize),
      ("💨", Self.ghostSize),
      ("🐔", Self.henSize),
      ("🥚", Self.eggSize),
      ("🐣", Self.chickSize),
      ("🥖", Self.dropSize),
      ("🍇", Self.dropSize),
      ("🧀", Self.dropSize),
      ("🎵", Self.dotSize),
      ("🔮", Self.chandelierSize),
      ("⚠️", Self.targetSize * 0.7),
      ("🧠", Self.brainSize),
      ("⚡", Self.brainSize * 0.8),
      ("🤖", Self.robotMinionSize),
      ("🦾", Self.robotMinionSize * 0.55)
    ]
    Task.detached(priority: .userInitiated) {
      GlyphWarmer.warm(glyphs)
    }
  }

  func updateScreenSize(_ newSize: CGSize) {
    guard newSize.width > 0, newSize.height > 0 else {
      return
    }
    guard didConfigure else {
      configure(screenSize: newSize)
      return
    }
    let oldSize = screenSize
    guard newSize != oldSize else {
      return
    }
    let dx = (newSize.width - oldSize.width) / 2.0

    for index in targets.indices {
      targets[index].x += dx
      targets[index].homeX += dx
    }
    for index in bullets.indices {
      bullets[index].x += dx
    }
    for index in enemyBullets.indices {
      enemyBullets[index].x += dx
    }
    for index in drops.indices {
      drops[index].x += dx
    }
    for index in ghosts.indices {
      ghosts[index].x += dx
    }
    for index in noteDots.indices {
      noteDots[index].x += dx
    }
    for index in eggs.indices {
      eggs[index].x += dx
    }
    for index in chicks.indices {
      chicks[index].x += dx
    }
    for index in robotBullets.indices {
      robotBullets[index].x += dx
    }
    ball?.x += dx
    chandelier?.x += dx
    hen?.x += dx
    robotBrain?.x += dx
    robotMinion?.x += dx
    robotMinion?.homeX += dx
    playerX = min(max(playerX + dx, 0), newSize.width)

    screenSize = newSize
    reflowStars(dx: dx, oldSize: oldSize, newSize: newSize)
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

    // Reset transient input/animation state so a held arrow at game-over doesn't
    // drift the ship on "Play Again," and the smoke/sine animators start fresh.
    movingLeft = false
    movingRight = false
    sineTime = 0
    smokeCooldown = 0
    smokeColorCycle = 0

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

    smoke = []
    ball = nil
    ghosts = []
    noteDots = []
    chandelier = nil
    frightActive = false
    frightTimer = 0
    hen = nil
    eggs = []
    chicks = []
    robotBrain = nil
    robotMinion = nil
    robotBullets = []
    screenShake = 0
    diveCooldown = Self.diveInterval
    specialCooldown = Self.firstSpecialDelay
    specialBag = []
    activeSpecial = nil
    ballInvulnerabilityTimer = 0
    minionInvulnerabilityTimer = 0
    nextBossScore = Self.bossScoreThreshold

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

  private func reflowStars(dx: CGFloat, oldSize: CGSize, newSize: CGSize) {
    for index in stars.indices {
      stars[index].x += dx
    }

    guard newSize.width > oldSize.width, dx > 0 else {
      stars.removeAll { $0.x < 0 || $0.x > newSize.width }
      return
    }

    // Keep star density uniform: add stars proportional to the new width gained.
    let density = Double(Self.starCount) / Double(oldSize.width)
    let extraCount = Int((density * Double(newSize.width - oldSize.width)).rounded())
    for offset in 0 ..< extraCount {
      let x = offset.isMultiple(of: 2)
        ? CGFloat.random(in: 0 ... dx)
        : CGFloat.random(in: (newSize.width - dx) ... newSize.width)
      stars.append(
        Star(
          x: x,
          y: CGFloat.random(in: 0 ... newSize.height),
          size: CGFloat.random(in: 1.0 ... 2.5),
          opacity: Double.random(in: 0.15 ... 0.5)
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
    let rawDt: CGFloat
    if let last = lastUpdateTime {
      rawDt = CGFloat(currentTime.timeIntervalSince(last))
    } else {
      rawDt = 0
    }
    lastUpdateTime = currentTime

    // Skip the first frame and any large hitch (e.g. returning from background).
    guard rawDt > 0, rawDt < 1, didConfigure, phase == .playing else {
      return
    }

    // Clamp the simulation step so a sub-second hitch (e.g. 0.9s) isn't applied in
    // one giant step — that moves the ball ~810pt at once and can tunnel through the
    // intersection tests. Normal ~1/60s frames are well under this cap.
    let dt = min(rawDt, 1.0 / 30.0)

    // Wrap at 4π so long sessions don't push the phase argument of sin(sineTime * k)
    // into the hundreds of thousands. 4π is an even multiple of 2π and keeps every
    // multiplier used in GameView (integer factors plus the 1.5 hen factor) continuous
    // across the wrap.
    sineTime = (sineTime + Double(dt) * 3.0).truncatingRemainder(dividingBy: 4.0 * .pi)

    updateCooldowns(dt: dt)
    updatePlayer(dt: dt)
    updateBullets(dt: dt)
    updateEnemyBullets(dt: dt)
    updateStars(dt: dt)
    updateTargets(dt: dt)
    updateDivers(dt: dt)
    spawnTargets(dt: dt)
    updateDrops(dt: dt)
    updateDeathEffects(dt: dt)
    updateSmoke(dt: dt)
    updateShieldAndAutofire(dt: dt)
    attemptEnemyFire(dt: dt)
    attemptDrops(dt: dt)
    updateSpecials(dt: dt)
    updateBall(dt: dt)
    updateGhosts(dt: dt)
    updateHenyard(dt: dt)
    updateRobot(dt: dt)
    updateScreenShake(dt: dt)
    resolveBulletHits()
    resolvePlayerHits()
    resolveMechanicCollisions()
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

    // Wrap horizontally around the screen edges. Fleeing off an edge is also the
    // player's escape from the hen-yard's chicks (Mechanic 4), which can't be shot.
    if playerX < 0 {
      playerX += screenSize.width
      escapeChicksThroughEdge()
    } else if playerX > screenSize.width {
      playerX -= screenSize.width
      escapeChicksThroughEdge()
    }
  }

  private func escapeChicksThroughEdge() {
    guard !chicks.isEmpty else {
      return
    }
    chicks.removeAll()
    Current.soundPlayer.play(.chime, shouldDebounce: false)
    HapticPlayer.playImpact(.medium)
  }

  // Player bullets rise at a fixed speed and cull only past the top edge, so
  // (unlike the enemy/robot bullets) they don't use the shared advanceAndCull.
  // internal (not private) so GameProjectileTests can pin this.
  func updateBullets(dt: CGFloat) {
    let distance = Self.bulletSpeed * dt
    for index in bullets.indices {
      bullets[index].y -= distance
    }
    bullets.removeAll { $0.y < -Self.bulletSize }
  }

  func updateEnemyBullets(dt: CGFloat) {
    advanceAndCull(&enemyBullets, size: Self.enemyBulletSize, dt: dt)
  }

  func advanceAndCull<P: MovingProjectile>(_ projectiles: inout [P], size: CGFloat, dt: CGFloat) {
    for index in projectiles.indices {
      projectiles[index].x += projectiles[index].velocityX * dt
      projectiles[index].y += projectiles[index].velocityY * dt
    }
    projectiles.removeAll {
      $0.y > screenSize.height + size
        || $0.y < -size
        || $0.x < -size
        || $0.x > screenSize.width + size
    }
  }

  func homingVelocityTowardPlayer(from source: CGPoint, speed: CGFloat) -> CGVector {
    let dx = playerX - source.x
    let dy = playerY - source.y
    let length = max(1, hypot(dx, dy))
    return CGVector(dx: dx / length * speed, dy: dy / length * speed)
  }

  static func diveArc(t: CGFloat, startY: CGFloat, endY: CGFloat, depth: CGFloat, homeX: CGFloat) -> CGPoint {
    let baselineY = startY + (endY - startY) * t
    let dip = 4 * depth * t * (1 - t)
    let x = homeX + diveWidthAmplitude * CGFloat(sin(Double(t) * .pi * 4))
    return CGPoint(x: x, y: baselineY + dip)
  }

  func firstBulletIndex(hitting center: CGPoint, size: CGFloat) -> Int? {
    bullets.firstIndex { bullet in
      Self.intersects(a: CGPoint(x: bullet.x, y: bullet.y), aSize: Self.bulletSize, b: center, bSize: size)
    }
  }

  func removeOverlappingPlayer<E: GamePositioned>(_ entities: inout [E], size: CGFloat) -> Bool {
    let countBefore = entities.count
    entities.removeAll { entity in
      Self.intersects(
        a: CGPoint(x: entity.x, y: entity.y),
        aSize: size,
        b: CGPoint(x: playerX, y: playerY),
        bSize: Self.playerSize
      )
    }
    return entities.count != countBefore
  }

  func collectOverlappingPlayer<E: GamePositioned & Identifiable>(_ entities: inout [E], size: CGFloat) -> [E] {
    let caught = entities.filter { entity in
      Self.intersects(
        a: CGPoint(x: entity.x, y: entity.y),
        aSize: size,
        b: CGPoint(x: playerX, y: playerY),
        bSize: Self.playerSize
      )
    }
    guard !caught.isEmpty else {
      return []
    }
    let caughtIDs = Set(caught.map(\.id))
    entities.removeAll { caughtIDs.contains($0.id) }
    return caught
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
    // Diving targets (Mechanic 1) are positioned by updateDivers, and a frozen
    // host (Mechanic 5) is held in place by the brain-core, so neither scrolls.
    for index in targets.indices where !targets[index].isDiving && !targets[index].isFrozen {
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

  var topHalfTargetIndices: [Int] {
    targets.indices.filter { targets[$0].y > 0 && targets[$0].y <= screenSize.height / 2 }
  }

  func attemptEnemyFire(dt: CGFloat) {
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
    let velocity = homingVelocityTowardPlayer(
      from: CGPoint(x: shooter.x, y: shooter.y),
      speed: Self.enemyBulletSpeed
    )
    enemyBullets.append(
      EnemyBullet(
        x: shooter.x,
        y: shooter.y,
        velocityX: velocity.dx,
        velocityY: velocity.dy
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
    var didAceKill = false

    for bullet in bullets {
      var hit = false
      for target in targets where !hitTargetIDs.contains(target.id) {
        let hitSize = Self.targetSize * target.renderScale
        if Self.intersects(
          a: CGPoint(x: bullet.x, y: bullet.y),
          aSize: Self.bulletSize,
          b: CGPoint(x: target.x, y: target.y),
          bSize: hitSize
        ) {
          hitTargetIDs.insert(target.id)
          deathEffects.append(DeathEffect(x: target.x, y: target.y, assetName: target.kind.assetName))
          hit = true
          let isAce = target.isDiving && target.diveWarningTimer <= 0
          if isAce {
            didAceKill = true
            score += Self.scorePerKill * Self.diveScoreMultiplier
          } else {
            score += Self.scorePerKill
          }
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
      if didAceKill {
        Current.soundPlayer.play(.randomGun, shouldDebounce: false, volume: 0.7)
        HapticPlayer.playImpact(.heavy)
      } else {
        Current.soundPlayer.play(.chomp, shouldDebounce: false, volume: 0.5)
        HapticPlayer.playImpact(.medium)
      }
    }
  }

  // internal (not private) so GameCollisionTests can characterize the player-hit
  // sweep; collectDrops likewise for the collect-caught shape.
  func resolvePlayerHits() {
    if removeOverlappingPlayer(&enemyBullets, size: Self.enemyBulletSize) {
      registerPlayerHit()
    }

    if removeOverlappingPlayer(&targets, size: Self.targetSize) {
      registerPlayerHit()
    }
  }

  func registerPlayerHit() {
    deathEffects.append(DeathEffect(x: playerX, y: playerY, assetName: nil))
    if shieldActive {
      HapticPlayer.playImpact(.light)
    } else {
      playerHealth -= Self.healthLossPerHit
      HapticPlayer.playImpact(.heavy)
    }
  }

  func collectDrops() {
    let caught = collectOverlappingPlayer(&drops, size: Self.dropSize)
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

  static func intersects(
    a: CGPoint,
    aSize: CGFloat,
    b: CGPoint,
    bSize: CGFloat
  ) -> Bool {
    abs(a.x - b.x) < (aSize + bSize) / 2 && abs(a.y - b.y) < (aSize + bSize) / 2
  }

  func showerDrops(at point: CGPoint, kinds: [DropKind]) {
    for (offset, kind) in kinds.enumerated() {
      let angle = Double(offset) * (.pi * 2 / Double(max(1, kinds.count)))
      drops.append(
        Drop(
          x: point.x + CGFloat(cos(angle)) * 30,
          y: point.y + CGFloat(sin(angle)) * 30,
          kind: kind
        )
      )
    }
  }

  func triggerScreenShake() {
    screenShake = Self.screenShakeDuration
  }

  private func updateScreenShake(dt: CGFloat) {
    guard screenShake > 0 else {
      return
    }
    screenShake = max(0, screenShake - dt)
  }
}
