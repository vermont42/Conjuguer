//
//  QuizRecordSessionTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite("Review and My Mistakes")
struct QuizRecordSessionTests {
  private let now = Date.now
  private let calendar = Calendar.current

  private func daysAgo(_ days: Double) -> Date {
    now.addingTimeInterval(-days * 86_400)
  }

  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  /// Twelve of parler's patterns: its présent and imparfait in every person.
  static func parlerPatterns() throws -> [(tense: Tense, item: PracticeItem)] {
    let parler = try #require(Verb.verbs["parler"])
    let tenses = PersonNumber.allCases.map(Tense.indicatifPrésent) + PersonNumber.allCases.map(Tense.imparfait)
    return tenses.map { ($0, PracticeItem.exercised(by: $0, of: parler)) }
  }

  @Test func missedItemsAreTheLastWrongAnswersMostRecentFirst() {
    var record = PracticeRecord()
    let first = PracticeItem.pattern(model: "1-1", tense: "indicatif_present", person: "fs", takesÊtre: false)
    let second = PracticeItem.pattern(model: "2-1", tense: "imparfait", person: "ss", takesÊtre: false)
    let rightOnly = PracticeItem.pattern(model: "1-1", tense: "futur_simple", person: "ts", takesÊtre: false)
    let repaired = PracticeItem.keyConjugation(verb: "venir", stem: .futur)
    let lookedUpAfterMissing = PracticeItem.keyConjugation(verb: "faire", stem: .présent)
    record.recordAnswer(first, isCorrect: false, at: daysAgo(3), calendar: calendar)
    record.recordAnswer(second, isCorrect: false, at: daysAgo(1), calendar: calendar)
    record.recordAnswer(rightOnly, isCorrect: true, at: daysAgo(2), calendar: calendar)
    record.recordAnswer(repaired, isCorrect: false, at: daysAgo(4), calendar: calendar)
    record.recordAnswer(repaired, isCorrect: true, at: daysAgo(0.5), calendar: calendar)
    record.recordAnswer(lookedUpAfterMissing, isCorrect: false, at: daysAgo(5), calendar: calendar)
    record.recordLookup([lookedUpAfterMissing, .keyConjugation(verb: "aller", stem: .présent)], at: now, calendar: calendar)

    #expect(record.missedItems() == [second, first, lookedUpAfterMissing])
  }

  @Test func theNextDueDateIsCountedInDays() throws {
    let practice = PracticeStore(getterSetter: GetterSetterFake())
    #expect(practice.daysUntilNextDue(at: now) == nil)
    let parler = try verb("parler")

    practice.recordAnswer(verb: parler, tense: .indicatifPrésent(.firstSingular), isCorrect: true, at: now)
    #expect(practice.daysUntilNextDue(at: now) == ReviewSchedule.intervals[1])

    practice.recordAnswer(verb: parler, tense: .indicatifPrésent(.secondSingular), isCorrect: false, at: now)
    #expect(practice.daysUntilNextDue(at: now) == 1)
  }

