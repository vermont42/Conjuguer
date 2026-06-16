//
//  LocalizationTests.swift
//  ConjuguerTests
//

@testable import Conjuguer
import Testing

@MainActor
struct LocalizationTests {
  @Test func formatStyleStringsSubstituteValues() {
    #expect(L.QuizView.score(42) == "Score: 42")
    #expect(L.QuizView.bestScore(7) == "Best score: 7")
    #expect(L.QuizView.elapsed(seconds: 90) == "Elapsed: 90 seconds")
    #expect(L.QuizView.progress(3, of: 30) == "3 out of 30")
    #expect(L.ResultsView.correct("12.5", of: 30) == "Correct: 12.5 / 30")
    #expect(L.ResultsView.time("1:23") == "Time: 1:23")
  }

  @Test func verbsUsingSelectsSingularOrPlural() {
    #expect(L.ModelView.verbsUsing(count: 1) == "Verb Using This Model")
    #expect(L.ModelView.verbsUsing(count: 0) == "Verb Using This Model")
    #expect(L.ModelView.verbsUsing(count: 2) == "Verbs Using This Model")
    #expect(L.ModelView.verbsUsing(count: 47) == "Verbs Using This Model")
  }

  @Test func ratingsPluralSelectsOneOrOther() {
    #expect(L.RatingsFetcher.ratings(count: 1) == "There is one rating for this version of Conjuguer.")
    #expect(L.RatingsFetcher.ratings(count: 5) == "There are 5 ratings for this version of Conjuguer.")
  }
}
