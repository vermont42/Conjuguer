//
//  Achievement.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation

// Semantic ordering: as Game Center lists them, the patterns level by level, then the verbs, then
// the être verbs.
/// Game Center achievements for mastery milestones, never for volume of play. Each counts what the
/// Mastery page counts, an item in the third box or beyond, so the record that fills the page also
/// earns these. Their titles, descriptions, and artwork live in App Store Connect; see
/// docs/game_center_setup.md.
enum Achievement: String, CaseIterable {
  case patternsBeginner
  case patternsElementary
  case patternsIntermediate
  case patternsAdvanced
  case pillars
  case tenIrregulars
  case twentyFiveIrregulars
  case fiftyIrregulars
  case houseOfÊtre

  struct Progress: Equatable {
    let mastered: Int
    let required: Int

    var isComplete: Bool {
      mastered >= required
    }

    /// What Game Center takes, from 0 to 100.
    var percentComplete: Double {
      guard required > 0 else {
        return 0
      }
      return Double(min(mastered, required)) / Double(required) * 100
    }
  }

  // Achievement IDs are permanent in App Store Connect, so these must match
  // docs/game_center_setup.md exactly and never change, even if an achievement is renamed.
  var identifier: String {
    switch self {
    case .patternsBeginner:
      return "conjuguer.achievement.patterns.beginner"
    case .patternsElementary:
      return "conjuguer.achievement.patterns.elementary"
    case .patternsIntermediate:
      return "conjuguer.achievement.patterns.intermediate"
    case .patternsAdvanced:
      return "conjuguer.achievement.patterns.advanced"
    case .pillars:
      return "conjuguer.achievement.verbs.pillars"
    case .tenIrregulars:
      return "conjuguer.achievement.verbs.core10"
    case .twentyFiveIrregulars:
      return "conjuguer.achievement.verbs.core25"
    case .fiftyIrregulars:
      return "conjuguer.achievement.verbs.core50"
    case .houseOfÊtre:
      return "conjuguer.achievement.etre"
    }
  }

  /// Game Center's points, at most 100 each and 1,000 in all. App Store Connect fixes a value
  /// once the achievement has been live.
  var points: Int {
    switch self {
    case .patternsBeginner:
      return 10
    case .patternsElementary, .pillars, .tenIrregulars, .houseOfÊtre:
      return 25
    case .patternsIntermediate, .twentyFiveIrregulars:
      return 50
    case .patternsAdvanced, .fiftyIrregulars:
      return 100
    }
  }

  var patternLevel: QuizLevel? {
    switch self {
    case .patternsBeginner:
      return .beginner
    case .patternsElementary:
      return .elementary
    case .patternsIntermediate:
      return .intermediate
    case .patternsAdvanced:
      return .advanced
    case .pillars, .tenIrregulars, .twentyFiveIrregulars, .fiftyIrregulars, .houseOfÊtre:
      return nil
    }
  }

  static func progress(in record: PracticeRecord) -> [Achievement: Progress] {
    let masteredCore = Set(coreVerbs.filter { isFullyMastered($0, in: record) }.map(\.dictionaryKey))
    let pillarKeys = Set(pillarVerbs.map(\.dictionaryKey))
    let être = houseOfÊtreItems
    var result: [Achievement: Progress] = [:]
    for achievement in allCases {
      switch achievement {
      case .patternsBeginner, .patternsElementary, .patternsIntermediate, .patternsAdvanced:
        let patterns = Mastery.patterns(at: achievement.patternLevel ?? .beginner)
        result[achievement] = Progress(mastered: masteredCount(of: patterns, in: record), required: patterns.count)
      case .pillars:
        result[achievement] = Progress(mastered: masteredCore.intersection(pillarKeys).count, required: pillarKeys.count)
      case .tenIrregulars:
        result[achievement] = Progress(mastered: masteredCore.count, required: 10)
      case .twentyFiveIrregulars:
        result[achievement] = Progress(mastered: masteredCore.count, required: 25)
      case .fiftyIrregulars:
        result[achievement] = Progress(mastered: masteredCore.count, required: coreVerbs.count)
      case .houseOfÊtre:
        result[achievement] = Progress(mastered: masteredCount(of: être, in: record), required: être.count)
      }
    }
    return result
  }

  /// The Mastery page's fifty most frequent irregular verbs, the same from Elementary up, whose
  /// band first holds fifty.
  static var coreVerbs: [Verb] {
    Mastery.coreVerbs(at: .elementary).map(\.verb)
  }

  /// être, avoir, aller, faire, and the four modals, all among the fifty.
  static var pillarVerbs: [Verb] {
    coreVerbs.filter(QuizDraw.isCore)
  }

  /// A verb counts once every key conjugation it has is mastered: the présent, the passé composé,
  /// and the futur, whatever the level, so that a Beginner who has met only the présent earns
  /// nothing. The passé simple, which only Advanced asks, is not required.
  static func isFullyMastered(_ verb: Verb, in record: PracticeRecord) -> Bool {
    let stems = Mastery.stems(PracticeItem.Stem.shown, of: verb)
    return !stems.isEmpty && stems.allSatisfy { stem in
      record.masteryState(of: .keyConjugation(verb: verb.dictionaryKey, stem: stem)) == .mastered
    }
  }

  /// The seventeen verbs of the maison d'être, the être verbs French schools teach.
  static let houseOfÊtreKeys = [
    "aller", "venir", "devenir", "revenir", "partir", "sortir exit", "naître", "mourir",
    "arriver", "entrer", "monter", "rester", "tomber", "retourner", "passer", "rentrer", "descendre"
  ]

  /// The passés composés of the maison d'être as the record keeps them: an irregular verb's key
  /// conjugation, and every person of the -er and -re patterns with être that the regular verbs
  /// share.
  static var houseOfÊtreItems: [PracticeItem] {
    var seen: Set<String> = []
    let items = houseOfÊtreKeys
      .compactMap { Verb.verbs[$0] }
      .flatMap { verb in PersonNumber.allCases.map { PracticeItem.exercised(by: .passéComposé($0), of: verb) } }
    return items.filter { seen.insert($0.key).inserted }
  }

  private static func masteredCount(of items: [PracticeItem], in record: PracticeRecord) -> Int {
    items.filter { record.masteryState(of: $0) == .mastered }.count
  }
}

extension GameCenter {
  /// Sends the achievements' progress as the record now stands: when the player signs in, when a
  /// quiz finishes or is quit, and when a review card is revealed, the moments an item can reach
  /// the third box. Measuring every level's patterns costs a moment, so nothing is measured while
  /// signed out. `GameCenterReal` sends only what has risen.
  func reportAchievements(in record: PracticeRecord) {
    guard isAuthenticated else {
      return
    }
    reportAchievementProgress(Achievement.progress(in: record).mapValues(\.percentComplete))
  }
}
