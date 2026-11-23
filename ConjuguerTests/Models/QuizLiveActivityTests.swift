//
//  QuizLiveActivityTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

// `Current.liveActivities` is shared with suites running in parallel, so each test compares the
// spy's counts before and after its own steps. The steps are synchronous on the main actor, so no
// other test's quiz can start or end between them.
@MainActor
struct QuizLiveActivityTests {
  private func spy() throws -> LiveActivitiesSpy {
    try #require(Current.liveActivities as? LiveActivitiesSpy)
  }

  @Test func aTabQuizStartsALiveActivityThatQuittingEnds() throws {
    let liveActivities = try spy()
    let quiz = Quiz(gameCenter: GameCenterSpy())
    let startsBefore = liveActivities.startCount
    let activeBefore = liveActivities.activeIDs

    quiz.start()
    #expect(liveActivities.startCount == startsBefore + 1)
    #expect(liveActivities.activeIDs.count == activeBefore.count + 1)

    quiz.quit()
    #expect(liveActivities.activeIDs == activeBefore)
  }

  @Test func eachAnswerButTheLastUpdatesTheActivityAndTheLastEndsIt() throws {
    let liveActivities = try spy()
    let quiz = Quiz(gameCenter: GameCenterSpy())
    quiz.start()
    let updatesBefore = liveActivities.updateCount
    let endsBefore = liveActivities.endCount
    let activeCount = liveActivities.activeIDs.count

    while quiz.quizState == .inProgress {
      quiz.process(proposedAnswer: "x")
      quiz.continueAfterCorrection()
    }

    #expect(quiz.questions.count == 2 * Quiz.questionCount, "Each of the ten misses is asked again.")
    #expect(liveActivities.updateCount == updatesBefore + quiz.questions.count - 1)
    #expect(liveActivities.endCount == endsBefore + 1)
    #expect(liveActivities.activeIDs.count == activeCount - 1)
  }

  @Test func restartingAQuizReplacesItsActivity() throws {
    let liveActivities = try spy()
    let quiz = Quiz(gameCenter: GameCenterSpy())
    quiz.start()
    let startsBefore = liveActivities.startCount
    let endsBefore = liveActivities.endCount
    let activeCount = liveActivities.activeIDs.count

    quiz.start()
    #expect(liveActivities.startCount == startsBefore + 1)
    #expect(liveActivities.endCount == endsBefore + 1)
    #expect(liveActivities.activeIDs.count == activeCount)
    quiz.quit()
  }

  @Test func aSheetsQuizStartsNoActivity() throws {
    let liveActivities = try spy()
    let venir = try #require(Verb.verbs["venir"])
    for scope in [QuizScope.verbPage(venir), .collection(.être)] {
      let quiz = Quiz(gameCenter: GameCenterSpy())
      let startsBefore = liveActivities.startCount
      quiz.start(scope: scope)
      #expect(quiz.quizState == .inProgress)
      #expect(liveActivities.startCount == startsBefore)
      quiz.quit()
    }
  }
}
