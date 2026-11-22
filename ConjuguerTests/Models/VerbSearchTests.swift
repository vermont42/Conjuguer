//
//  VerbSearchTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct VerbSearchTests {
  private static let frequencyVerbs = Verb.verbs.values.sorted { ($0.frequency, $0.id) < ($1.frequency, $1.id) }

  private static let alphabeticVerbs = Verb.verbs.values.sorted {
    $0.infinitif.compare($1.infinitif, locale: Util.french) == .orderedAscending
  }

  private var frequencyVerbs: [Verb] { Self.frequencyVerbs }

  private var alphabeticVerbs: [Verb] { Self.alphabeticVerbs }

  private func infinitives(_ query: String, in verbs: [Verb]? = nil) -> [String] {
    VerbSearch.matches(for: query, in: verbs ?? frequencyVerbs, includeGlosses: true).map(\.verb.infinitif)
  }

  @Test(arguments: [
    ("etre", "être"),
    ("venir", "venir"),
    ("go", "aller"),
    ("to go", "aller"),
    ("eat", "manger"),
    ("se souvenir", "souvenir"),
    ("s'asseoir", "asseoir"),
    ("s’asseoir", "asseoir"),
    ("manoeuvrer", "manœuvrer"),
    ("oeuvrer", "œuvrer"),
    ("Être", "être"),
    ("  venir ", "venir"),
    ("sort", "sortir"),
    ("eleve", "élever")
  ])
  func testQueryFindsVerbFirst(query: String, expected: String) {
    #expect(infinitives(query).first == expected)
  }

  @Test(arguments: ["etre", "venir", "go", "eat", "pecher"])
  func testRankingIgnoresTheListOrder(query: String) {
    #expect(infinitives(query, in: alphabeticVerbs) == infinitives(query))
  }

  @Test func testVenirLeadsItsDerivativesUnderAlphabetical() {
    let results = infinitives("venir", in: alphabeticVerbs)
    #expect(results.first == "venir")
    #expect(results.contains("advenir"))
  }

  @Test func testUnaccentedQueryShowsAccentPairByFrequency() throws {
    let results = Array(infinitives("pecher").prefix(2))
    #expect(Set(results) == ["pécher", "pêcher"])
    let first = try #require(Verb.verbs[results[0]])
    let second = try #require(Verb.verbs[results[1]])
    #expect(first.frequency <= second.frequency)
  }

  @Test(arguments: [
    ("pêcher", ["pêcher", "pécher"]),
    ("pécher", ["pécher", "pêcher"]),
    ("mater", ["mater", "mâter"]),
    ("mâter", ["mâter", "mater"]),
    ("tacher", ["tacher", "tâcher"]),
    ("tâcher", ["tâcher", "tacher"])
  ])
  func testLiteralMatchLeadsFoldedMatch(query: String, expected: [String]) {
    #expect(Array(infinitives(query).prefix(2)) == expected)
  }

  @Test func testAccentedPrefixPutsLiteralMatchesFirst() {
    let results = infinitives("pêch")
    let pêcher = results.firstIndex(of: "pêcher")
    let pécher = results.firstIndex(of: "pécher")
    #expect(pêcher != nil && pécher != nil)
    #expect((pêcher ?? .max) < (pécher ?? .max))
  }

  @Test func testUnaccentedPrefixRanksFoldedMatchesByFrequency() {
    let results = infinitives("pre")
    #expect(results.first == "prendre")
    let préparer = results.firstIndex(of: "préparer") ?? .max
    let presser = results.firstIndex(of: "presser") ?? .max
    #expect(préparer < presser, "préparer is commoner than presser, and pre says nothing about accents.")
  }

  @Test func testWholeMeaningRanksWithPrefixesByFrequency() {
    let results = infinitives("go")
    #expect(results.first == "aller")
    #expect(results.contains("gonfler"))
    let match = VerbSearch.matches(for: "go", in: frequencyVerbs, includeGlosses: true).first
    #expect(match?.kind == .glossMeaning)
  }

  @Test func testSubstringRanksBelowWholeWordGloss() {
    let results = infinitives("eat")
    let béatifier = results.firstIndex(of: "béatifier") ?? .max
    let manger = results.firstIndex(of: "manger") ?? .max
    #expect(manger < béatifier)
  }

  @Test func testGlossesAreSkippedWhenExcluded() {
    let results = VerbSearch.matches(for: "eat", in: frequencyVerbs, includeGlosses: false)
    #expect(!results.map(\.verb.infinitif).contains("manger"))
    #expect(results.allSatisfy { $0.kind.tier != 3 && $0.kind != .glossMeaning && $0.kind != .glossSubstring })
  }

  @Test func testExtraLettersAreNotSearched() {
    #expect(!infinitives("France").contains("haïr"))
  }

  @Test func testDoubledInfinitiveKeepsBothEntries() {
    let results = VerbSearch.matches(for: "haïr", in: frequencyVerbs, includeGlosses: true)
    #expect(results.prefix(2).map(\.verb.infinitif) == ["haïr", "haïr"])
    #expect(Set(results.prefix(2).map(\.verb.id)).count == 2)
  }

  @Test func testBareElidedPronounSearchesAsS() {
    let results = infinitives("s'")
    #expect(!results.isEmpty)
    #expect(results.prefix(20).allSatisfy { $0.hasPrefix("s") })
  }

  @Test(arguments: ["", "   "])
  func testBlankQueryMatchesNothing(query: String) {
    #expect(infinitives(query).isEmpty)
  }

  @Test func testNonsenseMatchesNothing() {
    #expect(infinitives("xqzw").isEmpty)
  }

  @Test(arguments: [
    ("Être", "etre"),
    ("manœuvrer", "manoeuvrer"),
    ("Cæsar", "caesar"),
    ("façonner", "faconner"),
    ("haïr", "hair"),
    ("ôter", "oter")
  ])
  func testFold(text: String, expected: String) {
    #expect(VerbSearch.fold(text) == expected)
  }

  @Test(arguments: [
    ("se souvenir", "souvenir"),
    ("s'asseoir", "asseoir"),
    ("S’Asseoir", "asseoir"),
    ("s'", "s"),
    ("se", "se"),
    ("sentir", "sentir")
  ])
  func testFrenchQuery(query: String, expected: String) {
    #expect(VerbSearch.frenchQuery(from: query) == expected)
  }

  @Test(arguments: [
    ("to go", "go"),
    ("To Eat", "eat"),
    ("to", "to"),
    ("tomber", "tomber")
  ])
  func testGlossQuery(query: String, expected: String) {
    #expect(VerbSearch.glossQuery(from: query) == expected)
  }

  @Test func testMeaningsDropParentheticalNotes() {
    #expect(VerbSearch.meanings(of: "hand over, pay, turn up (slang)") == ["hand over", "pay", "turn up"])
    #expect(VerbSearch.meanings(of: "can (food)") == ["can"])
  }

  @Test func testWholeWord() {
    #expect(VerbSearch.containsWholeWord("go", in: "go down"))
    #expect(!VerbSearch.containsWholeWord("go", in: "govern"))
    #expect(VerbSearch.containsWholeWord("eat", in: "overeat, eat"))
  }

  @Test func testTierOrderMatchesCaseOrder() {
    let tiers = VerbSearch.MatchKind.allCases.map(\.tier)
    #expect(tiers == tiers.sorted())
  }
}
