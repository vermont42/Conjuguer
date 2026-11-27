//
//  VerbSpotlightTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct VerbSpotlightTests {
  private func text(for key: String) throws -> VerbSpotlight.Text {
    let verb = try #require(Verb.verbs[key])
    let conjugations = VerbSpotlight.conjugationsByVerb(in: .bundled)
    return VerbSpotlight.text(for: verb, conjugations: conjugations[key] ?? [])
  }

  @Test func testTheDescriptionIsTheKeyConjugations() throws {
    #expect(try text(for: "aller").description == "va · est allé · ira")
  }

  @Test func testTheGlossLeadsTheAlternateNames() throws {
    let verb = try #require(Verb.verbs["aller"])
    let names = try text(for: "aller").alternateNames
    #expect(names.first == VerbSearchKeys.meanings(of: verb.translation).first)
    #expect(names.contains("est allé"))
  }

  @Test func testTheKeywordsHoldTheConjugationsAndTheGloss() throws {
    let keywords = try text(for: "aller").keywords
    #expect(keywords.contains("vais"))
    #expect(keywords.contains("allées"))
    #expect(keywords.contains("to go"))
    #expect(keywords.count == Set(keywords).count)
  }

  @Test func testAConjugationOfTwoVerbsIsAKeywordOfBoth() {
    let conjugations = VerbSpotlight.conjugationsByVerb(in: .bundled)
    #expect(conjugations["être"]?.contains("suis") == true)
    #expect(conjugations["suivre"]?.contains("suis") == true)
  }

  @Test(arguments: [("VerbEntity/aller", "aller"), ("VerbEntity/haïr France", "haïr France"), ("aller", "aller")])
  func testASpotlightIdentifierNamesTheVerb(identifier: String, key: String) {
    #expect(VerbSpotlight.verbKey(fromSpotlightIdentifier: identifier) == key)
  }

  @Test func testADoubledInfinitiveHasAnEntryForEachMeaning() throws {
    let exit = VerbEntity(verb: try #require(Verb.verbs["sortir exit"]))
    let obtain = VerbEntity(verb: try #require(Verb.verbs["sortir obtain"]))
    #expect(exit.id != obtain.id)
    #expect(exit.title == "sortir")
  }
}

@MainActor
@Suite(.serialized)
struct VerbSpotlightIndexingTests {
  private let map = ConjugationMap(verbsByConjugation: ["vais": ["aller"]])

  private func verbs(_ keys: [String]) throws -> [Verb] {
    try keys.map { try #require(Verb.verbs[$0]) }
  }

  @Test func aReindexDeletesTheEntriesBeforeWritingThem() async throws {
    let index = SpotlightIndexSpy()
    let store = GetterSetterFake()
    await VerbSpotlight.indexVerbsIfNeeded(index: index, store: store, verbs: try verbs(["aller", "parler"]), map: map)
    #expect(index.calls == [.deleteAll, .index(["aller", "parler"])])
    #expect(store.get(key: VerbSpotlight.indexedVersionKey) == VerbSpotlight.version)
  }

  @Test func anIndexOfThisVersionIsNotRepeated() async throws {
    let index = SpotlightIndexSpy()
    let store = GetterSetterFake(dictionary: [VerbSpotlight.indexedVersionKey: VerbSpotlight.version])
    await VerbSpotlight.indexVerbsIfNeeded(index: index, store: store, verbs: try verbs(["aller"]), map: map)
    #expect(index.calls.isEmpty)
  }

  @Test func aFailedDeleteStillIndexesAndTriesAgainNextLaunch() async throws {
    let index = SpotlightIndexSpy()
    index.deleteFails = true
    let store = GetterSetterFake()
    await VerbSpotlight.indexVerbsIfNeeded(index: index, store: store, verbs: try verbs(["aller"]), map: map)
    #expect(index.calls == [.deleteAll, .index(["aller"])])
    #expect(store.get(key: VerbSpotlight.indexedVersionKey) == nil)
  }

  @Test func aFailedIndexIsNotRecorded() async throws {
    let index = SpotlightIndexSpy()
    index.indexFails = true
    let store = GetterSetterFake()
    await VerbSpotlight.indexVerbsIfNeeded(index: index, store: store, verbs: try verbs(["aller"]), map: map)
    #expect(store.get(key: VerbSpotlight.indexedVersionKey) == nil)
  }
}
