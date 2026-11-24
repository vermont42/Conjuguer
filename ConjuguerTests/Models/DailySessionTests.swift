//
//  DailySessionTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/24/26.
//

@testable import Conjuguer
import Foundation
import Testing

/// A fixed calendar, so that a day is the same day on every machine.
private let paris: Calendar = {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
  return calendar
}()

/// Noon, or `hour`, of the `offset`th day after 2 November 2026.
private func day(_ offset: Int, hour: Int = 12) -> Date {
  let start = paris.date(from: DateComponents(year: 2026, month: 11, day: 2, hour: hour)) ?? .now
  return paris.date(byAdding: .day, value: offset, to: start) ?? start
}

@MainActor
@Suite("Daily Session")
struct DailySessionTests {
  private func streak(sessionsOn days: [Int]) -> DailyStreak {
    var streak = DailyStreak()
    for offset in days {
      streak.recordSession(at: day(offset), calendar: paris)
    }
    return streak
  }

  @Test func noSessionIsNoStreak() {
    #expect(DailyStreak().status(at: day(0), calendar: paris) == .none)
  }

  @Test func aStreakLivesThroughTheNextDayAndCanBeRepairedTheDayAfter() {
    let streak = streak(sessionsOn: [0])

    #expect(streak.status(at: day(0, hour: 23), calendar: paris) == .active(length: 1, isDoneToday: true))
    #expect(streak.status(at: day(1, hour: 0), calendar: paris) == .active(length: 1, isDoneToday: false))
    #expect(streak.status(at: day(2), calendar: paris) == .repairable(length: 1, sessionsToday: 0))
    #expect(streak.status(at: day(3), calendar: paris) == .none)
  }

  @Test func consecutiveDaysCountOnceEach() {
    let streak = streak(sessionsOn: [0, 1, 1, 2])

    #expect(streak.status(at: day(2), calendar: paris) == .active(length: 3, isDoneToday: true))
  }

  /// One missed day is repaired by two sessions the day after, and the missed day does not count.
  @Test func twoSessionsTheDayAfterAMissedDayRepairTheStreak() {
    var streak = streak(sessionsOn: [0, 1, 2])
    streak.recordSession(at: day(4, hour: 8), calendar: paris)
    #expect(streak.status(at: day(4), calendar: paris) == .repairable(length: 3, sessionsToday: 1))

    streak.recordSession(at: day(4, hour: 21), calendar: paris)
    #expect(streak.status(at: day(4, hour: 22), calendar: paris) == .active(length: 4, isDoneToday: true))
    #expect(streak.status(at: day(5), calendar: paris) == .active(length: 4, isDoneToday: false))
  }

  @Test func oneSessionTheDayAfterAMissedDayStartsANewStreak() {
    var streak = streak(sessionsOn: [0, 1, 3])
    #expect(streak.status(at: day(4), calendar: paris) == .active(length: 1, isDoneToday: false))

    streak.recordSession(at: day(4), calendar: paris)
    #expect(streak.status(at: day(4), calendar: paris) == .active(length: 2, isDoneToday: true))
  }

  @Test func twoMissedDaysCannotBeRepaired() {
    let streak = streak(sessionsOn: [0, 3, 3])

    #expect(streak.status(at: day(3), calendar: paris) == .active(length: 1, isDoneToday: true))
  }

  /// The clocks went back in Paris on 25 October 2026, a day of 25 hours.
  @Test func aDayOfTwentyFiveHoursIsOneDay() throws {
    let saturday = try #require(paris.date(from: DateComponents(year: 2026, month: 10, day: 24, hour: 23, minute: 30)))
    let sunday = try #require(paris.date(from: DateComponents(year: 2026, month: 10, day: 25, hour: 23, minute: 30)))
    var streak = DailyStreak()
    streak.recordSession(at: saturday, calendar: paris)
    streak.recordSession(at: sunday, calendar: paris)

    #expect(streak.status(at: sunday, calendar: paris) == .active(length: 2, isDoneToday: true))
  }

  /// Only the last two runs are kept, since only the one before the last can still be joined.
  @Test func runsThatCanNoLongerChangeAreDropped() {
    var streak = streak(sessionsOn: [0, 5, 10, 12])
    #expect(streak.sessions.count == 2)
    #expect(streak.status(at: day(12), calendar: paris) == .repairable(length: 1, sessionsToday: 1))

    streak.recordSession(at: day(12, hour: 20), calendar: paris)
    #expect(streak.status(at: day(12, hour: 21), calendar: paris) == .active(length: 2, isDoneToday: true))
  }

