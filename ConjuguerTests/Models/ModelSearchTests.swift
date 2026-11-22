//
//  ModelSearchTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct ModelSearchTests {
  private func matches(_ query: String) -> [ModelSearch.Match] {
    ModelSearch.matches(for: query, in: Array(VerbModel.models.values), verbs: Array(Verb.verbs.values))
  }

  @Test func testExemplarFindsItsModel() {
    let first = matches("venir").first
    #expect(first?.model.exemplar == "venir")
    #expect(first?.verb == nil)
  }

  @Test func testVerbFindsItsModel() throws {
    let devenir = try #require(Verb.verbs["devenir"])
    let first = matches("devenir").first
    #expect(first?.model.id == devenir.model)
    #expect(first?.verb?.infinitif == "devenir")
  }

  @Test func testExemplarMatchesPrecedeVerbMatches() {
    let results = matches("pr")
    let firstVerbMatch = results.firstIndex { $0.verb != nil } ?? results.count
    #expect(firstVerbMatch > 0)
    #expect(results[firstVerbMatch...].allSatisfy { $0.verb != nil })
  }

  @Test func testEachModelAppearsOnce() {
    let ids = matches("re").map(\.model.id)
    #expect(ids.count == Set(ids).count)
  }

  @Test func testFoldingReachesModels() {
    #expect(matches("ceder").first?.model.exemplar == "céder")
  }

  @Test func testNonsenseFindsNoModel() {
    #expect(matches("xqzw").isEmpty)
  }
}
