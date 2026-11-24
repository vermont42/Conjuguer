//
//  QuizAchievementTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/24/26.
//

@testable import Conjuguer
import Foundation
import Testing

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Personal bests and achievements")
  struct AchievementQuizTests {
    private func startedQuiz(_ gameCenter: GameCenterSpy = GameCenterSpy(), scope: QuizScope = .allVerbs, level: QuizLevel = .elementary) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(gameCenter: gameCenter, seed: 11)
      quiz.start(scope: scope)
      return quiz
    }

    private func correctAnswer(for question: QuizQuestion) -> String {
      let conjugated = Conjugator.conjugatedString(
        infinitif: question.verb.infinitif,
        tense: question.tense,
        extraLetters: question.verb.extraLetters,
        pronounGender: question.pronounGender
      ) ?? ""
      return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
    }

    private func finish(_ quiz: Quiz, rightly: Bool = true) {
      while let question = quiz.currentQuestion, quiz.quizState == .inProgress {
        if question.choice != nil {
          quiz.skipChoice(rightly: rightly)
          continue
        }
        quiz.process(proposedAnswer: rightly ? correctAnswer(for: question) : "x")
        if quiz.isHeld {
          quiz.continueAfterCorrection()
        }
      }
    }

    private func practice(mastering items: [PracticeItem]) throws {
      var record = PracticeRecord()
      AchievementTests.master(items, in: &record, from: Date.now.addingTimeInterval(-10 * 86_400))
      let getterSetter = GetterSetterFake()
      getterSetter.set(key: PracticeRecord.storageKey, value: try #require(record.json))
      Current.practice = PracticeStore(getterSetter: getterSetter)
    }

    private func restorePractice() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    @Test func theResultsReportEveryAchievement() throws {
      try practice(mastering: Mastery.patterns(at: .beginner))
      defer {
        restorePractice()
      }
      let gameCenter = GameCenterSpy(isAuthenticated: true)
      let quiz = startedQuiz(gameCenter, level: .beginner)
      finish(quiz)

      let report = try #require(gameCenter.achievementReports.last)
      #expect(gameCenter.achievementReports.count == 1)
      #expect(report.count == Achievement.allCases.count)
      #expect(report[.patternsBeginner] == 100)
      #expect((report[.patternsElementary] ?? 0) < 100)
    }

    @Test func aQuitReports() {
      let gameCenter = GameCenterSpy(isAuthenticated: true)
      let quiz = startedQuiz(gameCenter)
      quiz.quit()

      #expect(gameCenter.achievementReports.count == 1)
    }

    @Test func nothingIsReportedWhileSignedOut() {
      let gameCenter = GameCenterSpy()
      finish(startedQuiz(gameCenter))

      #expect(gameCenter.achievementReports.isEmpty)
    }

    @Test func theFirstBestThenOneNotBeatenThenOneBeaten() {
      Current.settings.resetBestScores()
      let first = startedQuiz()
      finish(first)
      #expect(first.isNewBest)
      #expect(first.previousBest == nil)
      #expect(Current.settings.bestScore(at: .elementary) == 100)

      let second = startedQuiz()
      second.process(proposedAnswer: "x")
      second.continueAfterCorrection()
      finish(second)
      #expect(!second.isNewBest)
      #expect(second.previousBest == 100)
      #expect(Current.settings.bestScore(at: .elementary) == 100)

      Current.settings.resetBestScores()
      Current.settings.recordScore(50, at: .elementary)
      let third = startedQuiz()
      finish(third)
      #expect(third.isNewBest)
      #expect(third.previousBest == 50)
      Current.settings.resetBestScores()
    }

    @Test func eachLevelKeepsItsOwnBest() {
      Current.settings.resetBestScores()
      Current.settings.recordScore(70, at: .advanced)
      let quiz = startedQuiz(level: .beginner)
      finish(quiz)

      #expect(quiz.isNewBest)
      #expect(quiz.previousBest == nil)
      #expect(Current.settings.bestScore(at: .advanced) == 70)
      Current.settings.resetBestScores()
      Current.settings.quizLevel = .elementary
    }

    @Test func tenMoresResultsShowNoBest() {
      Current.settings.resetBestScores()
      let quiz = startedQuiz()
      finish(quiz)
      #expect(quiz.isNewBest)

      quiz.continueSession()
      finish(quiz)
      #expect(!quiz.isNewBest)
      #expect(quiz.previousBest == nil)
      Current.settings.resetBestScores()
    }

    @Test func anUnrankedSessionShowsNoBest() throws {
      Current.settings.resetBestScores()
      Current.settings.recordScore(80, at: .elementary)
      for scope in [QuizScope.daily(), .verbPage(try #require(Verb.verbs["aller"]))] {
        let quiz = startedQuiz(scope: scope)
        finish(quiz)
        #expect(quiz.shouldShowResults)
        #expect(!quiz.isNewBest)
        #expect(quiz.previousBest == nil)
      }
      #expect(Current.settings.bestScore(at: .elementary) == 80)
      Current.settings.resetBestScores()
    }

    @Test func aScoreOfZeroSetsNoBest() {
      Current.settings.resetBestScores()
      let quiz = startedQuiz()
      finish(quiz, rightly: false)

      #expect(quiz.score == 0)
      #expect(!quiz.isNewBest)
      #expect(quiz.previousBest == nil)
      #expect(!Current.settings.hasBestScore)
    }

    @Test func resetForgetsTheBests() {
      Current.settings.recordScore(60, at: .intermediate)
      #expect(Current.settings.hasBestScore)

      Current.settings.resetBestScores()
      #expect(!Current.settings.hasBestScore)
      #expect(QuizLevel.allCases.allSatisfy { Current.settings.bestScore(at: $0) == 0 })
      #expect(Current.getterSetter.get(key: Settings.bestScoreKey(.intermediate)) == nil)
    }
  }
}
