//
//  FrequencyBand.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// The most frequent verbs, in three widths. The verb of the day and the random verb draw from
/// `top1000`, and the quiz's levels from all three (`QuizLevel.band`).
enum FrequencyBand: Int, CaseIterable {
  case top100 = 100
  case top300 = 300
  case top1000 = 1000

  var rankLimit: Int {
    rawValue
  }
}

extension Verb {
  @MainActor private static var bandCache: [FrequencyBand: [Verb]] = [:]
  @MainActor private static var cachedVerbsByFrequency: [Verb] = []

  /// `frequency` is a rank without gaps, but the two entries of a doubled infinitive (sortir to
  /// exit and to obtain) share one, so a band holds its count of infinitives and may hold an
  /// entry or two more than that.
  func isIn(_ band: FrequencyBand) -> Bool {
    frequency <= band.rankLimit
  }

  @MainActor static func verbs(in band: FrequencyBand) -> [Verb] {
    if let cached = bandCache[band], !cached.isEmpty {
      return cached
    }
    let verbs = Verb.verbs.values
      .filter { $0.isIn(band) }
      .sorted { ($0.frequency, $0.dictionaryKey) < ($1.frequency, $1.dictionaryKey) }
    bandCache[band] = verbs
    return verbs
  }

  @MainActor static var verbsByFrequency: [Verb] {
    if !cachedVerbsByFrequency.isEmpty {
      return cachedVerbsByFrequency
    }
    cachedVerbsByFrequency = Verb.verbs.values.sorted { ($0.frequency, $0.dictionaryKey) < ($1.frequency, $1.dictionaryKey) }
    return cachedVerbsByFrequency
  }
}
