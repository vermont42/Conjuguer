//
//  SpotlightIndexReal.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/27/26.
//

import AppIntents
import CoreSpotlight

// Each call makes its own CSSearchableIndex, which is not Sendable, so that none is held and sent
// to the index's own executor.
struct SpotlightIndexReal: SpotlightIndex {
  let name: String

  func deleteAllEntries() async throws {
    try await CSSearchableIndex(name: name).deleteAllSearchableItems()
  }

  func index(_ entities: [VerbEntity]) async throws {
    try await CSSearchableIndex(name: name).indexAppEntities(entities)
  }
}
