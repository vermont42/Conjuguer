//
//  VerbSearchConjugationTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct VerbSearchConjugationTests {
  private static let verbs = Verb.verbs.values.sorted { ($0.frequency, $0.id) < ($1.frequency, $1.id) }

  private func matches(_ query: String) -> [VerbSearch.Match] {
    VerbSearch.matches(for: query, in: Self.verbs, includeGlosses: true)
  }

  private func infinitives(_ query: String) -> [String] {
    matches(query).map(\.verb.infinitif)
  }

  private func firstLine(_ query: String) -> String? {
    matches(query).first?.conjugation?.line(pronounGender: .masculine)
  }

  @Test(arguments: [
    ("vais", "aller", "vais: Indicatif Présent (je)"),
    ("fait", "faire", "fait: Indicatif Présent (il) · Participe Passé"),
    ("ai", "avoir", "ai: Indicatif Présent (je)"),
    ("j'ai", "avoir", "ai: Indicatif Présent (je)"),
    ("j’ai", "avoir", "ai: Indicatif Présent (je)"),
    ("ai mangé", "manger", "ai mangé: Passé Composé (je)"),
    ("est allée", "aller", "est allée: Passé Composé (elle)"),
    ("me lève", "lever", "lève: Indicatif Présent (je, il) · Subjonctif Présent (je, il) · Impératif (tu)"),
    ("etait", "être", "était: Imparfait (il)"),
    ("vins", "venir", "vins: Passé Simple (je, tu)"),
    ("avions fini", "finir", "avions fini: Plus-que-parfait (nous)")
  ])
  func testConjugationFindsItsVerbFirst(query: String, verb: String, line: String) {
    #expect(infinitives(query).first == verb)
    #expect(firstLine(query) == line)
  }

  @Test func testHomographFindsBothVerbs() {
    let results = matches("suis")
    #expect(results.map(\.verb.infinitif) == ["être", "suivre"])
    #expect(results.map { $0.conjugation?.line(pronounGender: .masculine) } == [
      "suis: Indicatif Présent (je)",
      "suis: Indicatif Présent (je, tu) · Impératif (tu)"
    ])
    #expect(results.allSatisfy { $0.kind == .conjugation })
  }

  @Test func testPassÉSimpleThatIsNoInfinitiveFindsOnlyItsVerb() {
    #expect(Verb.verbs["vins"] == nil)
    #expect(infinitives("vins") == ["venir"])
  }

  @Test func testFoldedConjugationIsMarkedFolded() {
    #expect(matches("etait").first?.kind == .foldedConjugation)
    #expect(matches("était").first?.kind == .conjugation)
  }

  // A conjugation shares a tier with infinitive prefixes and ranks among them by frequency, so
  // the short conjugations of common verbs lead and those of rare verbs do not bury the verbs
  // the learner may be typing toward.
  @Test(arguments: [
    ("a", "avoir"),
    ("as", "avoir"),
    ("ai", "avoir"),
    ("es", "être"),
    ("eu", "avoir"),
    ("vu", "voir"),
    ("su", "savoir"),
    ("lu", "lire"),
    ("dû", "devoir"),
    ("du", "devoir"),
    ("bu", "boire"),
    ("va", "aller"),
    ("pu", "pouvoir"),
    ("tu", "taire"),
    ("né", "naître"),
    ("ri", "risquer"),
    ("réa", "réaliser")
  ])
  func testShortQueryRanksConjugationsWithPrefixes(query: String, expected: String) {
    #expect(infinitives(query).first == expected)
  }

  @Test func testShortQueriesStillListTheirPrefixes() {
    let ai = infinitives("ai")
    #expect(Array(ai.prefix(3)) == ["avoir", "aimer", "aider"])
    let ri = infinitives("ri")
    #expect(ri.firstIndex(of: "rire") == 1)
    let réa = infinitives("réa")
    #expect(réa.contains("réer"))
    #expect((réa.firstIndex(of: "réagir") ?? .max) < (réa.firstIndex(of: "réer") ?? .max))
  }

  @Test func testTypedConjugationRanksFoldedMatchesBelow() {
    let mate = infinitives("mate")
    #expect(mate.first == "mater")
    let materner = mate.firstIndex(of: "materner") ?? .max
    #expect(materner < (mate.firstIndex(of: "matérialiser") ?? .max))
    #expect(materner < (mate.firstIndex(of: "mâter") ?? .max))
    #expect(Array(infinitives("crois").prefix(3)) == ["croire", "croiser", "croître"])
  }

  @Test(arguments: [
    ("je me suis levé", "lever", "me suis levé: Passé Composé (je)"),
    ("elles se sont levées", "lever", "se sont levées: Passé Composé (elles)"),
    ("nous nous sommes levés", "lever", "nous sommes levés: Passé Composé (nous)"),
    ("s'est assis", "asseoir", "s'est assis: Passé Composé (il)"),
    ("elle s'est souvenue", "souvenir", "est souvenue: Passé Composé (elle)"),
    ("je me souviens", "souvenir", "souviens: Indicatif Présent (je, tu) · Impératif (tu)"),
    ("je ne sais pas", "savoir", "sais: Indicatif Présent (je, tu)"),
    ("je n'ai pas mangé", "manger", "ai mangé: Passé Composé (je)"),
    ("il y a", "avoir", "a: Indicatif Présent (il)"),
    ("que je sois", "être", "sois: Subjonctif Présent (je, tu) · Impératif (tu)"),
    ("lève-toi", "lever", "lève: Indicatif Présent (je, il) · Subjonctif Présent (je, il) · Impératif (tu)"),
    ("souviens-toi", "souvenir", "souviens-toi: Impératif (tu)"),
    ("a-t-il", "avoir", "a: Indicatif Présent (il)"),
    ("vas-tu", "aller", "vas: Indicatif Présent (tu)"),
    ("etait allee", "aller", "était allée: Plus-que-parfait (elle)"),
    ("allées", "aller", "allées: Participe Passé (accordé)")
  ])
  func testSentenceFindsItsVerb(query: String, verb: String, line: String) {
    #expect(infinitives(query).first == verb)
    #expect(firstLine(query) == line)
  }

  @Test func testPassiveIsNoCompoundTense() {
    #expect(!infinitives("est levé").contains("lever"))
  }

  @Test func testNamesTheThirdPersonAsTheSettingDoes() {
    let line = matches("va").first?.conjugation?.line(pronounGender: .feminine)
    #expect(line == "va: Indicatif Présent (elle) · Impératif (tu)")
  }

  @Test func testModelSearchIgnoresConjugations() {
    let models = ModelSearch.matches(for: "vais", in: Array(VerbModel.models.values), verbs: Self.verbs)
    #expect(models.isEmpty)
  }

  @Test(arguments: [
    ("vais", TenseTable.indicatifPrésent),
    ("vins", .passéSimple),
    ("fait", .indicatifPrésent),
    ("allées", .personless),
    ("ai mangé", .passéComposé)
  ])
  func testLandingScrollsToTheFirstMatchedCard(query: String, table: TenseTable) throws {
    let marks = try #require(matches(query).first?.conjugation?.marks)
    let firstTense = try #require(marks.tenses.first)
    #expect(VerbConjugations.scrollID(for: firstTense) == table.scrollID)
  }

  @Test func testCompoundMatchShowsTheCompoundTenses() throws {
    let compound = try #require(matches("ai mangé").first?.conjugation?.marks)
    #expect(compound.includesCompoundTense)
    #expect(compound.contains(.passéComposé(.firstSingular)))
    let simple = try #require(matches("vais").first?.conjugation?.marks)
    #expect(!simple.includesCompoundTense)
  }

  @Test func testEverySectionHasTheScrollIDThatTheLandingComputes() throws {
    let verb = try #require(Verb.verbs["aller"])
    let sections = VerbConjugations.sections(verb: verb, tables: TenseTable.allCases)
    for section in sections {
      for cell in section.cells {
        #expect(VerbConjugations.scrollID(for: cell.tense) == section.scrollID)
      }
    }
    #expect(Set(sections.map(\.scrollID)).count == sections.count)
  }

  @Test(arguments: [
    ("j'", true),
    ("nous", true),
    ("je me", true),
    ("qu'", true),
    ("je vais", false),
    ("venir", false)
  ])
  func testPronounsAloneAreStillBeingTyped(query: String, expected: Bool) {
    #expect(ConjugationQuery(query).isOnlyPronouns == expected)
  }

  @Test(arguments: [
    ("je vais", ["vais"], nil),
    ("j'ai mangé", ["ai", "mangé"], nil),
    ("je me suis levé", ["suis", "levé"], "me"),
    ("nous nous sommes levés", ["sommes", "levés"], "nous"),
    ("nous allons", ["allons"], nil),
    ("je ne mange plus", ["mange"], nil),
    ("tu", ["tu"], nil)
  ] as [(String, [String], String?)])
  func testQueryDropsWhatSurroundsAConjugation(query: String, words: [String], reflexive: String?) {
    let parsed = ConjugationQuery(query)
    #expect(parsed.words == words)
    #expect(parsed.reflexivePronoun == reflexive)
  }

  @Test(arguments: [("lève-toi", "lève"), ("a-t-il", "a"), ("arc-boutait", nil), ("vas", nil)] as [(String, String?)])
  func testHyphenatedPronounsLeaveTheVerb(word: String, expected: String?) {
    #expect(ConjugationQuery.verbPart(ofHyphenated: word) == expected)
  }

  @Test func testIndexSpellsAWordAsTypedThenFolded() {
    let spellings = ConjugationIndex.bundled.spellings(of: "mate")
    #expect(spellings.first == ConjugationIndex.Spelling(conjugation: "mate", isFolded: false))
    let folded = Set(spellings.dropFirst().map(\.conjugation))
    #expect(folded == ["maté", "mâte", "mâté"])
    #expect(spellings.dropFirst().allSatisfy { $0.isFolded })
    #expect(ConjugationIndex.bundled.spellings(of: "etait") == [ConjugationIndex.Spelling(conjugation: "était", isFolded: true)])
  }

  @Test(arguments: [
    ("finnissons", "finir", "finissons: Indicatif Présent (nous) · Impératif (nous)"),
    ("sommmes", "être", "sommes: Indicatif Présent (nous)"),
    ("je finnissons", "finir", "finissons: Indicatif Présent (nous) · Impératif (nous)")
  ])
  func testMisspelledConjugationGuessesItsVerb(query: String, verb: String, line: String) {
    #expect(matches(query).isEmpty)
    let guess = VerbSearch.guess(for: query, in: Self.verbs)
    #expect(guess?.verb.infinitif == verb)
    #expect(guess?.conjugation?.line(pronounGender: .masculine) == line)
  }

  @Test(arguments: ["venier", "etree", "manjer"])
  func testInfinitiveGuessCarriesNoConjugation(query: String) {
    #expect(VerbSearch.guess(for: query, in: Self.verbs)?.conjugation == nil)
  }

  @Test func testGuessWithoutAnIndexConsidersOnlyInfinitives() {
    #expect(VerbSearch.guess(for: "finnissons", in: Self.verbs, conjugations: nil)?.verb.infinitif != "finir")
  }

  @Test(arguments: [
    ("venir", "venir"),
    ("venier", "venir"),
    ("vneir", "venir"),
    ("abc", "cba"),
    ("ca", "abc"),
    ("finnissons", "finissons"),
    ("mangerions", "rangerions"),
    ("xyzzyq", "abaisser")
  ])
  func testBoundedDistanceAgreesWithEditDistance(lhs: String, rhs: String) {
    let full = VerbSearch.editDistance(Array(lhs), Array(rhs))
    var bounded = BoundedEditDistance(query: Array(lhs.utf8))
    for limit in 0...4 {
      let measured = Array(rhs.utf8).withUnsafeBufferPointer { bounded.measure($0, atMost: limit) }
      #expect(measured == (full <= limit ? full : nil), "limit \(limit)")
    }
  }
}
