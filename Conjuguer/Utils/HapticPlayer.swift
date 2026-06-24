//
//  HapticPlayer.swift
//  Conjuguer
//

import UIKit

enum HapticPlayer {
  static func playImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
  }
}
