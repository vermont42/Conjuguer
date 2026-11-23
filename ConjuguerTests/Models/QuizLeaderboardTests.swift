//
//  QuizLeaderboardTests.swift
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
  @Suite("Leaderboards by level")
  struct LeaderboardTests {
    private struct SlipNotFound: Error {}

    private func startedQuiz(
      _ gameCenter: GameCenterSpy,
      scope: QuizScope = .allVerbs,
      level: QuizLevel = .elementary
    ) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(gameCenter: gameCenter, seed: 7)
      quiz.start(scope: scope)
      return quiz
    }

    private func correctAnswer(for question: QuizQuestion) -> String {
      let conjugated = Conjugator.conjugatedString(
        infinitif: question.verb.infinitif,
        tense: question.tense,
        extraLetters: question.verb.extraLetters
      ) ?? ""
      return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
    }

    private func finishRightly(_ quiz: Quiz) {
      while let question = quiz.currentQuestion, quiz.quizState == .inProgress {
        quiz.process(proposedAnswer: correctAnswer(for: question))
      }
    }

    private func verb(_ infinitif: String) throws -> Verb {
      try #require(Verb.verbs.values.first { $0.infinitif == infinitif && $0.extraLetters == nil })
    }

    // These IDs are permanent in App Store Connect; see docs/game_center_setup.md.
    @Test(arguments: zip(QuizLevel.allCases, [
      "conjuguer.level.beginner",
      "conjuguer.level.elementary",
      "conjuguer.level.intermediate",
      "conjuguer.level.advanced"
    ]))
    func eachLevelHasItsOwnLeaderboard(level: QuizLevel, leaderboardID: String) {
      #expect(level.leaderboardID == leaderboardID)
    }

    @Test func leaderboardIDsAreDistinct() {
      #expect(Set(QuizLevel.allCases.map(\.leaderboardID)).count == QuizLevel.allCases.count)
    }

    @Test(arguments: QuizLevel.allCases)
    func aRankedSessionReportsToItsLevelsLeaderboard(level: QuizLevel) {
      let gameCenter = GameCenterSpy()
      let quiz = startedQuiz(gameCenter, level: level)
      finishRightly(quiz)

      #expect(gameCenter.reports == [GameCenterSpy.Report(score: 100, level: level)])
      #expect(Current.settings.bestScore(at: level) == 100)
    }

    @Test func theLevelIsTheOneTheQuizStartedAt() {
      let gameCenter = GameCenterSpy()
      let quiz = startedQuiz(gameCenter, level: .beginner)
      Current.settings.quizLevel = .advanced
      finishRightly(quiz)

      #expect(gameCenter.reports.map(\.level) == [.beginner])
      Current.settings.quizLevel = .elementary
    }

    @Test func theRankedScoreCountsSecondAttemptsButNotReasks() throws {
      let gameCenter = GameCenterSpy()
      let quiz = startedQuiz(gameCenter)
      quiz.process(proposedAnswer: "x")
      quiz.continueAfterCorrection()

      var slipped = false
      while let question = quiz.currentQuestion, quiz.quizState == .inProgress {
        let answer = correctAnswer(for: question).lowercased()
        if !slipped, !question.isReask, answer.filter(\.isLetter).count >= AnswerSlip.minimumLetterCount {
          quiz.process(proposedAnswer: answer + "q")
          #expect(quiz.isAwaitingSecondAttempt)
          slipped = true
        }
        quiz.process(proposedAnswer: answer)
      }
      guard slipped else {
        throw SlipNotFound()
      }

      #expect(quiz.reaskCount == 1)
      #expect(quiz.secondAttemptCount == 1)
      #expect(quiz.score == 90)
      #expect(gameCenter.reports.map(\.score) == [85])
    }

    @Test func tenMoreReportsNothing() {
      let gameCenter = GameCenterSpy()
      let quiz = startedQuiz(gameCenter)
      finishRightly(quiz)
      quiz.continueSession()
      finishRightly(quiz)

      #expect(gameCenter.reports.count == 1)
    }

    @Test func aScopedQuizReportsNowhere() throws {
      let gameCenter = GameCenterSpy()
      let bestScores = Current.settings.bestScores
      for scope in [
        QuizScope.myVerbs([try verb("parler"), try verb("finir")]),
        .verbPage(try verb("aller")),
        .collection(.être)
      ] {
        #expect(!scope.isRanked)
        let quiz = startedQuiz(gameCenter, scope: scope)
        finishRightly(quiz)
        #expect(quiz.shouldShowResults)
      }

      #expect(gameCenter.reports.isEmpty)
      #expect(Current.settings.bestScores == bestScores)
    }
  }
}
