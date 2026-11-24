//
//  QuizHubTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite("The Quiz tab's last result")
struct QuizHubTests {
  private let date = Date(timeIntervalSinceReferenceDate: 816_303_588)

  private var sample: LastQuizResult {
    LastQuizResult(kind: .verbPage, subject: "venir", level: .elementary, score: 25, correctCount: 2, secondAttemptCount: 1, questionCount: 3, date: date)
  }

  // A stored result must keep decoding after an update, so its form is pinned.
  @Test func storedFormIsPinned() throws {
    let json = #"{"kind":"allVerbs","levelKey":"intermediate","score":75,"correctCount":7,"secondAttemptCount":1,"questionCount":10,"date":816303588}"#
    let result = try #require(LastQuizResult(json: json))

    #expect(result == LastQuizResult(kind: .allVerbs, subject: nil, level: .intermediate, score: 75, correctCount: 7, secondAttemptCount: 1, questionCount: 10, date: date))
  }

  @Test func roundTrips() throws {
    let json = try #require(sample.json)
    #expect(LastQuizResult(json: json) == sample)
  }

  @Test func anUnreadableResultIsNone() {
    #expect(LastQuizResult(json: "{}") == nil)
    #expect(LastQuizResult(json: "") == nil)
  }

  @Test func anUnknownLevelReadsAsNone() {
    let result = LastQuizResult(kind: .review, subject: nil, level: nil, score: 0, correctCount: 0, secondAttemptCount: 0, questionCount: 1, date: date)
    #expect(result.level == nil)
    #expect(sample.level == .elementary)
  }

  @Test func eachScopeHasItsKind() throws {
    let venir = try #require(Verb.verbs["venir"])
    let custom = CustomQuiz(tenses: [.imparfait])
    let practiceSet = PracticeSet(custom: custom, level: .beginner)

    #expect(LastQuizResult.Kind(scope: .allVerbs) == .allVerbs)
    #expect(LastQuizResult.Kind(scope: .myVerbs([venir])) == .myVerbs)
    #expect(LastQuizResult.Kind(scope: .verbPage(venir)) == .verbPage)
    #expect(LastQuizResult.Kind(scope: .collection(.être)) == .collection)
    #expect(LastQuizResult.Kind(scope: .collection(.model("1-1"))) == .collection)
    #expect(LastQuizResult.Kind(scope: .custom(custom, myVerbs: [])) == .custom)
    #expect(LastQuizResult.Kind(scope: .custom(CustomQuiz(verbSet: .collection(.être)), myVerbs: [])) == .custom)
    #expect(LastQuizResult.Kind(scope: practiceSet.scope(source: .sharedLink)) == .practiceSet)
    #expect(LastQuizResult.Kind(scope: practiceSet.scope(source: .qrCode)) == .practiceSet)
    #expect(LastQuizResult.Kind(scope: .recordSession(.review)) == .review)
    #expect(LastQuizResult.Kind(scope: .recordSession(.mistakes)) == .mistakes)
  }

  @Test func titlesNameTheVerbOrCollection() throws {
    func collectionResult(_ collection: VerbCollection) -> LastQuizResult {
      LastQuizResult(kind: .collection, subject: collection.key, level: .beginner, score: 0, correctCount: 0, secondAttemptCount: 0, questionCount: 10, date: date)
    }
    let sortir = try #require(Verb.verbs.values.first { $0.infinitif == "sortir" && $0.extraLetters != nil })
    let doubled = LastQuizResult(kind: .verbPage, subject: sortir.dictionaryKey, level: .beginner, score: 0, correctCount: 0, secondAttemptCount: 0, questionCount: 3, date: date)

    #expect(sample.title == "venir")
    #expect(doubled.title == sortir.infinitifWithPossibleExtraLetters)
    #expect(collectionResult(.être).title == VerbCollection.être.title)
    #expect(collectionResult(.model("1-1")).title == VerbCollection.model("1-1").title)
  }

  @Test func everyCollectionIsFoundByItsKey() {
    for collection in VerbCollection.featured + [.model("1-1"), .model("2-1")] {
      #expect(VerbCollection(key: collection.key) == collection)
    }
    #expect(VerbCollection(key: "model-nonexistent") == nil)
    #expect(VerbCollection(key: "nonexistent") == nil)
  }

  @Test func theStoreKeepsTheResultAcrossALaunch() {
    let getterSetter = GetterSetterFake()
    PracticeStore(getterSetter: getterSetter).recordResult(sample)

    #expect(PracticeStore(getterSetter: getterSetter).lastResult == sample)
  }

  @Test func aResultAloneGivesResetSomethingToErase() {
    let practice = PracticeStore(getterSetter: GetterSetterFake())
    #expect(!practice.hasAnythingToReset)

    practice.recordResult(sample)

    #expect(practice.isEmpty)
    #expect(practice.hasAnythingToReset)
  }

