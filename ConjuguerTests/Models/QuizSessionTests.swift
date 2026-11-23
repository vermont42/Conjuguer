//
//  QuizSessionTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct QuizSessionTests {
  private func makeQuiz(level: QuizLevel = .elementary, seed: UInt64 = 1, now: @escaping () -> Date = { Date.now }) -> Quiz {
    Current.settings.quizLevel = level
    let quiz = Quiz(gameCenter: GameCenterStub(), seed: seed, now: now)
    quiz.start()
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

  private func answerRightly(_ quiz: Quiz, count: Int) {
    for _ in 0 ..< count {
      guard let question = quiz.currentQuestion else {
        return
      }
      quiz.process(proposedAnswer: correctAnswer(for: question))
    }
  }

  private func finishRightly(_ quiz: Quiz) {
    while quiz.quizState == .inProgress {
      answerRightly(quiz, count: 1)
    }
  }

  private func miss(_ quiz: Quiz) {
    quiz.process(proposedAnswer: "x")
    quiz.continueAfterCorrection()
  }

  private func withSpy(_ body: (AnalyticsSpy) throws -> Void) rethrows {
    let original = Current.analytics
    let spy = AnalyticsSpy()
    Current.analytics = spy
    defer {
      Current.analytics = original
    }
    try body(spy)
  }

  @Test(arguments: [
    (index: 0, count: 10, position: 4),
    (index: 5, count: 10, position: 9),
    (index: 7, count: 10, position: 10),
    (index: 9, count: 10, position: 10),
    (index: 9, count: 11, position: 11)
  ])
  func aMissReturnsThreeQuestionsOnOrAtTheRoundsEnd(index: Int, count: Int, position: Int) {
    #expect(Quiz.reaskPosition(after: index, in: count) == position)
  }

  @Test func aMissedQuestionReturnsOnceThreeQuestionsLater() throws {
    let quiz = makeQuiz()
    let missed = try #require(quiz.currentQuestion)

    quiz.process(proposedAnswer: "x")
    #expect(quiz.correction?.willBeReasked == true)
    #expect(quiz.questions.count == Quiz.questionCount + 1)
    let reask = quiz.questions[Quiz.reaskGap + 1]
    #expect(reask.isReask)
    #expect(reask.verb.id == missed.verb.id)
    #expect(reask.tense == missed.tense)
    quiz.continueAfterCorrection()

    answerRightly(quiz, count: Quiz.reaskGap)
    #expect(quiz.currentQuestion?.isReask == true)
    quiz.process(proposedAnswer: "x")
    #expect(quiz.correction?.willBeReasked == false)
    #expect(quiz.questions.count == Quiz.questionCount + 1, "A re-ask is not asked a third time.")
    quiz.quit()
  }

  @Test func aRightReaskEarnsHalfPointsAndCountsApart() {
    let quiz = makeQuiz()
    miss(quiz)
    finishRightly(quiz)

    #expect(quiz.score == 9 * 10 + 5)
    #expect(quiz.correctCount == 9)
    #expect(quiz.sessionQuestionCount == Quiz.questionCount)
    #expect(quiz.reaskCount == 1)
    #expect(quiz.reaskCorrectCount == 1)
    #expect(quiz.firstRoundScore == 90, "A re-ask's points do not rank.")
    #expect(quiz.quizResults.map(\.isReask) == [false, false, false, false, true] + Array(repeating: false, count: 6))
  }

  @Test func tenMoreContinuesTheSessionAndOnlyTheFirstRoundRanks() {
    Current.settings.bestScore = 0
    let quiz = makeQuiz()
    finishRightly(quiz)
    #expect(quiz.shouldShowResults)
    #expect(quiz.canContinue)
    #expect(Current.settings.bestScore == 100)

    quiz.continueSession()
    #expect(quiz.quizState == .inProgress)
    #expect(!quiz.shouldShowResults)
    #expect(quiz.roundCount == 2)
    #expect(quiz.questions.count == 2 * Quiz.questionCount)
    #expect(quiz.currentQuestionIndex == Quiz.questionCount)
    #expect(quiz.score == 100)
    #expect(quiz.lastRoundResult == nil, "A new round shows no mark from the last.")

    finishRightly(quiz)
    #expect(quiz.score == 200)
    #expect(quiz.firstRoundScore == 100)
    #expect(quiz.sessionQuestionCount == 2 * Quiz.questionCount)
    #expect(Current.settings.bestScore == 100, "Ten More's points are not a best score.")
    Current.settings.bestScore = 0
  }

  @Test func tenMoreKeepsTheClock() {
    let quiz = makeQuiz()
    quiz.clockTicked()
    finishRightly(quiz)
    quiz.continueSession()
    quiz.clockTicked()
    #expect(quiz.elapsedTime == 2)
    quiz.quit()
  }

  @Test func tenMoreDrawsVerbsNotYetAsked() {
    let quiz = makeQuiz(level: .advanced, seed: 3)
    let first = Set(quiz.questions.filter { !QuizDraw.isCore($0.verb) }.map(\.verb.id))
    finishRightly(quiz)
    quiz.continueSession()
    let second = Set(quiz.questions.suffix(Quiz.questionCount).filter { !QuizDraw.isCore($0.verb) }.map(\.verb.id))
    #expect(first.isDisjoint(with: second))
    quiz.quit()
  }

  @Test func tenMoreIsOfferedOnlyAtTheResults() {
    let quiz = makeQuiz()
    #expect(!quiz.canContinue)
    quiz.continueSession()
    #expect(quiz.questions.count == Quiz.questionCount)
    quiz.quit()
    #expect(!quiz.canContinue)
  }

  @Test func aVerbPagesThreeQuestionsDoNotContinue() throws {
    let parler = try #require(Verb.verbs["parler"])
    #expect(!QuizScope.verbPage(parler).continues)
    #expect(QuizScope.myVerbs([parler]).continues)
    #expect(QuizScope.collection(.être).continues)
    #expect(QuizScope.allVerbs.continues)

    Current.settings.quizLevel = .elementary
    let quiz = Quiz(gameCenter: GameCenterStub(), seed: 1)
    quiz.start(scope: .verbPage(parler))
    finishRightly(quiz)
    #expect(quiz.shouldShowResults)
    #expect(!quiz.canContinue)
  }

  @Test func eachRoundsCompletionSendsItsQuestionCountAndNoScore() {
    withSpy { spy in
      let quiz = makeQuiz()
      miss(quiz)
      finishRightly(quiz)
      quiz.continueSession()
      finishRightly(quiz)

      #expect(spy.signalNames == [.quizStart, .quizCompletion, .quizCompletion])
      let completions = spy.signalParameters.dropFirst()
      #expect(completions.map { $0[ParameterKey.questionCount.rawValue] } == ["10", "20"])
      #expect(completions.allSatisfy { $0["score"] == nil && $0["elapsedTime"] == nil })
      #expect(completions.allSatisfy { $0[ParameterKey.duration.rawValue] == "0-3s" })
    }
  }

  @Test func aQuitSendsTheQuestionReachedWithoutReasksAndTheDurationInABand() {
    var clock = Date(timeIntervalSince1970: 1_000)
    withSpy { spy in
      let quiz = makeQuiz(now: { clock })
      miss(quiz)
      answerRightly(quiz, count: Quiz.reaskGap)
      #expect(quiz.currentQuestion?.isReask == true)
      clock += 20
      quiz.quit()

      let quitParameters = spy.signalParameters.last
      #expect(spy.signalNames.last == .quizQuit)
      #expect(quitParameters?[ParameterKey.lastQuestionIndex.rawValue] == "3")
      #expect(quitParameters?[ParameterKey.duration.rawValue] == "15-40s")
      #expect(quitParameters?["elapsedTime"] == nil)
    }
  }

  @Test(arguments: [
    (seconds: 0.0, band: "0-3s"),
    (seconds: 2.9, band: "0-3s"),
    (seconds: 3.0, band: "3-15s"),
    (seconds: 14.9, band: "3-15s"),
    (seconds: 15.0, band: "15-40s"),
    (seconds: 40.0, band: "40s-2m"),
    (seconds: 119.0, band: "40s-2m"),
    (seconds: 120.0, band: "2m+"),
    (seconds: 3_600.0, band: "2m+")
  ])
  func durationsGoOutInBands(seconds: Double, band: String) {
    #expect(AnalyticsBand.quizDuration(seconds) == band)
  }

  @Test func aQuizInProgressIsRecordedUntilItEnds() throws {
    let getterSetter = Current.getterSetter
    getterSetter.remove(key: QuizAbandonment.key)

    let quiz = makeQuiz(level: .intermediate)
    var entries = QuizAbandonment.entries(getterSetter: getterSetter)
    #expect(entries.count == 1)
    #expect(entries.values.first == QuizAbandonment.Entry(level: "intermediate", source: "tab", lastQuestionIndex: 0))

    miss(quiz)
    answerRightly(quiz, count: Quiz.reaskGap)
    entries = QuizAbandonment.entries(getterSetter: getterSetter)
    #expect(entries.values.first?.lastQuestionIndex == 3, "The re-ask on screen is not counted.")

    finishRightly(quiz)
    #expect(QuizAbandonment.entries(getterSetter: getterSetter).isEmpty)

    quiz.continueSession()
    #expect(QuizAbandonment.entries(getterSetter: getterSetter).values.first?.lastQuestionIndex == 10)
    quiz.quit()
    #expect(QuizAbandonment.entries(getterSetter: getterSetter).isEmpty)
  }

  @Test func theNextLaunchReportsEachAbandonedQuizOnce() {
    let getterSetter = GetterSetterFake()
    let spy = AnalyticsSpy()
    QuizAbandonment.record(.init(level: "beginner", source: "tab", lastQuestionIndex: 4), id: "tab", getterSetter: getterSetter)
    QuizAbandonment.record(.init(level: "advanced", source: "list", lastQuestionIndex: 0), id: "sheet", getterSetter: getterSetter)
    QuizAbandonment.record(.init(level: "beginner", source: "tab", lastQuestionIndex: 6), id: "tab", getterSetter: getterSetter)
    QuizAbandonment.clear(id: "nothing", getterSetter: getterSetter)

    QuizAbandonment.reportAndClear(getterSetter: getterSetter, analytics: spy)
    #expect(spy.signalNames == [.quizAbandon, .quizAbandon])
    let indexes = Set(spy.signalParameters.compactMap { $0[ParameterKey.lastQuestionIndex.rawValue] })
    #expect(indexes == ["6", "0"])
    #expect(getterSetter.get(key: QuizAbandonment.key) == nil)

    QuizAbandonment.reportAndClear(getterSetter: getterSetter, analytics: spy)
    #expect(spy.signalNames.count == 2)
  }

  @Test func theClockIsHiddenByDefaultAndPersists() {
    let getterSetter = GetterSetterFake()
    let settings = Settings(getterSetter: getterSetter)
    #expect(settings.quizClock == .hide)
    settings.quizClock = .show
    #expect(Settings(getterSetter: getterSetter).quizClock == .show)
  }

  @Test(arguments: QuizClock.allCases)
  func theLiveActivityShowsTimeOnlyWithTheClock(clock: QuizClock) throws {
    let liveActivities = try #require(Current.liveActivities as? LiveActivitiesSpy)
    let original = Current.settings.quizClock
    Current.settings.quizClock = clock
    defer {
      Current.settings.quizClock = original
    }
    let quiz = makeQuiz()
    let state = try #require(liveActivities.lastState)
    #expect((state.startDate != nil) == (clock == .show))
    #expect(state.totalQuestions == Quiz.questionCount)
    quiz.process(proposedAnswer: "x")
    quiz.continueAfterCorrection()
    #expect(liveActivities.lastState?.totalQuestions == Quiz.questionCount + 1, "A re-ask lengthens the round.")
    #expect(quiz.showsClock == (clock == .show))
    quiz.quit()
    #expect((liveActivities.lastState?.elapsedTime != nil) == (clock == .show))
  }
}
