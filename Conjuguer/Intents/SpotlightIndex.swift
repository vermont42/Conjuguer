//
//  SpotlightIndex.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/27/26.
//

/// The named Spotlight index that holds the verbs' entries.
protocol SpotlightIndex {
  func deleteAllEntries() async throws
  func index(_ entities: [VerbEntity]) async throws
}
