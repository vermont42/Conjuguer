//
//  ModelPracticeTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite("Model practice")
struct ModelPracticeTests {
  private let date = Date(timeIntervalSince1970: 1_800_000_000)

  private func practice(_ modelID: String) throws -> ModelPractice {
    try #require(ModelPractice.practice(modelID))
  }

  private func record(knowing modelIDs: [String], rightCount: ((ModelPractice) -> Int)? = nil) throws -> PracticeRecord {
    var record = PracticeRecord()
    for modelID in modelIDs {
      let practice = try practice(modelID)
      let items = practice.items
      let count = rightCount?(practice) ?? (items.count + 1) / 2
      for item in items.prefix(count) {
        record.recordAnswer(item, isCorrect: true, at: date)
      }
    }
    return record
  }

  @Test(arguments: [
    (modelID: "6-7", kind: ModelPractice.Kind?.some(.verbEssentials), isAlone: true),
    (modelID: "5-2", kind: .verbEssentials, isAlone: true),
    (modelID: "4-2A", kind: .verbEssentials, isAlone: true),
    (modelID: "1-2B", kind: .markedCells, isAlone: true),
    (modelID: "1-3A", kind: .markedCells, isAlone: true),
    (modelID: "1-5", kind: .markedCells, isAlone: true),
    (modelID: "2-2", kind: .markedCells, isAlone: true),
    (modelID: "1-9", kind: .verbEssentials, isAlone: false),
    (modelID: "5-26", kind: .verbEssentials, isAlone: false),
    (modelID: "1-4A", kind: .markedCells, isAlone: false),
    (modelID: "1-1", kind: nil, isAlone: false),
    (modelID: "2-1", kind: nil, isAlone: false),
    (modelID: "5-1A", kind: nil, isAlone: false),
    (modelID: "5-1B", kind: nil, isAlone: false),
    (modelID: "2-5", kind: nil, isAlone: false),
    (modelID: "5-28", kind: nil, isAlone: false)
  ])
  func eachModelIsPracticedByItsKind(modelID: String, kind: ModelPractice.Kind?, isAlone: Bool) {
    let practice = ModelPractice.practice(modelID)

    #expect(practice?.kind == kind)
    #expect((practice?.offersPracticeAlone ?? false) == isAlone)
  }

  @Test(arguments: [
    (modelID: "1-1", absence: ModelPractice.Absence?.some(.base)),
    (modelID: "2-1", absence: .base),
    (modelID: "5-1A", absence: .base),
    (modelID: "5-1B", absence: .fewMarkedCells),
    (modelID: "5-1C", absence: .fewMarkedCells),
    (modelID: "2-4", absence: .fewMarkedCells),
    (modelID: "1-9", absence: .singleVerb),
    (modelID: "1-4A", absence: .singleVerb),
    (modelID: "6-7", absence: nil),
    (modelID: "1-2B", absence: nil),
    (modelID: "5-28", absence: nil)
  ])
  func aModelWithoutPracticeSaysWhy(modelID: String, absence: ModelPractice.Absence?) {
    #expect(ModelPractice.absence(of: modelID) == absence)
  }

  @Test func aModelIsItsTenMostFrequentAskableVerbs() throws {
    let venir = try practice("6-7")
    #expect(venir.verbs.count == ModelPractice.verbLimit)
    #expect(Array(venir.verbs.prefix(3).map(\.infinitif)) == ["venir", "devenir", "tenir"])
    #expect(venir.verbs.map(\.frequency) == venir.verbs.map(\.frequency).sorted())
    #expect(venir.items.count == 30)

    let couvrir = try practice("3-1")
    #expect(couvrir.verbs.count == 9)
    #expect(couvrir.verbs.allSatisfy { $0.isAskedByVerbEssentials })

    let partir = try practice("6-1")
    #expect(partir.verbs.first?.dictionaryKey == "sortir exit")
  }

