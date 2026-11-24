//
//  PracticeItemTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct PracticeItemTests {
  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  private func item(_ key: String, _ tense: Tense) throws -> PracticeItem {
    .exercised(by: tense, of: try verb(key))
  }

  private func pattern(_ model: String, _ tense: String, _ person: String? = nil, être: Bool = false) -> PracticeItem {
    .pattern(model: model, tense: tense, person: person, takesÊtre: être)
  }

  @Test(arguments: [
    (PracticeItem.keyConjugation(verb: "venir", stem: .présent), "key:venir:present"),
    (.keyConjugation(verb: "souvenir", stem: .passéComposé), "key:souvenir:passe_compose"),
    (.keyConjugation(verb: "sortir obtain", stem: .passéSimple), "key:sortir obtain:passe_simple"),
    (.pattern(model: "1-1", tense: "passe_compose", person: "fs", takesÊtre: true), "pattern:1-1:passe_compose:fs:etre"),
    (.pattern(model: "1-2B", tense: "indicatif_present", person: "fp", takesÊtre: false), "pattern:1-2B:indicatif_present:fp"),
    (.pattern(model: "2-1", tense: "participe_passe", person: nil, takesÊtre: false), "pattern:2-1:participe_passe")
  ])
  func keysArePinnedAndReadBack(item: PracticeItem, key: String) {
    #expect(item.key == key)
    #expect(PracticeItem(key: key) == item)
  }

  @Test(arguments: ["", "key:venir", "key:venir:bogus", "key::present", "pattern:1-1", "pattern:1-1:imparfait:fs:avoir", "pattern::imparfait:fs", "other:venir:present"])
  func unreadableKeysNameNothing(key: String) {
    #expect(PracticeItem(key: key) == nil)
  }

  @Test(arguments: ["parler", "aimer", "manger", "appeler", "acheter", "céder", "payer", "envoyer", "finir", "haïr France", "haïr Québec", "attendre", "rompre", "absenter", "arriver"])
  func regularFamiliesAreLearnedByPattern(key: String) throws {
    #expect(PracticeItem.isLearnedByPattern(try verb(key)))
  }

  @Test(arguments: ["aller", "être", "avoir", "venir", "prendre", "faire", "souvenir", "couvrir", "battre", "mettre", "gésir", "falloir"])
  func irregularVerbsAreLearnedVerbByVerb(key: String) throws {
    #expect(!PracticeItem.isLearnedByPattern(try verb(key)))
  }

  @Test func theBasesOwnVerbsShareTheBasesPatterns() throws {
    #expect(try item("parler", .indicatifPrésent(.firstSingular)) == pattern("1-1", "indicatif_present", "fs"))
    #expect(try item("aimer", .indicatifPrésent(.firstSingular)) == pattern("1-1", "indicatif_present", "fs"))
    #expect(try item("finir", .imparfait(.firstPlural)) == pattern("2-1", "imparfait", "fp"))
    #expect(try item("attendre", .indicatifPrésent(.thirdSingular)) == pattern("5-1A", "indicatif_present", "ts"))
    #expect(try item("parler", .participePassé) == pattern("1-1", "participe_passe"))
  }

  @Test func aSpellingChangeHasPatternsOnlyWhereItMarksTheCell() throws {
    #expect(try item("manger", .indicatifPrésent(.firstSingular)) == pattern("1-1", "indicatif_present", "fs"))
    #expect(try item("manger", .indicatifPrésent(.firstPlural)) == pattern("1-2B", "indicatif_present", "fp"))
    #expect(try item("appeler", .indicatifPrésent(.firstSingular)) == pattern("1-3A", "indicatif_present", "fs"))
    #expect(try item("appeler", .indicatifPrésent(.firstPlural)) == pattern("1-1", "indicatif_present", "fp"))
    #expect(try item("appeler", .futurSimple(.firstSingular)) == pattern("1-3A", "futur_simple", "fs"))
    #expect(try item("appeler", .imparfait(.firstSingular)) == pattern("1-1", "imparfait", "fs"))
    #expect(try item("rompre", .indicatifPrésent(.thirdSingular)) == pattern("5-1B", "indicatif_present", "ts"))
    #expect(try item("rompre", .indicatifPrésent(.firstSingular)) == pattern("5-1A", "indicatif_present", "fs"))
    #expect(try item("haïr France", .indicatifPrésent(.firstPlural)) == pattern("2-3A", "indicatif_present", "fp"))
  }

  /// The auxiliary's own irregular letters (sUIS) say nothing of the verb, so a compound tense is
  /// judged by its participle.
  @Test func aCompoundTenseIsJudgedByItsParticipleAndItsAuxiliary() throws {
    #expect(try item("appeler", .passéComposé(.firstSingular)) == pattern("1-1", "passe_compose", "fs"))
    #expect(try item("arriver", .passéComposé(.firstSingular)) == pattern("1-1", "passe_compose", "fs", être: true))
    #expect(try item("absenter", .plusQueParfait(.thirdPlural)) == pattern("1-1", "plus_que_parfait", "tp", être: true))
    #expect(try item("arriver", .indicatifPrésent(.firstSingular)) == pattern("1-1", "indicatif_present", "fs"))
  }

  @Test(arguments: [
    (Tense.indicatifPrésent(.firstPlural), PracticeItem.Stem.présent),
    (.impératif(.secondSingular), .présent),
    (.imparfait(.firstSingular), .présent),
    (.subjonctifPrésent(.thirdPlural), .présent),
    (.participePrésent, .présent),
    (.participePassé, .passéComposé),
    (.passéComposé(.firstSingular), .passéComposé),
    (.plusQueParfait(.secondPlural), .passéComposé),
    (.subjonctifPassé(.thirdSingular), .passéComposé),
    (.impératifPassé(.firstPlural), .passéComposé),
    (.futurSimple(.firstSingular), .futur),
    (.conditionnelPrésent(.thirdPlural), .futur),
    (.passéSimple(.firstPlural), .passéSimple),
    (.subjonctifImparfait(.thirdSingular), .passéSimple)
  ])
  func everyTenseOfAnIrregularVerbCountsAgainstItsStem(tense: Tense, stem: PracticeItem.Stem) throws {
    #expect(try item("venir", tense) == .keyConjugation(verb: "venir", stem: stem))
  }

  @Test func doubledEntriesKeepTheirOwnItems() throws {
    #expect(try item("sortir exit", .passéComposé(.firstSingular)) == .keyConjugation(verb: "sortir exit", stem: .passéComposé))
    #expect(try item("sortir obtain", .indicatifPrésent(.firstPlural)) == pattern("2-1", "indicatif_present", "fp"))
  }

  @Test func aLookupSchedulesTheShownKeyConjugationsOfAnIrregularVerbOnly() throws {
    #expect(PracticeItem.keyConjugations(of: try verb("venir")) == PracticeItem.Stem.shown.map { .keyConjugation(verb: "venir", stem: $0) })
    #expect(PracticeItem.keyConjugations(of: try verb("parler")).isEmpty)
    #expect(PracticeItem.keyConjugations(of: try verb("gésir")) == [.keyConjugation(verb: "gésir", stem: .présent)])
    #expect(PracticeItem.keyConjugations(of: try verb("accroire")).isEmpty)
  }

  @Test func theShownStemsAreTheVerbPagesKeyConjugations() {
    #expect(PracticeItem.Stem.shown.map(\.keyTense) == Verb.keyTenses)
    #expect(!PracticeItem.Stem.passéSimple.isShown)
  }

  /// The record's items and the card agree on which forms a verb has, for every verb learned
  /// verb by verb.
  @Test func everyIrregularVerbsLookupMatchesItsKeyConjugations() {
    let mismatched = Verb.verbs.values.filter { verb in
      !PracticeItem.isLearnedByPattern(verb) && PracticeItem.keyConjugations(of: verb).count != verb.keyConjugations().count
    }
    #expect(mismatched.map(\.dictionaryKey).isEmpty)
  }

  /// A review asks an item's own cell, which maps back to the item.
  @Test(arguments: [
    ("parler", Tense.imparfait(.secondSingular)),
    ("manger", .indicatifPrésent(.firstPlural)),
    ("appeler", .futurSimple(.thirdPlural)),
    ("arriver", .passéComposé(.firstPlural)),
    ("finir", .participePassé),
    ("attendre", .impératif(.secondPlural)),
    ("venir", .subjonctifImparfait(.firstSingular)),
    ("faire", .conditionnelPassé(.secondSingular))
  ])
  func anItemAsksItsOwnCellBack(key: String, tense: Tense) throws {
    let verb = try verb(key)
    let item = PracticeItem.exercised(by: tense, of: verb)
    let asked = try #require(item.tense)

    #expect(PracticeItem.exercised(by: asked, of: verb) == item)
    if case .keyConjugation = item {
      #expect(item.verb == verb)
    } else {
      #expect(item.verb == nil)
    }
  }
}
