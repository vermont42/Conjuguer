//
//  VerbEntity.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import AppIntents
import CoreSpotlight

/// A verb as App Intents and Spotlight see it. Its identifier is the verb's dictionary key, so
/// that each entry of a doubled infinitive (sortir exit, sortir obtain) is its own.
struct VerbEntity: AppEntity, IndexedEntity {
  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Intent.verbEntityName", defaultValue: "Verb"))
  static let defaultQuery = VerbEntityQuery()

  let id: String
  let title: String
  let translation: String

  /// Set only on the entities that `VerbSpotlight` indexes. A query's entities leave it nil,
  /// because a picker shows only the title and subtitle.
  var spotlight: VerbSpotlight.Text?

  @MainActor init(verb: Verb, spotlight: VerbSpotlight.Text? = nil) {
    id = verb.dictionaryKey
    title = verb.citationInfinitif
    translation = verb.translation
    self.spotlight = spotlight
  }

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(title)", subtitle: "\(translation)")
  }

  var attributeSet: CSSearchableItemAttributeSet {
    let attributes = defaultAttributeSet
    if let spotlight {
      attributes.alternateNames = spotlight.alternateNames
      attributes.keywords = spotlight.keywords
      attributes.contentDescription = spotlight.description
    }
    return attributes
  }
}

struct VerbEntityQuery: EntityStringQuery {
  static let matchLimit = 25

  func entities(for identifiers: [String]) async -> [VerbEntity] {
    await VerbData.ensureLoaded()
    return await MainActor.run {
      identifiers.compactMap { key in
        Verb.verbs[key].map { VerbEntity(verb: $0) }
      }
    }
  }

  // Ranked before the limit, by the verb list's own search, so that the verb asked for is not
  // cut off behind its prefixed relatives.
  func entities(matching string: String) async -> [VerbEntity] {
    await VerbData.ensureLoaded()
    await ConjugationIndex.warmBundled()
    return await MainActor.run {
      VerbSearch.matches(for: string, in: Array(Verb.verbs.values), includeGlosses: true)
        .prefix(Self.matchLimit)
        .map { VerbEntity(verb: $0.verb) }
    }
  }

  func suggestedEntities() async -> [VerbEntity] {
    await VerbData.ensureLoaded()
    return await MainActor.run {
      Verb.verbsByFrequency
        .prefix(10)
        .map { VerbEntity(verb: $0) }
    }
  }
}