  @Test func aSpellingChangeIsPracticedThroughTheCellsItMarks() throws {
    let manger = try practice("1-2B")

    #expect(manger.cells == [
      .participePrésent,
      .indicatifPrésent(.firstPlural),
      .imparfait(.firstSingular), .imparfait(.secondSingular), .imparfait(.thirdSingular), .imparfait(.thirdPlural),
      .impératif(.firstPlural)
    ])
    let appeler = try practice("1-3A")
    let céder = try practice("1-5")
    #expect(appeler.cells.count == 21)
    #expect(céder.cells.count == 9)
  }

  @Test func everyMarkedCellIsItsModelsOwnPatternForEveryVerb() {
    for practice in ModelPractice.all where practice.kind == .markedCells {
      #expect(practice.cells.count >= ModelPractice.minimumMarkedCells)
      for tense in practice.cells {
        switch tense {
        case .passéSimple, .subjonctifImparfait:
          Issue.record("\(practice.modelID) asks \(tense).")
        default:
          #expect(!tense.isCompound)
        }
        for verb in practice.verbs where verb.hasCell(tense) {
          guard case let .pattern(model, _, _, _) = PracticeItem.exercised(by: tense, of: verb) else {
            Issue.record("\(verb.infinitif) \(tense) is not a pattern.")
            continue
          }
          #expect(model == practice.modelID, "\(verb.infinitif) \(tense)")
        }
      }
    }
  }

  @Test func theListIsTheModelsPracticedAloneByUse() {
    let list = ModelPractice.practicedAloneByUse

    #expect(list.first?.modelID == "5-23")
    #expect(list.allSatisfy { $0.offersPracticeAlone })
    let firstFrequencies = list.compactMap(\.verbs.first?.frequency)
    #expect(firstFrequencies == firstFrequencies.sorted())
    #expect(list.contains { $0.modelID == "1-2B" })
    #expect(!list.contains { $0.modelID == "1-1" || $0.modelID == "1-9" })
  }

  @Test func aModelIsKnownOnceHalfItsItemsHaveClimbed() throws {
    for (modelID, short, half) in [("6-7", 14, 15), ("1-9", 1, 2), ("1-2B", 3, 4)] {
      let practice = try practice(modelID)
      let shortRecord = try record(knowing: [modelID], rightCount: { _ in short })
      let halfRecord = try record(knowing: [modelID], rightCount: { _ in half })
      #expect(!practice.isKnown(in: shortRecord), "\(modelID)")
      #expect(practice.isKnown(in: halfRecord), "\(modelID)")
    }
  }

  @Test func aWrongAnswerOrALookupDoesNotCount() throws {
    let venir = try practice("6-7")
    var record = try record(knowing: ["6-7"], rightCount: { _ in 15 })
    #expect(venir.isKnown(in: record))

    let first = try #require(venir.items.first)
    record.recordAnswer(first, isCorrect: false, at: date.addingTimeInterval(60))
    #expect(!venir.isKnown(in: record))

    var lookedUp = PracticeRecord()
    lookedUp.recordLookup(venir.items, at: date)
    #expect(!venir.isKnown(in: lookedUp))
  }

  @Test func aMixAddsOnlyKnownModelsOfTheSameKind() throws {
    let record = try record(knowing: ["1-9", "5-2", "1-3A", "6-7"])

    let partners = try ["6-7", "4-2A", "1-2B", "1-3A"].map { try practice($0).mixPartners(in: record).map(\.modelID) }
    #expect(partners == [["1-9", "5-2"], ["1-9", "5-2", "6-7"], ["1-3A"], []])
  }

  @Test func aRoundAloneAsksFiveOfTheModelsVerbs() throws {
    let venir = try practice("6-7")
    var generator = SeededRandomNumberGenerator(seed: 4)
    let session = ModelPracticeSession(modelID: "6-7", mode: .alone)

    let first = QuizDraw.modelPracticeQuestions(for: session, record: PracticeRecord(), asked: [], using: &generator)
    #expect(first.count == 15)
    let firstVerbs = Set(first.map(\.verb.id))
    #expect(firstVerbs.count == 5)
    #expect(firstVerbs.isSubset(of: Set(venir.verbs.map(\.id))))

    let second = QuizDraw.modelPracticeQuestions(for: session, record: PracticeRecord(), asked: first, using: &generator)
    #expect(Set(second.map(\.verb.id)).isDisjoint(with: firstVerbs))

    let devoir = QuizDraw.modelPracticeQuestions(for: ModelPracticeSession(modelID: "4-2A", mode: .alone), record: PracticeRecord(), asked: [], using: &generator)
    #expect(devoir.count == 6)
  }

  @Test func aRoundAloneOfASpellingChangeAsksItsCellsOnce() throws {
    var generator = SeededRandomNumberGenerator(seed: 6)
    let manger = QuizDraw.modelPracticeQuestions(for: ModelPracticeSession(modelID: "1-2B", mode: .alone), record: PracticeRecord(), asked: [], using: &generator)
    #expect(manger.count == 7)
    let cells = try practice("1-2B").cells
    #expect(Set(manger.map(\.tense)) == Set(cells))
    #expect(manger.allSatisfy { $0.verb.model == "1-2B" && $0.stepID == nil })

    let session = ModelPracticeSession(modelID: "1-3A", mode: .alone)
    let first = QuizDraw.modelPracticeQuestions(for: session, record: PracticeRecord(), asked: [], using: &generator)
    #expect(first.count == Quiz.questionCount)
    #expect(Set(first.map(\.tense)).count == Quiz.questionCount)
    let second = QuizDraw.modelPracticeQuestions(for: session, record: PracticeRecord(), asked: first, using: &generator)
    #expect(Set(second.map(\.tense)).isDisjoint(with: Set(first.map(\.tense))))
  }

  @Test func aMixedRoundIsThreeOwnVerbsAndTwoPartnersOneModelAtATime() throws {
    let record = try record(knowing: ["1-9", "5-2"])
    var generator = SeededRandomNumberGenerator(seed: 9)

    let questions = QuizDraw.modelPracticeQuestions(for: ModelPracticeSession(modelID: "6-7", mode: .mixed), record: record, asked: [], using: &generator)
    let verbs = questions.map(\.verb)

    #expect(questions.count == 15)
    #expect(Set(verbs.map(\.id)).count == 5)
    #expect(Set(verbs.filter { $0.model == "6-7" }.map(\.id)).count == QuizDraw.modelMixOwnVerbCount)
    #expect(verbs.contains { $0.infinitif == "aller" })
    #expect(Set(verbs.filter { $0.model == "5-2" }.map(\.id)).count == 1)
  }

  @Test func aShortSideLeavesTheRestToTheOther() throws {
    let record = try record(knowing: ["5-2"])
    var generator = SeededRandomNumberGenerator(seed: 2)

    let questions = QuizDraw.modelPracticeQuestions(for: ModelPracticeSession(modelID: "4-2A", mode: .mixed), record: record, asked: [], using: &generator)
    let verbs = Set(questions.map(\.verb.id))

    #expect(verbs.count == 5)
    #expect(verbs.isSuperset(of: ["devoir", "redevoir"]))
  }

  @Test func aMixedSpellingChangeRoundIsSixOwnCellsAndFourPartners() throws {
    let record = try record(knowing: ["1-3A"])
    var generator = SeededRandomNumberGenerator(seed: 3)

    let questions = QuizDraw.modelPracticeQuestions(for: ModelPracticeSession(modelID: "1-2B", mode: .mixed), record: record, asked: [], using: &generator)

    #expect(questions.count == Quiz.questionCount)
    #expect(questions.filter { $0.verb.model == "1-2B" }.count == QuizDraw.modelMixOwnCellCount)
    #expect(questions.filter { $0.verb.model == "1-3A" }.count == 4)
  }

  @Test func partnersTakeTurns() {
    let turns = QuizDraw.inTurn([["a1", "a2", "a3"], ["b1"], ["c1", "c2"]], isAsked: { $0 == "c1" })

    #expect(turns == ["a1", "b1", "a2", "c2", "a3", "c1"])
    var generator = SeededRandomNumberGenerator(seed: 1)
    #expect(QuizDraw.mix(own: [1], others: [7, 8, 9, 10, 11], count: 5, ownCount: 3, using: &generator).sorted() == [1, 7, 8, 9, 10])
  }

  @Test func theScopesAreUnrankedAndAMixSendsNoCounts() throws {
    let alone = QuizScope.modelPractice(ModelPracticeSession(modelID: "6-7", mode: .alone))
    #expect(alone.isVerbEssentials)
    #expect(alone.questionCount == 15)
    #expect(alone.source == .modelAlone)
    #expect(alone.namedCollection == .model("6-7"))
    #expect(alone.collection == nil)
    #expect(alone.title == "venir (6-7)")
    #expect(alone.sessionTitle == "venir (6-7)")
    #expect(!alone.isRanked)
    #expect(!alone.mixesDueItems)
    #expect(!alone.asksByLevel)
    #expect(alone.sendsQuestionCounts)
    #expect(alone.continues)
    #expect(!alone.startsLiveActivity)
    #expect(LastQuizResult.Kind(scope: alone) == .modelAlone)

    let mixed = QuizScope.modelPractice(ModelPracticeSession(modelID: "1-2B", mode: .mixed))
    #expect(!mixed.isVerbEssentials)
    #expect(mixed.questionCount == Quiz.questionCount)
    #expect(mixed.source == .modelMixed)
    #expect(mixed.title == L.ModelPractice.mixedTitle("manger (1-2B)"))
    #expect(!mixed.sendsQuestionCounts)
    #expect(LastQuizResult.Kind(scope: mixed) == .modelMixed)

    let result = LastQuizResult(kind: .modelMixed, subject: "1-2B", level: nil, score: 0, correctCount: 0, secondAttemptCount: 0, questionCount: 10, date: date)
    #expect(result.title == mixed.title)
    let json = try #require(result.json)
    #expect(LastQuizResult(json: json) == result)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Model practice sessions")
  struct ModelPracticeSessionTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func restorePractice() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    private func correctAnswer(for question: QuizQuestion) -> String {
      let conjugated = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: question.verb.extraLetters) ?? ""
      return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
    }

    private func finish(_ quiz: Quiz, rightly: Bool) {
      while let question = quiz.currentQuestion, quiz.quizState == .inProgress {
        if rightly {
          quiz.process(proposedAnswer: correctAnswer(for: question))
        } else {
          quiz.process(proposedAnswer: "x")
          quiz.continueAfterCorrection()
        }
      }
    }

    private func practice(_ modelID: String) throws -> ModelPractice {
      try #require(ModelPractice.practice(modelID))
    }

    @Test func aModelPracticedAloneBecomesKnownAndJoinsAnotherModelsMix() throws {
      let store = freshPractice()
      defer {
        restorePractice()
      }
      Current.settings.quizLevel = .beginner
      let prendre = try practice("5-2")
      let venir = try practice("6-7")
      #expect(prendre.mixPartners(in: store.record).isEmpty)

      let alone = Quiz(gameCenter: GameCenterSpy(), seed: 11)
      alone.start(scope: .modelPractice(ModelPracticeSession(modelID: "6-7", mode: .alone)))
      finish(alone, rightly: true)

      #expect(alone.score == 150)
      #expect(venir.isKnown(in: store.record))
      #expect(prendre.mixPartners(in: store.record).map(\.modelID) == ["6-7"])

      let mixed = Quiz(gameCenter: GameCenterSpy(), seed: 12)
      mixed.start(scope: .modelPractice(ModelPracticeSession(modelID: "5-2", mode: .mixed)))
      defer {
        mixed.quit()
      }
      let verbs = mixed.questions.map(\.verb)
      #expect(Set(verbs.filter { $0.model == "5-2" }.map(\.id)).count == 3)
      #expect(Set(verbs.filter { $0.model == "6-7" }.map(\.id)).count == 2)
      #expect(mixed.essentialsRows != nil)
    }

    @Test func aWrongRoundLeavesTheModelUnknown() throws {
      let store = freshPractice()
      defer {
        restorePractice()
      }
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 13)
      quiz.start(scope: .modelPractice(ModelPracticeSession(modelID: "1-2B", mode: .alone)))
      finish(quiz, rightly: false)

      let manger = try practice("1-2B")
      #expect(quiz.sessionQuestionCount == 7)
      #expect(!manger.isKnown(in: store.record))
    }

    @Test func aSpellingChangeRoundRightMakesTheModelKnown() throws {
      let store = freshPractice()
      defer {
        restorePractice()
      }
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 14)
      quiz.start(scope: .modelPractice(ModelPracticeSession(modelID: "1-2B", mode: .alone)))
      #expect(quiz.essentialsRows == nil)
      finish(quiz, rightly: true)

      let manger = try practice("1-2B")
      #expect(quiz.score == 70)
      #expect(manger.isKnown(in: store.record))
    }

    @Test func anotherRoundContinuesAndNothingRanksOrNamesTheModel() throws {
      let store = freshPractice()
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
      Current.settings.quizLevel = .beginner
      let bestScore = Current.settings.bestScore(at: .beginner)
      let quiz = Quiz(gameCenter: gameCenter, seed: 15)
      quiz.start(scope: .modelPractice(ModelPracticeSession(modelID: "6-7", mode: .alone)))
      let firstVerbs = Set(quiz.questions.map(\.verb.id))
      finish(quiz, rightly: true)

      #expect(quiz.canContinue)
      #expect(Current.settings.bestScore(at: .beginner) == bestScore)
      #expect(gameCenter.reports.isEmpty)
      #expect(store.lastResult?.kind == .modelAlone)
      #expect(store.lastResult?.title == "venir (6-7)")
      #expect(store.lastResult?.level == nil)
      let start = try #require(spy.signalParameters.first)
      #expect(spy.signalNames.first == .quizStart)
      #expect(start[ParameterKey.source.rawValue] == AnalyticsSource.modelAlone.rawValue)
      #expect(start[ParameterKey.collection.rawValue] == "model")
      #expect(spy.signalParameters.last?[ParameterKey.questionCount.rawValue] == "15")

      quiz.continueSession()
      #expect(quiz.questions.count == 30)
      #expect(firstVerbs.isDisjoint(with: Set(quiz.questions[15...].map(\.verb.id))))
      finish(quiz, rightly: true)

      let mixed = Quiz(gameCenter: gameCenter, seed: 16)
      mixed.start(scope: .modelPractice(ModelPracticeSession(modelID: "5-2", mode: .mixed)))
      finish(mixed, rightly: true)
      #expect(spy.signalParameters.last?[ParameterKey.questionCount.rawValue] == nil)
      #expect(spy.signalParameters.last?[ParameterKey.source.rawValue] == AnalyticsSource.modelMixed.rawValue)
      #expect(store.lastResult?.kind == .modelMixed)
      #expect(gameCenter.reports.isEmpty)
    }
  }
}
