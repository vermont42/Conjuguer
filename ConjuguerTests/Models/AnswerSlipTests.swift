//
//  AnswerSlipTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct AnswerSlipTests {
  private func isSlip(_ infinitif: String, _ tense: Tense, _ answer: String) throws -> Bool {
    let verb = try #require(Verb.verbs[infinitif])
    let correctAnswers = try #require(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: .feminine))
    return AnswerSlip.isSlip(proposedAnswer: answer, correctAnswers: correctAnswers, verb: verb, tense: tense)
  }

  @Test(arguments: [
    ("être", Tense.indicatifPrésent(.secondPlural), "etes"),
    ("acheter", .indicatifPrésent(.firstSingular), "achete"),
    ("payer", .indicatifPrésent(.firstSingular), "pàie"),
    ("placer", .passéSimple(.thirdSingular), "placa"),
    ("préférer", .passéComposé(.firstSingular), "ai prefere"),
    ("parler", .passéComposé(.firstSingular), "ai parle"),
    ("parler", .passéComposé(.firstSingular), "j'ai parle"),
    ("prendre", .indicatifPrésent(.thirdPlural), "prenent"),
    ("prendre", .indicatifPrésent(.thirdPlural), "ils prennnent"),
    ("finir", .futurSimple(.firstPlural), "fniirons"),
    ("vouloir", .indicatifPrésent(.firstSingular), "veus"),
    ("aller", .passéComposé(.firstSingular), "suis allé"),
    ("souvenir", .indicatifPrésent(.firstSingular), "je me souvien")
  ])
  func earnsOneMoreTry(infinitif: String, tense: Tense, answer: String) throws {
    #expect(try isSlip(infinitif, tense, answer))
  }

  // Each of these is near the right answer but spells another cell of the verb, or is too short
  // for one letter to be a slip.
  @Test(arguments: [
    ("parler", Tense.participePassé, "parle"),
    ("parler", .indicatifPrésent(.firstSingular), "parlé"),
    ("prendre", .subjonctifImparfait(.thirdSingular), "prit"),
    ("finir", .subjonctifImparfait(.thirdSingular), "finit"),
    ("avoir", .subjonctifImparfait(.thirdSingular), "eut"),
    ("être", .subjonctifImparfait(.thirdSingular), "fut"),
    ("finir", .futurSimple(.firstPlural), "finirions"),
    ("venir", .indicatifPrésent(.thirdSingular), "viens"),
    ("vouloir", .indicatifPrésent(.firstSingular), "veut"),
    ("être", .participePassé, "ete"),
    ("parler", .indicatifPrésent(.firstSingular), "xyz"),
    ("parler", .indicatifPrésent(.firstSingular), "tu parle")
  ])
  func goesStraightToTheCorrection(infinitif: String, tense: Tense, answer: String) throws {
    #expect(try !isSlip(infinitif, tense, answer))
  }

  @Test func countsTheLettersOfTheRightAnswer() {
    #expect(AnswerSlip.isSlip("etes", of: "êtes"))
    #expect(AnswerSlip.isSlip("vex", of: "veux"))
    #expect(!AnswerSlip.isSlip("ete", of: "été"))
    #expect(!AnswerSlip.isSlip("ai", of: "as"))
    #expect(AnswerSlip.isSlip("a ete", of: "a été"))
  }
}
