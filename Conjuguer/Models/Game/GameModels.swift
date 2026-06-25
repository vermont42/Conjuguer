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
  // Mechanic 1 (dive-bombers): a target normally falls straight down, but a
  // selected one peels off into a sine-modulated parabola toward the player's
  // column. While diving it scales up so it reads as "charged."
  var isDiving = false
  var diveWarningTimer: CGFloat = 0 // > 0 while telegraphing the dive with ⚠️
  var diveProgress: CGFloat = 0     // 0 … 1 across the dive arc
  var diveStartY: CGFloat = 0
  var homeX: CGFloat = 0            // target column (player's x when the dive launched)
  // Mechanic 5 (robot boss): the brain-core freezes its host enemy near the top
  // so it stops scrolling and the fight stays up there.
  var isFrozen = false

  var renderScale: CGFloat {
    isDiving && diveWarningTimer <= 0 ? 1.3 : 1.0
  }
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

// MARK: - Mechanic 1: Tricolore dive smoke trail

struct Smoke: Identifiable {
  static let duration: CGFloat = 0.45

  let id = UUID()
  let x: CGFloat
  let y: CGFloat
  // 0 = bleu, 1 = blanc, 2 = rouge — cycles to draw the Tricolore trail.
  let colorIndex: Int
  var age: CGFloat = 0

  var progress: CGFloat {
    min(age / Self.duration, 1.0)
  }
}

// MARK: - Mechanic 2: Le Ballon des Bleus (bouncing ball)

struct GameBall: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  var velocityX: CGFloat
  var velocityY: CGFloat
  var remainingTime: CGFloat
}

// MARK: - Mechanic 3: Le Fantôme de l'Opéra (ghost hunt)

enum GhostPhase {
  case descending
  case chasing
  case fleeing
  case devoured
  case exiting
}

struct Ghost: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  var phase: GhostPhase = .descending
  var dotTimer: CGFloat = 0
  var devourTimer: CGFloat = 0

  var emoji: String {
    switch phase {
    case .descending, .chasing, .exiting:
      return "👻"
    case .fleeing:
      return "😱"
    case .devoured:
      return "💨"
    }
  }
}

struct NoteDot: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
}

struct Chandelier: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
}

// MARK: - Mechanic 4: La Basse-Cour (hen, eggs, hatchlings)

struct Hen: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  var movingRight: Bool
  var layTimer: CGFloat = 0
}

struct Egg: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  var velocityY: CGFloat
  var hatchTimer: CGFloat = 0
}

struct Chick: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
}

// MARK: - Mechanic 5: Goldorak (converter robot mini-boss)

enum BrainPhase {
  case ascending
  case lockedOn
  case converting
}

struct RobotBrain {
  var x: CGFloat
  var y: CGFloat
  var phase: BrainPhase = .ascending
  var hitsRemaining = 3
  var targetTargetID: UUID?
  var lockOnTimer: CGFloat = 0
  var showBolt = false
}

struct RobotMinion {
  var x: CGFloat
  var y: CGFloat
  var homeX: CGFloat
  var homeY: CGFloat
  var hasLeftArm = true
  var hasRightArm = true
  var isDiving = false
  var diveProgress: CGFloat = 0
  var diveStartY: CGFloat = 0
  var divePauseTimer: CGFloat = 0
  var fireTimer: CGFloat = 0
  let assetName: String

  var isArmed: Bool {
    hasLeftArm || hasRightArm
  }
}

struct RobotBullet: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  let velocityX: CGFloat
  let velocityY: CGFloat
  let isRed: Bool // alternates red / yellow
}

/// The cyclic "special" mechanics — only one runs at a time, picked from a
/// shuffled bag on a timer. The dive-bombers (Mechanic 1) and the robot boss
/// (Mechanic 5) are scheduled separately (ambient timer / score threshold).
enum SpecialMechanic: CaseIterable {
  case ball     // Mechanic 2
  case ghosts   // Mechanic 3
  case henyard  // Mechanic 4
}
