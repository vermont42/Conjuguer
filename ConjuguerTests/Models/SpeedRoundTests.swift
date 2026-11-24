//
//  SpeedRoundTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/24/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite("Speed Round")
struct SpeedRoundTests {
  private let calendar = Calendar.current
  private let now = Date(timeIntervalSince1970: 1_800_000_000)

  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  /// Right answers on two days, four apart, which reach the third box.
  static func master(_ items: [PracticeItem], in record: inout PracticeRecord, from start: Date, calendar: Calendar = .current) {
    for item in items {
      record.recordAnswer(item, isCorrect: true, at: start, calendar: calendar)
      record.recordAnswer(item, isCorrect: true, at: start.addingTimeInterval(4 * 86_400), calendar: calendar)
    }
  }

  static func items() throws -> [PracticeItem] {
    let plan: [(key: String, tense: Tense)] = [
      ("parler", .indicatifPrésent(.firstSingular)),
      ("finir", .imparfait(.firstPlural)),
      ("manger", .indicatifPrésent(.firstPlural)),
      ("venir", .indicatifPrésent(.thirdSingular)),
      ("faire", .futurSimple(.thirdSingular))
    ]
    return try plan.map { PracticeItem.exercised(by: $0.tense, of: try #require(Verb.verbs[$0.key])) }
  }

  private func item(of question: QuizQuestion) -> PracticeItem {
    PracticeItem.exercised(by: question.tense, of: question.verb)
  }

  @Test func onlyTheThirdBoxAndAboveIsMastered() throws {
    let parler = try verb("parler")
    let mastered = PracticeItem.exercised(by: .indicatifPrésent(.firstSingular), of: parler)
    let learning = PracticeItem.exercised(by: .indicatifPrésent(.secondSingular), of: parler)
    let missed = PracticeItem.exercised(by: .indicatifPrésent(.thirdSingular), of: parler)
    var record = PracticeRecord()
    Self.master([mastered], in: &record, from: now, calendar: calendar)
    record.recordAnswer(learning, isCorrect: true, at: now, calendar: calendar)
    record.recordAnswer(missed, isCorrect: false, at: now, calendar: calendar)
    record.recordLookup([.keyConjugation(verb: "venir", stem: .présent)], at: now, calendar: calendar)

    #expect(record.entry(for: mastered)?.schedule.box == MasteryState.masteredBox)
    #expect(SpeedRound.masteredItems(in: record) == [mastered])
  }

  @Test func anItemThatCanNoLongerBeAskedIsNotMastered() {
    var record = PracticeRecord()
    let unaskable: [PracticeItem] = [
      .keyConjugation(verb: "notaverb", stem: .présent),
      .keyConjugation(verb: "parler", stem: .présent),
      .pattern(model: "1-1", tense: "notatense", person: "fs", takesÊtre: false)
    ]
    Self.master(unaskable, in: &record, from: now, calendar: calendar)

    #expect(SpeedRound.masteredItems(in: record).isEmpty)
  }

  @Test(arguments: QuizLevel.allCases)
  func aRoundAsksOnlyMasteredItems(level: QuizLevel) throws {
    let items = try Self.items()
    var generator = SeededRandomNumberGenerator(seed: 3)
    let questions = QuizDraw.speedRoundQuestions(for: items, slots: level.slots, band: level.band, count: 30, using: &generator)

    #expect(questions.count == 30)
    #expect(questions.allSatisfy { items.contains(item(of: $0)) && $0.verb.hasCell($0.tense) })
  }

  /// Each item is asked once before any is asked again, and none twice running, across a cycle's
  /// end and across batches.
  @Test func itemsComeRoundInTurnAndNeverTwiceRunning() throws {
    let items = try Self.items()
    let level = QuizLevel.elementary
    for seed in UInt64(0) ..< 20 {
      var generator = SeededRandomNumberGenerator(seed: seed)
      let first = QuizDraw.speedRoundQuestions(for: items, slots: level.slots, band: level.band, count: 10, using: &generator).map(item)
      let last = try #require(first.last)
      let second = QuizDraw.speedRoundQuestions(for: items, slots: level.slots, band: level.band, count: 10, after: last, using: &generator).map(item)

      #expect(Set(first.prefix(5)).count == 5)
      #expect(Set(first.suffix(5)).count == 5)
      let sequence = first + second
      #expect(zip(sequence, sequence.dropFirst()).allSatisfy { $0 != $1 }, "seed \(seed)")
    }
  }

  @Test func oneItemIsAskedOverAndOver() throws {
    var generator = SeededRandomNumberGenerator(seed: 1)
    let item = PracticeItem.exercised(by: .indicatifPrésent(.firstSingular), of: try verb("parler"))
    let questions = QuizDraw.speedRoundQuestions(for: [item], slots: QuizLevel.beginner.slots, band: QuizLevel.beginner.band, count: 4, using: &generator)

    #expect(questions.count == 4)
  }

  @Test func nothingMasteredAsksNothing() {
    var generator = SeededRandomNumberGenerator(seed: 1)
    #expect(QuizDraw.speedRoundQuestions(for: [], slots: QuizLevel.beginner.slots, band: QuizLevel.beginner.band, count: 10, using: &generator).isEmpty)
  }

  /// A pattern comes back with another verb of the band that shares it, so that it is the pattern,
  /// not one verb's conjugation, that is practiced.
  @Test func aPatternAsksAnotherVerbOfTheBandEachTime() throws {
    let item = PracticeItem.exercised(by: .imparfait(.firstSingular), of: try verb("parler"))
    var generator = SeededRandomNumberGenerator(seed: 4)
    let band = QuizLevel.beginner.band
    let questions = QuizDraw.speedRoundQuestions(for: [item], slots: QuizLevel.beginner.slots, band: band, count: 12, using: &generator)
    let bandKeys = Set(QuizDraw.verbs(in: band).map(\.dictionaryKey))

    #expect(questions.allSatisfy { $0.tense == .imparfait(.firstSingular) })
    #expect(questions.allSatisfy { bandKeys.contains($0.verb.dictionaryKey) && self.item(of: $0) == item })
    #expect(Set(questions.map(\.verb.id)).count > 1)
    #expect(zip(questions, questions.dropFirst()).allSatisfy { $0.verb.id != $1.verb.id })
  }

  @Test func aSpellingChangePatternAsksVerbsOfItsModel() throws {
    let manger = try verb("manger")
    let item = PracticeItem.exercised(by: .indicatifPrésent(.firstPlural), of: manger)
    var generator = SeededRandomNumberGenerator(seed: 2)
    let questions = QuizDraw.speedRoundQuestions(for: [item], slots: QuizLevel.elementary.slots, band: QuizLevel.elementary.band, count: 6, using: &generator)

    #expect(questions.count == 6)
    #expect(questions.allSatisfy { $0.verb.model == manger.model && $0.tense == .indicatifPrésent(.firstPlural) })
  }

  /// Mastered vient asks any cell of the présent's stem that the level asks of venir, or il vient
  /// itself. Venir's subjonctif présent is never asked by the default quiz, whose pools for it hold
  /// only regular verbs and être, avoir, and aller, so the round does not ask it either.
  @Test func aKeyConjugationAsksTheCellsOfItsStemThatTheLevelAsks() throws {
    let venir = try verb("venir")
    let être = try verb("être")

    let beginner = QuizDraw.speedRoundCells(of: .présent, verb: venir, slots: QuizLevel.beginner.slots)
    #expect(beginner.first == .indicatifPrésent(.thirdSingular))
    #expect(Set(beginner) == Set(QuizTenseSlot.indicatifPrésent.cells + QuizTenseSlot.impératif.cells))
    #expect(beginner.count == Set(beginner).count)

    let intermediate = QuizDraw.speedRoundCells(of: .présent, verb: venir, slots: QuizLevel.intermediate.slots)
    #expect(intermediate.contains(.imparfait(.firstPlural)))
    #expect(intermediate.contains(.participePrésent))
    #expect(!intermediate.contains(.subjonctifPrésent(.thirdSingular)))
    #expect(intermediate.allSatisfy { PracticeItem.Stem($0) == .présent })
    #expect(QuizDraw.speedRoundCells(of: .présent, verb: être, slots: QuizLevel.intermediate.slots).contains(.subjonctifPrésent(.firstSingular)))

    #expect(QuizDraw.speedRoundCells(of: .passéSimple, verb: venir, slots: QuizLevel.elementary.slots) == [.passéSimple(.thirdSingular)])
    let futur = QuizDraw.speedRoundCells(of: .futur, verb: venir, slots: QuizLevel.elementary.slots)
    #expect(futur.contains(.futurSimple(.firstSingular)))
    #expect(futur.contains(.conditionnelPrésent(.thirdPlural)))
  }

  @Test func falloirIsAskedOnlyInIl() throws {
    let falloir = try verb("falloir")
    let cells = QuizDraw.speedRoundCells(of: .présent, verb: falloir, slots: QuizLevel.intermediate.slots)

    #expect(cells.allSatisfy { $0.personNumber == nil || $0.personNumber == .thirdSingular })
  }

  @Test func theScopeIsNeitherRankedNorContinuedAndSendsNoCounts() {
    let scope = QuizScope.speedRound

    #expect(scope.isSpeedRound)
    #expect(!scope.isRanked)
    #expect(!scope.continues)
    #expect(!scope.startsLiveActivity)
    #expect(!scope.mixesDueItems)
    #expect(!scope.mixesChoiceQuestions)
    #expect(!scope.sendsQuestionCounts)
    #expect(!scope.asksByLevel)
    #expect(scope.source == .speedRound)
    #expect(scope.sessionTitle == L.SpeedRound.title)
    #expect(LastQuizResult.Kind(scope: scope) == .speedRound)
  }

  @Test func theBestIsKeptAcrossALaunchAndForgottenByReset() {
    let getterSetter = GetterSetterFake()
    let practice = PracticeStore(getterSetter: getterSetter)
    #expect(practice.speedRoundBest == nil)
    #expect(!practice.hasAnythingToReset)

    #expect(!practice.recordSpeedRound(0))
    #expect(practice.speedRoundBest == nil)
    #expect(practice.recordSpeedRound(12))
    #expect(!practice.recordSpeedRound(12))
    #expect(!practice.recordSpeedRound(9))
    #expect(practice.hasAnythingToReset)
    #expect(PracticeStore(getterSetter: getterSetter).speedRoundBest == 12)

    practice.reset()
    #expect(practice.speedRoundBest == nil)
    #expect(PracticeStore(getterSetter: getterSetter).speedRoundBest == nil)
  }

  @Test func aMissIsWrittenOutWithItsPronoun() throws {
    let cases: [(key: String, tense: Tense, written: String)] = [
      ("venir", .indicatifPrésent(.firstPlural), "nous venons"),
      ("aimer", .indicatifPrésent(.firstSingular), "j'aime"),
      ("venir", .impératif(.secondSingular), "(tu) vIEns\u{202F}!"),
      ("souvenir", .indicatifPrésent(.firstSingular), "je me souvIEns"),
      ("souvenir", .impératif(.secondSingular), "(tu) souvIEns-toi\u{202F}!"),
      ("venir", .participePassé, "venu")
    ]
    for (key, tense, written) in cases {
      let verb = try verb(key)
      let question = QuizQuestion(verb: verb, tense: tense)
      let answer = try #require(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: question.pronounGender))
      let miss = SpeedRoundMiss(question: question, correctAnswers: answer)
      #expect(miss.answer.lowercased() == written.lowercased(), "\(key) \(tense)")
      #expect(miss.infinitif == verb.infinitifWithPossibleExtraLetters)
    }
  }
}

extension QuizTests {
  @MainActor
  @Suite("A Speed Round in a quiz")
  struct SpeedRoundQuizTests {
    /// The unit-test world's store is shared, so each test puts back an empty one.
    @discardableResult
    private func practice(mastering items: [PracticeItem]) throws -> PracticeStore {
      var record = PracticeRecord()
      SpeedRoundTests.master(items, in: &record, from: Date.now.addingTimeInterval(-10 * 86_400))
      let getterSetter = GetterSetterFake()
      getterSetter.set(key: PracticeRecord.storageKey, value: try #require(record.json))
      let practice = PracticeStore(getterSetter: getterSetter)
      Current.practice = practice
      return practice
    }

    private func restorePractice() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    private func started(gameCenter: GameCenter = GameCenterSpy()) -> Quiz {
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(gameCenter: gameCenter, seed: 21)
      quiz.start(scope: .speedRound)
      return quiz
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

    private func tick(_ quiz: Quiz, seconds: Int) {
      for _ in 0 ..< seconds {
        quiz.clockTicked()
      }
    }

    @Test func tooFewMasteredStartsNothing() throws {
      try practice(mastering: [])
      defer {
        restorePractice()
      }
      let quiz = started()

      #expect(quiz.quizState == .notStarted)
      #expect(SpeedRound.items(from: Current.practice).isEmpty)
    }

    @Test func aRightAnswerCountsAndAMissMovesOnAtOnce() throws {
      try practice(mastering: try SpeedRoundTests.items())
      defer {
        restorePractice()
      }
      let quiz = started()
      defer {
        quiz.quit()
      }

      quiz.process(proposedAnswer: try correctAnswer(quiz))
      #expect(quiz.correctCount == 1)
      #expect(quiz.currentQuestionIndex == 1)
      #expect(quiz.speedRoundMiss == nil)

      let missed = try #require(quiz.currentQuestion)
      quiz.process(proposedAnswer: "definitelywrong")
      #expect(quiz.correction == nil)
      #expect(!quiz.isHeld)
      #expect(!quiz.isAwaitingSecondAttempt)
      #expect(quiz.currentQuestionIndex == 2)
      #expect(quiz.speedRoundMiss?.infinitif == missed.verb.infinitifWithPossibleExtraLetters)
      #expect(quiz.reaskCount == 0)
      #expect(quiz.questions.allSatisfy { !$0.isReask })

      quiz.process(proposedAnswer: try correctAnswer(quiz))
      #expect(quiz.speedRoundMiss == nil)
      #expect(quiz.correctCount == 2)
    }

    /// A slip, which earns one more try in any other quiz, is a miss in a Speed Round.
    @Test func aSlipIsAMiss() throws {
      try practice(mastering: try SpeedRoundTests.items())
      defer {
        restorePractice()
      }
      let quiz = started()
      defer {
        quiz.quit()
      }
      let answer = try correctAnswer(quiz)
      quiz.process(proposedAnswer: String(answer.dropLast()))

      #expect(quiz.quizResults.first?.conjugationResult == .noMatch)
      #expect(!quiz.isAwaitingSecondAttempt)
      #expect(quiz.currentQuestionIndex == 1)
    }

    @Test func theRecordIsUntouched() throws {
      let practice = try practice(mastering: try SpeedRoundTests.items())
      defer {
        restorePractice()
      }
      let before = practice.record
      let quiz = started()
      for index in 0 ..< 8 {
        quiz.process(proposedAnswer: index.isMultiple(of: 2) ? try correctAnswer(quiz) : "definitelywrong")
      }
      quiz.quit()

      #expect(practice.record == before)
    }

    @Test func everyQuestionIsAMasteredItem() throws {
      let items = try SpeedRoundTests.items()
      try practice(mastering: items)
      defer {
        restorePractice()
      }
      let quiz = started()
      defer {
        quiz.quit()
      }
      for _ in 0 ..< 25 {
        quiz.process(proposedAnswer: try correctAnswer(quiz))
      }

      #expect(quiz.quizState == .inProgress)
      #expect(quiz.correctCount == 25)
      #expect(quiz.questions.count > 25)
      #expect(quiz.questions.allSatisfy { items.contains(PracticeItem.exercised(by: $0.tense, of: $0.verb)) })
    }

    /// The minute ends the round, drops the question left unanswered, and keeps a new best.
    @Test func sixtySecondsEndTheRoundAndKeepTheBest() throws {
      let practice = try practice(mastering: try SpeedRoundTests.items())
      defer {
        restorePractice()
      }
      let quiz = started()
      for index in 0 ..< 4 {
        quiz.process(proposedAnswer: index == 1 ? "definitelywrong" : try correctAnswer(quiz))
      }
      tick(quiz, seconds: SpeedRound.duration - 1)
      #expect(quiz.quizState == .inProgress)
      #expect(quiz.speedRoundSecondsLeft == 1)

      tick(quiz, seconds: 1)
      #expect(quiz.quizState == .notStarted)
      #expect(quiz.shouldShowResults)
      #expect(quiz.questions.count == 4)
      #expect(quiz.correctCount == 3)
      #expect(quiz.sessionQuestionCount == 4)
      #expect(quiz.isNewSpeedRoundBest)
      #expect(quiz.speedRoundPreviousBest == nil)
      #expect(practice.speedRoundBest == 3)
      #expect(!quiz.canContinue)

      let result = try #require(practice.lastResult)
      #expect(result.kind == .speedRound)
      #expect(result.correctCount == 3)
      #expect(result.level == nil)
      #expect(result.title == L.SpeedRound.title)

      quiz.start(scope: .speedRound)
      #expect(!quiz.shouldShowResults)
      #expect(quiz.speedRoundSecondsLeft == SpeedRound.duration)
      quiz.process(proposedAnswer: try correctAnswer(quiz))
      tick(quiz, seconds: SpeedRound.duration)
      #expect(!quiz.isNewSpeedRoundBest)
      #expect(quiz.speedRoundPreviousBest == 3)
      #expect(practice.speedRoundBest == 3)
    }

    @Test func aRoundPostsNoScoreAndSendsNoCounts() throws {
      try practice(mastering: try SpeedRoundTests.items())
      defer {
        restorePractice()
      }
      let original = Current.analytics
      let spy = AnalyticsSpy()
      Current.analytics = spy
      defer {
        Current.analytics = original
      }
      let gameCenter = GameCenterSpy()
      let bestScore = Current.settings.bestScore(at: .elementary)

      let quiz = started(gameCenter: gameCenter)
      quiz.process(proposedAnswer: try correctAnswer(quiz))
      tick(quiz, seconds: SpeedRound.duration)
      let quitter = started(gameCenter: gameCenter)
      quitter.process(proposedAnswer: "definitelywrong")
      quitter.quit()

      let signals = Array(zip(spy.signalNames, spy.signalParameters))
      let start = try #require(signals.first { $0.0 == .quizStart }?.1)
      let completion = try #require(signals.first { $0.0 == .quizCompletion }?.1)
      let quit = try #require(signals.first { $0.0 == .quizQuit }?.1)
      #expect(start[ParameterKey.source.rawValue] == AnalyticsSource.speedRound.rawValue)
      #expect(completion[ParameterKey.questionCount.rawValue] == nil)
      #expect(quit[ParameterKey.lastQuestionIndex.rawValue] == nil)
      #expect(gameCenter.reports.isEmpty)
      #expect(Current.settings.bestScore(at: .elementary) == bestScore)
    }
  }
}