  @Test(arguments: [(1, "1"), (2, "2-6"), (6, "2-6"), (7, "7-29"), (29, "7-29"), (30, "30+"), (365, "30+")])
  func theStreakIsSentInBands(length: Int, band: String) {
    #expect(AnalyticsBand.streak(length) == band)
  }

  @Test func theStoreKeepsTheStreakAcrossALaunchAndResetForgetsIt() {
    let getterSetter = GetterSetterFake()
    let practice = PracticeStore(getterSetter: getterSetter, calendar: paris)
    #expect(!practice.hasAnythingToReset)
    #expect(practice.recordDailySession(at: day(0)) == .active(length: 1, isDoneToday: true))
    practice.recordDailySession(at: day(1))
    #expect(practice.hasAnythingToReset)

    let relaunched = PracticeStore(getterSetter: getterSetter, calendar: paris)
    #expect(relaunched.streakStatus(at: day(1)) == .active(length: 2, isDoneToday: true))

    relaunched.reset()
    #expect(PracticeStore(getterSetter: getterSetter, calendar: paris).streakStatus(at: day(1)) == .none)
  }

  @Test func theHubAndTheResultsSayWhatTheStreakNeeds() {
    #expect(DailyStreak.Status.none.hubDetail == L.DailySession.description)
    #expect(DailyStreak.Status.none.resultsLine == nil)
    #expect(DailyStreak.Status.active(length: 3, isDoneToday: false).hubDetail == L.DailySession.streakKeepGoing(3))
    #expect(DailyStreak.Status.active(length: 3, isDoneToday: true).hubDetail == L.DailySession.streakDoneToday(3))
    #expect(DailyStreak.Status.active(length: 3, isDoneToday: true).resultsLine == L.DailySession.streak(3))
    #expect(DailyStreak.Status.repairable(length: 3, sessionsToday: 0).hubDetail == L.DailySession.repairTwo(3))
    #expect(DailyStreak.Status.repairable(length: 3, sessionsToday: 1).resultsLine == L.DailySession.repairOne(3))
    #expect(DailyStreak.Status.repairable(length: 3, sessionsToday: 1).awaitsRepairSession)
    #expect(!DailyStreak.Status.repairable(length: 3, sessionsToday: 0).awaitsRepairSession)
    #expect(!DailyStreak.Status.active(length: 3, isDoneToday: true).awaitsRepairSession)
  }

  @Test func theScopeIsNeitherRankedNorContinued() {
    let scope = QuizScope.daily()

    #expect(scope.isDaily)
    #expect(!scope.isRanked)
    #expect(!scope.continues)
    #expect(scope.startsLiveActivity)
    #expect(scope.mixesDueItems)
    #expect(scope.dueItemLimit == Quiz.questionCount)
    #expect(!scope.mixesChoiceQuestions)
    #expect(scope.asksByLevel)
    #expect(scope.sendsQuestionCounts)
    #expect(scope.source == .daily)
    #expect(scope.sessionTitle == L.DailySession.title)
    #expect(QuizScope.daily(source: .reminder).source == .reminder)
    #expect(LastQuizResult.Kind(scope: scope) == .daily)
    #expect(QuizScope.allVerbs.dueItemLimit == QuizDraw.dueItemLimit)
  }

  @Test func remindersComeEachDayAtTheChosenTime() {
    let reminders = DailyReminderPlan.reminders(record: PracticeRecord(), streak: DailyStreak(), minutes: 18 * 60 + 15, now: day(0, hour: 9), calendar: paris)

    #expect(reminders.count == DailyReminderPlan.dayCount)
    let first = reminders[0]
    #expect(paris.dateComponents([.day, .hour, .minute], from: first.date) == DateComponents(day: 2, hour: 18, minute: 15))
    #expect(first.identifier == "dailyReminder.2026-11-02")
    #expect(first.title == L.DailyReminder.title)
    #expect(first.body == L.DailyReminder.body)
    #expect(Set(reminders.map(\.identifier)).count == reminders.count)
  }

  @Test func todaysReminderIsLeftOutOnceItsTimeHasPassed() throws {
    let reminders = DailyReminderPlan.reminders(record: PracticeRecord(), streak: DailyStreak(), minutes: 8 * 60, now: day(0, hour: 9), calendar: paris)

    #expect(reminders.count == DailyReminderPlan.dayCount - 1)
    #expect(paris.component(.day, from: try #require(reminders.first).date) == 3)
  }

