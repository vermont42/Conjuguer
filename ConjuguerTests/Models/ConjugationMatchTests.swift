//
//  ConjugationMatchTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct ConjugationMatchTests {
  private func matches(_ verb: String, _ text: String) throws -> [ConjugationMatch] {
    try #require(Verb.verbs[verb]).conjugations(matching: text)
  }

  private func cell(_ tense: Tense) -> ConjugationMatch {
    ConjugationMatch(tense: tense, isAgreement: false)
  }

  @Test(arguments: [
    ("aller", "vais", Tense.indicatifPrésent(.firstSingular)),
    ("aller", "  Vais ", .indicatifPrésent(.firstSingular)),
    ("avoir", "a", .indicatifPrésent(.thirdSingular)),
    ("être", "été", .participePassé),
    ("aller", "ir", .radicalFutur),
    ("venir", "vint", .passéSimple(.thirdSingular)),
    ("avoir", "ai eu", .passéComposé(.firstSingular)),
    ("manger", "ai  mangé", .passéComposé(.firstSingular)),
    ("aller", "suis allé", .passéComposé(.firstSingular)),
    ("finir", "avions fini", .plusQueParfait(.firstPlural)),
    ("souvenir", "souviens-toi", .impératif(.secondSingular))
  ])
  func matchesOneCell(verb: String, text: String, tense: Tense) throws {
    #expect(try matches(verb, text) == [cell(tense)])
  }

  @Test func matchesEveryPersonThatSharesASpelling() throws {
    #expect(try matches("venir", "vins") == [cell(.passéSimple(.firstSingular)), cell(.passéSimple(.secondSingular))])
  }

  @Test func matchesACompoundCellAgreedEitherWay() throws {
    #expect(try matches("aller", "est allé") == [cell(.passéComposé(.thirdSingular))])
    #expect(try matches("aller", "est allée") == [cell(.passéComposé(.thirdSingular))])
    #expect(try matches("aller", "sont allées") == [cell(.passéComposé(.thirdPlural))])
  }

  @Test func matchesTheParticipleAgreed() throws {
    #expect(try matches("aller", "allées") == [ConjugationMatch(tense: .participePassé, isAgreement: true)])
    #expect(try matches("prendre", "prise") == [ConjugationMatch(tense: .participePassé, isAgreement: true)])
  }

  @Test func listsEveryMatchInPageOrder() throws {
    #expect(try matches("manger", "mange") == [
      cell(.indicatifPrésent(.firstSingular)),
      cell(.indicatifPrésent(.thirdSingular)),
      cell(.subjonctifPrésent(.firstSingular)),
      cell(.subjonctifPrésent(.thirdSingular)),
      cell(.impératif(.secondSingular))
    ])
  }

  @Test func matchesEachAlternate() throws {
    let paie = try matches("payer", "paie")
    #expect(paie == (try matches("payer", "paye")))
    #expect(paie.contains(cell(.indicatifPrésent(.firstSingular))))
  }

  // clore has no imparfait, though the Conjugator spells one.
  @Test func skipsDefectiveCells() throws {
    #expect(try matches("clore", "closait").isEmpty)
    #expect(try matches("clore", "clos").contains(cell(.participePassé)))
  }

  @Test(arguments: [("aller", "aller"), ("être", "etait"), ("aller", ""), ("aller", "mange")])
  func matchesNothing(verb: String, text: String) throws {
    #expect(try matches(verb, text).isEmpty)
  }
}
