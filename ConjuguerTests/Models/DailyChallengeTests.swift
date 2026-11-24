//
//  DailyChallengeTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/24/26.
//

@testable import Conjuguer
import Foundation
import Testing

/// Noon of the `offset`th day after 24 November 2026, in the test machine's own calendar, as a
/// learner's day is.
@MainActor private func day(_ offset: Int) -> Date {
  let start = WidgetDateHelper.calendar.date(from: DateComponents(year: 2026, month: 11, day: 24, hour: 12)) ?? .now
  return WidgetDateHelper.calendar.date(byAdding: .day, value: offset, to: start) ?? start
}

@MainActor private func cells(_ questions: [QuizQuestion]) -> [String] {
  questions.map { "\($0.verb.id)|\($0.tense)" }
}

@MainActor private var approvedKey: DailyChallenge.Key? {
  DailyChallenge.Key(day: "2026-11-24", level: .elementary)
}

@MainActor
@Suite("Daily Challenge")
struct DailyChallengeTests {
  /// Changing either changes every challenge on every device.
  @Test func theSeedIsPinned() throws {
    let key = try #require(approvedKey)
    #expect(key.seedText == "challenge-2026-11-24-elementary")
    #expect(key.seed == 10_065_244_829_978_648_830)
  }

  @Test func aDayRoundTrips() throws {
    let key = DailyChallenge.Key(date: day(0), level: .advanced)
    #expect(key.day == "2026-11-24")
    #expect(key.level == .advanced)
    let parsed = try #require(DailyChallenge.Key(day: key.day, level: .advanced))
    #expect(parsed == key)
    #expect(WidgetDateHelper.dateString(for: parsed.date) == key.day)
  }

  @Test(arguments: ["2026-02-30", "2026-13-01", "2026-1-5", "2026-11-24x", "yesterday", ""])
  func aDayThatIsNotADateNamesNoChallenge(_ text: String) {
    #expect(DailyChallenge.Key(day: text, level: .beginner) == nil)
  }

  @Test(arguments: QuizLevel.allCases)
  func theSameKeyDrawsTheSameFive(_ level: QuizLevel) {
    let key = DailyChallenge.Key(date: day(0), level: level)
    let first = DailyChallenge.draw(for: key)
    #expect(first.count == DailyChallenge.questionCount)
    #expect(cells(DailyChallenge.draw(for: key)) == cells(first))
    #expect(cells(DailyChallenge.questions(for: key)) == cells(first))
  }

  @Test func daysAndLevelsDiffer() {
    let days = (0 ..< 10).map { cells(DailyChallenge.questions(for: DailyChallenge.Key(date: day($0), level: .intermediate))) }
    #expect(Set(days).count == days.count)
    let levels = QuizLevel.allCases.map { cells(DailyChallenge.questions(for: DailyChallenge.Key(date: day(0), level: $0))) }
    #expect(Set(levels).count == levels.count)
  }

  /// Each of twenty days asks five cells of the level's tenses, of verbs in its band that have
  /// them, with no verb twice, at least two core verbs, and the irregular share of the default
  /// quiz.
  @Test(arguments: QuizLevel.allCases)
  func everyDayIsABalancedChallengeAtItsLevel(_ level: QuizLevel) {
    let levelCells = Set(level.slots.flatMap(\.cells))
    for offset in 0 ..< 20 {
      let questions = DailyChallenge.questions(for: DailyChallenge.Key(date: day(offset), level: level))
      #expect(questions.count == DailyChallenge.questionCount)
      #expect(questions.allSatisfy { levelCells.contains($0.tense) && $0.verb.hasCell($0.tense) })
      if let band = level.band {
        #expect(questions.allSatisfy { $0.verb.isIn(band) })
      }
      #expect(Set(questions.map(\.verb.id)).count == questions.count)
      #expect(questions.filter { QuizDraw.isCore($0.verb) }.count >= QuizDraw.minimumCoreQuestions)
      #expect(questions.filter { VerbDraw.isIrregular($0.verb) }.count >= 3)
      #expect(questions.allSatisfy { !$0.isReask && $0.choice == nil && $0.sentence == nil && $0.recognition == nil })
    }
  }

  @Test func aResultCountsItsOutcomes() throws {
    let key = try #require(approvedKey)
    let result = DailyChallengeResult(key: key, outcomes: [.right, .secondTry, .wrong, .right, .right])
    #expect(result.score == 35)
    #expect(result.dots == "🟢🟠🔴🟢🟢")
    #expect(result.pointsLine == "35 / 50")
    #expect(result.spokenSummary == "Right on the first try: 3 of 5. On the second: 1. Score: 35 of 50.")
  }

