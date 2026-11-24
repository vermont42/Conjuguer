//
//  AchievementTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/24/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct AchievementTests {
  static let now = Date(timeIntervalSince1970: 1_800_000_000)

  /// Two right answers four days apart put a new item in the third box: mastered.
  static func master(_ items: [PracticeItem], in record: inout PracticeRecord, from date: Date = now) {
    let later = date.addingTimeInterval(4 * 86_400)
    for item in items {
      record.recordAnswer(item, isCorrect: true, at: date, calendar: .current)
      record.recordAnswer(item, isCorrect: true, at: later, calendar: .current)
    }
  }

  static func keyConjugations(of verbs: [Verb]) -> [PracticeItem] {
    verbs.flatMap { verb in
      Mastery.stems(PracticeItem.Stem.shown, of: verb).map { PracticeItem.keyConjugation(verb: verb.dictionaryKey, stem: $0) }
    }
  }

  private func progress(_ achievement: Achievement, in record: PracticeRecord) throws -> Achievement.Progress {
    try #require(Achievement.progress(in: record)[achievement])
  }

  // These IDs are permanent in App Store Connect; see docs/game_center_setup.md.
  @Test(arguments: zip(Achievement.allCases, [
    "conjuguer.achievement.patterns.beginner",
    "conjuguer.achievement.patterns.elementary",
    "conjuguer.achievement.patterns.intermediate",
    "conjuguer.achievement.patterns.advanced",
    "conjuguer.achievement.verbs.pillars",
    "conjuguer.achievement.verbs.core10",
    "conjuguer.achievement.verbs.core25",
    "conjuguer.achievement.verbs.core50",
    "conjuguer.achievement.etre"
  ]))
  func eachAchievementHasItsPermanentID(achievement: Achievement, identifier: String) {
    #expect(achievement.identifier == identifier)
  }

  @Test func theIDsAreDistinct() {
    #expect(Set(Achievement.allCases.map(\.identifier)).count == Achievement.allCases.count)
  }

  @Test func thePointsStayWithinGameCentersLimits() {
    #expect(Achievement.allCases.map(\.points) == [10, 25, 50, 100, 25, 25, 50, 100, 25])
    #expect(Achievement.allCases.map(\.points).reduce(0, +) == 410)
  }

  @Test func theCoreVerbsAreTheMasteryPagesFiftyAtEveryLevelAboveBeginner() {
    let keys = Achievement.coreVerbs.map(\.dictionaryKey)
    #expect(keys.count == 50)
    for level in [QuizLevel.intermediate, .advanced] {
      #expect(Mastery.coreVerbs(at: level).map(\.verb.dictionaryKey) == keys)
    }
  }

  @Test func thePillarsAreÊtreAvoirAllerFaireAndTheModals() {
    #expect(Set(Achievement.pillarVerbs.map(\.infinitif)) == QuizDraw.coreInfinitifs)
    #expect(Achievement.pillarVerbs.count == 8)
  }

  @Test func theHouseOfÊtreIsTwentyPassésComposés() {
    let items = Achievement.houseOfÊtreItems
    #expect(Achievement.houseOfÊtreKeys.allSatisfy { Verb.verbs[$0]?.auxiliary == .être })
    #expect(items.count == 20)
    #expect(items.contains(.keyConjugation(verb: "aller", stem: .passéComposé)))
    #expect(items.contains(.keyConjugation(verb: "sortir exit", stem: .passéComposé)))
    for model in ["1-1", "5-1A"] {
      for person in PersonNumber.allCases {
        #expect(items.contains(.pattern(model: model, tense: Tense.passéComposé(person).articleKey, person: person.rawValue, takesÊtre: true)))
      }
    }
  }

  @Test func anEmptyRecordEarnsNothing() {
    let progress = Achievement.progress(in: PracticeRecord())
    #expect(progress.count == Achievement.allCases.count)
    #expect(Achievement.allCases.compactMap { progress[$0]?.required } == [46, 223, 368, 901, 8, 10, 25, 50, 20])
    #expect(progress.values.allSatisfy { $0.mastered == 0 && $0.percentComplete == 0 && !$0.isComplete })
  }

  /// A level's band and tenses hold the lower levels', so its patterns complete theirs too.
  @Test(arguments: QuizLevel.allCases)
  func aLevelsPatternsEarnItsAchievementAndTheLowerLevels(level: QuizLevel) throws {
    var record = PracticeRecord()
    Self.master(Mastery.patterns(at: level), in: &record)
    let progress = Achievement.progress(in: record)

    for achievement in Achievement.allCases {
      guard let patternLevel = achievement.patternLevel else {
        continue
      }
      let isEarned = try #require(progress[achievement]).isComplete
      let order = QuizLevel.allCases
      #expect(isEarned == ((order.firstIndex(of: patternLevel) ?? 0) <= (order.firstIndex(of: level) ?? 0)))
    }
  }

  @Test func onePatternShortIsNotEarned() throws {
    var record = PracticeRecord()
    Self.master(Array(Mastery.patterns(at: .beginner).dropLast()), in: &record)
    let progress = try progress(.patternsBeginner, in: record)

    #expect(!progress.isComplete)
    #expect(progress.mastered == 45)
    #expect(abs(progress.percentComplete - 4_500.0 / 46) < 0.000_1)
  }

  @Test func learningCountsForNothing() throws {
    var record = PracticeRecord()
    for item in Mastery.patterns(at: .beginner) {
      record.recordAnswer(item, isCorrect: true, at: Self.now, calendar: .current)
    }

    #expect(try progress(.patternsBeginner, in: record).mastered == 0)
  }

  @Test func aVerbNeedsAllThreeKeyConjugations() throws {
    let venir = try #require(Verb.verbs["venir"])
    var record = PracticeRecord()
    Self.master([.keyConjugation(verb: "venir", stem: .présent), .keyConjugation(verb: "venir", stem: .futur)], in: &record)
    #expect(!Achievement.isFullyMastered(venir, in: record))

    Self.master([.keyConjugation(verb: "venir", stem: .passéComposé)], in: &record)
    #expect(Achievement.isFullyMastered(venir, in: record))
    #expect(try progress(.tenIrregulars, in: record).mastered == 1)
    #expect(try progress(.pillars, in: record).mastered == 0)
  }

  @Test func thePasséSimpleIsNotRequired() throws {
    let faire = try #require(Verb.verbs["faire"])
    var record = PracticeRecord()
    Self.master(Self.keyConjugations(of: [faire]), in: &record)

    #expect(record.entry(for: .keyConjugation(verb: "faire", stem: .passéSimple)) == nil)
    #expect(Achievement.isFullyMastered(faire, in: record))
  }

  @Test(arguments: [(10, Achievement.tenIrregulars), (25, .twentyFiveIrregulars), (50, .fiftyIrregulars)])
  func eachStepOfIrregularVerbs(count: Int, achievement: Achievement) throws {
    var record = PracticeRecord()
    Self.master(Self.keyConjugations(of: Array(Achievement.coreVerbs.prefix(count - 1))), in: &record)
    #expect(try !progress(achievement, in: record).isComplete)

    Self.master(Self.keyConjugations(of: [Achievement.coreVerbs[count - 1]]), in: &record)
    #expect(try progress(achievement, in: record).isComplete)
  }

  @Test func thePillars() throws {
    var record = PracticeRecord()
    Self.master(Self.keyConjugations(of: Achievement.pillarVerbs), in: &record)

    #expect(try progress(.pillars, in: record).isComplete)
    #expect(try progress(.tenIrregulars, in: record).mastered == 8)
  }

  @Test func theHouseOfÊtre() throws {
    var record = PracticeRecord()
    Self.master(Array(Achievement.houseOfÊtreItems.dropFirst()), in: &record)
    #expect(try progress(.houseOfÊtre, in: record).mastered == 19)

    Self.master(Achievement.houseOfÊtreItems, in: &record)
    #expect(try progress(.houseOfÊtre, in: record).isComplete)
  }

  @Test func nothingIsMeasuredWhileSignedOut() {
    let signedOut = GameCenterSpy()
    signedOut.reportAchievements(in: PracticeRecord())
    #expect(signedOut.achievementReports.isEmpty)

    let signedIn = GameCenterSpy(isAuthenticated: true)
    signedIn.reportAchievements(in: PracticeRecord())
    #expect(signedIn.achievementReports.count == 1)
    #expect(signedIn.achievementReports.first?.count == Achievement.allCases.count)
  }
}
