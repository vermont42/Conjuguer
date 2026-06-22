//
//  ConjugationResultTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct ConjugationResultTests {
  @Test(arguments: [
    ("parle", "parle", ConjugationResult.totalMatch),
    ("parle", "Parle", .totalMatch),
    ("être", "etre", .totalMatch),
    ("achète", "achete", .partialMatch),
    ("parle", "xyz", .noMatch),
    ("paye/paie", "pàie", .partialMatch),
    ("paye/paie", "paie", .totalMatch),
    ("plaça", "placa", .partialMatch),
    ("haïs", "hais", .partialMatch)
  ])
  func scoresAnswer(correctAnswers: String, proposedAnswer: String, expected: ConjugationResult) {
    #expect(ConjugationResult.score(correctAnswers: correctAnswers, proposedAnswer: proposedAnswer) == expected)
  }
}
