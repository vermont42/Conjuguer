//
//  VerbLookupTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct VerbLookupTests {
  private func lookup(_ word: String) -> VerbLookup {
    VerbLookup(word: word, verbs: Array(Verb.verbs.values))
  }

  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  private func conjugatedVerbs(_ found: VerbLookup) -> [String] {
    found.findings.compactMap { finding in
      if case .conjugation(_, let verb) = finding {
        return verb.infinitif
      }
      return nil
    }
  }

  @Test func testAnInfinitiveOpensItsPageUnmarked() throws {
    let found = lookup("aller")
    #expect(found.findings == [.infinitive(try verb("aller"))])
    #expect(found.destination == URL.verbDeeplink("aller", source: .lookup))
  }

  @Test func testAnInfinitivesAnswerGivesItsKeyConjugations() {
    #expect(lookup("aller").answer(pronounGender: .masculine).hasSuffix(": va · est allé · ira"))
  }

  @Test func testAPronominalVerbIsNamedWithItsPronoun() {
    let answer = lookup("se souvenir").answer(pronounGender: .masculine)
    #expect(answer.hasPrefix("se souvenir, “"))
    #expect(answer.hasSuffix(": se souvient · s'est souvenu · se souviendra"))
  }

  @Test func testAConjugationOpensItsVerbOnTheMatch() {
    let found = lookup("vais")
    #expect(conjugatedVerbs(found) == ["aller"])
    #expect(found.destination == URL.verbDeeplink("aller", source: .lookup, match: "vais"))
  }

  @Test func testTheAnswerNamesTheCellsAndTheVerb() {
    #expect(lookup("vais").answer(pronounGender: .masculine) == "vais: Indicatif Présent (je) of aller")
  }

  @Test func testAConjugationOfTwoVerbsNamesBothAndOpensTheSearch() {
    let found = lookup("suis")
    #expect(Set(conjugatedVerbs(found)) == ["être", "suivre"])
    #expect(found.destination == URL.searchDeeplink(text: "suis", source: .lookup))
    #expect(found.answer(pronounGender: .masculine).components(separatedBy: "\n").count == 2)
  }

  @Test func testAFoldedConjugationAnswersInTheAppsSpelling() {
    let found = lookup("etait")
    #expect(conjugatedVerbs(found) == ["être"])
    #expect(found.destination == URL.verbDeeplink("être", source: .lookup, match: "était"))
  }

  @Test func testAPronominalCompoundOpensTheAvoirVerbOnItsCell() throws {
    let found = lookup("je me suis levé")
    #expect(conjugatedVerbs(found) == ["lever"])
    let destination = try #require(found.destination)
    let match = try #require(destination.deeplinkQueryValue(named: URL.matchQueryName))
    let marks = try #require(MarkedConjugations(text: match, on: try verb("lever")))
    #expect(marks.contains(.passéComposé(.firstSingular)))
  }

  @Test func testAnEnglishMeaningNamesItsFirstVerbAndOpensTheSearch() throws {
    let found = lookup("go")
    guard case .otherMatches(let first, let count) = found.findings.first else {
      Issue.record("Expected other matches, found \(found.findings)")
      return
    }
    #expect(first == (try verb("aller")))
    #expect(count > 1)
    #expect(found.destination == URL.searchDeeplink(text: "go", source: .lookup))
  }

  @Test func testAMisspellingOffersTheGuess() throws {
    #expect(lookup("venier").findings == [.guess(try verb("venir"), conjugation: nil)])
    #expect(lookup("venier").answer(pronounGender: .masculine).hasSuffix("Perhaps you meant venir."))
  }

  @Test func testNonsenseFindsNothingAndOpensTheTrimmedSearch() {
    let found = lookup("  xyzzyq ")
    #expect(found.findings == [.nothing])
    #expect(found.destination == URL.searchDeeplink(text: "xyzzyq", source: .lookup))
  }
}
