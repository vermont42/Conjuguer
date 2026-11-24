//
//  QuizPracticeTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Practice record")
  struct PracticeTests {
    private let tenDaysAgo = Date.now.addingTimeInterval(-10 * 86_400)

    /// A fresh record for the test, since the unit-test world's is shared. Each test puts back an
    /// empty one with `defer`, so that its overdue items reach no other suite's quiz.
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func restorePractice() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    private func verb(_ key: String) throws -> Verb {
      try #require(Verb.verbs[key])
    }

    private func correctAnswer(for question: QuizQuestion) -> String {
      let conjugated = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: question.verb.extraLetters) ?? ""
      return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
    }

    private func item(of question: QuizQuestion) -> PracticeItem {
      .exercised(by: question.tense, of: question.verb)
    }

    @Test func answersAreRecordedAsGivenAndKeptOnQuit() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 11)
      quiz.start()
      let first = try #require(quiz.currentQuestion)
      quiz.process(proposedAnswer: correctAnswer(for: first))
      let second = try #require(quiz.currentQuestion)
      quiz.process(proposedAnswer: "definitelywrong")
      quiz.continueAfterCorrection()

      quiz.quit()

      #expect(practice.record.entry(for: item(of: first))?.lastAnswerWasRight == true)
      #expect(practice.record.entry(for: item(of: second))?.lastAnswerWasRight == false)
      #expect(practice.record.entries.count <= 2)
    }

    @Test func everyScopeWritesToTheRecord() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let parler = try verb("parler")
      for scope in [QuizScope.verbPage(parler), .myVerbs([parler])] {
        let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 3)
        quiz.start(scope: scope)
        let question = try #require(quiz.currentQuestion)

        quiz.process(proposedAnswer: correctAnswer(for: question))

        #expect(practice.record.entry(for: item(of: question))?.lastAnswerWasRight == true)
        quiz.quit()
      }
    }

    @Test func dueItemsAreLimitedToTheLevelAndTheBandInTheRecordsOrder() throws {
      let venir = try verb("venir")
      let rare = try #require(Verb.verbs.values.sorted { $0.dictionaryKey < $1.dictionaryKey }.first { verb in
        !PracticeItem.isLearnedByPattern(verb) && !verb.isIn(.top1000) && !verb.keyConjugations().isEmpty
      })
      let items: [PracticeItem] = [
        .keyConjugation(verb: venir.dictionaryKey, stem: .passéSimple),
        .keyConjugation(verb: rare.dictionaryKey, stem: .présent),
        .pattern(model: "1-1", tense: "subjonctif_present", person: "fs", takesÊtre: false),
        .keyConjugation(verb: venir.dictionaryKey, stem: .futur),
        .pattern(model: "1-2B", tense: "indicatif_present", person: "fp", takesÊtre: false),
        .pattern(model: "1-1", tense: "passe_compose", person: "ts", takesÊtre: true),
        .pattern(model: "2-1", tense: "imparfait", person: "sp", takesÊtre: false)
      ]
      var generator = SeededRandomNumberGenerator(seed: 5)

      let questions = QuizDraw.dueQuestions(for: items, slots: QuizLevel.elementary.slots, band: QuizLevel.elementary.band, using: &generator)

      // Elementary asks no passé simple and no subjonctif, and the rare verb is beyond its band.
      #expect(questions.map(\.tense) == [.futurSimple(.thirdSingular), .indicatifPrésent(.firstPlural), .passéComposé(.thirdSingular)])
      #expect(questions[0].verb == venir)
      #expect(questions.map(item(of:)) == [items[3], items[4], items[5]])
      #expect(questions.allSatisfy { $0.verb.isIn(.top300) })
    }

    @Test func aDefaultSessionMixesInDueItems() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let venir = try verb("venir")
      practice.recordAnswer(verb: venir, tense: .imparfait(.secondSingular), isCorrect: false, at: tenDaysAgo)
      Current.settings.quizLevel = .elementary

      for seed in UInt64(1) ... 5 {
        let quiz = Quiz(gameCenter: GameCenterSpy(), seed: seed)
        quiz.start()
        #expect(quiz.questions.count == Quiz.questionCount)
        #expect(quiz.questions.contains { $0.verb == venir && $0.tense == .indicatifPrésent(.thirdSingular) })
        quiz.quit()
      }
    }

    @Test func aDefaultRoundTakesAtMostThreeDueItems() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let parler = try verb("parler")
      for tense in [Tense.indicatifPrésent(.firstSingular), .indicatifPrésent(.secondSingular), .indicatifPrésent(.firstPlural), .imparfait(.firstSingular), .imparfait(.secondPlural)] {
        practice.recordAnswer(verb: parler, tense: tense, isCorrect: false, at: tenDaysAgo)
      }
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 9)

      quiz.start()

      #expect(quiz.questions.count == Quiz.questionCount)
      let dueKeys = Set(practice.dueItems().map(\.key))
      #expect(quiz.questions.filter { dueKeys.contains(item(of: $0).key) }.count >= QuizDraw.dueItemLimit)
      quiz.quit()
      var generator = SeededRandomNumberGenerator(seed: 1)
      let due = QuizDraw.dueQuestions(for: practice.dueItems(), slots: QuizLevel.elementary.slots, band: QuizLevel.elementary.band, using: &generator)
      #expect(due.count == QuizDraw.dueItemLimit)
    }

    @Test func aScopedQuizMixesInNothing() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let venir = try verb("venir")
      practice.recordAnswer(verb: venir, tense: .imparfait(.secondSingular), isCorrect: false, at: tenDaysAgo)
      let parler = try verb("parler")

      for scope in [QuizScope.myVerbs([parler]), .verbPage(parler)] {
        let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 2)
        quiz.start(scope: scope)
        #expect(quiz.questions.allSatisfy { $0.verb == parler })
        quiz.quit()
      }
      #expect(!QuizScope.myVerbs([parler]).mixesDueItems)
      #expect(QuizScope.allVerbs.mixesDueItems)
      var practiceSetScope = QuizScope.allVerbs
      practiceSetScope.level = .beginner
      #expect(!practiceSetScope.mixesDueItems)
    }
  }
}
