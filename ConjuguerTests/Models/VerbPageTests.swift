//
//  VerbPageTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/26/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct VerbPageTests {
  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  private func cell(_ conjugations: VerbConjugations, _ tense: Tense) throws -> VerbConjugations.Cell {
    let sections = conjugations.simpleSections + conjugations.compoundSections
    return try #require(sections.flatMap(\.cells).first { $0.tense == tense })
  }

  @Test(arguments: ["œuvre", "Œuvre", "æquo", "aime", "hésite"])
  func aLigatureOrAVowelElides(word: String) {
    #expect(PersonNumber.elides(before: word, hasAspiratedH: false))
  }

  @Test func œuvrersJeCellsElide() throws {
    let conjugations = VerbConjugations(verb: try verb("œuvrer"), pronounGender: .feminine)
    let présent = try cell(conjugations, .indicatifPrésent(.firstSingular))
    #expect(présent.pronoun == "j'")
    #expect(présent.accessibility == "j'œuvre")
    #expect(try cell(conjugations, .imparfait(.firstSingular)).accessibility == "j'œuvrais")
    #expect(try cell(conjugations, .passéComposé(.firstSingular)).pronoun == "j'")
    let keyConjugations = try verb("œuvrer").keyConjugations()
    #expect(keyConjugations == ["œuvre", "A œuvré", "œuvrera"])
  }

  @Test func theCacheGivesBothBlocksInTheGenderAsked() throws {
    let aller = try verb("aller")
    let feminine = VerbConjugations.memoized(for: aller, pronounGender: .feminine)
    let masculine = VerbConjugations.memoized(for: aller, pronounGender: .masculine)

    #expect(try cell(feminine, .indicatifPrésent(.thirdSingular)).accessibility == "elle va")
    #expect(try cell(feminine, .passéComposé(.thirdSingular)).accessibility == "elle est allée")
    #expect(try cell(masculine, .indicatifPrésent(.thirdSingular)).accessibility == "il va")
    #expect(try cell(masculine, .passéComposé(.thirdSingular)).accessibility == "il est allé")
    #expect(feminine.compoundSections.map(\.table) == TenseTable.compound)
  }

  @Test(arguments: [Tense.participePassé, .participePrésent, .radicalFutur, .impératifPassé(.secondSingular)])
  func aCellWithNoSubjectHasNoPronoun(tense: Tense) throws {
    let parts = VerbConjugations.conjugationParts(verb: try verb("aller"), tense: tense, pronounGender: .feminine)
    #expect(parts.pronoun.isEmpty)
    #expect(parts.spoken == parts.form.lowercased())
  }

  @Test func theScheduleHoldsTheKeyConjugationsThePageShows() {
    for verb in Verb.verbs.values where !PracticeItem.isLearnedByPattern(verb) {
      let stems = PracticeItem.keyConjugations(of: verb).compactMap { item -> PracticeItem.Stem? in
        guard case let .keyConjugation(_, stem) = item else {
          return nil
        }
        return stem
      }
      #expect(stems == verb.keyConjugationsByStem().map(\.stem), "\(verb.id)")
      #expect(stems.count == verb.keyConjugations().count, "\(verb.id)")
    }
  }

  @Test func aCompoundTableIsOneWhoseTensesAreCompound() {
    for table in TenseTable.allCases {
      #expect(table.tenses.allSatisfy { $0.isCompound == table.isCompound })
    }
  }
}
