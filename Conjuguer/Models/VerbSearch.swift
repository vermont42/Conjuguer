//
//  VerbSearch.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// The one matching and ranking rule for verb search. The verb list and the model list use it
/// today, and reverse lookup, Spotlight, and the Look Up intent are to use it, so that no two of
/// them can drift.
enum VerbSearch {
  // Cases run best first, and `matches` tries them in this order. Cases that share a tier rank
  // together by frequency: a prefix, a folded prefix, and a whole English meaning are about
  // equally strong evidence, so "go" finds aller (whose meaning it is) ahead of gonfler (which it
  // begins), while "sort" still finds sortir ahead of trier. The two exact cases keep separate
  // tiers so that mater, typed, leads mâter.
  enum MatchKind: Int, CaseIterable, Comparable {
    case exactInfinitive
    case exactFoldedInfinitive
    case infinitivePrefix
    case glossMeaning
    case foldedInfinitivePrefix
    case wholeWordGloss
    case infinitiveSubstring
    case foldedInfinitiveSubstring
    case glossSubstring

    var tier: Int {
      switch self {
      case .exactInfinitive:
        return 0
      case .exactFoldedInfinitive:
        return 1
      case .infinitivePrefix, .glossMeaning, .foldedInfinitivePrefix:
        return 2
      case .wholeWordGloss:
        return 3
      case .infinitiveSubstring, .foldedInfinitiveSubstring:
        return 4
      case .glossSubstring:
        return 5
      }
    }

    var isFolded: Bool {
      switch self {
      case .exactFoldedInfinitive, .foldedInfinitivePrefix, .foldedInfinitiveSubstring:
        return true
      case .exactInfinitive, .infinitivePrefix, .glossMeaning, .wholeWordGloss, .infinitiveSubstring, .glossSubstring:
        return false
      }
    }

    static func < (lhs: MatchKind, rhs: MatchKind) -> Bool {
      lhs.rawValue < rhs.rawValue
    }
  }

  struct Match: Equatable {
    let verb: Verb
    let kind: MatchKind
  }

