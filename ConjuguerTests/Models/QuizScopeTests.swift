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

  private func questions(_ scope: QuizScope, seed: UInt64, level: QuizLevel = .elementary) -> [QuizQuestion] {
    var generator = SeededRandomNumberGenerator(seed: seed)
    return scope.questions(level: level, using: &generator)
  }

  private func slots(_ questions: [QuizQuestion]) -> Set<QuizTenseSlot> {
    Set(questions.compactMap { QuizTenseSlot(tense: $0.tense) })
  }

  private func correctAnswer(for question: QuizQuestion) -> String {
    let conjugated = Conjugator.conjugatedString(
      infinitif: question.verb.infinitif,
      tense: question.tense,
      extraLetters: question.verb.extraLetters
    ) ?? ""
    return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
  }

  @Test func theDefaultQuizIsRankedAndAsksTheLearnersLevel() {
    Current.settings.quizLevel = .intermediate
    let quiz = Quiz(gameCenter: GameCenterStub(), seed: 3)
    quiz.start()
    #expect(quiz.scope.isRanked)
    #expect(quiz.scope.source == .tab)
    #expect(quiz.level == .intermediate)
    #expect(quiz.questions.count == Quiz.questionCount)
    #expect(slots(quiz.questions).isSubset(of: QuizLevel.intermediate.slots))
    quiz.quit()
    Current.settings.quizLevel = .elementary
  }

  @Test(arguments: QuizLevel.allCases)
  func aMyVerbsQuizDrawsOnlyFromMyVerbsAtTheLevel(level: QuizLevel) throws {
    let verbs = try [verb("être"), verb("parler"), verb("finir")]
    let ids = Set(verbs.map(\.id))
    for seed in seeds {
      let asked = questions(.myVerbs(verbs), seed: seed, level: level)
      #expect(asked.count == Quiz.questionCount)
      #expect(asked.allSatisfy { ids.contains($0.verb.id) })
      #expect(slots(asked).isSubset(of: level.slots))
    }
  }

  // At Beginner each verb has six présents and three impératifs, so every verb has a fresh cell
  // of either tense for three rounds, and those rounds take the verbs strictly in turn.
  @Test func aMyVerbsQuizTakesItsVerbsInTurn() throws {
    let verbs = try [verb("être"), verb("parler"), verb("finir")]
    for seed in seeds {
      let asked = questions(.myVerbs(verbs), seed: seed, level: .beginner)
      let firstRound = asked.prefix(verbs.count).map(\.verb.id)
      #expect(Set(firstRound).count == verbs.count)
      for index in verbs.count ..< verbs.count * 3 {
        #expect(asked[index].verb.id == firstRound[index % verbs.count])
      }
    }
  }

  @Test func aSingleVerbRepeatsACellOnlyWhenItMust() throws {
    let être = try verb("être")
    for seed in seeds {
      let asked = questions(.myVerbs([être]), seed: seed)
      #expect(asked.count == Quiz.questionCount)
      for slot in QuizTenseSlot.allCases {
        let tenses = asked.map(\.tense).filter { slot.cells.contains($0) }
        #expect(Set(tenses).count == min(tenses.count, slot.cells.count), "\(slot)")
      }
    }
  }

  // falloir has only the third-person singular, so it has no impératif: those questions fall to
  // parler, or are never drawn when falloir is the only verb.
  @Test func aDefectiveVerbIsAskedOnlyTheCellsItHas() throws {
    let falloir = try verb("falloir")
    let parler = try verb("parler")
    for seed in seeds {
      let alone = questions(.myVerbs([falloir]), seed: seed)
      #expect(alone.count == Quiz.questionCount)
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
      #expect(slots(asked).count == 3)
    }
  }

  @Test func testMeAtBeginnerAsksOnlyThePrésentAndTheImpératif() throws {
    let venir = try verb("venir")
    for seed in seeds {
      let asked = questions(.verbPage(venir), seed: seed, level: .beginner)
      #expect(asked.count == QuizScope.verbPageQuestionCount)
      #expect(Set(asked.map(\.tense)).count == 3)
      #expect(slots(asked) == [.indicatifPrésent, .impératif])
    }
  }

  // Intermediate weights the présent 3 and the plus-que-parfait 1, so the présent turns up in
  // more of the three-question quizzes.
  @Test func testMeFavorsTheHeavierTenses() throws {
    let venir = try verb("venir")
    var présents = 0
    var plusQueParfaits = 0
    for seed in UInt64(1) ... 2_000 {
      let asked = slots(questions(.verbPage(venir), seed: seed, level: .intermediate))
      présents += asked.contains(.indicatifPrésent) ? 1 : 0
      plusQueParfaits += asked.contains(.plusQueParfait) ? 1 : 0
    }
    #expect(présents > plusQueParfaits * 2)
    #expect(plusQueParfaits > 200)
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
    for level in QuizLevel.allCases {
      #expect(!accroire.canBeQuizzed(at: level))
      #expect(try verb("parler").canBeQuizzed(at: level))
    }
    let choir = try verb("choir")
    #expect(!choir.canBeQuizzed(at: .beginner))
    #expect(choir.canBeQuizzed(at: .elementary))

    let quiz = Quiz(gameCenter: GameCenterStub())
    quiz.start(scope: .verbPage(accroire))
    #expect(quiz.quizState == .notStarted)
    #expect(quiz.questions.isEmpty)
  }

  // A scoped quiz leaves the best score alone, as it posts nothing to the leaderboard.
  @Test func aScopedQuizIsUnrankedAndAsksTheLearnersLevel() throws {
    Current.settings.quizLevel = .advanced
    Current.settings.bestScore = 0
    let quiz = Quiz(gameCenter: GameCenterStub())
    quiz.start(scope: .myVerbs([try verb("parler"), try verb("finir")]))
    #expect(!quiz.scope.isRanked)
    #expect(quiz.level == .advanced)
    for question in quiz.questions {
      quiz.process(proposedAnswer: correctAnswer(for: question))
    }
    #expect(quiz.shouldShowResults)
    #expect(quiz.score == Quiz.questionCount * 10)
    #expect(Current.settings.bestScore == 0)
    Current.settings.quizLevel = .elementary
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
    Current.settings.quizLevel = .intermediate
    defer {
      Current.settings.quizLevel = .elementary
    }

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
    #expect(spy.signalParameters.allSatisfy { $0[ParameterKey.level.rawValue] == QuizLevel.intermediate.rawValue })
  }
}
