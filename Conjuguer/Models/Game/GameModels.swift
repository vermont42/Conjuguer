//
//  GameModels.swift
//  Conjuguer
//
//  Lightweight value types for the Arc de Triomphe minigame. The game is pure
//  SwiftUI (no SpriteKit): GameState owns arrays of these and moves them every
//  frame, GameView renders them with .position() modifiers.
//

import CoreGraphics
import Foundation

/// A French-flag bullet fired upward by the player. Destroyed on leaving the top
/// of the screen or on hitting a target.
struct Bullet: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
}

/// A rooster, croissant, or beret scrolling down the screen for the player to shoot.
struct Target: Identifiable {
  enum Kind: CaseIterable {
    case rooster
    case croissant
    case beret

    /// Asset-catalog name of the sprite (reuses the app-icon preview imagesets).
    var assetName: String {
      switch self {
      case .rooster:
        return "RoosterIconPreview"
      case .croissant:
        return "CroissantIconPreview"
      case .beret:
        return "BeretIconPreview"
      }
    }
  }

  let id = UUID()
  let kind: Target.Kind
  var x: CGFloat
  var y: CGFloat
}

/// A faint background dot that scrolls down to convey forward motion over the
/// black background.
struct Star: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  let size: CGFloat
  let opacity: Double
}
