//
//  MasteryTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/24/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct MasteryTests {
  private let calendar = Calendar.current
  private let now = Date(timeIntervalSince1970: 1_800_000_000)

  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  private func pattern(_ model: String, _ tense: String, _ person: String? = nil, être: Bool = false) -> PracticeItem {
    .pattern(model: model, tense: tense, person: person, takesÊtre: être)
  }

  /// A new item answered right enters the second box, due in three days, and answered right again
  /// then, the third: mastered.
  private func master(_ items: [PracticeItem], in record: inout PracticeRecord) {
    let later = now.addingTimeInterval(4 * 86_400)
    for item in items {
      record.recordAnswer(item, isCorrect: true, at: now, calendar: calendar)
      record.recordAnswer(item, isCorrect: true, at: later, calendar: calendar)
    }
  }

  @Test func theStateFollowsTheBox() {
    let item = pattern("1-1", "imparfait", "fs")
    var record = PracticeRecord()
    #expect(record.masteryState(of: item) == .notPracticed)

    record.recordAnswer(item, isCorrect: false, at: now, calendar: calendar)
    #expect(record.masteryState(of: item) == .learning)

    record.recordAnswer(item, isCorrect: true, at: now.addingTimeInterval(86_400), calendar: calendar)
    #expect(record.entry(for: item)?.schedule.box == 1)
    #expect(record.masteryState(of: item) == .learning)

    record.recordAnswer(item, isCorrect: true, at: now.addingTimeInterval(5 * 86_400), calendar: calendar)
    #expect(record.entry(for: item)?.schedule.box == MasteryState.masteredBox)
    #expect(record.masteryState(of: item) == .mastered)

    record.recordAnswer(item, isCorrect: false, at: now.addingTimeInterval(6 * 86_400), calendar: calendar)
    #expect(record.masteryState(of: item) == .learning)
  }

  @Test func aLookupIsLearningNotMastered() throws {
    var record = PracticeRecord()
    record.recordLookup(PracticeItem.keyConjugations(of: try verb("venir")), at: now, calendar: calendar)

    #expect(record.masteryState(of: .keyConjugation(verb: "venir", stem: .présent)) == .learning)
  }

  @Test(arguments: zip(QuizLevel.allCases, [46, 223, 368, 901]))
  func eachLevelShowsItsBandsPatterns(level: QuizLevel, count: Int) {
    #expect(Mastery(level: level, record: PracticeRecord()).patternCount == count)
  }

  /// One verb of each model and auxiliary stands for the rest, so the page must find exactly the
  /// patterns that asking every verb of the band every cell of the level would. Advanced's band,
  /// every verb, takes ten seconds to measure this way, so it is left out.
  @Test(arguments: [QuizLevel.beginner, .elementary, .intermediate])
  func thePatternsAreThoseTheBandCanBeAsked(level: QuizLevel) {
    var expected: Set<String> = []
    for verb in level.verbs where PracticeItem.isLearnedByPattern(verb) {
      for tense in level.slots.flatMap(\.cells) where !VerbConjugations.isDefective(verb: verb, tense: tense) {
        expected.insert(PracticeItem.exercised(by: tense, of: verb).key)
      }
    }
    let shown = Mastery.patterns(at: level).map(\.key)

    #expect(shown.count == Set(shown).count)
    #expect(Set(shown) == expected)
  }

  @Test func theRegularCardsGiveEachFamilyARowAndEachPersonAMark() throws {
    let beginner = Mastery(level: .beginner, record: PracticeRecord())
    #expect(beginner.regular.map(\.slot) == [.indicatifPrésent, .impératif])

    let présent = try #require(beginner.regular.first)
    #expect(présent.rows.map(\.modelID) == ["1-1", "2-1", "5-1A"])
    #expect(présent.rows.allSatisfy { $0.cells.map(\.person) == PersonNumber.allCases })
    #expect(beginner.regular[1].rows.allSatisfy { $0.cells.map(\.person) == PersonNumber.impératifPersonNumbers })
  }

  /// Elementary's band has être verbs among parler's family only (arriver, rester), so the passé
  /// composé has a fourth row, and a participle has one mark a family.
  @Test func compoundTensesHaveAnÊtreRowAndParticiplesOneMark() throws {
    let elementary = Mastery(level: .elementary, record: PracticeRecord())
    let passéComposé = try #require(elementary.regular.first { $0.slot == .passéComposé })
    let participe = try #require(elementary.regular.first { $0.slot == .participePassé })

    #expect(passéComposé.rows.map(\.id) == ["1-1:false", "1-1:true", "2-1:false", "5-1A:false"])
    #expect(passéComposé.rows[1].cells.first?.item == pattern("1-1", "passe_compose", "fs", être: true))
    #expect(participe.rows.map(\.cells.count) == [1, 1, 1])
    #expect(participe.rows.allSatisfy { $0.cells.first?.person == nil })
  }

  @Test func spellingChangeModelsShowOnlyTheirChangedCells() throws {
    let beginner = Mastery(level: .beginner, record: PracticeRecord())
    #expect(beginner.spellingChanges.map(\.modelID) == ["1-2A", "1-2B", "1-3A", "1-5", "1-8"])

    let manger = try #require(beginner.spellingChanges.first { $0.modelID == "1-2B" })
    #expect(manger.cells.map(\.item) == [pattern("1-2B", "indicatif_present", "fp"), pattern("1-2B", "imperatif", "fp")])
    #expect(manger.example?.lowercased() == "nous mangeons")

    let appeler = try #require(beginner.spellingChanges.first { $0.modelID == "1-3A" })
    #expect(appeler.example?.lowercased() == "j'appelle")
  }

  @Test(arguments: zip(QuizLevel.allCases, [36, 50, 50, 50]))
  func theVerbsAreTheBandsMostUsedIrregularVerbs(level: QuizLevel, count: Int) throws {
    let core = Mastery.coreVerbs(at: level).map(\.verb)

    #expect(core.count == count)
    #expect(core.first?.infinitif == "être")
    #expect(core.map(\.frequency) == core.map(\.frequency).sorted())
    #expect(core.allSatisfy { !PracticeItem.isLearnedByPattern($0) })
    let last = try #require(core.last)
    let skipped = level.verbs.filter { $0.frequency < last.frequency && !core.contains($0) }
    #expect(skipped.allSatisfy(PracticeItem.isLearnedByPattern))
  }

  @Test func eachLevelShowsTheStemsItAsks() {
    #expect(Mastery.stems(askedAt: .beginner) == [.présent])
    #expect(Mastery.stems(askedAt: .elementary) == [.présent, .passéComposé, .futur])
    #expect(Mastery.stems(askedAt: .intermediate) == [.présent, .passéComposé, .futur])
    #expect(Mastery.stems(askedAt: .advanced) == PracticeItem.Stem.allCases)
  }

  @Test func aVerbRowShowsItsKeyConjugations() throws {
    let advanced = Mastery(level: .advanced, record: PracticeRecord())
    let venir = try #require(advanced.verbs.first { $0.verb.infinitif == "venir" })
    let falloir = try #require(advanced.verbs.first { $0.verb.infinitif == "falloir" })

    #expect(venir.keyConjugations.map { $0.conjugation.lowercased() } == ["vient", "est venu", "viendra", "vint"])
    #expect(falloir.keyConjugations.map { $0.conjugation.lowercased() } == ["faut", "a fallu", "faudra", "fallut"])
  }

  @Test func theDisplayReflectsTheRecord() throws {
    var record = PracticeRecord()
    master([.keyConjugation(verb: "venir", stem: .présent)], in: &record)
    record.recordAnswer(.keyConjugation(verb: "venir", stem: .passéComposé), isCorrect: true, at: now, calendar: calendar)
    master(PersonNumber.allCases.map { pattern("1-1", "indicatif_present", $0.rawValue) }, in: &record)
    record.recordAnswer(pattern("2-1", "participe_passe"), isCorrect: false, at: now, calendar: calendar)
    master([pattern("1-2B", "imparfait", "fs")], in: &record)

    let elementary = Mastery(level: .elementary, record: record)
    let venir = try #require(elementary.verbs.first { $0.verb.infinitif == "venir" })
    let présent = try #require(elementary.regular.first { $0.slot == .indicatifPrésent })
    let participe = try #require(elementary.regular.first { $0.slot == .participePassé })
    let manger = try #require(elementary.spellingChanges.first { $0.modelID == "1-2B" })

    #expect(venir.keyConjugations.map(\.state) == [.mastered, .learning, .notPracticed])
    #expect(présent.rows[0].cells.allSatisfy { $0.state == .mastered })
    #expect(présent.rows[1].cells.allSatisfy { $0.state == .notPracticed })
    #expect(participe.rows[1].cells.map(\.state) == [.learning])
    #expect(manger.cells.filter { $0.state == .mastered }.map(\.item) == [pattern("1-2B", "imparfait", "fs")])
    #expect(elementary.masteredPatternCount == 7)
    #expect(elementary.masteredVerbCount == 0)
  }

  /// venir's présent is all that Beginner asks of it, so mastering it masters the verb there, and
  /// not at Elementary, which also asks its passé composé and futur.
  @Test func aVerbIsMasteredWhenEveryStemItsLevelAsksIs() {
    var record = PracticeRecord()
    master([.keyConjugation(verb: "venir", stem: .présent)], in: &record)

    #expect(Mastery(level: .beginner, record: record).masteredVerbCount == 1)
    #expect(Mastery(level: .elementary, record: record).masteredVerbCount == 0)

    master([.keyConjugation(verb: "venir", stem: .passéComposé), .keyConjugation(verb: "venir", stem: .futur)], in: &record)
    #expect(Mastery(level: .elementary, record: record).masteredVerbCount == 1)
    #expect(Mastery(level: .advanced, record: record).masteredVerbCount == 0)
  }

  /// A pattern the level does not ask is not counted, though the record keeps it.
  @Test func aPatternBeyondTheLevelIsNotCounted() {
    var record = PracticeRecord()
    master([pattern("1-1", "imparfait", "fs")], in: &record)

    #expect(Mastery(level: .beginner, record: record).masteredPatternCount == 0)
    #expect(Mastery(level: .elementary, record: record).masteredPatternCount == 1)
  }

  /// The mapping decides where an answer lands: nous mangeons in manger's card, je mange in the
  /// -er family's row, and nous venions in venir's présent.
  @Test func answersLandWhereTheMappingSendsThem() throws {
    let manger = try verb("manger")
    var record = PracticeRecord()
    master([
      PracticeItem.exercised(by: .indicatifPrésent(.firstPlural), of: manger),
      PracticeItem.exercised(by: .indicatifPrésent(.firstSingular), of: manger),
      PracticeItem.exercised(by: .imparfait(.firstPlural), of: try verb("venir"))
    ], in: &record)

    let beginner = Mastery(level: .beginner, record: record)
    let mangerCard = try #require(beginner.spellingChanges.first { $0.modelID == "1-2B" })
    let présent = try #require(beginner.regular.first { $0.slot == .indicatifPrésent })
    let venir = try #require(beginner.verbs.first { $0.verb.infinitif == "venir" })

    #expect(mangerCard.cells.first?.state == .mastered)
    #expect(présent.rows[0].cells.first?.state == .mastered)
    #expect(venir.isMastered)
    #expect(beginner.masteredPatternCount == 2)
  }
}
