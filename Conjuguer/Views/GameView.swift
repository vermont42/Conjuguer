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

  var body: some View {
    GeometryReader { geometry in
      TimelineView(.animation) { timeline in
        gameField
          .onChange(of: timeline.date) { _, newDate in
            gameState.update(currentTime: newDate)
          }
      }
      .contentShape(Rectangle())
      .onTapGesture(coordinateSpace: .local) { location in
        // Tapping the right half fires a bullet; the left half holds the arrows.
        if location.x > geometry.size.width / 2 {
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

  private var gameField: some View {
    ZStack(alignment: .topLeading) {
      Color.black

      ForEach(gameState.stars) { star in
        Circle()
          .fill(Color.white.opacity(star.opacity))
          .frame(width: star.size, height: star.size)
          .position(x: star.x, y: star.y)
      }

      ForEach(gameState.targets) { target in
        Image(target.kind.assetName)
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .frame(width: GameState.targetSize, height: GameState.targetSize)
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          .position(x: target.x, y: target.y)
      }

      ForEach(gameState.deathEffects) { effect in
        deathEffectView(effect)
      }

      ForEach(gameState.drops) { drop in
        Text(drop.kind.emoji)
          .font(.system(size: GameState.dropSize))
          .position(x: drop.x, y: drop.y)
      }

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
    HStack(spacing: Layout.tripleDefaultSpacing) {
      arrowButton(systemName: "arrowtriangle.left.fill", label: L.Game.moveLeft) { isPressed in
        gameState.movingLeft = isPressed
      }

      arrowButton(systemName: "arrowtriangle.right.fill", label: L.Game.moveRight) { isPressed in
        gameState.movingRight = isPressed
      }
    }
    .padding(.leading, Layout.tripleDefaultSpacing)
    .padding(.bottom, Layout.tripleDefaultSpacing)
  }

  private func arrowButton(
    systemName: String,
    label: String,
    setPressed: @escaping (Bool) -> Void
  ) -> some View {
    Image(systemName: systemName)
      .font(.system(size: 44, weight: .bold))
      .foregroundStyle(.white)
      .frame(width: 64, height: 64)
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