  /// Ranked by tier, then by frequency, whatever order `verbs` arrives in.
  ///
  /// Within a tier, a folded match ranks below a literal one only when the query carries an
  /// accent or a ligature. A learner who types pêch wants pêcher ahead of pécher, but one who
  /// types pre has told the search nothing about accents and should see préparer by its
  /// frequency, not after every verb that begins with a bare pre.
  static func matches(for query: String, in verbs: [Verb], includeGlosses: Bool) -> [Match] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      return []
    }
    let frenchQuery = frenchQuery(from: trimmed)
    let foldedQuery = fold(frenchQuery)
    let queryIsMarked = foldedQuery != frenchQuery
    let englishQuery = includeGlosses ? glossQuery(from: trimmed) : nil

    let found = verbs.compactMap { verb -> Match? in
      kind(of: keys(for: verb), frenchQuery: frenchQuery, foldedQuery: foldedQuery, englishQuery: englishQuery)
        .map { Match(verb: verb, kind: $0) }
    }

    func sortKey(_ match: Match) -> (Int, Int, Int) {
      (match.kind.tier, queryIsMarked && match.kind.isFolded ? 1 : 0, match.verb.frequency)
    }

    return found.sorted { lhs, rhs in
      let (left, right) = (sortKey(lhs), sortKey(rhs))
      if left != right {
        return left < right
      }
      return lhs.verb.id < rhs.verb.id
    }
  }

  /// The verb whose folded infinitive is fewest edits from the folded query, offered when a
  /// search found nothing. On a tie, the more frequent verb wins. Nil when no verb is near
  /// enough to be a plausible misspelling.
  static func closestVerb(to query: String, in verbs: [Verb]) -> Verb? {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    let foldedQuery = Array(fold(frenchQuery(from: trimmed)))
    guard !trimmed.isEmpty, !foldedQuery.isEmpty else {
      return nil
    }
    let maxDistance = maxGuessDistance(forQueryLength: foldedQuery.count)
    var best: (verb: Verb, rank: (distance: Int, frequency: Int, id: String))?
    for verb in verbs {
      let candidate = Array(keys(for: verb).foldedInfinitif)
      guard abs(candidate.count - foldedQuery.count) <= maxDistance else {
        continue
      }
      let distance = editDistance(foldedQuery, candidate)
      guard distance <= maxDistance else {
        continue
      }
      let rank = (distance: distance, frequency: verb.frequency, id: verb.id)
      if let current = best, current.rank <= rank {
        continue
      }
      best = (verb, rank)
    }
    return best?.verb
  }

  // One edit in three letters, and never more than three, keeps a guess recognizable: venier
  // finds venir, but a four-letter query never "finds" a verb that shares one letter with it.
  nonisolated static func maxGuessDistance(forQueryLength length: Int) -> Int {
    min(3, max(1, length / 3))
  }

  /// Optimal string alignment distance: insertions, deletions, substitutions, and swaps of two
  /// adjacent letters each cost one, because a swap is the commonest slip on a keyboard (vneir
  /// for venir).
  nonisolated static func editDistance(_ lhs: [Character], _ rhs: [Character]) -> Int {
    guard !lhs.isEmpty else {
      return rhs.count
    }
    guard !rhs.isEmpty else {
      return lhs.count
    }
    var twoRowsBack = [Int](repeating: 0, count: rhs.count + 1)
    var previousRow = Array(0...rhs.count)
    var currentRow = [Int](repeating: 0, count: rhs.count + 1)
    for i in 1...lhs.count {
      currentRow[0] = i
      for j in 1...rhs.count {
        let substitutionCost = lhs[i - 1] == rhs[j - 1] ? 0 : 1
        currentRow[j] = min(previousRow[j] + 1, currentRow[j - 1] + 1, previousRow[j - 1] + substitutionCost)
        if i > 1, j > 1, lhs[i - 1] == rhs[j - 2], lhs[i - 2] == rhs[j - 1] {
          currentRow[j] = min(currentRow[j], twoRowsBack[j - 2] + 1)
        }
      }
      (twoRowsBack, previousRow, currentRow) = (previousRow, currentRow, twoRowsBack)
    }
    return previousRow[rhs.count]
  }

  /// Collapses what a learner without a French keyboard types: accents, the cedilla, and the
  /// ligatures, so that etre finds être and manoeuvrer finds manœuvrer. For matching only.
  nonisolated static func fold(_ text: String) -> String {
    text.lowercased()
      .replacingOccurrences(of: "œ", with: "oe")
      .replacingOccurrences(of: "æ", with: "ae")
      .folding(options: .diacriticInsensitive, locale: nil)
  }

  /// Infinitives are stored without their reflexive pronoun, so "se souvenir" and "s'asseoir"
  /// mean souvenir and asseoir. A bare s' is a pronoun still being typed, so it searches as s
  /// rather than finding nothing and sounding the trombone mid-word.
  nonisolated static func frenchQuery(from query: String) -> String {
    let lowered = query.lowercased().replacingOccurrences(of: "’", with: "'")
    for pronoun in ["se ", "s'"] where lowered.hasPrefix(pronoun) {
      let stripped = lowered.dropFirst(pronoun.count).trimmingCharacters(in: .whitespaces)
      return stripped.isEmpty ? "s" : stripped
    }
    return lowered
  }

  /// Glosses are stored without a leading "to", so a learner who types "to go" means "go".
  nonisolated static func glossQuery(from query: String) -> String {
    let lowered = query.lowercased()
    guard lowered.hasPrefix("to ") else {
      return lowered
    }
    let stripped = lowered.dropFirst(3).trimmingCharacters(in: .whitespaces)
    return stripped.isEmpty ? lowered : stripped
  }

  /// The meanings a gloss lists, each without its parenthetical note: "can (food)" is a meaning
  /// "can", and "hand over, pay, turn up (slang)" holds three.
  nonisolated static func meanings(of gloss: String) -> [String] {
    gloss.lowercased()
      .split(whereSeparator: { $0 == "," || $0 == ";" })
      .map { meaning in
        meaning.replacingOccurrences(of: #"\([^)]*\)"#, with: "", options: .regularExpression)
          .trimmingCharacters(in: .whitespaces)
      }
      .filter { !$0.isEmpty }
  }

  nonisolated static func containsWholeWord(_ word: String, in text: String) -> Bool {
    var searchRange = text.startIndex..<text.endIndex
    while let range = text.range(of: word, range: searchRange) {
      let letterBefore = range.lowerBound > text.startIndex && text[text.index(before: range.lowerBound)].isLetter
      let letterAfter = range.upperBound < text.endIndex && text[range.upperBound].isLetter
      if !letterBefore && !letterAfter {
        return true
      }
      searchRange = text.index(after: range.lowerBound)..<text.endIndex
    }
    return false
  }

  private struct Keys {
    let infinitif: String
    let foldedInfinitif: String
    let gloss: String
    let meanings: [String]
  }

  private static var keysCache: [String: (source: (String, String), keys: Keys)] = [:]

  // Keyed by id but checked against the verb's text, so that a test's made-up verb never reads
  // the keys of a real verb that shares its id.
  private static func keys(for verb: Verb) -> Keys {
    let source = (verb.infinitif, verb.translation)
    if let cached = keysCache[verb.id], cached.source == source {
      return cached.keys
    }
    let infinitif = verb.infinitif.lowercased()
    let keys = Keys(
      infinitif: infinitif,
      foldedInfinitif: fold(infinitif),
      gloss: verb.translation.lowercased(),
      meanings: meanings(of: verb.translation)
    )
    keysCache[verb.id] = (source, keys)
    return keys
  }

  private static func kind(of keys: Keys, frenchQuery: String, foldedQuery: String, englishQuery: String?) -> MatchKind? {
    if keys.infinitif == frenchQuery {
      return .exactInfinitive
    }
    if keys.foldedInfinitif == foldedQuery {
      return .exactFoldedInfinitive
    }
    if keys.infinitif.hasPrefix(frenchQuery) {
      return .infinitivePrefix
    }
    if let englishQuery, keys.meanings.contains(englishQuery) {
      return .glossMeaning
    }
    if keys.foldedInfinitif.hasPrefix(foldedQuery) {
      return .foldedInfinitivePrefix
    }
    if let englishQuery, containsWholeWord(englishQuery, in: keys.gloss) {
      return .wholeWordGloss
    }
    if keys.infinitif.contains(frenchQuery) {
      return .infinitiveSubstring
    }
    if keys.foldedInfinitif.contains(foldedQuery) {
      return .foldedInfinitiveSubstring
    }
    if let englishQuery, keys.gloss.contains(englishQuery) {
      return .glossSubstring
    }
    return nil
  }
}