  @Test func resetForgetsTheResult() {
    let getterSetter = GetterSetterFake()
    let practice = PracticeStore(getterSetter: getterSetter)
    practice.recordResult(sample)
    practice.reset()

    #expect(practice.lastResult == nil)
    #expect(!practice.hasAnythingToReset)
    #expect(PracticeStore(getterSetter: getterSetter).lastResult == nil)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("The last result, kept by quizzes")
  struct LastResultTests {
    /// A fresh store for the test, since the unit-test world's is shared. Each test puts back an
    /// empty one with `defer`.
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func restorePractice() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    private func started(_ scope: QuizScope = .allVerbs, level: QuizLevel = .intermediate, now: Date = .now) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 11) { now }
      quiz.start(scope: scope)
      return quiz
    }

    private func correctAnswer(for question: QuizQuestion) -> String {
      let conjugated = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: question.verb.extraLetters) ?? ""
      return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
    }

    /// Answers the first question wrongly and the rest rightly, re-ask included.
    private func finishMissingFirst(_ quiz: Quiz) throws {
      var isFirst = true
      while quiz.quizState == .inProgress {
        let question = try #require(quiz.currentQuestion)
        if question.choice != nil {
          quiz.skipChoice()
          continue
        }
        quiz.process(proposedAnswer: isFirst ? "definitelywrong" : correctAnswer(for: question))
        isFirst = false
        if quiz.correction != nil {
          quiz.continueAfterCorrection()
        }
      }
    }

    @Test func aFinishedQuizKeepsItsResult() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let now = Date(timeIntervalSinceReferenceDate: 816_303_588)
      let quiz = started(now: now)
      try finishMissingFirst(quiz)

      let result = try #require(practice.lastResult)
      #expect(result.kind == .allVerbs)
      #expect(result.level == .intermediate)
      #expect(result.correctCount == Quiz.questionCount - 1)
      #expect(result.secondAttemptCount == 0)
      #expect(result.questionCount == Quiz.questionCount)
      #expect(result.score == quiz.score)
      #expect(result.date == now)
    }

    @Test func tenMoreReplacesItWithTheSessionSoFar() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let quiz = started()
      try finishMissingFirst(quiz)
      quiz.continueSession()
      try finishMissingFirst(quiz)

      let result = try #require(practice.lastResult)
      #expect(result.questionCount == 2 * Quiz.questionCount)
      #expect(result.correctCount == 2 * Quiz.questionCount - 2)
      #expect(result.score == quiz.score)
    }

    @Test func aQuitQuizKeepsNothing() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let quiz = started()
      let question = try #require(quiz.currentQuestion)
      quiz.process(proposedAnswer: correctAnswer(for: question))
      quiz.quit()

      #expect(practice.lastResult == nil)
    }

    @Test func aRecordSessionKeepsNoLevel() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let venir = try #require(Verb.verbs["venir"])
      practice.recordAnswer(verb: venir, tense: .futurSimple(.thirdSingular), isCorrect: false)
      let quiz = started(.recordSession(.mistakes))
      try finishMissingFirst(quiz)

      let result = try #require(practice.lastResult)
      #expect(result.kind == .mistakes)
      #expect(result.level == nil)
      #expect(result.questionCount == 1)
    }

    @Test func onlyARecordSessionAsksByNoLevel() throws {
      let venir = try #require(Verb.verbs["venir"])
      #expect(QuizScope.allVerbs.asksByLevel)
      #expect(QuizScope.verbPage(venir).asksByLevel)
      #expect(QuizScope.collection(.être).asksByLevel)
      #expect(!QuizScope.recordSession(.review).asksByLevel)
      #expect(!QuizScope.recordSession(.mistakes).asksByLevel)
    }

    @Test func aRecordSessionsLiveActivityNamesTheSession() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let liveActivities = try #require(Current.liveActivities as? LiveActivitiesSpy)
      let venir = try #require(Verb.verbs["venir"])
      practice.recordAnswer(verb: venir, tense: .futurSimple(.thirdSingular), isCorrect: false)

      let session = started(.recordSession(.mistakes))
      #expect(liveActivities.lastAttributes?.level == QuizRecordSession.mistakes.title)
      session.quit()

      let quiz = started(level: .beginner)
      #expect(liveActivities.lastAttributes?.level == QuizLevel.beginner.localizedName)
      quiz.quit()
    }

    @Test func aVerbPageQuizNamesItsVerb() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let venir = try #require(Verb.verbs["venir"])
      let quiz = started(.verbPage(venir))
      try finishMissingFirst(quiz)

      let result = try #require(practice.lastResult)
      #expect(result.kind == .verbPage)
      #expect(result.subject == "venir")
      #expect(result.questionCount == QuizScope.verbPageQuestionCount)
    }

    @Test func aCollectionsQuizNamesItsCollection() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let quiz = started(.collection(.être))
      try finishMissingFirst(quiz)

      let result = try #require(practice.lastResult)
      #expect(result.kind == .collection)
      #expect(result.subject == VerbCollection.être.key)
    }
  }
}
