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
      quiz.continueAfterCorrection()
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
      quiz.continueAfterCorrection()
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
      losingQuiz.continueAfterCorrection()
    }
    #expect(losingQuiz.score == 0)
    #expect(Current.settings.bestScore == 750, "A lower score must not overwrite the stored best.")
  }

  @Test(arguments: [QuizDifficulty.regular, .ridiculous])
  func noSeededQuizAsksADefectiveCell(difficulty: QuizDifficulty) {
    Current.settings.quizDifficulty = difficulty
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

  @Test func ridiculousAsksFalloirOnlyInTheThirdPersonSingular() throws {
    Current.settings.quizDifficulty = .ridiculous
    for seed in UInt64(0) ..< 20 {
      let quiz = Quiz(gameCenter: GameCenterStub(), seed: seed)
      quiz.start()
      let falloir = try #require(quiz.questions.first { $0.verb.infinitif == "falloir" })
      #expect(falloir.tense == .subjonctifImparfait(.thirdSingular))
      quiz.quit()
    }
  }

  @Test func aSeedRepeatsItsQuiz() {
    Current.settings.quizDifficulty = .regular
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
    Current.settings.quizDifficulty = .regular
    let quiz = Quiz(gameCenter: GameCenterStub(), shouldShuffle: false)
    quiz.start()
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
    let quiz = makeDeterministicQuiz(difficulty: .regular)
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
    let quiz = makeDeterministicQuiz(difficulty: .regular)
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
    let quiz = makeDeterministicQuiz(difficulty: .regular)
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
    let quiz = makeDeterministicQuiz(difficulty: .regular)
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
    let quiz = makeDeterministicQuiz(difficulty: .regular)
    let (slip, _) = try reachASlip(quiz)
    quiz.process(proposedAnswer: slip)
    quiz.clockTicked()
    #expect(quiz.elapsedTime == 1)
    quiz.quit()
    #expect(!quiz.isAwaitingSecondAttempt)
  }

  @Test func aRightSecondAttemptEarnsHalfPointsAtRidiculous() throws {
    let quiz = makeDeterministicQuiz(difficulty: .ridiculous)
    let (slip, answer) = try reachASlip(quiz)
    let score = quiz.score
    quiz.process(proposedAnswer: slip)
    quiz.process(proposedAnswer: answer)
    #expect(quiz.score == score + 10)
    quiz.quit()
  }

  @Test func theClockStandsStillWhileACorrectionIsHeld() {
    let quiz = makeDeterministicQuiz(difficulty: .regular)
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
    let quiz = makeDeterministicQuiz(difficulty: .regular)
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
    let quiz = makeDeterministicQuiz(difficulty: .regular)
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
