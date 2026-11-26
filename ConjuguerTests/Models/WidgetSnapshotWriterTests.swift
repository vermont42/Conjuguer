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

  @Test func snapshotsCoverTheComingWeekFromTheFrequentBand() {
    let snapshots = WidgetSnapshotWriter.generateBundle(from: day("2026-11-23")).snapshots
    #expect(snapshots.count == WidgetSnapshotWriter.futureDayCount)
    #expect(snapshots.first?.dateString == "2026-11-23")
    #expect(snapshots.allSatisfy { $0.frequency <= VerbDraw.frequentBand.rankLimit })
  }

  @Test func snapshotsKeepTheVerbTheWidgetShowsToday() throws {
    let kept = try #require(Verb.verbs["abcéder"])
    let snapshots = WidgetSnapshotWriter.generateBundle(from: day("2026-11-23"), keeping: kept).snapshots
    let fresh = WidgetSnapshotWriter.generateBundle(from: day("2026-11-23")).snapshots
    #expect(snapshots.first?.verbKey == "abcéder")
    #expect(Array(snapshots.dropFirst()) == Array(fresh.dropFirst()))
  }

  // The app rewrites the snapshots at every activation. Starring a verb on a day My Verbs owns
  // would change that day's draw, but the verb already shown must stay.
  @Test func aRewriteAfterMyVerbsChangeKeepsTodaysVerb() throws {
    let morning = day("2026-11-22").addingTimeInterval(8 * 3_600)
    let evening = day("2026-11-22").addingTimeInterval(20 * 3_600)
    let firstWrite = WidgetSnapshotWriter.generateBundle(from: morning).snapshots
    let displayed = try #require(WidgetSnapshotWriter.displayedVerb(in: firstWrite, on: evening))
    let myVerbs = try [#require(Verb.verbs["être"])]
    let rewrite = WidgetSnapshotWriter.generateBundle(from: evening, myVerbs: myVerbs, keeping: displayed).snapshots
    let unkept = WidgetSnapshotWriter.generateBundle(from: evening, myVerbs: myVerbs).snapshots
    #expect(unkept.first?.verbKey == "être", "2026-11-22 is a My Verbs day.")
    #expect(rewrite.first?.verbKey == firstWrite.first?.verbKey)
    #expect(rewrite.first == firstWrite.first)
  }

  @Test func theDisplayedVerbIsTheSnapshotForThatDay() {
    let snapshots = WidgetSnapshotWriter.generateBundle(from: day("2026-11-22")).snapshots
    let secondDay = WidgetSnapshotWriter.displayedVerb(in: snapshots, on: day("2026-11-23"))
    #expect(secondDay?.dictionaryKey == snapshots[1].verbKey)
    #expect(WidgetSnapshotWriter.displayedVerb(in: snapshots, on: day("2026-11-21")) == nil)
    #expect(WidgetSnapshotWriter.displayedVerb(in: [], on: day("2026-11-22")) == nil)
  }

  private func temporaryFile() -> URL {
    FileManager.default.temporaryDirectory.appendingPathComponent("widget_snapshots_\(UUID().uuidString).json")
  }

  private func bundle(at url: URL) throws -> WidgetSnapshotBundle {
    try #require(WidgetSnapshotBundle.decoded(from: Data(contentsOf: url)))
  }

  @Test func aMissingFileIsWritten() throws {
    let url = temporaryFile()
    defer { try? FileManager.default.removeItem(at: url) }

    #expect(WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: [], now: day("2026-11-23")))

    let written = try bundle(at: url)
    #expect(written.snapshots.count == WidgetSnapshotWriter.futureDayCount)
    #expect(written.snapshots.first?.dateString == "2026-11-23")
  }

  @Test func aCorruptFileIsWrittenAfresh() throws {
    let url = temporaryFile()
    defer { try? FileManager.default.removeItem(at: url) }
    try Data("{ not a bundle".utf8).write(to: url)

    #expect(WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: [], now: day("2026-11-23")))

    #expect(try bundle(at: url) == WidgetSnapshotWriter.generateBundle(from: day("2026-11-23")))
  }

  @Test func aFileFromAnotherDayGivesWayToTodaysDraw() throws {
    let url = temporaryFile()
    defer { try? FileManager.default.removeItem(at: url) }
    WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: [], now: day("2026-11-01"))

    #expect(WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: [], now: day("2026-11-23")))

    #expect(try bundle(at: url).snapshots == WidgetSnapshotWriter.generateBundle(from: day("2026-11-23")).snapshots)
  }

  @Test func aSecondIdenticalWriteIsSkipped() throws {
    let url = temporaryFile()
    defer { try? FileManager.default.removeItem(at: url) }
    let myVerbs = try [#require(Verb.verbs["être"]), #require(Verb.verbs["venir"])]
    let morning = day("2026-11-22").addingTimeInterval(8 * 3_600)
    #expect(WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: myVerbs, now: morning))
    let first = try Data(contentsOf: url)

    #expect(!WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: myVerbs, now: morning.addingTimeInterval(3_600)))
    #expect(try Data(contentsOf: url) == first)
  }

  /// T2 through the disk: a relaunch on the same day, with a verb starred since, keeps today's
  /// verb.
  @Test func aRelaunchAfterMyVerbsChangeKeepsTodaysVerbThroughTheDisk() throws {
    let url = temporaryFile()
    defer { try? FileManager.default.removeItem(at: url) }
    let morning = day("2026-11-22").addingTimeInterval(8 * 3_600)
    WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: [], now: morning)
    let shown = try bundle(at: url).snapshots.first

    let myVerbs = try [#require(Verb.verbs["être"])]
    #expect(WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: myVerbs, now: morning.addingTimeInterval(10 * 3_600)))

    #expect(try bundle(at: url).snapshots.first == shown)
    #expect(WidgetSnapshotWriter.generateBundle(from: morning, myVerbs: myVerbs).snapshots.first?.verbKey == "être", "2026-11-22 is a My Verbs day.")
  }

  /// A build before the bundle wrote the bare list of snapshots.
  @Test func aFileOfBareSnapshotsStillKeepsTodaysVerb() throws {
    let url = temporaryFile()
    defer { try? FileManager.default.removeItem(at: url) }
    let morning = day("2026-11-22").addingTimeInterval(8 * 3_600)
    let snapshots = WidgetSnapshotWriter.generateBundle(from: morning).snapshots
    try JSONEncoder().encode(snapshots).write(to: url)

    let myVerbs = try [#require(Verb.verbs["être"])]
    #expect(WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: myVerbs, now: morning.addingTimeInterval(3_600)))

    #expect(try bundle(at: url).snapshots.first == snapshots.first)
  }

  /// The turns of My Verbs reach the next write, a week later, through the file.
  @Test func myVerbsTurnsCarryFromOneWriteToTheNext() throws {
    let url = temporaryFile()
    defer { try? FileManager.default.removeItem(at: url) }
    let myVerbs = try [#require(Verb.verbs["être"]), #require(Verb.verbs["venir"])]
    WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: myVerbs, now: day("2026-11-22"))
    let firstWeek = try bundle(at: url)
    #expect(firstWeek.myVerbsLastShown.keys.sorted() == ["venir", "être"].sorted())

    WidgetSnapshotWriter.writeSnapshots(to: url, myVerbs: myVerbs, now: day("2026-11-28"))

    let byDay = try Dictionary(uniqueKeysWithValues: (firstWeek.snapshots.prefix(6) + bundle(at: url).snapshots).compactMap { snapshot in snapshot.verbKey.map { (snapshot.dateString, $0) } })
    let myVerbsDays = ["2026-11-22", "2026-11-25", "2026-11-28", "2026-12-01", "2026-12-04"]
    #expect(myVerbsDays.compactMap { byDay[$0] } == ["venir", "être", "venir", "être", "venir"])
  }

  @Test func testSnapshotWrongAnswersAreDistinctAndExcludeCorrect() {
    guard let snapshot = WidgetSnapshotWriter.generateBundle(from: day("2025-06-15"), dayCount: 1).snapshots.first else {
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
        let snapshot = WidgetSnapshotWriter.generateBundle(from: date, dayCount: 1).snapshots.first
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
        let snapshot = WidgetSnapshotWriter.generateBundle(from: date, dayCount: 1).snapshots.first
      else {
        continue
      }
      let question = snapshot.quizQuestion
      pairs.insert("\(question.pronoun ?? "")|\(question.tenseDisplay)")
    }
    #expect(pairs.count > 6, "Person and tense must be decorrelated (found \(pairs.count) distinct pairs).")
  }

  @Test func testDateStringIsCalendarIndependentYMD() {
    #expect(WidgetSnapshotWriter.dateString(for: day("2025-03-07")) == "2025-03-07")
  }

  @Test func testQuestionIDEmbedsDateLevelAndVerb() throws {
    let verb = try #require(Verb.verbs["parler"])
    let snapshot = WidgetSnapshotWriter.generateSnapshot(verb: verb, date: day("2025-03-07"), level: .intermediate)
    let asked = try #require(DailyChallenge.questions(for: DailyChallenge.Key(date: day("2025-03-07"), level: .intermediate)).first)
    #expect(snapshot.quizQuestion.questionID == "2025-03-07-intermediate-\(asked.verb.dictionaryKey)")
    #expect(snapshot.dateString == "2025-03-07")
  }

  @Test func testDoubledInfinitifSnapshotsResolveTheirEntry() throws {
    // Doubled infinitives (haïr France/Québec, ouïr, saillir, sortir) have no bare-infinitif
    // dictionary key, so conjugating or deeplinking by `infinitif` alone found nothing: the
    // widget showed dashes and opened the verb list instead of the verb.
    let doubled = VerbDraw.frequentVerbs.filter { $0.extraLetters != nil }
    #expect(!doubled.isEmpty, "The frequent band should hold at least one doubled infinitif.")
    for verb in doubled {
      let snapshot = WidgetSnapshotWriter.generateSnapshot(verb: verb, date: day("2025-01-01"))
      let verbKey = try #require(snapshot.verbKey)
      #expect(Verb.verbs[verbKey] != nil, "\(verbKey) must be a Verb.verbs key so the widget deeplink opens it.")
      #expect(!snapshot.participePassé.isEmpty, "\(verbKey) must conjugate.")
      #expect(snapshot.quizQuestion.correctAnswer != "—", "\(verbKey) must conjugate.")
      #expect(WidgetSnapshotWriter.displayedVerb(in: [snapshot], on: day("2025-01-01")) == verb)
    }
  }

  @Test func testTruncateReturnsShortTextUnchanged() {
    #expect(WidgetSnapshotWriter.truncateToSentenceBoundary("Hello world.", maxLength: 100) == "Hello world.")
  }

  @Test func testTruncateCutsAtLastSentenceBoundary() {
    let text = "First sentence. Second sentence goes on."
    #expect(WidgetSnapshotWriter.truncateToSentenceBoundary(text, maxLength: 25) == "First sentence.")
  }

  @Test func testTruncateAppendsEllipsisWhenNoBoundary() {
    // No period in the prefix, so the truncation falls back to an ellipsis.
    #expect(WidgetSnapshotWriter.truncateToSentenceBoundary("Supercalifragilistic", maxLength: 5) == "Super…")
  }

  @Test func testTruncateDropsDanglingBoldOpener() {
    // Cutting inside `~…~` bold markup would leave an odd tilde count, which the widget's
    // etymology parser renders as bold running to the end. The dangling opener is dropped.
    let text = "Du latin ~parabolare~, mot très ~long et interminable qui déborde largement."
    let truncated = WidgetSnapshotWriter.truncateToSentenceBoundary(text, maxLength: 45)
    #expect(truncated.filter { $0 == "~" }.count.isMultiple(of: 2), "Tilde count must be balanced after truncation.")
  }

  @Test func testTruncateKeepsClosingQuoteAfterPeriod() {
    let text = "It began as artisans' cant from the sense “to emboss.” Later it meant to work hard."
    #expect(WidgetSnapshotWriter.truncateToSentenceBoundary(text, maxLength: 60) == "It began as artisans' cant from the sense “to emboss.”")
  }

  @Test func testTruncateKeepsClosingGuillemetAfterPeriod() {
    let text = "Il signifiait « tenir debout. » Le sens moderne vint plus tard."
    #expect(WidgetSnapshotWriter.truncateToSentenceBoundary(text, maxLength: 35) == "Il signifiait « tenir debout. »")
  }

  @Test func testTruncateSkipsPeriodInsideGloss() {
    let text = "Du latin ~necesse~. On l'analyse en ~ne-~ (« ne... pas ») et ~cedere~, mot très long."
    #expect(WidgetSnapshotWriter.truncateToSentenceBoundary(text, maxLength: 60) == "Du latin ~necesse~.")
  }

  @Test func testRebalanceLeavesBalancedTextUnchanged() {
    let balanced = "Du latin ~parabolare~, « raconter »."
    #expect(WidgetSnapshotWriter.rebalanceTildes(balanced) == balanced)
  }

  @Test func testRebalanceStripsSingleDanglingTilde() {
    #expect(WidgetSnapshotWriter.rebalanceTildes("Du latin ~parabolare") == "Du latin parabolare")
  }
}
