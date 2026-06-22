//
//  QuizTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import Testing

@MainActor
@Suite(.serialized)
struct QuizTests {
  @Test func testRegularQuizLifecycle() {
    Current.settings.quizDifficulty = .regular
    let quiz = Current.quiz

    quiz.start()
    #expect(quiz.quizState == .inProgress)
    #expect(quiz.questions.count == 30)

    let questionCount = quiz.questions.count
    for _ in 0 ..< questionCount {
      quiz.process(proposedAnswer: "x")
    }

    #expect(quiz.quizResults.count == 30)
    #expect(quiz.currentQuestionIndex == 30)
    #expect(quiz.shouldShowResults)
    #expect(quiz.quizState == .notStarted)
  }

  @Test func testAllIncorrectAnswersScoreZero() {
    Current.settings.quizDifficulty = .regular
    let quiz = Current.quiz

    quiz.start()
    let questionCount = quiz.questions.count
    for _ in 0 ..< questionCount {
      quiz.process(proposedAnswer: "x")
    }

    #expect(quiz.score == 0)
  }
}
