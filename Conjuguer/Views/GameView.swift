//
//  GameView.swift
//  Conjuguer
//
//  Renders and drives the Arc de Triomphe minigame. The frame clock is a
//  TimelineView(.animation); each tick forwards the timeline date to
//  GameState.update(currentTime:), which advances all motion. Rendering is plain
//  SwiftUI: a ZStack of .position()'d sprites over a black background.
//

import SwiftUI

struct GameView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var gameState = GameState()

  // Geometry of the bottom-left move controls, shared by `arrowControls` (which
  // lays the buttons out) and `controlRect(in:)` (which carves out the no-fire
  // zone). Keeping them in one place stops the tap test from drifting from the
  // visible buttons.
  private static let arrowButtonSize: CGFloat = 64
  private static let arrowSpacing = Layout.tripleDefaultSpacing
  private static let arrowInset = Layout.tripleDefaultSpacing
  // A little forgiveness around the visible buttons so a near-miss tap on a
  // control doesn't fire instead.
  private static let controlPadding = Layout.defaultSpacing

  // The rectangle (in `.local` coordinates) occupied by the arrow controls,
  // padded slightly. Taps inside it are reserved for movement and never fire.
  private func controlRect(in size: CGSize) -> CGRect {
    let width = Self.arrowButtonSize * 2 + Self.arrowSpacing
    let height = Self.arrowButtonSize
    let originX = Self.arrowInset - Self.controlPadding
    let originY = size.height - Self.arrowInset - height - Self.controlPadding
    return CGRect(
      x: originX,
      y: originY,
      width: width + Self.controlPadding * 2,
      height: height + Self.controlPadding * 2
    )
  }

  var body: some View {
    GeometryReader { geometry in
      TimelineView(.animation) { timeline in
        gameField
          .offset(shakeOffset)
          .onChange(of: timeline.date) { _, newDate in
            gameState.update(currentTime: newDate)
          }
      }
      .contentShape(Rectangle())
      .onTapGesture(coordinateSpace: .local) { location in
        // Tapping anywhere outside the arrow-control rectangle fires a bullet;
        // taps inside it are reserved for the move controls and never fire.
        if !controlRect(in: geometry.size).contains(location) {
          gameState.fire()
        }
      }
      .overlay(alignment: .topLeading) {
        endGameButton
      }
      .overlay(alignment: .topTrailing) {
        statusLabels
      }
      .overlay(alignment: .bottomLeading) {
        arrowControls
      }
      .overlay {
        if gameState.phase == .gameOver {
          gameOverOverlay
        }
      }
      .onAppear {
        gameState.configure(screenSize: geometry.size)
      }
      .onChange(of: geometry.size) { _, newSize in
        gameState.updateScreenSize(newSize)
      }
    }
    // The GeometryReader respects the safe area, so its size and the edge
    // overlays (quit button, score, arrows) stay clear of the status bar and
    // home indicator. The black still bleeds full-screen behind everything.
    .background(Color.black.ignoresSafeArea())
    .onDisappear {
      gameState.stopMusic()
    }
  }

  // Mechanic 5: a brief screen shake on boss conversion/defeat. Deterministic
  // (driven by sineTime) so it needs no per-frame randomness in the view.
  private var shakeOffset: CGSize {
    let shake = gameState.screenShake
    guard shake > 0 else {
      return .zero
    }
    let intensity = shake / GameState.screenShakeDuration
    let magnitude = GameState.screenShakeMagnitude * intensity
    return CGSize(
      width: CGFloat(sin(gameState.sineTime * 47)) * magnitude,
      height: CGFloat(cos(gameState.sineTime * 53)) * magnitude
    )
  }

  private var gameField: some View {
    ZStack(alignment: .topLeading) {
      Color.black

      ForEach(gameState.stars) { star in
        Circle()
          .fill(Color.white.opacity(star.opacity))
          .frame(width: star.size, height: star.size)
          .position(x: star.x, y: star.y)
      }

      ForEach(gameState.smoke) { puff in
        smokeView(puff)
      }

      ForEach(gameState.targets) { target in
        let size = GameState.targetSize * target.renderScale
        Image(target.kind.assetName)
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .frame(width: size, height: size)
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          .position(x: target.x, y: target.y)
      }

      mechanicSprites

      ForEach(gameState.deathEffects) { effect in
        deathEffectView(effect)
      }

      ForEach(gameState.drops) { drop in
        Text(drop.kind.emoji)
          .font(.system(size: GameState.dropSize))
          .position(x: drop.x, y: drop.y)
      }

      projectileSprites

      Image("ArcDeTriompheIconPreview")
        .resizable()
        .aspectRatio(1, contentMode: .fit)
        .frame(width: GameState.playerSize, height: GameState.playerSize)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(max(0.1, gameState.playerHealth))
        .overlay {
          if gameState.shieldActive {
            Circle()
              .stroke(Color.cyan, lineWidth: 3)
              .frame(width: GameState.playerSize + 14, height: GameState.playerSize + 14)
              .opacity(0.6 + 0.4 * sin(gameState.sineTime * 3))
          }
        }
        .position(x: gameState.playerX, y: gameState.playerY)
        .accessibilityHidden(true)
    }
  }

  @ViewBuilder private var projectileSprites: some View {
    ForEach(gameState.bullets) { bullet in
      Text("🇫🇷")
        .font(.system(size: GameState.bulletSize))
        .position(x: bullet.x, y: bullet.y)
    }

    ForEach(gameState.enemyBullets) { bullet in
      Text("🏴󠁧󠁢󠁥󠁮󠁧󠁿")
        .font(.system(size: GameState.enemyBulletSize))
        .position(x: bullet.x, y: bullet.y)
    }

    // Mechanic 5: the robot minion's fast red/yellow rectangle bullets.
    ForEach(gameState.robotBullets) { bullet in
      RoundedRectangle(cornerRadius: 2, style: .continuous)
        .fill(bullet.isRed ? Color.customRed : Color.yellow)
        .frame(width: GameState.robotBulletSize * 0.5, height: GameState.robotBulletSize)
        .position(x: bullet.x, y: bullet.y)
    }
  }

  // Mechanics 1–5 sprites, grouped to keep the main ZStack readable.
  @ViewBuilder private var mechanicSprites: some View {
    // Mechanic 1: telegraph an incoming dive with ⚠️ in the target column.
    ForEach(gameState.targets.filter { $0.isDiving && $0.diveWarningTimer > 0 }) { target in
      Text("⚠️")
        .font(.system(size: GameState.targetSize * 0.7))
        .position(x: target.homeX, y: GameState.targetSize)
        .opacity(0.5 + 0.5 * sin(gameState.sineTime * 6))
    }

    // Mechanic 3: musical-note dots, chandelier, ghosts.
    ForEach(gameState.noteDots) { dot in
      Text("🎵")
        .font(.system(size: GameState.dotSize))
        .position(x: dot.x, y: dot.y)
    }

    if let chandelier = gameState.chandelier {
      Text("🔮")
        .font(.system(size: GameState.chandelierSize))
        .position(x: chandelier.x, y: chandelier.y)
    }

    ForEach(gameState.ghosts) { ghost in
      Text(ghost.emoji)
        .font(.system(size: GameState.ghostSize))
        .position(x: ghost.x, y: ghost.y)
    }

    // Mechanic 4: hen, eggs, chicks.
    if let hen = gameState.hen {
      Text("🐔")
        .font(.system(size: GameState.henSize))
        .position(x: hen.x, y: hen.y)
    }

    ForEach(gameState.eggs) { egg in
      Text("🥚")
        .font(.system(size: GameState.eggSize))
        .position(x: egg.x, y: egg.y)
    }

    ForEach(gameState.chicks) { chick in
      Text("🐣")
        .font(.system(size: GameState.chickSize))
        .position(x: chick.x, y: chick.y)
    }

    // Mechanic 2: the bouncing ball.
    if let ball = gameState.ball {
      Text("⚽")
        .font(.system(size: GameState.ballSize))
        .position(x: ball.x, y: ball.y)
    }

    robotSprites
  }

  @ViewBuilder private var robotSprites: some View {
    // Mechanic 5: brain-core (+ lock-on bolt) and the robot minion (+ arms).
    if let brain = gameState.robotBrain {
      Text("🧠")
        .font(.system(size: GameState.brainSize))
        .position(x: brain.x, y: brain.y)
      if brain.showBolt {
        Text("⚡")
          .font(.system(size: GameState.brainSize * 0.8))
          .position(x: brain.x, y: brain.y + GameState.brainSize * 0.7)
          .opacity(0.5 + 0.5 * sin(gameState.sineTime * 8))
      }
    }

    if let minion = gameState.robotMinion {
      Text("🤖")
        .font(.system(size: GameState.robotMinionSize))
        .position(x: minion.x, y: minion.y)
      if minion.hasLeftArm {
        Text("🦾")
          .font(.system(size: GameState.robotMinionSize * 0.55))
          .scaleEffect(x: -1, y: 1)
          .position(x: minion.x - GameState.robotMinionSize * 0.55, y: minion.y)
      }
      if minion.hasRightArm {
        Text("🦾")
          .font(.system(size: GameState.robotMinionSize * 0.55))
          .position(x: minion.x + GameState.robotMinionSize * 0.55, y: minion.y)
      }
    }
  }

  private func smokeView(_ puff: Smoke) -> some View {
    let colors: [Color] = [.customBlue, .white, .customRed]
    let scale = 1.0 - puff.progress
    return Circle()
      .fill(colors[puff.colorIndex])
      .frame(width: 10 * scale, height: 10 * scale)
      .opacity(Double(scale) * 0.8)
      .position(x: puff.x, y: puff.y)
  }

  private func deathEffectView(_ effect: DeathEffect) -> some View {
    let scale = 1.0 - effect.progress
    let opacity = Double(scale)
    let radius = effect.progress * 25

    return ZStack {
      if let assetName = effect.assetName {
        Image(assetName)
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .frame(width: GameState.targetSize, height: GameState.targetSize)
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          .scaleEffect(scale)
          .opacity(opacity)
      }

      ForEach(0 ..< DeathEffect.particleCount, id: \.self) { index in
        let angle = Double(index) * (.pi * 2.0 / Double(DeathEffect.particleCount))
        Circle()
          .fill(index.isMultiple(of: 2) ? Color.customRed : Color.customBlue)
          .frame(width: 8 * scale, height: 8 * scale)
          .opacity(opacity)
          .offset(x: cos(angle) * radius, y: sin(angle) * radius)
      }
    }
    .position(x: effect.x, y: effect.y)
  }

  private var endGameButton: some View {
    Button {
      dismiss()
    } label: {
      Image(systemName: "xmark.circle.fill")
        .font(.largeTitle)
        .foregroundStyle(Color.customRed)
        .padding(Layout.doubleDefaultSpacing)
    }
    .accessibilityLabel(L.Game.endGame)
    .accessibilityIdentifier("button_game_endGame")
  }

  private var statusLabels: some View {
    VStack(alignment: .trailing, spacing: Layout.defaultSpacing) {
      Text(L.Game.score(gameState.score))
        .foregroundStyle(.white)
        .accessibilityIdentifier("label_game_score")

      Text(L.Game.health(Int((gameState.playerHealth * 100).rounded())))
        .foregroundStyle(healthColor)
        .accessibilityIdentifier("label_game_health")
    }
    .font(buttonFont)
    .padding(Layout.doubleDefaultSpacing)
  }

  private var healthColor: Color {
    let percent = Int((gameState.playerHealth * 100).rounded())
    if percent > 50 {
      return .customGreen
    } else if percent > 25 {
      return .yellow
    } else {
      return .customRed
    }
  }

  private var gameOverOverlay: some View {
    ZStack {
      Color.black.opacity(0.75)
        .ignoresSafeArea()

      VStack(spacing: Layout.doubleDefaultSpacing) {
        Text(L.Game.gameOver)
          .font(.largeTitle)
          .bold()
          .foregroundStyle(Color.customRed)

        Text(L.Game.finalScore(gameState.finalScore))
          .font(.title2)
          .foregroundStyle(.white)

        if gameState.isNewHighScore {
          Text(L.Game.newHighScore)
            .font(.headline)
            .foregroundStyle(Color.customGreen)
        } else {
          Text(L.Game.highScore(gameState.highScore))
            .font(.headline)
            .foregroundStyle(.white)
        }

        Button(L.Game.playAgain) {
          gameState.restart()
        }
        .funButton()
        .padding(.top, Layout.doubleDefaultSpacing)
        .accessibilityIdentifier("button_game_playAgain")

        Button(L.Game.quit) {
          dismiss()
        }
        .funButton(tint: .customRed)
        .accessibilityIdentifier("button_game_quit")
      }
      .padding(Layout.tripleDefaultSpacing)
    }
  }

  private var arrowControls: some View {
    HStack(spacing: Self.arrowSpacing) {
      arrowButton(systemName: "arrowtriangle.left.fill", label: L.Game.moveLeft) { isPressed in
        gameState.movingLeft = isPressed
      }

      arrowButton(systemName: "arrowtriangle.right.fill", label: L.Game.moveRight) { isPressed in
        gameState.movingRight = isPressed
      }
    }
    .padding(.leading, Self.arrowInset)
    .padding(.bottom, Self.arrowInset)
  }

  private func arrowButton(
    systemName: String,
    label: String,
    setPressed: @escaping (Bool) -> Void
  ) -> some View {
    Image(systemName: systemName)
      .font(.system(size: 44, weight: .bold))
      .foregroundStyle(.white)
      .frame(width: Self.arrowButtonSize, height: Self.arrowButtonSize)
      .contentShape(Rectangle())
      // minimumDistance 0 makes this a press-and-hold control: pressed on touch
      // down, released on lift, so the player moves only while the arrow is held.
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in
            setPressed(true)
          }
          .onEnded { _ in
            setPressed(false)
          }
      )
      .accessibilityLabel(label)
  }
}
