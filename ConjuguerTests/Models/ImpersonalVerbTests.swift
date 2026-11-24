//
//  ImpersonalVerbTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite("Impersonal verbs")
struct ImpersonalVerbTests {
  @Test(arguments: [
    (key: "falloir", isImpersonal: true),
    (key: "pleuvoir", isImpersonal: true),
    (key: "repleuvoir", isImpersonal: true),
    (key: "neiger", isImpersonal: true),
    (key: "bruiner", isImpersonal: true),
    (key: "apparoir", isImpersonal: true),
    (key: "chaloir", isImpersonal: true),
    (key: "poindre", isImpersonal: false),
    (key: "advenir", isImpersonal: false),
    (key: "incomber", isImpersonal: false),
    (key: "échoir", isImpersonal: false),
    (key: "parler", isImpersonal: false)
  ])
  func onlyAVerbWhoseThirdPersonIsImpersonalIsImpersonal(key: String, isImpersonal: Bool) throws {
    let verb = try #require(Verb.verbs[key])

    #expect(verb.isImpersonal == isImpersonal)
    #expect(verb.pronounGender(for: .feminine) == (isImpersonal ? .masculine : .feminine))
    #expect(verb.pronounGender(for: .both) == (isImpersonal ? .masculine : .both))
  }

  @Test func écoconcevoirIsConjugatedLikeConcevoir() throws {
    let verb = try #require(Verb.verbs["écoconcevoir"])

    #expect(verb.model == "4-2B")
    #expect(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .indicatifPrésent(.thirdSingular), extraLetters: nil, pronounGender: .masculine)?.lowercased() == "écoconçoit")
    #expect(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .participePassé, extraLetters: nil, pronounGender: .masculine)?.lowercased() == "écoconçu")
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Impersonal verbs under the feminine setting")
  struct ImpersonalVerbSettingTests {
    private func withFeminine(_ body: () throws -> Void) rethrows {
      let original = Current.settings.pronounGender
      Current.settings.pronounGender = .feminine
      defer {
        Current.settings.pronounGender = original
      }
      try body()
    }

    @Test(arguments: [
      (key: "falloir", tense: Tense.indicatifPrésent(.thirdSingular), frame: [AnswerFrame.Segment.pronoun("il"), .blank]),
      (key: "neiger", tense: .passéComposé(.thirdSingular), frame: [.pronoun("il"), .blank]),
      (key: "pleuvoir", tense: .futurSimple(.thirdPlural), frame: [.pronoun("ils"), .blank]),
      (key: "parler", tense: .indicatifPrésent(.thirdSingular), frame: [.pronoun("elle"), .blank])
    ])
    func theQuizAsksAnImpersonalVerbWithIl(key: String, tense: Tense, frame: [AnswerFrame.Segment]) throws {
      try withFeminine {
        let verb = try #require(Verb.verbs[key])

        #expect(QuizQuestion(verb: verb, tense: tense).answerFrame.segments == frame)
      }
    }

    @Test func theVerbPageShowsIlFaut() throws {
      try withFeminine {
        let falloir = try #require(Verb.verbs["falloir"])
        let parler = try #require(Verb.verbs["parler"])

        #expect(VerbConjugations.conjugationParts(verb: falloir, tense: .indicatifPrésent(.thirdSingular)).spoken == "il faut")
        #expect(VerbConjugations.conjugationParts(verb: parler, tense: .indicatifPrésent(.thirdSingular)).spoken == "elle parle")
      }
    }

    @Test func anImpersonalAnswerIsRecordedAndListedWithIl() throws {
      try withFeminine {
        let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 1)
        quiz.start(scope: .verbPage(try #require(Verb.verbs["falloir"])))
        defer {
          quiz.quit()
        }
        let question = try #require(quiz.currentQuestion)
        let answer = try #require(Conjugator.conjugatedString(infinitif: "falloir", tense: question.tense, extraLetters: nil, pronounGender: .masculine))

        quiz.process(proposedAnswer: answer)

        let result = try #require(quiz.quizResults.first)
        #expect(result.conjugationResult == .totalMatch)
        #expect(result.pronounGender == .masculine)
        #expect(result.tense.pronounDecorator(pronounGender: try #require(result.pronounGender)).hasSuffix("il"))
      }
    }
  }
}
