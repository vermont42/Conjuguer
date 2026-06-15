//
//  QuizTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import XCTest

@MainActor
class QuizTests: XCTestCase {
  func testRegularQuizLifecycle() {
    Current.settings.quizDifficulty = .regular
    let quiz = Current.quiz

    quiz.start()
    XCTAssertTrue(quiz.quizState == .inProgress)
    XCTAssertEqual(quiz.questions.count, 30)

    let questionCount = quiz.questions.count
    for _ in 0 ..< questionCount {
      quiz.process(proposedAnswer: "x")
    }

    XCTAssertEqual(quiz.quizResults.count, 30)
    XCTAssertEqual(quiz.currentQuestionIndex, 30)
    XCTAssertTrue(quiz.shouldShowResults)
    XCTAssertTrue(quiz.quizState == .notStarted)
  }

  func testAllIncorrectAnswersScoreZero() {
    Current.settings.quizDifficulty = .regular
    let quiz = Current.quiz

    quiz.start()
    let questionCount = quiz.questions.count
    for _ in 0 ..< questionCount {
      quiz.process(proposedAnswer: "x")
    }

    XCTAssertEqual(quiz.score, 0)
  }
}
