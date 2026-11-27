//
//  RelatedVerbs.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// The verbs a verb page leads to: the verbs built on the same base (prendre, apprendre,
/// comprendre, surprendre), and the most frequent verbs of the other bases that share its model.
struct RelatedVerbs: Equatable {
  /// The innermost base, which every verb built on it shares: prendre for apprendre, and couvrir
  /// for redécouvrir, whose own base is découvrir. A verb with no base is its own root.
  let root: String

  /// The verbs built on `root`, the root verb first, then by frequency. The verb whose page this
  /// is does not appear.
  let builtOnRoot: [Verb]

  let model: VerbModel?

  /// The most frequent verb of each other root among the model's verbs, by frequency.
  let modelRelatives: [Verb]

  var isEmpty: Bool {
    builtOnRoot.isEmpty && modelRelatives.isEmpty
  }
}

/// How a verb page finds a verb's base. French marks no prefix in the data, and a suffix match
/// alone fails (oublier ends in lier), so a base counts only when the letters before it are a
/// verbal prefix and the verb's etymology names the base as a word (`~prendre~`), or the pair is
/// one of a few known ones. Measured 2026-11-22: about 1,420 verbs have a base, and of the 300 most
/// frequent, the 65 that do were all right once the false pairs below were removed. See docs/feature_architecture.md § Related Verbs.
enum VerbBase {
  /// The allomorphs of French verbal prefixes, as they appear before a base: ap- in apprendre,
  /// res- in ressortir, d- in décrire. main- and satis- are not prefixes, but maintenir and
  /// satisfaire are built on tenir and faire in the same way.
  static let prefixes = [
    "a", "ab", "abs", "ac", "ad", "af", "ag", "al", "an", "ap", "ar", "as", "at",
    "bien", "circon", "co", "col", "com", "con", "contre", "cor",
    "d", "de", "dé", "des", "dés", "di", "dis",
    "é", "em", "en", "entr", "entre", "es", "ex",
    "il", "im", "in", "inter", "ir",
    "main", "mal", "mau", "mé", "més", "o", "ob",
    "par", "per", "pré", "pro",
    "r", "ra", "re", "ré", "res",
    "satis", "sou", "sous", "sub", "sup", "super", "sur",
    "tra", "trans", "tres"
  ]

  /// The base must be a verb, and three letters is the shortest that is (ouïr aside).
  static let minimumBaseLength = 3

  /// Pairs that pass the rule but are wrong, each because its etymology names the base only to
  /// refute the link (supplier is not plier bent) or because the shared letters are a
  /// coincidence (arriver names English river, considérer the cognate sidérer).
  static let falsePairs: Set<Pair> = [
    Pair(verb: "arriver", base: "river"),
    Pair(verb: "asservir", base: "servir"),
    Pair(verb: "considérer", base: "sidérer"),
    Pair(verb: "débrailler", base: "brailler"),
    Pair(verb: "délibérer", base: "libérer"),
    Pair(verb: "encastrer", base: "castrer"),
    Pair(verb: "enrouer", base: "rouer"),
    Pair(verb: "épisser", base: "pisser"),
    Pair(verb: "supplier", base: "plier")
  ]

  /// Pairs whose etymology names only the Latin verb (advenir's names ~venīre~), found among
  /// prefixed verbs that share an irregular model with a verb that has no base.
  static let knownPairs: Set<Pair> = [
    Pair(verb: "abstraire", base: "traire"),
    Pair(verb: "advenir", base: "venir"),
    Pair(verb: "coopérer", base: "opérer"),
    Pair(verb: "dégénérer", base: "générer"),
    Pair(verb: "précéder", base: "céder"),
    Pair(verb: "régénérer", base: "générer")
  ]

  struct Pair: Hashable {
    let verb: String
    let base: String
  }

  /// The infinitive this one is built on, if any. Of two candidates (rappeler: r+appeler or
  /// ra+ppeler), the longer base wins.
  @MainActor static func base(of infinitif: String) -> String? {
    if let cached = baseCache[infinitif] {
      return cached.base
    }
    let base = base(of: infinitif, etymology: Etymology.text(for:))
    baseCache[infinitif] = CachedBase(base: base)
    return base
  }

