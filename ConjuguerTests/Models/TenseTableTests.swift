//
//  TenseTableTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct TenseTableTests {
  @Test func testSimpleTensesFollowTheCorpusCount() {
    #expect(TenseTable.simple == [
      .indicatifPrésent, .imparfait, .passéSimple, .futurSimple, .conditionnelPrésent,
      .subjonctifPrésent, .impératif, .subjonctifImparfait
    ])
  }

  @Test func testCompoundTensesFollowTheCorpusCount() {
    #expect(TenseTable.compound == [
      .passéComposé, .plusQueParfait, .conditionnelPassé, .subjonctifPlusQueParfait,
      .subjonctifPassé, .passéAntérieur, .futurAntérieur, .passéSurcomposé, .impératifPassé
    ])
  }

  @Test func testThePersonlessCardSitsBetweenTheBlocks() {
    let tables = TenseTable.allCases
    #expect(tables == TenseTable.simple + [.personless] + TenseTable.compound)
    #expect(TenseTable.personless.tenses == [.participePassé, .participePrésent, .radicalFutur])
  }

  @Test func testEveryCellBelongsToTheTableThatListsIt() {
    for table in TenseTable.allCases {
      for tense in table.tenses {
        #expect(tense.table == table)
      }
    }
    #expect(TenseTable.allTenses.count == Set(TenseTable.allTenses).count)
    #expect(TenseTable.allTenses.count == 3 + 15 * 6 + 2 * 3)
  }

  @Test func testEveryTenseHasAnArticle() {
    for tense in TenseTable.allTenses {
      #expect(tense.article != nil, "\(tense.titleCaseName) has no article")
    }
  }

  @Test func testScrollIDsAreDistinct() {
    let ids = TenseTable.allCases.map(\.scrollID)
    #expect(Set(ids).count == ids.count)
  }

  @Test func testSecondNamesInEnglish() {
    #expect(Tense.passéSimple(.firstSingular).secondName == "simple past")
    #expect(Tense.passéComposé(.firstSingular).secondName == "compound past")
    #expect(Tense.participePassé.secondName == "past participle")
    #expect(L.VerbView.secondName("pluperfect") == "also pluperfect")
  }

  @Test(arguments: [
    ("aller", true),
    ("parler", false)
  ])
  func testColorKeyNeedsTheVerbsOwnRedLetters(infinitif: String, hasRedLetters: Bool) throws {
    let verb = try #require(Verb.verbs[infinitif])
    #expect(VerbConjugations(verb: verb).hasIrregularLetters == hasRedLetters)
  }
}
