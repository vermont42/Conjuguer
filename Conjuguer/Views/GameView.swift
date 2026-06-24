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
        scoreLabel
      }
      .overlay(alignment: .bottomLeading) {
        arrowControls
      }
      .onAppear {
        gameState.configure(screenSize: geometry.size)
      }
    }
    // The GeometryReader respects the safe area, so its size and the edge
    // overlays (quit button, score, arrows) stay clear of the status bar and
    // home indicator. The black still bleeds full-screen behind everything.
    .background(Color.black.ignoresSafeArea())
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

      ForEach(gameState.bullets) { bullet in
        Text("🇫🇷")
          .font(.system(size: GameState.bulletSize))
          .position(x: bullet.x, y: bullet.y)
      }

      Image("ArcDeTriompheIconPreview")
        .resizable()
        .aspectRatio(1, contentMode: .fit)
        .frame(width: GameState.playerSize, height: GameState.playerSize)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .position(x: gameState.playerX, y: gameState.playerY)
        .accessibilityHidden(true)
    }
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

  private var scoreLabel: some View {
    Text(L.Game.score(gameState.score))
      .font(buttonFont)
      .foregroundStyle(.white)
      .padding(Layout.doubleDefaultSpacing)
      .accessibilityIdentifier("label_game_score")
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