  /// Today's session done, today's reminder goes. The days after say what the streak needs.
  @Test func aDoneDayGetsNoReminderAndARepairableDaySaysSo() {
    let reminders = DailyReminderPlan.reminders(record: PracticeRecord(), streak: streak(sessionsOn: [0]), minutes: 18 * 60, now: day(0, hour: 9), calendar: paris)

    #expect(reminders.count == DailyReminderPlan.dayCount - 1)
    #expect(reminders.map(\.identifier).first == "dailyReminder.2026-11-03")
    #expect(reminders[0].body == L.DailyReminder.body)
    #expect(reminders[1].body == L.DailySession.repairTwo(1))
    #expect(reminders[2].body == L.DailyReminder.body)
  }

  @Test func aReminderCountsWhatWillBeDueThatDay() throws {
    let parler = try #require(Verb.verbs["parler"])
    var record = PracticeRecord()
    for person in [PersonNumber.firstSingular, .secondSingular] {
      record.recordAnswer(.exercised(by: .indicatifPrésent(person), of: parler), isCorrect: false, at: day(-1), calendar: paris)
    }
    // Right on day 0 as a new item, so due three days later.
    record.recordAnswer(.exercised(by: .imparfait(.firstSingular), of: parler), isCorrect: true, at: day(0), calendar: paris)
    record.recordAnswer(.keyConjugation(verb: "notaverb", stem: .présent), isCorrect: false, at: day(-1), calendar: paris)
    let reminders = DailyReminderPlan.reminders(record: record, streak: DailyStreak(), minutes: 18 * 60, now: day(0, hour: 9), calendar: paris)

    #expect(reminders[0].body == L.DailyReminder.bodyDue(2))
    #expect(reminders[3].body == L.DailyReminder.bodyDue(3))
  }
}