  @Test func theSharedTextIsTheApprovedOne() throws {
    let key = try #require(approvedKey)
    let result = DailyChallengeResult(key: key, outcomes: [.right, .secondTry, .wrong, .right, .right])
    #expect(result.shareText(locale: Locale(identifier: "en_US")) == """
      Conjuguer · Daily Challenge
      November 24, 2026 · Elementary
      🟢🟠🔴🟢🟢  35 / 50

      Take this challenge in Conjuguer:
      conjuguer://quiz/challenge?date=2026-11-24&level=elementary&source=challengeLink

      Get Conjuguer on the App Store:
      https://apps.apple.com/app/conjuguer/id1588624373
      """)
  }

  @Test func theSharedDateFollowsTheLocale() throws {
    let result = DailyChallengeResult(key: try #require(approvedKey), outcomes: [.right])
    #expect(result.shareText(locale: Locale(identifier: "fr_FR")).contains("24 novembre 2026"))
  }

  /// The widget's question for a day is the first of that day's challenge, with three wrong
  /// answers that are other conjugations of the same verb.
  @Test(arguments: QuizLevel.allCases)
  func theWidgetAsksTheChallengesFirstQuestion(_ level: QuizLevel) throws {
    let fallback = try #require(Verb.verbs["parler"])
    for offset in 0 ..< 10 {
      let key = DailyChallenge.Key(date: day(offset), level: level)
      let first = try #require(DailyChallenge.questions(for: key).first)
      let widget = WidgetSnapshotWriter.quizQuestion(on: day(offset), level: level, fallbackVerb: fallback)
      let answer = Conjugator.conjugatedString(infinitif: first.verb.infinitif, tense: first.tense, extraLetters: first.verb.extraLetters)

      #expect(widget.infinitif == first.verb.infinitifWithPossibleExtraLetters)
      #expect(widget.tenseDisplay == first.tense.titleCaseName)
      #expect(widget.correctAnswer == answer)
      #expect(widget.questionID == "\(key.day)-\(level.rawValue)-\(first.verb.dictionaryKey)")
      #expect(widget.wrongAnswers.count == 3)
      #expect(Set(widget.wrongAnswers).count == 3)
      #expect(!widget.wrongAnswers.contains(widget.correctAnswer))
    }
  }

  @Test func theSnapshotCarriesTheChallengesQuestion() throws {
    let verb = try #require(Verb.verbs["venir"])
    let snapshot = WidgetSnapshotWriter.generateSnapshot(verb: verb, date: day(0), level: .beginner)
    #expect(snapshot.quizQuestion == WidgetSnapshotWriter.quizQuestion(on: day(0), level: .beginner, fallbackVerb: verb))
    #expect(snapshot.infinitif == "venir")
  }

  @Test func theStableSeedIsFNV1a() {
    #expect(WidgetQuizQuestion.stableSeed(for: "") == 0xcbf2_9ce4_8422_2325)
    #expect(WidgetQuizQuestion.stableSeed(for: "a") == 0xaf63_dc4c_8601_ec8c)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("A daily challenge in a quiz")
  struct ChallengeQuizTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func restore() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    private func correctAnswer(_ quiz: Quiz) throws -> String {
      let question = try #require(quiz.currentQuestion)
      let conjugated = try #require(Conjugator.conjugatedString(
        infinitif: question.verb.infinitif,
        tense: question.tense,
        extraLetters: question.verb.extraLetters,
        pronounGender: question.pronounGender
      ))
      return (conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated).lowercased()
    }

    private func key(_ level: QuizLevel = .intermediate) -> DailyChallenge.Key {
      DailyChallenge.Key(date: day(0), level: level)
    }

    @Test func everyQuizAsksTheSameFiveWhateverTheSeedTheLevelAndTheRecord() throws {
      let practice = freshPractice()
      defer {
        restore()
      }
      let parler = try #require(Verb.verbs["parler"])
      practice.recordAnswer(verb: parler, tense: .imparfait(.firstPlural), isCorrect: false, at: day(-3))
      let expected = cells(DailyChallenge.questions(for: key()))
      for (seed, level) in [(UInt64(1), QuizLevel.beginner), (2, .advanced)] {
        Current.settings.quizLevel = level
        let quiz = Quiz(gameCenter: GameCenterSpy(), seed: seed, now: { day(0) })
        quiz.start(scope: .challenge(key()))
        #expect(cells(quiz.questions) == expected)
        #expect(quiz.level == .intermediate)
        quiz.quit()
      }
    }

    @Test func aFinishedChallengeIsKeptOnceAndNeverRanked() throws {
      let practice = freshPractice()
      defer {
        restore()
      }
      Current.settings.quizLevel = .intermediate
      let bestBefore = Current.settings.bestScore(at: .intermediate)
      let gameCenter = GameCenterSpy(isAuthenticated: true)
      let quiz = Quiz(gameCenter: gameCenter, seed: 3, now: { day(0) })
      quiz.start(scope: .challenge(key()))
      #expect(!quiz.scope.isRanked)
      while quiz.quizState == .inProgress {
        quiz.process(proposedAnswer: try correctAnswer(quiz))
      }

      let result = try #require(quiz.challengeResult)
      #expect(result.outcomes == Array(repeating: .right, count: 5))
      #expect(result.score == 50)
      #expect(practice.challengeResult(for: key()) == result)
      #expect(gameCenter.reports.isEmpty)
      #expect(Current.settings.bestScore(at: .intermediate) == bestBefore)
      #expect(!quiz.canContinue)
      #expect(practice.lastResult?.kind == .challenge)

      let again = Quiz(gameCenter: GameCenterSpy(), seed: 4, now: { day(0) })
      again.start(scope: .challenge(key()))
      while again.quizState == .inProgress {
        again.process(proposedAnswer: "x")
        again.continueAfterCorrection()
      }
      #expect(again.challengeResult == result)
      #expect(practice.challengeResults.count == 1)
    }

    /// A miss is held for its correction but never re-asked, so that the results are the five
    /// questions the shared text reports.
    @Test func aMissIsNotReasked() throws {
      freshPractice()
      defer {
        restore()
      }
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 5, now: { day(0) })
      quiz.start(scope: .challenge(key()))
      quiz.process(proposedAnswer: "x")
      #expect(quiz.correction?.willBeReasked == false)
      #expect(quiz.questions.count == DailyChallenge.questionCount)
      quiz.continueAfterCorrection()
      while quiz.quizState == .inProgress {
        quiz.process(proposedAnswer: try correctAnswer(quiz))
      }
      #expect(quiz.challengeResult?.outcomes == [.wrong, .right, .right, .right, .right])
      #expect(quiz.challengeResult?.score == 40)
    }

    @Test func aQuitChallengeKeepsNothing() {
      let practice = freshPractice()
      defer {
        restore()
      }
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 6, now: { day(0) })
      quiz.start(scope: .challenge(key()))
      quiz.quit()
      #expect(quiz.challengeResult == nil)
      #expect(practice.challengeResult(for: key()) == nil)
    }

    @Test func theStoreKeepsTheLatestTwelveAcrossALaunchAndAReset() {
      let getterSetter = GetterSetterFake()
      let practice = PracticeStore(getterSetter: getterSetter)
      for offset in 0 ..< 14 {
        practice.recordChallenge(DailyChallengeResult(key: DailyChallenge.Key(date: day(offset), level: .beginner), outcomes: [.right]))
      }
      #expect(practice.challengeResults.count == DailyChallengeResult.keptCount)
      #expect(practice.challengeResults.first?.key == DailyChallenge.Key(date: day(2), level: .beginner))
      #expect(practice.challengeResults.last?.key == DailyChallenge.Key(date: day(13), level: .beginner))

      let relaunched = PracticeStore(getterSetter: getterSetter)
      #expect(relaunched.challengeResults == practice.challengeResults)
      relaunched.reset()
      #expect(relaunched.challengeResults.count == DailyChallengeResult.keptCount)
      #expect(PracticeStore(getterSetter: getterSetter).challengeResults.count == DailyChallengeResult.keptCount)
    }

    /// The signals name the challenge and its length, and sharing names only the level.
    @Test func theSignalsCarryTheSourceAndNeverTheResult() throws {
      freshPractice()
      let original = Current.analytics
      let spy = AnalyticsSpy()
      Current.analytics = spy
      defer {
        Current.analytics = original
        restore()
      }
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 7, now: { day(0) })
      quiz.start(scope: .challenge(key(), source: .challengeLink))
      while quiz.quizState == .inProgress {
        quiz.process(proposedAnswer: try correctAnswer(quiz))
      }
      try #require(quiz.challengeResult).signalShare()

      let start = try #require(spy.signalNames.firstIndex(of: .quizStart))
      #expect(spy.signalParameters[start][ParameterKey.source.rawValue] == AnalyticsSource.challengeLink.rawValue)
      let completion = try #require(spy.signalNames.firstIndex(of: .quizCompletion))
      #expect(spy.signalParameters[completion][ParameterKey.questionCount.rawValue] == "5")
      let share = try #require(spy.signalNames.firstIndex(of: .tapShareChallenge))
      #expect(spy.signalParameters[share] == [ParameterKey.level.rawValue: QuizLevel.intermediate.rawValue])
    }
  }
}
