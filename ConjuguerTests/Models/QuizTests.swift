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
  // A seeded quiz is deterministic, so a test can read the built questions, conjugate each
  // itself, and feed the correct answer back.
  private func makeDeterministicQuiz(level: QuizLevel = .elementary) -> Quiz {
    Current.settings.quizLevel = level
    let quiz = Quiz(gameCenter: GameCenterStub(), seed: 1)
    quiz.start()
    return quiz
  }

  // The exported/scored form is the first of any slash-separated alternates, which
  // ConjugationResult scores as a total match (mirrors Quiz.exportFixtureAnswers).
  private func correctAnswer(for question: QuizQuestion) -> String {
    let conjugated = Conjugator.conjugatedString(
      infinitif: question.verb.infinitif,
      tense: question.tense,
      extraLetters: question.verb.extraLetters
    ) ?? ""
    return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
  }

  private func answerAllCorrectly(_ quiz: Quiz) {
    let questions = quiz.questions
    for question in questions {
      quiz.process(proposedAnswer: correctAnswer(for: question))
    }
  }

  @Test func testQuizLifecycle() {
    Current.settings.quizLevel = .elementary
    let quiz = Current.quiz

    quiz.start()
    #expect(quiz.quizState == .inProgress)
    #expect(quiz.questions.count == 30)

    let questionCount = quiz.questions.count
    for _ in 0 ..< questionCount {
      quiz.process(proposedAnswer: "x")
      quiz.continueAfterCorrection()
    }

    #expect(quiz.quizResults.count == 30)
    #expect(quiz.currentQuestionIndex == 30)
    #expect(quiz.shouldShowResults)
    #expect(quiz.quizState == .notStarted)
  }

  @Test func testAllIncorrectAnswersScoreZero() {
    Current.settings.quizLevel = .elementary
    let quiz = Current.quiz

    quiz.start()
    let questionCount = quiz.questions.count
    for _ in 0 ..< questionCount {
      quiz.process(proposedAnswer: "x")
      quiz.continueAfterCorrection()
    }

    #expect(quiz.score == 0)
  }

  // The timer does not advance during a synchronous test, so this is the quickest quiz possible,
  // and speed adds nothing.
  @Test(arguments: QuizLevel.allCases)
  func everyLevelScoresTenARightAnswerAndNothingElse(level: QuizLevel) {
    let quiz = makeDeterministicQuiz(level: level)
    answerAllCorrectly(quiz)

    #expect(quiz.currentQuestionIndex == 30)
    #expect(quiz.shouldShowResults)
    #expect(quiz.elapsedTime == 0)
    #expect(quiz.score == 300)
  }

  // A completed quiz whose score beats the stored best writes it back; a subsequent
  // lower-scoring quiz must not overwrite it.
  @Test func testBestScoreWriteBack() {
    Current.settings.bestScore = 0

    let winningQuiz = makeDeterministicQuiz()
    answerAllCorrectly(winningQuiz)
    #expect(Current.settings.bestScore == 300)

    let losingQuiz = makeDeterministicQuiz()
    let questionCount = losingQuiz.questions.count
    for _ in 0 ..< questionCount {
      losingQuiz.process(proposedAnswer: "x")
      losingQuiz.continueAfterCorrection()
    }
    #expect(losingQuiz.score == 0)
    #expect(Current.settings.bestScore == 300, "A lower score must not overwrite the stored best.")
  }

  @Test(arguments: QuizLevel.allCases)
  func noSeededQuizAsksADefectiveCell(level: QuizLevel) {
    Current.settings.quizLevel = level
    for seed in UInt64(0) ..< 100 {
      let quiz = Quiz(gameCenter: GameCenterStub(), seed: seed)
      quiz.start()
      #expect(quiz.questions.count == 30)
      for question in quiz.questions where !question.verb.hasCell(question.tense) {
        Issue.record("Seed \(seed) asked \(question.verb.infinitif), \(question.tense.titleCaseName)\(question.tense.pronounDecorator).")
      }
      quiz.quit()
    }
  }

  @Test func aSeedRepeatsItsQuiz() {
    Current.settings.quizLevel = .advanced
    func questions(seed: UInt64) -> [String] {
      let quiz = Quiz(gameCenter: GameCenterStub(), seed: seed)
      quiz.start()
      defer {
        quiz.quit()
      }
      return quiz.questions.map { "\($0.verb.id) \($0.tense)" }
    }
    let first = questions(seed: 7)
    #expect(questions(seed: 7) == first)
    #expect(questions(seed: 8) != first)
  }

  @Test func recordsTheAppsSpellingOfAVariant() throws {
    let quiz = makeDeterministicQuiz()
    let question = try #require(quiz.questions.first)
    let conjugation = correctAnswer(for: question).lowercased()
    let variant = try #require(StandardVariants.variants(of: conjugation, verb: question.verb, tense: question.tense).first ?? Optional(conjugation))
    quiz.process(proposedAnswer: variant)
    let result = try #require(quiz.quizResults.first)
    #expect(result.conjugationResult == .totalMatch)
    #expect(result.shownSpelling == (variant == conjugation ? nil : correctAnswer(for: question)))
    quiz.quit()
  }

  @Test func aWrongAnswerHoldsItsQuestionUntilContinue() throws {
    let quiz = makeDeterministicQuiz()
    let first = try #require(quiz.questions.first)

    quiz.process(proposedAnswer: "x")
    let correction = try #require(quiz.correction)
    #expect(correction.difference.given == "x")
    #expect(quiz.currentQuestionIndex == 0)
    #expect(quiz.quizResults.count == 1)

    quiz.process(proposedAnswer: correctAnswer(for: first))
    #expect(quiz.quizResults.count == 1, "An answer typed while a correction is held is not graded.")

    quiz.continueAfterCorrection()
    #expect(quiz.correction == nil)
    #expect(quiz.currentQuestionIndex == 1)
    quiz.quit()
  }

  @Test func aRightAnswerAdvancesAtOnce() throws {
    let quiz = makeDeterministicQuiz()
    let first = try #require(quiz.questions.first)
    quiz.process(proposedAnswer: correctAnswer(for: first))
    #expect(quiz.correction == nil)
    #expect(quiz.currentQuestionIndex == 1)
    quiz.quit()
  }

  /// Answers every question right until one whose answer has four letters or more, and returns
  /// that answer with a letter added, which is one slip from it.
  private func reachASlip(_ quiz: Quiz) throws -> (slip: String, answer: String) {
    for question in quiz.questions {
      let answer = correctAnswer(for: question).lowercased()
      if answer.filter(\.isLetter).count >= AnswerSlip.minimumLetterCount {
        return (answer + "q", answer)
      }
      quiz.process(proposedAnswer: answer)
    }
    throw SlipNotFound()
  }

  private struct SlipNotFound: Error {}

  @Test func aSlipEarnsOneMoreAttempt() throws {
    let quiz = makeDeterministicQuiz()
    let (slip, answer) = try reachASlip(quiz)
    let index = quiz.currentQuestionIndex
    let resultCount = quiz.quizResults.count
    let score = quiz.score

    quiz.process(proposedAnswer: slip)
    #expect(quiz.isAwaitingSecondAttempt)
    #expect(quiz.firstAttempt == slip)
    #expect(quiz.correction == nil)
    #expect(quiz.currentQuestionIndex == index)
    #expect(quiz.quizResults.count == resultCount)

    quiz.process(proposedAnswer: answer)
    #expect(!quiz.isAwaitingSecondAttempt)
    #expect(quiz.currentQuestionIndex == index + 1)
    #expect(quiz.score == score + 5)
    let result = try #require(quiz.quizResults.last)
    #expect(result.conjugationResult == .secondAttemptMatch)
    #expect(result.firstAttempt == slip)
    #expect(result.actualAnswer == answer)
    #expect(quiz.secondAttemptCount == 1)
    #expect(quiz.correctCount == index)
    quiz.quit()
  }

  @Test func aQuestionGetsOneMoreAttemptAtMost() throws {
    let quiz = makeDeterministicQuiz()
    let (slip, _) = try reachASlip(quiz)
    let index = quiz.currentQuestionIndex

    quiz.process(proposedAnswer: slip)
    quiz.process(proposedAnswer: slip)
    #expect(!quiz.isAwaitingSecondAttempt)
    #expect(quiz.correction != nil)
    #expect(quiz.currentQuestionIndex == index)
    let result = try #require(quiz.quizResults.last)
    #expect(result.conjugationResult == .noMatch)
    #expect(result.firstAttempt == slip)

    quiz.continueAfterCorrection()
    #expect(quiz.currentQuestionIndex == index + 1)
    #expect(quiz.firstAttempt == nil)
    quiz.quit()
  }

  @Test func theClockRunsDuringASecondAttempt() throws {
    let quiz = makeDeterministicQuiz()
    let (slip, _) = try reachASlip(quiz)
    quiz.process(proposedAnswer: slip)
    quiz.clockTicked()
    #expect(quiz.elapsedTime == 1)
    quiz.quit()
    #expect(!quiz.isAwaitingSecondAttempt)
  }

  @Test func aRightSecondAttemptEarnsHalfPointsAtAdvanced() throws {
    let quiz = makeDeterministicQuiz(level: .advanced)
    let (slip, answer) = try reachASlip(quiz)
    let score = quiz.score
    quiz.process(proposedAnswer: slip)
    quiz.process(proposedAnswer: answer)
    #expect(quiz.score == score + 5)
    quiz.quit()
  }

  @Test func theClockStandsStillWhileACorrectionIsHeld() {
    let quiz = makeDeterministicQuiz()
    quiz.clockTicked()
    #expect(quiz.elapsedTime == 1)

    quiz.process(proposedAnswer: "x")
    quiz.clockTicked()
    quiz.clockTicked()
    #expect(quiz.elapsedTime == 1)

    quiz.continueAfterCorrection()
    quiz.clockTicked()
    #expect(quiz.elapsedTime == 2)
    quiz.quit()
  }

  @Test func aWrongLastAnswerShowsItsCorrectionBeforeTheResults() throws {
    let quiz = makeDeterministicQuiz()
    for question in quiz.questions.dropLast() {
      quiz.process(proposedAnswer: correctAnswer(for: question))
    }
    quiz.process(proposedAnswer: "x")
    #expect(quiz.correction != nil)
    #expect(quiz.quizState == .inProgress)
    #expect(!quiz.shouldShowResults)

    quiz.continueAfterCorrection()
    #expect(quiz.shouldShowResults)
    #expect(quiz.quizState == .notStarted)
    #expect(quiz.quizResults.count == 30)
  }

  @Test func quittingReleasesAHeldCorrection() {
    let quiz = makeDeterministicQuiz()
    quiz.process(proposedAnswer: "x")
    #expect(quiz.correction != nil)
    quiz.quit()
    #expect(quiz.correction == nil)

    quiz.start()
    #expect(quiz.correction == nil)
    #expect(quiz.currentQuestionIndex == 0)
    quiz.quit()
  }
}