  /// The rule itself, uncached, reading each verb's etymology from `etymology`, so that a test can
  /// run it over both languages' etymologies.
  @MainActor static func base(of infinitif: String, etymology: (String) -> String?) -> String? {
    prefixes
      .filter { infinitif.hasPrefix($0) }
      .map { String(infinitif.dropFirst($0.count)) }
      .filter { isBase($0, of: infinitif, etymology: etymology) }
      .max { $0.count < $1.count }
  }

  /// The innermost base, following bases that are themselves built on another: redécouvrir,
  /// découvrir, couvrir.
  @MainActor static func root(of infinitif: String) -> String {
    var root = infinitif
    // The bound guards against a cycle in the data, which no verb has today.
    for _ in 0..<4 {
      guard let base = base(of: root) else {
        break
      }
      root = base
    }
    return root
  }

  @MainActor private static func isBase(_ candidate: String, of infinitif: String, etymology: (String) -> String?) -> Bool {
    guard candidate.count >= minimumBaseLength, Verb.entriesByInfinitif[candidate] != nil else {
      return false
    }
    let pair = Pair(verb: infinitif, base: candidate)
    if knownPairs.contains(pair) {
      return true
    }
    guard !falsePairs.contains(pair) else {
      return false
    }
    return etymology(infinitif)?.contains("~\(candidate)~") == true
  }

  private struct CachedBase {
    let base: String?
  }

  @MainActor private static var baseCache: [String: CachedBase] = [:]
}

extension Verb {
  @MainActor private static var cachedEntriesByInfinitif: [String: [Verb]]?
  @MainActor private static var relatedCache: [String: RelatedVerbs] = [:]

  /// Every entry of each infinitive. Four infinitives have two (sortir to exit and to obtain).
  @MainActor static var entriesByInfinitif: [String: [Verb]] {
    if let cachedEntriesByInfinitif {
      return cachedEntriesByInfinitif
    }
    let index = Dictionary(grouping: Verb.verbs.values) { $0.infinitif }
      .mapValues { $0.sorted { $0.id < $1.id } }
    cachedEntriesByInfinitif = index
    return index
  }

  @MainActor var root: String {
    VerbBase.root(of: infinitif)
  }

  @MainActor var related: RelatedVerbs {
    if let cached = Self.relatedCache[id] {
      return cached
    }
    let related = computeRelated()
    Self.relatedCache[id] = related
    return related
  }

  @MainActor private func computeRelated() -> RelatedVerbs {
    let root = self.root
    let rootEntry = rootEntry(for: root)
    // Every verb built on a root ends in it, since a base is what a prefix leaves.
    let derivatives = Verb.verbs.values
      .filter { $0.infinitif != root && $0.infinitif != infinitif && $0.infinitif.hasSuffix(root) && $0.root == root }
      .sorted(by: Verb.byFrequency)
    let model = VerbModel.models[self.model]
    return RelatedVerbs(
      root: root,
      builtOnRoot: (rootEntry.map { [$0] } ?? []) + derivatives,
      model: model,
      modelRelatives: model.map { modelRelatives(in: $0, excludingRoot: root) } ?? []
    )
  }

  /// The entry of the root to show on this page: none when this verb is the root, and otherwise
  /// the one that shares this verb's model when the root has two (ressortir leads to sortir, to
  /// exit, and assortir to sortir, to obtain).
  @MainActor private func rootEntry(for root: String) -> Verb? {
    guard root != infinitif, let entries = Verb.entriesByInfinitif[root] else {
      return nil
    }
    return entries.first { $0.model == model } ?? entries.first
  }

  @MainActor private func modelRelatives(in model: VerbModel, excludingRoot root: String) -> [Verb] {
    var seenRoots: Set<String> = [root]
    var relatives: [Verb] = []
    for member in model.entriesByFrequency where member.infinitif != infinitif {
      let memberRoot = member.root
      guard !seenRoots.contains(memberRoot) else {
        continue
      }
      seenRoots.insert(memberRoot)
      relatives.append(member)
      if relatives.count == RelatedVerbs.shortListLength {
        break
      }
    }
    return relatives
  }
}

extension RelatedVerbs {
  /// How many verbs a relation shows on the verb page before its "All" chip.
  static let shortListLength = 6
}
