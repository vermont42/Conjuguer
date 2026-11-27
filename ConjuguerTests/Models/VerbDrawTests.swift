//
//  VerbDrawTests.swift
//  ConjuguerTests
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct VerbDrawTests {
  private func day(_ dateString: String) -> Date {
    guard let date = WidgetDateHelper.date(fromDateString: dateString) else {
      fatalError("Invalid test date: \(dateString)")
    }
    return date
  }

  private func days(from start: String, count: Int) -> [Date] {
    (0 ..< count).compactMap { WidgetDateHelper.calendar.date(byAdding: .day, value: $0, to: day(start)) }
  }

  private func verbs(_ keys: [String]) throws -> [Verb] {
    try keys.map { try #require(Verb.verbs[$0]) }
  }

  @Test(arguments: [
    ("aller", true), ("faire", true), ("prendre", true), ("venir", true), ("ouvrir", true),
    ("parler", false), ("finir", false), ("manger", false), ("lancer", false), ("appeler", false),
    ("envoyer", false), ("haïr", false)
  ])
  func irregularMeansTheThirdGroupAndAller(infinitif: String, isIrregular: Bool) throws {
    let verb = try #require(Verb.verbs[infinitif] ?? Verb.entriesByInfinitif[infinitif]?.first)
    #expect(VerbDraw.isIrregular(verb) == isIrregular)
  }

  @Test(arguments: [
    ("aller", 4), ("venir", 4), ("faire", 4), ("apprendre", 2), ("parler", 2), ("rappeler", 1)
  ])
  func theWeightFavorsIrregularAndBaseVerbs(infinitif: String, weight: Int) throws {
    let verb = try #require(Verb.verbs[infinitif])
    #expect(VerbDraw.weight(of: verb) == UInt64(weight))
  }

  @Test func theFrequentVerbsAreTheTop1000() {
    #expect(VerbDraw.frequentVerbs == Verb.verbs(in: .top1000))
    #expect(VerbDraw.frequentVerbs.allSatisfy(WidgetSnapshotWriter.isEligible))
  }

  @Test func theDayNumberCountsFromTheFirstOf2025() {
    #expect(VerbDraw.dayNumber(of: day("2025-01-01")) == 0)
    #expect(VerbDraw.dayNumber(of: day("2026-11-22")) == 690)
    let evening = day("2026-11-22").addingTimeInterval(23 * 3_600)
    #expect(VerbDraw.dayNumber(of: evening) == 690)
  }

  // Pinned against an independent Python reimplementation of the draw (SplitMix64 seeded with
  // the day number, weights from the model and the base rule), so that a change to the
  // generator, the weights, or the band shows here.
  @Test func theFrequentDrawMatchesItsReimplementation() {
    let expected = ["parvenir", "boire", "distribuer", "rechercher", "prévoir", "vendre", "croître", "visiter", "admirer", "manger"]
    let drawn = days(from: "2026-11-22", count: 10).map {
      VerbDraw.verbOfTheDay(on: $0, myVerbs: [], frequentVerbs: VerbDraw.frequentVerbs)?.dictionaryKey
    }
    #expect(drawn == expected)
  }

  /// Each My Verbs day records its verb, as the writer does, so that the next takes its turn.
  @Test func myVerbsTakeEveryThirdDayInTurn() throws {
    let myVerbs = try verbs(["être", "venir"])
    let expected = ["venir", "boire", "distribuer", "être", "prévoir", "vendre", "venir", "visiter", "admirer", "être"]
    var lastShown: [String: Date] = [:]
    var drawn: [String?] = []
    for date in days(from: "2026-11-22", count: 10) {
      let verb = VerbDraw.verbOfTheDay(on: date, myVerbs: myVerbs, frequentVerbs: VerbDraw.frequentVerbs, lastShown: lastShown)
      if VerbDraw.isMyVerbsDay(date), let verb {
        lastShown[verb.dictionaryKey] = date
      }
      drawn.append(verb?.dictionaryKey)
    }
    #expect(drawn == expected)
  }

  /// The verbs My Verbs days give, each with My Verbs as it stood that day. `listOnTurn` gives
  /// the list for each turn from the verbs given so far.
  private func myVerbsDayPicks(turns: Int, listOnTurn: (Int, [String]) throws -> [Verb]) throws -> [(key: String, list: [String])] {
    let myVerbsDays = days(from: "2026-11-22", count: turns * VerbDraw.myVerbsOdds).filter(VerbDraw.isMyVerbsDay)
    var lastShown: [String: Date] = [:]
    var picks: [(key: String, list: [String])] = []
    for (turn, date) in myVerbsDays.enumerated() {
      let list = try listOnTurn(turn, picks.map(\.key))
      let verb = try #require(VerbDraw.verbOfTheDay(on: date, myVerbs: list, frequentVerbs: VerbDraw.frequentVerbs, lastShown: lastShown))
      lastShown[verb.dictionaryKey] = date
      picks.append((verb.dictionaryKey, list.map(\.dictionaryKey)))
    }
    return picks
  }

  /// A verb given again must find every verb of that day's list given since its last turn.
  private func expectNoRepeatWhileAnotherWaits(_ picks: [(key: String, list: [String])], sourceLocation: SourceLocation = #_sourceLocation) {
    for (index, pick) in picks.enumerated() {
      guard let previous = picks[..<index].lastIndex(where: { $0.key == pick.key }) else {
        continue
      }
      let givenSince = Set(picks[(previous + 1) ..< index].map(\.key))
      let waiting = pick.list.filter { $0 != pick.key && !givenSince.contains($0) }
      #expect(waiting.isEmpty, "Turn \(index) gave \(pick.key) again while \(waiting) waited.", sourceLocation: sourceLocation)
    }
  }

  @Test func aVerbAddedBetweenMyVerbsDaysTakesItsTurnBeforeAnyRepeats() throws {
    let start = try verbs(["aller", "être", "venir"])
    let grown = try start + verbs(["faire"])
    let picks = try myVerbsDayPicks(turns: 9) { turn, _ in
      turn < 2 ? start : grown
    }
    #expect(picks.count == 9)
    expectNoRepeatWhileAnotherWaits(picks)
  }

  /// Opening the widget's verb moves it to the front of Recent, so My Verbs reorders.
  @Test func myVerbsWhoseRecentsReorderStillTakeTurns() throws {
    let verbs = try verbs(["aller", "être", "venir", "faire"])
    let picks = try myVerbsDayPicks(turns: 8) { _, given in
      guard let opened = given.last else {
        return verbs
      }
      return verbs.filter { $0.dictionaryKey == opened } + verbs.filter { $0.dictionaryKey != opened }
    }
    expectNoRepeatWhileAnotherWaits(picks)
    #expect(Set(picks.prefix(4).map(\.key)).count == 4)
  }

  @Test func myVerbsNeverWaitLongerThanThreeDays() throws {
    let myVerbs = try verbs(["être", "venir", "abcéder"])
    let keys = Set(myVerbs.map(\.dictionaryKey))
    var gap = 0
    var longestGap = 0
    for date in days(from: "2026-01-01", count: 365) {
      let verb = VerbDraw.verbOfTheDay(on: date, myVerbs: myVerbs, frequentVerbs: VerbDraw.frequentVerbs)
      gap = keys.contains(verb?.dictionaryKey ?? "") ? 0 : gap + 1
      longestGap = max(longestGap, gap)
    }
    #expect(longestGap == 2)
  }

  @Test func everyMomentOfADayDrawsTheDaysVerb() {
    let start = day("2025-06-15")
    let moments = [0, 1, 3_600, 43_200, 86_399].map { start.addingTimeInterval(Double($0)) }
    let keys = moments.compactMap { VerbDraw.verbOfTheDay(on: $0, myVerbs: [], frequentVerbs: VerbDraw.frequentVerbs)?.dictionaryKey }
    #expect(keys.count == moments.count)
    #expect(Set(keys).count == 1)
    let week = days(from: "2025-06-15", count: 7).compactMap {
      VerbDraw.verbOfTheDay(on: $0, myVerbs: [], frequentVerbs: VerbDraw.frequentVerbs)?.dictionaryKey
    }
    #expect(Set(week).count > 1)
  }

  /// Each draw weighs every verb it is offered, and a verb's weight reads its etymology, so these
  /// tests draw from a few verbs of the band rather than all 1,000. Drawing thousands of times from
  /// the whole band took over two minutes.
  private func sampleOfEachWeight() throws -> [Verb] {
    let weighed = VerbDraw.frequentVerbs.map { ($0, VerbDraw.weight(of: $0)) }
    let sample = [(1, 4), (2, 3), (4, 3)].flatMap { weight, count in
      weighed.filter { $0.1 == weight }.prefix(count).map(\.0)
    }
    try #require(sample.count == 10)
    return sample
  }

  @Test func theDrawFavorsWeightedVerbsInProportion() throws {
    let sample = try sampleOfEachWeight()
    let weights = sample.map(VerbDraw.weight(of:))
    let total = Double(weights.reduce(0, +))
    let favoredWeight = Double(weights.filter { $0 > 1 }.reduce(0, +))
    let expectedShare = favoredWeight / total
    let countShare = Double(weights.filter { $0 > 1 }.count) / Double(sample.count)
    let favoredKeys = Set(zip(sample, weights).filter { $0.1 > 1 }.map(\.0.dictionaryKey))

    var generator = SeededRandomNumberGenerator(seed: 12)
    let drawCount = 10_000
    var favored = 0
    for _ in 0 ..< drawCount {
      if let verb = VerbDraw.draw(goesToMyVerbs: false, myVerbs: [], frequentVerbs: sample, using: &generator), favoredKeys.contains(verb.dictionaryKey) {
        favored += 1
      }
    }
    let share = Double(favored) / Double(drawCount)
    #expect(abs(share - expectedShare) < 0.02, "Favored share \(share), expected \(expectedShare).")
    #expect(share > countShare + 0.05, "Favored share \(share) should exceed their count's \(countShare).")
  }

  @Test func aRandomVerbComesFromMyVerbsAboutOneTimeInThree() throws {
    let myVerbs = try verbs(["abcéder", "zoner"])
    let keys = Set(myVerbs.map(\.dictionaryKey))
    let frequentVerbs = try verbs(["parler", "finir"])
    var generator = SeededRandomNumberGenerator(seed: 7)
    let drawCount = 9_000
    var fromMyVerbs = 0
    for _ in 0 ..< drawCount {
      let verb = VerbDraw.randomVerb(myVerbs: myVerbs, frequentVerbs: frequentVerbs, using: &generator)
      if keys.contains(verb?.dictionaryKey ?? "") {
        fromMyVerbs += 1
      }
    }
    let share = Double(fromMyVerbs) / Double(drawCount)
    #expect(abs(share - 1.0 / 3.0) < 0.02, "My Verbs share \(share).")
  }

  @Test func aRandomVerbWithoutMyVerbsComesFromTheBand() {
    let frequentVerbs = VerbDraw.frequentVerbs
    var generator = SeededRandomNumberGenerator(seed: 3)
    for _ in 0 ..< 50 {
      let verb = VerbDraw.randomVerb(myVerbs: [], frequentVerbs: frequentVerbs, using: &generator)
      #expect(verb?.isIn(VerbDraw.frequentBand) == true)
    }
  }

  @Test func nothingToDrawFromGivesNoVerb() {
    var generator = SeededRandomNumberGenerator(seed: 1)
    #expect(VerbDraw.randomVerb(myVerbs: [], frequentVerbs: [], using: &generator) == nil)
    #expect(VerbDraw.verbOfTheDay(on: day("2026-11-23"), myVerbs: [], frequentVerbs: []) == nil)
  }

  @Test func myVerbsAloneStillGiveAVerbEveryDay() throws {
    let myVerbs = try verbs(["être"])
    for date in days(from: "2026-11-22", count: 6) {
      #expect(VerbDraw.verbOfTheDay(on: date, myVerbs: myVerbs, frequentVerbs: [])?.infinitif == "être")
    }
  }
}
