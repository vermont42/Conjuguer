//
//  GameModels.swift
//  Conjuguer
//

import CoreGraphics
import Foundation

struct Bullet: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
}

struct Target: Identifiable {
  enum Kind: CaseIterable {
    case rooster
    case croissant
    case beret

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

struct EnemyBullet: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  let velocityX: CGFloat
  let velocityY: CGFloat
}

enum DropKind: CaseIterable {
  case baguette // restores health
  case grape    // grants autofire
  case cheese   // grants a temporary shield

  var emoji: String {
    switch self {
    case .baguette:
      return "🥖"
    case .grape:
      return "🍇"
    case .cheese:
      return "🧀"
    }
  }
}

struct Drop: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  let kind: DropKind
}

struct DeathEffect: Identifiable {
  static let duration: CGFloat = 0.5
  static let particleCount = 8

  let id = UUID()
  let x: CGFloat
  let y: CGFloat
  // nil for the player's hit burst, where only the particles should show (no
  // shrinking sprite, since the player itself persists).
  let assetName: String?
  var age: CGFloat = 0

  var progress: CGFloat {
    min(age / Self.duration, 1.0)
  }
}

struct Star: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  let size: CGFloat
  let opacity: Double
}

enum GamePhase {
  case playing
  case gameOver
}