extension QuizTests {
  @MainActor
  @Suite("A daily session in a quiz")
  struct DailySessionQuizTests {
    /// The unit-test world's store is shared, so each test puts back an empty one.
    @discardableResult
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake(), calendar: paris)
      Current.practice = practice
      return practice
    }

    private func restore() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.settings.dailyReminder = .off
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

    private func item(of question: QuizQuestion) -> PracticeItem {
      PracticeItem.exercised(by: question.tense, of: question.verb)
    }

    /// A daily session started at `date` and answered right throughout.
    @discardableResult
    private func finishDailySession(at date: Date, source: AnalyticsSource = .daily, gameCenter: GameCenter = GameCenterSpy()) throws -> Quiz {
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(gameCenter: gameCenter, seed: 8, now: { date })
      quiz.start(scope: .daily(source: source))
      while quiz.quizState == .inProgress {
        quiz.process(proposedAnswer: try correctAnswer(quiz))
      }
      return quiz
    }

    @Test func aSessionAsksTenAtTheLevelDueItemsFirstAndNothingBeyondIt() throws {
      let practice = freshPractice()
      defer {
        restore()
      }
      let parler = try #require(Verb.verbs["parler"])
      let venir = try #require(Verb.verbs["venir"])
      let due = [
        PracticeItem.exercised(by: .imparfait(.firstPlural), of: parler),
        PracticeItem.exercised(by: .indicatifPrésent(.thirdSingular), of: venir)
      ]
      let beyond = PracticeItem.exercised(by: .passéSimple(.thirdSingular), of: venir)
      practice.recordAnswer(verb: parler, tense: .imparfait(.firstPlural), isCorrect: false, at: day(-1))
      practice.recordAnswer(verb: venir, tense: .indicatifPrésent(.thirdSingular), isCorrect: false, at: day(-1))
      practice.recordAnswer(verb: venir, tense: .passéSimple(.thirdSingular), isCorrect: false, at: day(-1))
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 2, now: { day(0) })
      quiz.start(scope: .daily())
      defer {
        quiz.quit()
      }

      #expect(quiz.questions.count == Quiz.questionCount)
      let cells = Set(QuizLevel.elementary.slots.flatMap(\.cells))
      #expect(quiz.questions.allSatisfy { cells.contains($0.tense) && $0.choice == nil })
      let asked = quiz.questions.map(item(of:))
      #expect(due.allSatisfy(asked.contains))
      #expect(!asked.contains(beyond))
    }

    @Test func tenDueItemsFillTheSessionMostOverdueFirst() throws {
      let practice = freshPractice()
      defer {
        restore()
      }
      let parler = try #require(Verb.verbs["parler"])
      let tenses = PersonNumber.allCases.map(Tense.indicatifPrésent) + PersonNumber.allCases.map(Tense.imparfait)
      for (index, tense) in tenses.enumerated() {
        practice.recordAnswer(verb: parler, tense: tense, isCorrect: false, at: day(-10 + index))
      }
      let due = practice.dueItems(at: day(10))
      #expect(due.count == tenses.count)
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 4, now: { day(10) })
      quiz.start(scope: .daily())
      defer {
        quiz.quit()
      }

      #expect(quiz.questions.count == Quiz.questionCount)
      #expect(Set(quiz.questions.map(item(of:))) == Set(due.prefix(Quiz.questionCount)))
    }

    @Test func finishingExtendsTheStreakAndSendsItsBand() throws {
      let practice = freshPractice()
      defer {
        restore()
      }
      let original = Current.analytics
      let spy = AnalyticsSpy()
      Current.analytics = spy
      defer {
        Current.analytics = original
      }
      let gameCenter = GameCenterSpy()
      let bestScore = Current.settings.bestScore(at: .elementary)
      let quiz = try finishDailySession(at: day(0), gameCenter: gameCenter)

      #expect(quiz.shouldShowResults)
      #expect(quiz.correctCount == Quiz.questionCount)
      #expect(quiz.dailyStreakStatus == .active(length: 1, isDoneToday: true))
      #expect(practice.streakStatus(at: day(0)) == .active(length: 1, isDoneToday: true))
      #expect(!quiz.canContinue)
      #expect(gameCenter.reports.isEmpty)
      #expect(Current.settings.bestScore(at: .elementary) == bestScore)
      #expect(practice.lastResult?.kind == .daily)
      #expect(practice.lastResult?.level == .elementary)
      #expect(practice.lastResult?.title == L.DailySession.title)
      let completion = try #require(Array(zip(spy.signalNames, spy.signalParameters)).last { $0.0 == .quizCompletion }?.1)
      #expect(completion[ParameterKey.streak.rawValue] == "1")
      #expect(completion[ParameterKey.source.rawValue] == "daily")
      #expect(completion[ParameterKey.questionCount.rawValue] == "10")
    }

    @Test func aQuitSessionDoesNotCount() throws {
      let practice = freshPractice()
      defer {
        restore()
      }
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 8, now: { day(0) })
      quiz.start(scope: .daily())
      quiz.process(proposedAnswer: try correctAnswer(quiz))
      quiz.quit()

      #expect(practice.streakStatus(at: day(0)) == .none)
      #expect(quiz.dailyStreakStatus == nil)
    }

    /// Two days, a missed day, then two sessions: the first's results offer the second, which
    /// repairs.
    @Test func aStreakIsRepairedAcrossDays() throws {
      let practice = freshPractice()
      defer {
        restore()
      }
      try finishDailySession(at: day(0))
      try finishDailySession(at: day(1))
      #expect(practice.streakStatus(at: day(3)) == .repairable(length: 2, sessionsToday: 0))

      let first = try finishDailySession(at: day(3, hour: 9))
      #expect(first.dailyStreakStatus == .repairable(length: 2, sessionsToday: 1))
      #expect(first.dailyStreakStatus?.awaitsRepairSession == true)
      #expect(first.dailyStreakStatus?.resultsLine == L.DailySession.repairOne(2))

      let second = try finishDailySession(at: day(3, hour: 10))
      #expect(second.dailyStreakStatus == .active(length: 3, isDoneToday: true))
      #expect(second.dailyStreakStatus?.awaitsRepairSession == false)
      #expect(practice.streakStatus(at: day(4)) == .active(length: 3, isDoneToday: false))
    }

    /// On the real clock and calendar, which the plan reads.
    @Test func finishingReschedulesTheReminderWhileItIsOn() throws {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
      defer {
        restore()
      }
      let reminders = try #require(Current.reminderScheduler as? ReminderSchedulerSpy)
      Current.settings.dailyReminder = .on
      let before = reminders.schedules.count
      try finishDailySession(at: .now)

      #expect(reminders.schedules.count == before + 1)
      #expect(!reminders.scheduled.isEmpty)
      #expect(!reminders.scheduled.contains { $0.identifier == DailyReminderPlan.identifierPrefix + DailyStreak.dayKey(.now) })

      Current.settings.dailyReminder = .off
      Current.rescheduleReminders()
      #expect(reminders.scheduled.isEmpty)
    }

    @Test func theReminderNamesItselfAsTheSource() throws {
      freshPractice()
      defer {
        restore()
      }
      let original = Current.analytics
      let spy = AnalyticsSpy()
      Current.analytics = spy
      defer {
        Current.analytics = original
      }
      try finishDailySession(at: day(0), source: .reminder)

      let start = try #require(Array(zip(spy.signalNames, spy.signalParameters)).last { $0.0 == .quizStart }?.1)
      #expect(start[ParameterKey.source.rawValue] == "reminder")
    }
  }
}
