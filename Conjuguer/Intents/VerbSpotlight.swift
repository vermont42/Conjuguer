//
//  VerbSpotlight.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import AppIntents
import os

/// Conjuguer's Spotlight entries, one per verb entry, in a named index. Each can be found by its
/// infinitive, by its gloss's meanings, and by its conjugations, so that typing vais or "go" on
/// the Home Screen can find aller.
enum VerbSpotlight {
  struct Text: Hashable, Sendable {
    /// The gloss's meanings, then the key conjugations (va, est allé, ira). Spotlight shows the
    /// first under the description, so the gloss leads.
    let alternateNames: [String]

    let keywords: [String]

    /// Shown under the title: the key conjugations, which stand alone with no label.
    let description: String
  }

  static let indexName = "verbs"

  /// Raise this when the entries' contents change, so that every install indexes again.
  private static let format = 1
  static let indexedVersionKey = "spotlightIndexedVersion"

  /// Indexing takes several seconds of the main actor, which the Conjugator needs for the key
  /// conjugations, so it runs only when the app's version or the entries' format has changed
  /// since the last index that succeeded.
  static var version: String {
    let info = Bundle.main.infoDictionary
    let marketing = info?["CFBundleShortVersionString"] as? String ?? ""
    let build = info?["CFBundleVersion"] as? String ?? ""
    return "\(format)-\(marketing)-\(build)"
  }

  // Each window's launch asks for an index, and two windows that launch together would
  // otherwise both spend those seconds.
  private(set) static var isIndexing = false

  /// Deletes the index's entries before writing them again, so that a verb that left
  /// `verbs.xml`, or an entry whose key changed when its infinitive gained a second entry, leaves
  /// Spotlight too. A failed delete still indexes, which keeps the entries current, but is not
  /// recorded as done, so the next launch tries again.
  static func indexVerbsIfNeeded(
    index: SpotlightIndex = SpotlightIndexReal(name: indexName),
    store: GetterSetter = Current.getterSetter,
    verbs: [Verb] = Array(Verb.verbs.values),
    map: ConjugationMap = .bundled
  ) async {
    let version = version
    guard !isIndexing, store.get(key: indexedVersionKey) != version else {
      return
    }
    isIndexing = true
    defer {
      isIndexing = false
    }
    let conjugations = await Task.detached(priority: .utility) {
      conjugationsByVerb(in: map)
    }.value
    var entities: [VerbEntity] = []
    for (offset, verb) in verbs.enumerated() {
      entities.append(VerbEntity(verb: verb, spotlight: text(for: verb, conjugations: conjugations[verb.dictionaryKey] ?? [])))
      if offset.isMultiple(of: 100) {
        await Task.yield()
      }
    }
    var deleted = true
    do {
      try await index.deleteAllEntries()
    } catch {
      deleted = false
      Log.spotlight.error("Could not delete the verbs' Spotlight entries: \(error.localizedDescription, privacy: .public)")
    }
    do {
      try await index.index(entities)
      if deleted {
        store.set(key: indexedVersionKey, value: version)
      }
    } catch {
      Log.spotlight.error("Could not index the verbs for Spotlight: \(error.localizedDescription, privacy: .public)")
    }
  }

  static func text(for verb: Verb, conjugations: Set<String>) -> Text {
    let meanings = VerbSearchKeys.meanings(of: verb.translation)
    let keyConjugations = verb.keyConjugations().map { $0.lowercased() }
    return Text(
      alternateNames: (meanings + keyConjugations).uniqued(),
      keywords: (conjugations.sorted() + meanings + meanings.map { "to \($0)" }).uniqued(),
      description: keyConjugations.joined(separator: " · ")
    )
  }

  nonisolated static func conjugationsByVerb(in map: ConjugationMap) -> [String: Set<String>] {
    var conjugations: [String: Set<String>] = [:]
    for (conjugation, keys) in map.verbsByConjugation {
      for key in keys {
        conjugations[key, default: []].insert(conjugation)
      }
    }
    return conjugations
  }

  /// The verb entry a Spotlight result names. App entities' identifiers arrive prefixed with
  /// their type's name ("VerbEntity/aller", seen in Konjugieren on iOS 26.3).
  static func verbKey(fromSpotlightIdentifier identifier: String) -> String {
    let prefix = "\(VerbEntity.self)/"
    return identifier.hasPrefix(prefix) ? String(identifier.dropFirst(prefix.count)) : identifier
  }
}

extension Array where Element: Hashable {
  /// The elements in order, each at its first appearance.
  nonisolated func uniqued() -> [Element] {
    var seen: Set<Element> = []
    return filter { seen.insert($0).inserted }
  }
}
