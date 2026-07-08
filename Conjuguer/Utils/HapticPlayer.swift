//
//  HapticPlayer.swift
//  Conjuguer
//

import UIKit

enum HapticPlayer {
  // Cache one generator per style and prepare() it, rather than allocating a fresh
  // UIImpactFeedbackGenerator per hit (churn, plus weaker/late haptics without prepare()).
  private static var generators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]

  static func playImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = generator(for: style)
    generator.impactOccurred()
    // Re-prepare so the Taptic Engine stays warm for the next hit.
    generator.prepare()
  }

  private static func generator(for style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
    if let existing = generators[style] {
      return existing
    }
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generators[style] = generator
    return generator
  }
}
