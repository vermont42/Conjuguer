//
//  QuizTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct QuizTests {
  // A quiz built with `shouldShuffle: false` is deterministic: the CyclingDecks stay
  // in declaration order and the question list is not shuffled, so we can read the
  // built questions, conjugate each ourselves, and feed the correct answer back.
  private func makeDeterministicQuiz(difficulty: QuizDifficulty) -> Quiz {
    Current.settings.quizDifficulty = difficulty
    let quiz = Quiz(gameCenter: GameCenterStub(), shouldShuffle: false)
    quiz.start()
    return quiz
  }

  // The exported/scored form is the first of any slash-separated alternates, which
  // ConjugationResult scores as a total match (mirrors Quiz.exportFixtureAnswers).
  private func correctAnswer(for question: QuizQuestion) -> String {
    let conjugated = Conjugator.conjugatedString(
      infinitif: question.verb.infinitif,
      tense: question.tense,
      extraLetters: nil
    ) ?? ""
    return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
  }

  private func answerAllCorrectly(_ quiz: Quiz) {
    let questions = quiz.questions
    for question in questions {
      quiz.process(proposedAnswer: correctAnswer(for: question))
    }
  }

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

  // 30 total matches at 10 points each = 300 (regular multiplier ×1). Since the timer
  // does not advance during a synchronous test, elapsedTime stays 0, so completeQuiz()
  // adds the 0-120s bonus of 450: 300 + 450 = 750. This exercises the score sum, the
  // ×1 regular multiplier, and the score >= 150 elapsed-time bonus path together.
  @Test func testAllCorrectRegularQuizScoresWithBonus() {
    let quiz = makeDeterministicQuiz(difficulty: .regular)
    answerAllCorrectly(quiz)

    #expect(quiz.currentQuestionIndex == 30)
    #expect(quiz.shouldShowResults)
    #expect(quiz.score == 750)
  }

  // The .ridiculous multiplier doubles each question: 30 × 10 × 2 = 600, plus the same
  // 450 elapsed-time bonus = 1050. Compared against the regular 750 above, this pins the
  // scoreModifier's effect.
  @Test func testAllCorrectRidiculousQuizAppliesMultiplier() {
    let quiz = makeDeterministicQuiz(difficulty: .ridiculous)
    answerAllCorrectly(quiz)

    #expect(quiz.score == 1050)
  }

  // A completed quiz whose score beats the stored best writes it back; a subsequent
  // lower-scoring quiz must not overwrite it.
  @Test func testBestScoreWriteBack() {
    Current.settings.bestScore = 0

    let winningQuiz = makeDeterministicQuiz(difficulty: .regular)
    answerAllCorrectly(winningQuiz)
    #expect(Current.settings.bestScore == 750)

    let losingQuiz = makeDeterministicQuiz(difficulty: .regular)
    let questionCount = losingQuiz.questions.count
    for _ in 0 ..< questionCount {
      losingQuiz.process(proposedAnswer: "x")
    }
    #expect(losingQuiz.score == 0)
    #expect(Current.settings.bestScore == 750, "A lower score must not overwrite the stored best.")
  }
}
