//
//  AnswerDifferenceTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct AnswerDifferenceTests {
  @Test func aMissingAccentIsMarkedOnBothSides() {
    let difference = AnswerDifference.between(given: "parle", expected: "parlé")
    #expect(difference.givenMarks == [false, false, false, false, true])
    #expect(difference.expectedMarks == [false, false, false, false, true])
    #expect(difference.expectedMarkedLetters == ["é"])
  }

  @Test func aMissingLetterIsMarkedOnlyInTheRightAnswer() {
    let difference = AnswerDifference.between(given: "finisons", expected: "finissons")
    #expect(!difference.givenMarks.contains(true))
    #expect(difference.expectedMarkedLetters == ["s"])
  }

  @Test func anExtraLetterIsMarkedOnlyInTheLearnersAnswer() {
    let difference = AnswerDifference.between(given: "parlee", expected: "parle")
    #expect(difference.givenMarks.filter { $0 }.count == 1)
    #expect(!difference.expectedMarks.contains(true))
  }

  @Test func aSwapMarksBothLettersOnBothSides() {
    let difference = AnswerDifference.between(given: "ecrivias", expected: "écrivais")
    #expect(difference.givenMarks == [true, false, false, false, false, true, true, false])
    #expect(difference.expectedMarkedLetters == ["é", "a", "i"])
  }

  @Test func aRedLetterIsNotADifference() {
    let difference = AnswerDifference.between(given: "suis allée", expected: "SUis allée")
    #expect(!difference.givenMarks.contains(true))
    #expect(!difference.expectedMarks.contains(true))
    #expect(difference.expected == "SUis allée")
  }

  @Test func anEmptyAnswerMarksEveryLetter() {
    let difference = AnswerDifference.between(given: "", expected: "irai")
    #expect(difference.givenMarks.isEmpty)
    #expect(difference.expectedMarks == [true, true, true, true])
  }

  @Test func theTypedPronounIsDropped() {
    let difference = AnswerDifference.nearest(answer: "Je parlais", correctAnswers: "parle", tense: .indicatifPrésent(.firstSingular), isReflexive: false)
    #expect(difference.given == "parlais")
    #expect(difference.expected == "parle")
  }

  @Test func aPronominalVerbsReflexivePronounIsDropped() {
    let present = AnswerDifference.nearest(answer: "je me souvient", correctAnswers: "souviens", tense: .indicatifPrésent(.firstSingular), isReflexive: true)
    #expect(present.given == "souvient")
    #expect(present.expectedMarkedLetters == ["s"])

    let imperative = AnswerDifference.nearest(answer: "souvient-toi", correctAnswers: "souviens", tense: .impératif(.secondSingular), isReflexive: true)
    #expect(imperative.given == "souvient")
  }

  @Test func theNearestAlternateIsShown() {
    let difference = AnswerDifference.nearest(answer: "payes", correctAnswers: "paie/paye", tense: .indicatifPrésent(.firstSingular), isReflexive: false)
    #expect(difference.expected == "paye")
  }

  @Test func theFirstAlternateWinsATie() {
    let difference = AnswerDifference.nearest(answer: "x", correctAnswers: "paie/paye", tense: .indicatifPrésent(.firstSingular), isReflexive: false)
    #expect(difference.expected == "paie")
  }
}
