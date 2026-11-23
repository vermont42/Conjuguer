//
//  AnswerSpellingTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct AnswerSpellingTests {
  @Test(arguments: [
    ("  parle ", "parle"),
    ("J’ai   parlé", "j'ai parlé"),
    ("SUIS\tallée", "suis allée")
  ])
  func normalizes(answer: String, expected: String) {
    #expect(AnswerSpelling.normalized(answer) == expected)
  }

  @Test(arguments: [
    ("je parle", Tense.indicatifPrésent(.firstSingular), false, "parle"),
    ("j'ai parlé", .passéComposé(.firstSingular), false, "ai parlé"),
    ("j' ai parlé", .passéComposé(.firstSingular), false, "ai parlé"),
    ("on parle", .indicatifPrésent(.thirdSingular), false, "parle"),
    ("elles parlent", .indicatifPrésent(.thirdPlural), false, "parlent"),
    ("nous sommes allés", .passéComposé(.firstPlural), false, "sommes allés"),
    ("je me souviens", .indicatifPrésent(.firstSingular), true, "souviens"),
    ("me souviens", .indicatifPrésent(.firstSingular), true, "souviens"),
    ("nous nous souvenons", .indicatifPrésent(.firstPlural), true, "souvenons"),
    ("il s'est souvenu", .passéComposé(.thirdSingular), true, "est souvenu"),
    ("souviens-toi", .impératif(.secondSingular), true, "souviens")
  ])
  func stripsPronounsOfTheAskedPerson(answer: String, tense: Tense, isReflexive: Bool, expected: String) {
    #expect(AnswerSpelling.candidates(for: answer, tense: tense, isReflexive: isReflexive).contains(expected))
  }

  @Test(arguments: [
    ("tu parles", Tense.indicatifPrésent(.firstSingular), false, "parles"),
    ("je me parle", .indicatifPrésent(.firstSingular), false, "parle"),
    ("tu parle", .impératif(.secondSingular), false, "parle"),
    ("je parlé", .participePassé, false, "parlé"),
    ("parle-toi", .impératif(.secondSingular), false, "parle")
  ])
  func keepsOtherPronouns(answer: String, tense: Tense, isReflexive: Bool, unexpected: String) {
    #expect(!AnswerSpelling.candidates(for: answer, tense: tense, isReflexive: isReflexive).contains(unexpected))
  }
}
