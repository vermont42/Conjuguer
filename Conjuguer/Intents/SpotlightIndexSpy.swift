//
//  SpotlightIndexSpy.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/27/26.
//

final class SpotlightIndexSpy: SpotlightIndex {
  enum Call: Equatable {
    case deleteAll
    case index([String])
  }

  struct Failure: Error {}

  private(set) var calls: [Call] = []
  var deleteFails = false
  var indexFails = false

  func deleteAllEntries() async throws {
    calls.append(.deleteAll)
    if deleteFails {
      throw Failure()
    }
  }

  func index(_ entities: [VerbEntity]) async throws {
    calls.append(.index(entities.map(\.id).sorted()))
    if indexFails {
      throw Failure()
    }
  }
}
