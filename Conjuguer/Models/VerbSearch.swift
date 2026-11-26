//
//  VerbSearch.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// The one matching and ranking rule for verb search, shared by the verb list, the model list,
/// Spotlight, and the Look Up intent so that no two of them can drift.
enum VerbSearch {
  // Cases run best first, and `matches` tries them in this order. Cases that share a tier rank
  // together by frequency: a prefix, a folded prefix, a whole English meaning, and a whole
  // conjugation are about equally strong evidence, so "go" finds aller (whose meaning it is)
  // ahead of gonfler (which it begins), "ai" finds avoir ahead of aimer, and "réa" finds
  // réaliser ahead of réer, of which it is a passé simple. The two exact cases keep separate
  // tiers so that mater, typed, leads mâter.
  enum MatchKind: Int, CaseIterable, Comparable {
    case exactInfinitive
    case exactFoldedInfinitive
    case conjugation
    case infinitivePrefix
    case glossMeaning
    case foldedConjugation
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
      case .conjugation, .infinitivePrefix, .glossMeaning, .foldedConjugation, .foldedInfinitivePrefix:
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
      case .exactFoldedInfinitive, .foldedConjugation, .foldedInfinitivePrefix, .foldedInfinitiveSubstring:
        return true
      case .exactInfinitive, .conjugation, .infinitivePrefix, .glossMeaning, .wholeWordGloss, .infinitiveSubstring, .glossSubstring:
        return false
      }
    }

    var isConjugation: Bool {
      self == .conjugation || self == .foldedConjugation
    }

    static func < (lhs: MatchKind, rhs: MatchKind) -> Bool {
      lhs.rawValue < rhs.rawValue
    }
  }

  struct Match: Equatable {
    let verb: Verb
    let kind: MatchKind
    let conjugation: MatchedConjugation?

    init(verb: Verb, kind: MatchKind, conjugation: MatchedConjugation? = nil) {
      self.verb = verb
      self.kind = kind
      self.conjugation = conjugation
    }
  }

  /// Ranked by tier, then by frequency, whatever order `verbs` arrives in, with one match per
  /// verb, its best. A conjugation is looked up in `conjugations` unless that is nil, as it is
  /// for the Models tab, which names models rather than finding verbs.
  ///
  /// Within a tier, a folded match ranks below a literal one when the query carries an accent or
  /// a ligature. A learner who types pêch wants pêcher ahead of pécher, but one who types pre has
  /// told the search nothing about accents and should see préparer by its frequency, not after
  /// every verb that begins with a bare pre. A word typed as a conjugation spells its accents as
  /// meant, too: mate is mater's, so mâter's mâte and matérialiser wait.
  static func matches(
    for query: String,
    in verbs: [Verb],
    includeGlosses: Bool,
    conjugations index: ConjugationIndex? = ConjugationIndex.bundled
  ) -> [Match] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      return []
    }
    let frenchQuery = frenchQuery(from: trimmed)
    let foldedQuery = fold(frenchQuery)
    let queryIsMarked = foldedQuery != frenchQuery
    let englishQuery = includeGlosses ? glossQuery(from: trimmed) : nil

    var best: [String: Match] = [:]
    var verbsByKey: [String: Verb] = [:]
    for verb in verbs {
      verbsByKey[verb.dictionaryKey] = verb
      if let kind = kind(of: keys(for: verb), frenchQuery: frenchQuery, foldedQuery: foldedQuery, englishQuery: englishQuery) {
        best[verb.id] = Match(verb: verb, kind: kind)
      }
    }

    let conjugationResults = index.map { conjugationMatches(for: trimmed, index: $0) { verbsByKey[$0] } } ?? []
    let typedAConjugation = conjugationResults.contains { $0.kind == .conjugation }

    func isDemoted(_ match: Match) -> Bool {
      (queryIsMarked || typedAConjugation) && match.kind.isFolded
    }

    func rank(_ match: Match) -> (Int, Int) {
      (match.kind.tier, isDemoted(match) ? 1 : 0)
    }

    // On a tie, the conjugation wins, because its row can say which cells the query fills.
    for match in conjugationResults {
      if let current = best[match.verb.id], rank(current) < rank(match) {
        continue
      }
      if let current = best[match.verb.id], current.kind.isConjugation, rank(current) <= rank(match) {
        continue
      }
      best[match.verb.id] = match
    }

    func sortKey(_ match: Match) -> (Int, Int, Int) {
      let (tier, demotion) = rank(match)
      return (tier, demotion, match.verb.frequency)
    }

    return best.values.sorted { lhs, rhs in
      let (left, right) = (sortKey(lhs), sortKey(rhs))
      if left != right {
        return left < right
      }
      return lhs.verb.id < rhs.verb.id
    }
  }

  struct Guess: Equatable {
    let verb: Verb
    let conjugation: MatchedConjugation?
  }

  /// What the guess needs of a verb, as values that can leave the main actor.
  nonisolated struct GuessCandidate: Sendable {
    let id: String
    let dictionaryKey: String
    let frequency: Int
    let foldedInfinitifBytes: [UInt8]
    let infinitiveKey: String
  }

  /// A guess by verb id, before its verb and cells are looked up on the main actor.
  nonisolated struct GuessFinding: Equatable, Sendable {
    let verbID: String
    let conjugation: String?
  }

  static func guessCandidates(of verbs: [Verb]) -> [GuessCandidate] {
    verbs.map { verb in
      GuessCandidate(
        id: verb.id,
        dictionaryKey: verb.dictionaryKey,
        frequency: verb.frequency,
        foldedInfinitifBytes: keys(for: verb).foldedInfinitifBytes,
        infinitiveKey: ConjugationMap.key(verb.infinitif)
      )
    }
  }

  static func guess(for query: String, in verbs: [Verb], conjugations index: ConjugationIndex? = ConjugationIndex.bundled) -> Guess? {
    guess(for: query, among: guessCandidates(of: verbs), conjugations: index).flatMap { finding in
      guess(from: finding, verbNamed: { id in verbs.first { $0.id == id } })
    }
  }

  /// The finding's verb, and the cells of its conjugation, which only the main actor can read.
  static func guess(from finding: GuessFinding, verbNamed: (String) -> Verb?) -> Guess? {
    guard let verb = verbNamed(finding.verbID) else {
      return nil
    }
    let cells = finding.conjugation.map { verb.conjugations(matching: $0) } ?? []
    let conjugation = finding.conjugation.flatMap { text in
      cells.isEmpty ? nil : MatchedConjugation(text: text, cells: cells)
    }
    return Guess(verb: verb, conjugation: conjugation)
  }

  /// The verb whose folded infinitive, or one of whose folded conjugations, is fewest edits from
  /// the folded query, offered when a search found nothing: finnissons guesses finir through
  /// finissons. On a tie, an infinitive beats a conjugation, and then the more frequent verb
  /// wins. Nil when no verb is near enough to be a plausible misspelling, and when the task
  /// running it is cancelled, since a guess for text since edited is not wanted. Conjugations
  /// are considered only for a query that is one word once its pronouns are dropped, and only
  /// with an index.
  nonisolated static func guess(
    for query: String,
    among candidates: [GuessCandidate],
    conjugations index: ConjugationIndex? = ConjugationIndex.bundled
  ) -> GuessFinding? {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    let foldedQuery = Array(fold(frenchQuery(from: trimmed)))
    guard !trimmed.isEmpty, !foldedQuery.isEmpty else {
      return nil
    }
    // The conjugation's spelling breaks the last tie, so that a guess never depends on the
    // order in which the index happens to hold its folds.
    var best: (finding: GuessFinding, rank: (distance: Int, isConjugation: Int, frequency: Int, id: String, spelling: String))?

    func consider(_ candidate: GuessCandidate, conjugation: String?, distance: Int) {
      let rank = (distance: distance, isConjugation: conjugation == nil ? 0 : 1, frequency: candidate.frequency, id: candidate.id, spelling: conjugation ?? "")
      if let current = best, current.rank <= rank {
        return
      }
      best = (GuessFinding(verbID: candidate.id, conjugation: conjugation), rank)
    }

    let maxDistance = maxGuessDistance(forQueryLength: foldedQuery.count)
    var infinitiveDistance = BoundedEditDistance(query: Array(String(foldedQuery).utf8))
    var candidatesByKey: [String: GuessCandidate] = [:]
    for candidate in candidates {
      candidatesByKey[candidate.dictionaryKey] = candidate
      let distance = candidate.foldedInfinitifBytes.withUnsafeBufferPointer { bytes in
        infinitiveDistance.measure(bytes, atMost: maxDistance)
      }
      if let distance {
        consider(candidate, conjugation: nil, distance: distance)
      }
    }

    let words = ConjugationQuery(trimmed).words
    if let index, words.count == 1, let word = words.first, !Task.isCancelled {
      let foldedWord = fold(word)
      let wordMaxDistance = min(maxGuessDistance(forQueryLength: foldedWord.count), best?.rank.distance ?? .max)
      if let nearest = index.nearestFolds(to: foldedWord, within: wordMaxDistance) {
        for conjugation in nearest.folds.flatMap(index.conjugations(folding:)) {
          for verbKey in index.map.verbs(for: conjugation) {
            guard let candidate = candidatesByKey[verbKey] else {
              continue
            }
            let isInfinitive = conjugation == candidate.infinitiveKey
            consider(candidate, conjugation: isInfinitive ? nil : conjugation, distance: nearest.distance)
          }
        }
      }
    }

    return Task.isCancelled ? nil : best?.finding
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
    let foldedInfinitifBytes: [UInt8]
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
      foldedInfinitifBytes: Array(fold(infinitif).utf8),
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
