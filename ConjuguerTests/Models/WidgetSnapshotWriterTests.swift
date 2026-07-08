//
//  WidgetSnapshotWriterTests.swift
//  ConjuguerTests
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct WidgetSnapshotWriterTests {
  // Build a Date at a fixed calendar day using the same Gregorian calendar the writer
  // uses, so day-index math is reproducible regardless of the test machine's locale.
  private func day(_ dateString: String) -> Date {
    guard let date = WidgetDateHelper.date(fromDateString: dateString) else {
      fatalError("Invalid test date: \(dateString)")
    }
    return date
  }

  // MARK: verbOfTheDay day-index hash

  @Test func testVerbOfTheDayIsDeterministicForADate() {
    let eligible = WidgetSnapshotWriter.eligibleVerbs()
    #expect(!eligible.isEmpty)

    let first = WidgetSnapshotWriter.verbOfTheDay(from: eligible, date: day("2025-06-15"))
    let second = WidgetSnapshotWriter.verbOfTheDay(from: eligible, date: day("2025-06-15"))
    #expect(first.infinitif == second.infinitif, "The same day must always yield the same verb.")
  }

  @Test func testVerbOfTheDayChangesAcrossConsecutiveDays() {
    let eligible = WidgetSnapshotWriter.eligibleVerbs()
    // The index steps by 127 (a prime, < verb count) per day, so adjacent days land
    // on distinct indices and therefore distinct verbs.
    let today = WidgetSnapshotWriter.verbOfTheDay(from: eligible, date: day("2025-06-15"))
    let tomorrow = WidgetSnapshotWriter.verbOfTheDay(from: eligible, date: day("2025-06-16"))
    #expect(today.infinitif != tomorrow.infinitif, "Consecutive days should rotate the verb.")
  }

  // MARK: generateSnapshot / generateWrongAnswers (dedup + padding)

  @Test func testSnapshotWrongAnswersAreDistinctAndExcludeCorrect() {
    guard let snapshot = WidgetSnapshotWriter.generateSnapshot(date: day("2025-06-15")) else {
      Issue.record("Expected a snapshot for an eligible-verb day.")
      return
    }

    let question = snapshot.quizQuestion
    #expect(question.wrongAnswers.count == 3, "The quiz always offers three distractors.")
    #expect(!question.wrongAnswers.contains(question.correctAnswer), "A distractor must never equal the correct answer.")
    #expect(Set(question.wrongAnswers).count == question.wrongAnswers.count, "Distractors must be unique.")
  }

  @Test func testSnapshotWrongAnswersAreNeverSyntheticPadding() {
    // Finding 33: the old fallback appended `correctAnswer + "xx…"` when it ran out of
    // real forms, surfacing fake options like `parlonsxx`. Sweeping many days, no
    // distractor may be the correct answer with a trailing run of `x` padding.
    let start = day("2025-01-01")
    for offset in 0 ..< 40 {
      guard
        let date = WidgetDateHelper.calendar.date(byAdding: .day, value: offset, to: start),
        let snapshot = WidgetSnapshotWriter.generateSnapshot(date: date)
      else {
        continue
      }
      let question = snapshot.quizQuestion
      for wrong in question.wrongAnswers where wrong.hasPrefix(question.correctAnswer) {
        let suffix = wrong.dropFirst(question.correctAnswer.count)
        #expect(
          !(!suffix.isEmpty && suffix.allSatisfy { $0 == "x" }),
          "Distractor \"\(wrong)\" for \"\(question.correctAnswer)\" is synthetic `x` padding."
        )
      }
    }
  }

  @Test func testSnapshotDecorrelatesPersonAndTense() {
    // Finding 2: person and tense were welded (both indexed by seed % 6), so only 6 of
    // 36 combinations ever appeared. Sweeping 36 consecutive days must surface well more
    // than 6 distinct (pronoun, tense) pairs.
    var pairs: Set<String> = []
    let start = day("2025-01-01")
    for offset in 0 ..< 36 {
      guard
        let date = WidgetDateHelper.calendar.date(byAdding: .day, value: offset, to: start),
        let snapshot = WidgetSnapshotWriter.generateSnapshot(date: date)
      else {
        continue
      }
      let question = snapshot.quizQuestion
      pairs.insert("\(question.pronoun ?? "")|\(question.tenseDisplay)")
    }
    #expect(pairs.count > 6, "Person and tense must be decorrelated (found \(pairs.count) distinct pairs).")
  }

  // MARK: date strings

  @Test func testDateStringIsCalendarIndependentYMD() {
    #expect(WidgetSnapshotWriter.dateString(for: day("2025-03-07")) == "2025-03-07")
  }

  @Test func testQuestionIDEmbedsDateAndInfinitif() {
    guard let snapshot = WidgetSnapshotWriter.generateSnapshot(date: day("2025-03-07")) else {
      Issue.record("Expected a snapshot for an eligible-verb day.")
      return
    }
    #expect(snapshot.quizQuestion.questionID == "2025-03-07-\(snapshot.infinitif)")
    #expect(snapshot.dateString == "2025-03-07")
  }

  // MARK: truncateToSentenceBoundary

  @Test func testTruncateReturnsShortTextUnchanged() {
    #expect(WidgetSnapshotWriter.truncateToSentenceBoundary("Hello world.", maxLength: 100) == "Hello world.")
  }

  @Test func testTruncateCutsAtLastSentenceBoundary() {
    // prefix(25) = "First sentence. Second se"; the last "." is kept, the rest dropped.
    let text = "First sentence. Second sentence goes on."
    #expect(WidgetSnapshotWriter.truncateToSentenceBoundary(text, maxLength: 25) == "First sentence.")
  }

  @Test func testTruncateAppendsEllipsisWhenNoBoundary() {
    // No period in the prefix, so the truncation falls back to an ellipsis.
    #expect(WidgetSnapshotWriter.truncateToSentenceBoundary("Supercalifragilistic", maxLength: 5) == "Super…")
  }

  // MARK: rebalanceTildes (finding 33)

  @Test func testTruncateDropsDanglingBoldOpener() {
    // Cutting inside `~…~` bold markup would leave an odd tilde count, which the widget's
    // etymology parser renders as bold running to the end. The dangling opener is dropped.
    let text = "Du latin ~parabolare~, mot très ~long et interminable qui déborde largement."
    let truncated = WidgetSnapshotWriter.truncateToSentenceBoundary(text, maxLength: 45)
    #expect(truncated.filter { $0 == "~" }.count.isMultiple(of: 2), "Tilde count must be balanced after truncation.")
  }

  @Test func testRebalanceLeavesBalancedTextUnchanged() {
    let balanced = "Du latin ~parabolare~, « raconter »."
    #expect(WidgetSnapshotWriter.rebalanceTildes(balanced) == balanced)
  }

  @Test func testRebalanceStripsSingleDanglingTilde() {
    #expect(WidgetSnapshotWriter.rebalanceTildes("Du latin ~parabolare") == "Du latin parabolare")
  }
}
