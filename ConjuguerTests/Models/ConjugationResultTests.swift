//
//  ConjugationResultTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct ConjugationResultTests {
  private func grade(_ infinitif: String, _ tense: Tense, _ answer: String) throws -> AnswerGrade {
    let verb = try #require(Verb.verbs[infinitif])
    let correctAnswers = try #require(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: .feminine))
    return ConjugationResult.grade(proposedAnswer: answer, correctAnswers: correctAnswers, verb: verb, tense: tense)
  }

  @Test(arguments: [
    ("parler", Tense.indicatifPrésent(.firstSingular), "parle", ConjugationResult.totalMatch),
    ("parler", .indicatifPrésent(.firstSingular), "Parle", .totalMatch),
    ("parler", .indicatifPrésent(.firstSingular), " parle ", .totalMatch),
    ("parler", .indicatifPrésent(.firstSingular), "je parle", .totalMatch),
    ("parler", .passéComposé(.firstSingular), "j'ai parlé", .totalMatch),
    ("parler", .passéComposé(.firstSingular), "j’ai  parlé", .totalMatch),
    ("aller", .passéComposé(.firstPlural), "nous sommes allées", .totalMatch),
    ("souvenir", .indicatifPrésent(.firstSingular), "je me souviens", .totalMatch),
    ("souvenir", .impératif(.secondSingular), "souviens-toi", .totalMatch),
    ("payer", .indicatifPrésent(.firstSingular), "paie", .totalMatch),
    ("payer", .indicatifPrésent(.firstSingular), "paye", .totalMatch),
    ("acheter", .indicatifPrésent(.firstSingular), "achete", .noMatch),
    ("être", .indicatifPrésent(.secondPlural), "etes", .noMatch),
    ("payer", .indicatifPrésent(.firstSingular), "pàie", .noMatch),
    ("placer", .passéSimple(.thirdSingular), "placa", .noMatch),
    ("parler", .passéComposé(.firstSingular), "ai parle", .noMatch),
    ("parler", .indicatifPrésent(.firstSingular), "xyz", .noMatch),
    ("parler", .indicatifPrésent(.firstSingular), "tu parle", .noMatch),
    ("aller", .passéComposé(.firstPlural), "sommes allés", .noMatch)
  ])
  func gradesAnswer(infinitif: String, tense: Tense, answer: String, expected: ConjugationResult) throws {
    #expect(try grade(infinitif, tense, answer).result == expected)
  }

  @Test(arguments: [
    ("connaître", Tense.indicatifPrésent(.thirdSingular), "il connait", "connaÎt"),
    ("céder", .futurSimple(.firstSingular), "je cèderai", "céderai"),
    ("étiqueter", .indicatifPrésent(.firstSingular), "j'étiquète", "étiquetTe")
  ])
  func showsTheAppsSpellingOfAVariant(infinitif: String, tense: Tense, answer: String, shown: String) throws {
    #expect(try grade(infinitif, tense, answer) == AnswerGrade(result: .totalMatch, shownSpelling: shown))
  }

  @Test func showsNoSpellingForTheAppsOwn() throws {
    #expect(try grade("connaître", .indicatifPrésent(.thirdSingular), "connaît").shownSpelling == nil)
  }
}
