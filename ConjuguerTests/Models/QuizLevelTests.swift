//
//  QuizLevelTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct QuizLevelTests {
  private func defaultQuizzes(level: QuizLevel, seeds: ClosedRange<UInt64>) -> [QuizQuestion] {
    Current.settings.quizLevel = level
    defer {
      Current.settings.quizLevel = .elementary
    }
    return seeds.flatMap { seed in
      let quiz = Quiz(gameCenter: GameCenterStub(), seed: seed)
      quiz.start()
      defer {
        quiz.quit()
      }
      return quiz.questions
    }
  }

  @Test func eachLevelAsksItsOwnTenses() {
    #expect(QuizLevel.beginner.slots == [.indicatifPrésent, .impératif])
    #expect(Set(QuizLevel.elementary.slots) == [
      .indicatifPrésent, .impératif, .passéComposé, .participePassé, .imparfait, .futurSimple, .conditionnelPrésent
    ])
    #expect(Set(QuizLevel.intermediate.slots) == Set(QuizLevel.elementary.slots).union([
      .subjonctifPrésent, .plusQueParfait, .conditionnelPassé, .participePrésent
    ]))
    #expect(Set(QuizLevel.advanced.slots) == Set(QuizTenseSlot.allCases))
  }

  @Test func noLevelAsksATenseTwice() {
    for level in QuizLevel.allCases {
      #expect(Set(level.slots).count == level.slots.count, "\(level)")
    }
  }

  @Test func theWeights() {
    let threes: Set<QuizTenseSlot> = [.indicatifPrésent, .passéComposé]
    let twos: Set<QuizTenseSlot> = [.impératif, .imparfait, .futurSimple, .conditionnelPrésent, .subjonctifPrésent, .passéSimple, .subjonctifImparfait]
    for slot in QuizTenseSlot.allCases {
      let expected = threes.contains(slot) ? 3 : twos.contains(slot) ? 2 : 1
      #expect(slot.weight == expected, "\(slot)")
    }
  }

  @Test func everyCellBelongsToOneSlot() {
    for slot in QuizTenseSlot.allCases {
      #expect(!slot.cells.isEmpty, "\(slot)")
      for cell in slot.cells {
        #expect(QuizTenseSlot(tense: cell) == slot, "\(cell)")
      }
    }
    #expect(QuizTenseSlot.impératif.cells.count == 3)
    #expect(QuizTenseSlot.impératifPassé.cells.count == 3)
    #expect(QuizTenseSlot(tense: .radicalFutur) == nil)
  }

  @Test(arguments: QuizLevel.allCases)
  func theDefaultQuizDrawsOnlyTheLevelsTensesAndEveryOne(level: QuizLevel) {
    let questions = defaultQuizzes(level: level, seeds: 1 ... 40)
    let asked = Set(questions.compactMap { QuizTenseSlot(tense: $0.tense) })
    #expect(questions.count == 40 * Quiz.questionCount)
    #expect(asked == Set(level.slots))
  }

  @Test(arguments: QuizLevel.allCases)
  func theDefaultQuizDrawsEachTensesVerbsFromItsPools(level: QuizLevel) throws {
    for question in defaultQuizzes(level: level, seeds: 1 ... 20) {
      let slot = try #require(QuizTenseSlot(tense: question.tense))
      #expect(slot.verbPools.contains { $0.admits(question.verb) }, "\(question.verb.infinitif), \(slot)")
    }
  }

  // At Advanced the weights total 30, so the présent's 3 is 10% of the draws, the imparfait's 2
  // is 6.7%, and the plus-que-parfait's 1 is 3.3%.
  @Test func theDefaultQuizDrawsEachTenseAtItsWeight() {
    let questions = defaultQuizzes(level: .advanced, seeds: 1 ... 600)
    let total = QuizLevel.advanced.slots.reduce(0) { $0 + $1.weight }
    #expect(total == 30)
    for slot in [QuizTenseSlot.indicatifPrésent, .imparfait, .plusQueParfait, .participePassé] {
      let share = Double(questions.filter { QuizTenseSlot(tense: $0.tense) == slot }.count) / Double(questions.count)
      let expected = Double(slot.weight) / Double(total)
      #expect(abs(share - expected) < expected * 0.2, "\(slot): \(share) against \(expected)")
    }
  }

  @Test func aStartedQuizCarriesTheLevel() {
    Current.settings.quizLevel = .intermediate
    defer {
      Current.settings.quizLevel = .elementary
    }
    let original = Current.analytics
    let spy = AnalyticsSpy()
    Current.analytics = spy
    defer {
      Current.analytics = original
    }

    let quiz = Quiz(gameCenter: GameCenterStub(), seed: 1)
    quiz.start()
    #expect(quiz.level == .intermediate)
    quiz.quit()

    #expect(spy.signalNames == [.quizStart, .quizQuit])
    #expect(spy.signalParameters.allSatisfy { $0[ParameterKey.level.rawValue] == "intermediate" })
  }

  @Test func eachLevelHasAName() {
    #expect(QuizLevel.allCases.map(\.localizedName) == ["Beginner", "Elementary", "Intermediate", "Advanced"])
    #expect(QuizLevel.elementary.localizedNameWithLabel == "Level: Elementary")
  }
}
