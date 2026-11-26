//
//  SeededRandomNumberGenerator.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// SplitMix64: the same seed gives the same sequence on every device and in every process. It
/// draws every learner's verb of the day, the day's challenge, and the widget's quiz options, and
/// it lets tests check what a random draw produces over many runs.
struct SeededRandomNumberGenerator: RandomNumberGenerator {
  private var state: UInt64

  init(seed: UInt64) {
    state = seed
  }

  mutating func next() -> UInt64 {
    state &+= 0x9E3779B97F4A7C15
    var z = state
    z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
    z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
    return z ^ (z >> 31)
  }
}