  @Test func aSessionAsksBeyondTheLevelsTensesAndBand() throws {
    let rare = try #require(Verb.verbs.values.sorted { $0.dictionaryKey < $1.dictionaryKey }.first { verb in
      !PracticeItem.isLearnedByPattern(verb) && !verb.isIn(.top1000) && verb.hasCell(.passéSimple(.thirdSingular))
        && PracticeItem.keyConjugations(of: verb).count == PracticeItem.Stem.shown.count
    })
    let finir = try verb("finir")
    let items: [PracticeItem] = [
      .keyConjugation(verb: rare.dictionaryKey, stem: .passéSimple),
      .exercised(by: .subjonctifImparfait(.secondPlural), of: finir)
    ]
    var generator = SeededRandomNumberGenerator(seed: 4)

    let questions = QuizDraw.sessionQuestions(for: items, band: QuizLevel.beginner.band, excluded: [], limit: Quiz.questionCount, using: &generator)

    #expect(questions.map(\.tense) == [.passéSimple(.thirdSingular), .subjonctifImparfait(.secondPlural)])
    #expect(questions[0].verb == rare)
    let pattern = questions[1]
    #expect(QuizLevel.beginner.band.map { pattern.verb.isIn($0) } ?? true)
    #expect(PracticeItem.exercised(by: pattern.tense, of: pattern.verb) == items[1])
  }

  @Test func aPatternNoBandVerbHasIsAskedOfAnyVerb() throws {
    let bandModels = Set(Verb.verbs(in: .top100).map(\.model))
    let tenses: [Tense] = [.indicatifPrésent(.firstSingular), .indicatifPrésent(.firstPlural), .futurSimple(.firstSingular)]
    let found = Verb.verbs.values.sorted { $0.dictionaryKey < $1.dictionaryKey }.lazy.compactMap { verb -> (Verb, Tense)? in
      guard PracticeItem.isLearnedByPattern(verb), !bandModels.contains(verb.model) else {
        return nil
      }
      let tense = tenses.first { tense in
        guard verb.hasCell(tense), case let .pattern(model, _, _, _) = PracticeItem.exercised(by: tense, of: verb) else {
          return false
        }
        return model == verb.model
      }
      return tense.map { (verb, $0) }
    }.first
    let (rareVerb, tense) = try #require(found)
    let item = PracticeItem.exercised(by: tense, of: rareVerb)
    var generator = SeededRandomNumberGenerator(seed: 6)

    let questions = QuizDraw.sessionQuestions(for: [item], band: .top100, excluded: [], limit: Quiz.questionCount, using: &generator)

    let question = try #require(questions.first)
    #expect(questions.count == 1)
    #expect(question.verb.model == rareVerb.model)
    #expect(PracticeItem.exercised(by: question.tense, of: question.verb) == item)
  }

  @Test func aVerbsKeyConjugationsSitTogetherInTheirOrder() throws {
    let venir = try verb("venir")
    let faire = try verb("faire")
    let pattern = PracticeItem.exercised(by: .imparfait(.firstPlural), of: try verb("parler"))
    let items: [PracticeItem] = [
      .keyConjugation(verb: venir.dictionaryKey, stem: .futur),
      pattern,
      .keyConjugation(verb: faire.dictionaryKey, stem: .présent),
      .keyConjugation(verb: venir.dictionaryKey, stem: .passéSimple),
      .keyConjugation(verb: venir.dictionaryKey, stem: .présent)
    ]
    var generator = SeededRandomNumberGenerator(seed: 2)

    let questions = QuizDraw.sessionQuestions(for: items, band: QuizLevel.elementary.band, excluded: [], limit: Quiz.questionCount, using: &generator)

    #expect(questions.map(\.tense) == [
      .indicatifPrésent(.thirdSingular),
      .futurSimple(.thirdSingular),
      .passéSimple(.thirdSingular),
      .imparfait(.firstPlural),
      .indicatifPrésent(.thirdSingular)
    ])
    #expect(questions.map(\.verb.dictionaryKey) == [venir, venir, venir, questions[3].verb, faire].map(\.dictionaryKey))
  }

  @Test func aSessionSkipsExcludedAndUnaskableItemsAndStopsAtItsLimit() throws {
    let unknown = PracticeItem.keyConjugation(verb: "zzzunknown", stem: .présent)
    let unreadable = PracticeItem.pattern(model: "1-1", tense: "no_such_tense", person: "fs", takesÊtre: false)
    let regularKey = PracticeItem.keyConjugation(verb: "parler", stem: .présent)
    let patterns = try Self.parlerPatterns()
    var generator = SeededRandomNumberGenerator(seed: 8)

    let questions = QuizDraw.sessionQuestions(
      for: [unknown, unreadable, regularKey] + patterns.map(\.item),
      band: QuizLevel.elementary.band,
      excluded: [patterns[0].item.key],
      limit: Quiz.questionCount,
      using: &generator
    )

    #expect(!unknown.isAskable)
    #expect(!unreadable.isAskable)
    #expect(!regularKey.isAskable)
    #expect(patterns.allSatisfy { $0.item.isAskable })
    #expect(questions.map(\.tense) == Array(patterns.dropFirst().prefix(Quiz.questionCount).map(\.tense)))
  }

  @Test func aRecordSessionIsNeverRankedAndMixesInNothing() {
    for session in QuizRecordSession.allCases {
      let scope = QuizScope.recordSession(session)
      #expect(!scope.isRanked)
      #expect(!scope.mixesDueItems)
      #expect(!scope.sendsQuestionCounts)
      #expect(scope.continues)
      #expect(scope.source == session.source)
    }
    #expect(QuizScope.allVerbs.sendsQuestionCounts)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Record sessions")
  struct RecordSessionTests {
    /// A fresh record for the test, since the unit-test world's is shared. Each test puts back an
    /// empty one with `defer`.
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func restorePractice() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    private func daysAgo(_ days: Double) -> Date {
      Date.now.addingTimeInterval(-days * 86_400)
    }

    private func started(_ session: QuizRecordSession, gameCenter: GameCenterSpy = GameCenterSpy(), seed: UInt64 = 3) -> Quiz {
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(gameCenter: gameCenter, seed: seed)
      quiz.start(scope: .recordSession(session))
      return quiz
    }

    private func correctAnswer(for question: QuizQuestion) -> String {
      let conjugated = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: question.verb.extraLetters) ?? ""
      return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
    }

    private func finish(_ quiz: Quiz, correctly: Bool) throws {
      while quiz.quizState == .inProgress {
        let question = try #require(quiz.currentQuestion)
        quiz.process(proposedAnswer: correctly ? correctAnswer(for: question) : "definitelywrong")
        if quiz.correction != nil {
          quiz.continueAfterCorrection()
        }
      }
    }

    private func items(of quiz: Quiz) -> [PracticeItem] {
      quiz.questions.filter { !$0.isReask }.map { .exercised(by: $0.tense, of: $0.verb) }
    }

    /// Twelve of parler's patterns missed on twelve days, the oldest first.
    private func missTwelvePatterns(in practice: PracticeStore) throws -> [PracticeItem] {
      let parler = try #require(Verb.verbs["parler"])
      let patterns = try QuizRecordSessionTests.parlerPatterns()
      for (index, pattern) in patterns.enumerated() {
        practice.recordAnswer(verb: parler, tense: pattern.tense, isCorrect: false, at: daysAgo(Double(30 - index)))
      }
      return patterns.map(\.item)
    }

    @Test func reviewAsksTheMostOverdueTenThenTheRest() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let patterns = try missTwelvePatterns(in: practice)
      #expect(QuizRecordSession.review.askableCount(from: practice) == 12)

      let quiz = started(.review)
      #expect(items(of: quiz) == Array(patterns.prefix(10)))
      try finish(quiz, correctly: true)
      #expect(quiz.canContinue)

      quiz.continueSession()
      #expect(items(of: quiz).suffix(2) == Array(patterns.suffix(2)))
      try finish(quiz, correctly: true)

      #expect(quiz.sessionQuestionCount == 12)
      #expect(!quiz.canContinue)
      #expect(practice.dueItems().isEmpty)
    }

    @Test func aShortReviewAsksWhatIsDueAndDoesNotContinue() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let venir = try #require(Verb.verbs["venir"])
      practice.recordAnswer(verb: venir, tense: .futurSimple(.firstPlural), isCorrect: false, at: daysAgo(4))
      practice.recordAnswer(verb: venir, tense: .indicatifPrésent(.firstSingular), isCorrect: false, at: daysAgo(3))

      let quiz = started(.review)

      #expect(quiz.questions.map(\.tense) == [.indicatifPrésent(.thirdSingular), .futurSimple(.thirdSingular)])
      try finish(quiz, correctly: true)
      #expect(quiz.sessionQuestionCount == 2)
      #expect(quiz.correctCount == 2)
      #expect(!quiz.canContinue)
    }

    @Test func anEmptyRecordStartsNothing() {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      for session in QuizRecordSession.allCases {
        #expect(session.askableCount(from: practice) == 0)
        let quiz = started(session)
        #expect(quiz.quizState == .notStarted)
        #expect(quiz.questions.isEmpty)
      }
    }

    @Test func aMistakeLeavesOnceAnsweredRight() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let patterns = try missTwelvePatterns(in: practice)
      let quiz = started(.mistakes)
      #expect(items(of: quiz) == Array(patterns.reversed().prefix(10)))

      let first = try #require(quiz.currentQuestion)
      quiz.process(proposedAnswer: correctAnswer(for: first))
      quiz.quit()

      #expect(practice.missedItems() == Array(patterns.reversed().dropFirst()))
      #expect(QuizRecordSession.mistakes.askableCount(from: practice) == 11)
    }

    @Test func aMistakeMissedAgainDoesNotReturnInTenMore() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let patterns = try missTwelvePatterns(in: practice)
      let quiz = started(.mistakes)

      try finish(quiz, correctly: false)
      #expect(practice.missedItems().count == 12)
      #expect(quiz.canContinue)
      quiz.continueSession()

      #expect(items(of: quiz).suffix(2) == Array(patterns.prefix(2).reversed()))
      try finish(quiz, correctly: false)
      #expect(!quiz.canContinue)
    }

    @Test func aRecordSessionSendsNoCountsAndPostsNoScore() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let spy = try #require(Current.analytics as? AnalyticsSpy)
      _ = try missTwelvePatterns(in: practice)
      let gameCenter = GameCenterSpy()
      let bestScore = Current.settings.bestScore(at: .elementary)

      let quiz = started(.mistakes, gameCenter: gameCenter)
      let entry = QuizAbandonment.entries(getterSetter: Current.getterSetter).values.first { $0.source == "mistakes" }
      #expect(entry != nil)
      #expect(entry?.lastQuestionIndex == nil)
      let startIndex = try #require(spy.signalNames.lastIndex(of: .quizStart))
      #expect(spy.signalParameters[startIndex][ParameterKey.source.rawValue] == "mistakes")
      try finish(quiz, correctly: true)

      let completionIndex = try #require(spy.signalNames.lastIndex(of: .quizCompletion))
      #expect(spy.signalParameters[completionIndex][ParameterKey.questionCount.rawValue] == nil)
      #expect(spy.signalParameters[completionIndex][ParameterKey.source.rawValue] == "mistakes")
      #expect(gameCenter.reports.isEmpty)
      #expect(Current.settings.bestScore(at: .elementary) == bestScore)

      let review = started(.review)
      review.quit()
      let quitIndex = try #require(spy.signalNames.lastIndex(of: .quizQuit))
      #expect(spy.signalParameters[quitIndex][ParameterKey.lastQuestionIndex.rawValue] == nil)
      #expect(spy.signalParameters[quitIndex][ParameterKey.source.rawValue] == "review")
    }
  }
}
