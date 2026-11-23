//
//  QuizScopeTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct QuizScopeTests {
  private let seeds: [UInt64] = Array(1 ... 200)

  private func verb(_ infinitif: String, extraLetters: String? = nil) throws -> Verb {
    try #require(Verb.verbs.values.first { $0.infinitif == infinitif && $0.extraLetters == extraLetters })
  }

  private func questions(_ scope: QuizScope, seed: UInt64) -> [QuizQuestion] {
    var generator = SeededRandomNumberGenerator(seed: seed)
    return scope.questions(using: &generator)
  }

  private func slotCounts(_ questions: [QuizQuestion]) -> [QuizTenseSlot: Int] {
    questions.reduce(into: [:]) { counts, question in
      if let slot = QuizTenseSlot(tense: question.tense) {
        counts[slot, default: 0] += 1
      }
    }
  }

  private func regularQuotas() -> [QuizTenseSlot: Int] {
    Dictionary(uniqueKeysWithValues: QuizTenseSlot.allCases.map { ($0, $0.regularQuota) })
  }

  private func correctAnswer(for question: QuizQuestion) -> String {
    let conjugated = Conjugator.conjugatedString(
      infinitif: question.verb.infinitif,
      tense: question.tense,
      extraLetters: question.verb.extraLetters
    ) ?? ""
    return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
  }

  @Test func theRegularQuotasMakeAFullQuiz() {
    #expect(QuizTenseSlot.allCases.reduce(0) { $0 + $1.regularQuota } == Quiz.questionCount)
  }

  @Test func theDefaultRegularQuizAsksTheSlotQuotas() {
    Current.settings.quizDifficulty = .regular
    let quiz = Quiz(gameCenter: GameCenterStub())
    quiz.start()
    #expect(quiz.scope.isRanked)
    #expect(quiz.scope.source == .tab)
    #expect(quiz.difficulty == .regular)
    #expect(slotCounts(quiz.questions) == regularQuotas())
    quiz.quit()
  }

  @Test func theDefaultRidiculousQuizIsUnchanged() {
    Current.settings.quizDifficulty = .ridiculous
    let quiz = Quiz(gameCenter: GameCenterStub(), shouldShuffle: false)
    quiz.start()
    #expect(quiz.difficulty == .ridiculous)
    #expect(quiz.questions.count == 30)
    #expect(quiz.questions.first?.verb.infinitif == "réaliser")
    #expect(quiz.questions.last?.verb.infinitif == "mouvoir")
    quiz.quit()
    Current.settings.quizDifficulty = .regular
  }

  @Test func aMyVerbsQuizDrawsOnlyFromMyVerbsInRegularsMix() throws {
    let verbs = try [verb("être"), verb("parler"), verb("finir")]
    let ids = Set(verbs.map(\.id))
    for seed in seeds {
      let asked = questions(.myVerbs(verbs), seed: seed)
      #expect(asked.count == Quiz.questionCount)
      #expect(asked.allSatisfy { ids.contains($0.verb.id) })
      #expect(slotCounts(asked) == regularQuotas())
    }
  }

  @Test func aMyVerbsQuizTakesItsVerbsInTurn() throws {
    let verbs = try [verb("être"), verb("parler"), verb("finir")]
    let asked = questions(.myVerbs(verbs), seed: 7)
    for verb in verbs {
      #expect(asked.filter { $0.verb.id == verb.id }.count == 10)
    }
  }

  @Test func aSingleVerbRepeatsACellOnlyWhenItMust() throws {
    let être = try verb("être")
    for seed in seeds {
      let asked = questions(.myVerbs([être]), seed: seed)
      #expect(asked.count == Quiz.questionCount)
      for slot in QuizTenseSlot.allCases {
        let distinct = Set(asked.map(\.tense).filter { slot.cells.contains($0) })
        #expect(distinct.count == min(slot.regularQuota, slot.cells.count), "\(slot)")
      }
    }
  }

  // falloir has only the third-person singular, so it has no impératif: those three questions
  // fall to parler, or are dropped when falloir is the only verb.
  @Test func aDefectiveVerbIsAskedOnlyTheCellsItHas() throws {
    let falloir = try verb("falloir")
    let parler = try verb("parler")
    for seed in seeds {
      let alone = questions(.myVerbs([falloir]), seed: seed)
      #expect(alone.count == Quiz.questionCount - QuizTenseSlot.impératif.regularQuota)
      #expect(alone.allSatisfy { falloir.hasCell($0.tense) })

      let mixed = questions(.myVerbs([falloir, parler]), seed: seed)
      #expect(mixed.count == Quiz.questionCount)
      #expect(mixed.allSatisfy { $0.verb.hasCell($0.tense) })
      #expect(mixed.filter { QuizTenseSlot(tense: $0.tense) == .impératif }.allSatisfy { $0.verb.id == parler.id })
    }
  }

  @Test func testMeAsksThreeDifferentTensesOfTheVerbWithoutParticiples() throws {
    let venir = try verb("venir")
    for seed in seeds {
      let asked = questions(.verbPage(venir), seed: seed)
      #expect(asked.count == QuizScope.verbPageQuestionCount)
      #expect(asked.allSatisfy { $0.verb.id == venir.id })
      #expect(asked.allSatisfy { $0.tense != .participePassé && $0.tense != .participePrésent })
      #expect(Set(asked.compactMap { QuizTenseSlot(tense: $0.tense) }).count == 3)
    }
  }

  // Regular weights the présent 7 and the imparfait 3, so the présent turns up in more of the
  // three-question quizzes.
  @Test func testMeFavorsTheTensesRegularAsksMost() throws {
    let venir = try verb("venir")
    var présents = 0
    var imparfaits = 0
    for seed in UInt64(1) ... 2_000 {
      let slots = Set(questions(.verbPage(venir), seed: seed).compactMap { QuizTenseSlot(tense: $0.tense) })
      présents += slots.contains(.indicatifPrésent) ? 1 : 0
      imparfaits += slots.contains(.imparfait) ? 1 : 0
    }
    #expect(présents > imparfaits * 3 / 2)
    #expect(imparfaits > 200)
  }

  @Test func testMeOnAVerbWithFewCellsAsksWhatItHas() throws {
    let falloir = try verb("falloir")
    let gésir = try verb("gésir")
    let choir = try verb("choir")
    let chaloir = try verb("chaloir")
    for seed in seeds {
      let falloirs = questions(.verbPage(falloir), seed: seed)
      #expect(falloirs.count == 3)
      #expect(falloirs.allSatisfy { $0.tense.personNumber == .thirdSingular })

      let gésirs = questions(.verbPage(gésir), seed: seed)
      #expect(gésirs.count == 3)
      #expect(Set(gésirs.map(\.tense)).count == 3)
      #expect(gésirs.allSatisfy { gésir.hasCell($0.tense) && $0.tense != .participePrésent })

      #expect(questions(.verbPage(choir), seed: seed).map(\.tense) == [.participePassé])
      #expect(questions(.verbPage(chaloir), seed: seed).map(\.tense) == [.indicatifPrésent(.thirdSingular)])
    }
  }

  @Test func aVerbWithOnlyItsInfinitifCannotBeQuizzed() throws {
    let accroire = try verb("accroire")
    #expect(!accroire.canBeQuizzed)
    #expect(try verb("parler").canBeQuizzed)
    #expect(try verb("choir").canBeQuizzed)

    let quiz = Quiz(gameCenter: GameCenterStub())
    quiz.start(scope: .verbPage(accroire))
    #expect(quiz.quizState == .notStarted)
    #expect(quiz.questions.isEmpty)
  }

  // A scoped quiz asks Regular's mix, so it scores as Regular even with Ridiculous chosen, and it
  // leaves the best score alone, as it posts nothing to the leaderboard.
  @Test func aScopedQuizIsUnrankedAndScoresAsRegular() throws {
    Current.settings.quizDifficulty = .ridiculous
    Current.settings.bestScore = 0
    let quiz = Quiz(gameCenter: GameCenterStub())
    quiz.start(scope: .myVerbs([try verb("parler"), try verb("finir")]))
    #expect(!quiz.scope.isRanked)
    #expect(quiz.difficulty == .regular)
    for question in quiz.questions {
      quiz.process(proposedAnswer: correctAnswer(for: question))
    }
    #expect(quiz.shouldShowResults)
    #expect(quiz.score == 750)
    #expect(Current.settings.bestScore == 0)
    Current.settings.quizDifficulty = .regular
  }

  // sortir (obtain) conjugates like finir and sortir (exit) like partir, so each entry must be
  // graded with its own extra letters: il sortit, not il sort.
  @Test func aDoubledEntryIsGradedAsItself() throws {
    let obtain = try verb("sortir", extraLetters: "obtain")
    let quiz = Quiz(gameCenter: GameCenterStub())
    quiz.start(scope: .verbPage(obtain))
    let questionCount = quiz.questions.count
    for question in quiz.questions {
      quiz.process(proposedAnswer: correctAnswer(for: question))
    }
    #expect(quiz.quizResults.count == questionCount)
    #expect(quiz.quizResults.allSatisfy { $0.conjugationResult == .totalMatch })
  }

  @Test(arguments: [AnalyticsSource.tab, .myVerbs, .verbPage])
  func everyQuizSignalCarriesItsSource(source: AnalyticsSource) throws {
    let parler = try verb("parler")
    let scope: QuizScope
    switch source {
    case .myVerbs:
      scope = .myVerbs([parler])
    case .verbPage:
      scope = .verbPage(parler)
    default:
      scope = .allVerbs
    }
    let original = Current.analytics
    let spy = AnalyticsSpy()
    Current.analytics = spy
    defer {
      Current.analytics = original
    }
    Current.settings.quizDifficulty = .regular

    let quiz = Quiz(gameCenter: GameCenterStub())
    quiz.start(scope: scope)
    quiz.quit()
    quiz.start(scope: scope)
    for _ in quiz.questions {
      quiz.process(proposedAnswer: "x")
      quiz.continueAfterCorrection()
    }

    let quizSignals: [AnalyticsName] = [.quizStart, .quizQuit, .quizStart, .quizCompletion]
    #expect(spy.signalNames == quizSignals)
    #expect(spy.signalParameters.allSatisfy { $0[ParameterKey.source.rawValue] == source.rawValue })
    #expect(spy.signalParameters.allSatisfy { $0[ParameterKey.difficulty.rawValue] == QuizDifficulty.regular.rawValue })
  }
}
