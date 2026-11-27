//
//  AnswerFrameTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct AnswerFrameTests {
  private func frame(_ infinitif: String, _ tense: Tense, _ pronounGender: PronounGender = .feminine) throws -> AnswerFrame {
    let verb = try #require(Verb.verbs[infinitif])
    let answer = try #require(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: pronounGender))
    return AnswerFrame.quizFrame(for: tense, answer: answer, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH, pronounGender: pronounGender)
  }

  @Test(arguments: [
    ("parler", Tense.indicatifPrésent(.firstSingular), PronounGender.feminine, [AnswerFrame.Segment.pronoun("je"), .blank]),
    ("aimer", .indicatifPrésent(.firstSingular), .feminine, [.pronoun("j'"), .blank]),
    ("œuvrer", .indicatifPrésent(.firstSingular), .feminine, [.pronoun("j'"), .blank]),
    ("haïr France", .indicatifPrésent(.firstSingular), .feminine, [.pronoun("je"), .blank]),
    ("parler", .indicatifPrésent(.thirdSingular), .feminine, [.pronoun("elle"), .blank]),
    ("parler", .indicatifPrésent(.thirdSingular), .masculine, [.pronoun("il"), .blank]),
    ("parler", .futurSimple(.thirdPlural), .feminine, [.pronoun("elles"), .blank]),
    ("parler", .futurSimple(.thirdPlural), .both, [.pronoun("ils"), .blank]),
    ("parler", .passéComposé(.firstSingular), .feminine, [.pronoun("j'"), .gender(isFeminine: true), .blank]),
    ("aller", .passéComposé(.firstSingular), .masculine, [.pronoun("je"), .gender(isFeminine: false), .blank]),
    ("aller", .passéComposé(.firstPlural), .both, [.pronoun("nous"), .gender(isFeminine: false), .blank]),
    ("aller", .passéComposé(.secondPlural), .feminine, [.pronoun("vous"), .gender(isFeminine: true), .blank]),
    ("aller", .passéComposé(.thirdSingular), .feminine, [.pronoun("elle"), .blank]),
    ("aller", .plusQueParfait(.thirdPlural), .masculine, [.pronoun("ils"), .blank]),
    ("souvenir", .indicatifPrésent(.firstSingular), .feminine, [.pronoun("je me"), .blank]),
    ("absenter", .indicatifPrésent(.firstSingular), .feminine, [.pronoun("je m'"), .blank]),
    ("absenter", .indicatifPrésent(.thirdPlural), .masculine, [.pronoun("ils s'"), .blank]),
    ("souvenir", .passéComposé(.secondSingular), .feminine, [.pronoun("tu t'"), .gender(isFeminine: true), .blank]),
    ("souvenir", .passéComposé(.firstPlural), .feminine, [.pronoun("nous nous"), .gender(isFeminine: true), .blank]),
    ("souvenir", .impératif(.secondSingular), .feminine, [.addressee("tu"), .blank, .reflexiveSuffix("-toi"), .punctuation("!")]),
    ("finir", .impératif(.firstPlural), .feminine, [.addressee("nous"), .blank, .punctuation("!")]),
    ("aller", .impératifPassé(.secondPlural), .masculine, [.addressee("vous"), .gender(isFeminine: false), .blank, .punctuation("!")]),
    ("parler", .participePrésent, .feminine, [.blank]),
    ("venir", .participePassé, .feminine, [.blank])
  ])
  func framesQuestion(infinitif: String, tense: Tense, pronounGender: PronounGender, expected: [AnswerFrame.Segment]) throws {
    #expect(try frame(infinitif, tense, pronounGender).segments == expected)
  }

  /// A learner who types the frame's own words before or after the answer is still right.
  @Test(arguments: ["parler", "aimer", "haïr France", "aller", "souvenir", "absenter", "être", "falloir"])
  func everyCellHasOneBlankAndAcceptsTheFrameTypedWithTheAnswer(infinitif: String) throws {
    let verb = try #require(Verb.verbs[infinitif])
    for pronounGender in PronounGender.allCases {
      for tense in Tense.allConcreteCases where verb.hasCell(tense) {
        let answers = try #require(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: pronounGender))
        let answer = try #require(answers.components(separatedBy: Tense.alternateConjugationSeparator).first)
        let frame = AnswerFrame.quizFrame(for: tense, answer: answers, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH, pronounGender: pronounGender)
        #expect(frame.segments.filter { $0 == .blank }.count == 1, "\(infinitif) \(tense)")

        var typed = answer
        for segment in frame.leadingSegments {
          if case .pronoun(let pronoun) = segment {
            typed = pronoun.hasSuffix("'") ? pronoun + typed : "\(pronoun) \(typed)"
          }
        }
        for segment in frame.trailingSegments {
          if case .reflexiveSuffix(let suffix) = segment {
            typed += suffix
          }
        }
        let grade = ConjugationResult.grade(proposedAnswer: typed, correctAnswers: answers, verb: verb, tense: tense)
        #expect(grade.result == .totalMatch, "\(infinitif) \(tense) \(pronounGender): \(typed)")
      }
    }
  }

  @Test(arguments: [
    ("parler", Tense.passéComposé(.firstSingular), PronounGender.feminine, "je, feminine, blank"),
    ("absenter", .indicatifPrésent(.firstSingular), .feminine, "je me, blank"),
    ("parler", .indicatifPrésent(.thirdSingular), .masculine, "il, singular, blank"),
    ("absenter", .indicatifPrésent(.thirdPlural), .feminine, "elles se, plural, blank"),
    ("souvenir", .impératif(.secondSingular), .feminine, "tu, blank, toi"),
    ("venir", .participePassé, .feminine, "blank")
  ])
  func readsFrameAsOnePrompt(infinitif: String, tense: Tense, pronounGender: PronounGender, expected: String) throws {
    #expect(try frame(infinitif, tense, pronounGender).spokenPrompt == expected)
  }

  @Test(arguments: [
    (Tense.impératif(.secondSingular), PronounGender.feminine, "tu", false),
    (.indicatifPrésent(.firstPlural), .feminine, "nous", false),
    (.indicatifPrésent(.thirdSingular), .feminine, "elle", false),
    (.passéComposé(.firstSingular), .feminine, "je", true),
    (.impératifPassé(.secondPlural), .masculine, "vous", true)
  ])
  func aResultsRowShowsTheGenderWhereTheFrameDoes(tense: Tense, pronounGender: PronounGender, pronoun: String, showsGender: Bool) {
    let abbreviation = pronounGender == .masculine ? L.PronounGender.masculineAbbreviation : L.PronounGender.feminineAbbreviation
    #expect(tense.pronounDecorator(pronounGender: pronounGender) == " - " + pronoun + (showsGender ? " (\(abbreviation))" : ""))
    #expect(Tense.participePassé.pronounDecorator(pronounGender: pronounGender).isEmpty)
  }
}
