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
    #expect(names.first == VerbSearch.meanings(of: verb.translation).first)
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
