//
//  SettingsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct SettingsTests {
  private static var retained: [Settings] = []

  private static func makeSettings(getterSetter: GetterSetter) -> Settings {
    let settings = Settings(getterSetter: getterSetter)
    retained.append(settings)
    return settings
  }

  @Test func testModelSortSurvivesReload() {
    let store = GetterSetterFake()

    let settings = SettingsTests.makeSettings(getterSetter: store)
    settings.modelSort = .alphabetical

    let reloaded = SettingsTests.makeSettings(getterSetter: store)
    #expect(reloaded.modelSort == .alphabetical, "modelSort must survive a relaunch.")
  }

  @Test func theDailyReminderIsOffAt18AndSurvivesReload() {
    let store = GetterSetterFake()
    let settings = SettingsTests.makeSettings(getterSetter: store)
    #expect(settings.dailyReminder == .off)
    #expect(settings.dailyReminderMinutes == 18 * 60)

    settings.dailyReminder = .on
    settings.dailyReminderMinutes = 7 * 60 + 30
    let reloaded = SettingsTests.makeSettings(getterSetter: store)
    #expect(reloaded.dailyReminder == .on)
    #expect(reloaded.dailyReminderMinutes == 450)
  }

  @Test func testVerbSortSurvivesReload() {
    let store = GetterSetterFake()

    let settings = SettingsTests.makeSettings(getterSetter: store)
    settings.verbSort = .alphabetical

    let reloaded = SettingsTests.makeSettings(getterSetter: store)
    #expect(reloaded.verbSort == .alphabetical, "verbSort must survive a relaunch.")
  }

  @Test(arguments: [
    (nil, QuizLevel.beginner),
    ("Regular", .elementary),
    ("Ridiculous", .advanced)
  ] as [(String?, QuizLevel)])
  func theStoredDifficultyBecomesALevel(difficulty: String?, level: QuizLevel) {
    let store = GetterSetterFake()
    if let difficulty {
      store.set(key: Settings.quizDifficultyKey, value: difficulty)
    }

    let settings = SettingsTests.makeSettings(getterSetter: store)

    #expect(settings.quizLevel == level)
    #expect(store.get(key: Settings.quizLevelKey) == level.rawValue)
  }

  @Test func aStoredLevelOutranksTheOldDifficulty() {
    let store = GetterSetterFake()
    store.set(key: Settings.quizDifficultyKey, value: "Ridiculous")
    store.set(key: Settings.quizLevelKey, value: QuizLevel.beginner.rawValue)

    let settings = SettingsTests.makeSettings(getterSetter: store)

    #expect(settings.quizLevel == .beginner)
  }

  @Test func eachLevelKeepsItsOwnBestScore() {
    let store = GetterSetterFake()
    let settings = SettingsTests.makeSettings(getterSetter: store)

    settings.recordScore(70, at: .beginner)
    settings.recordScore(90, at: .advanced)
    settings.recordScore(60, at: .advanced)

    #expect(settings.bestScore(at: .beginner) == 70)
    #expect(settings.bestScore(at: .elementary) == 0)
    #expect(settings.bestScore(at: .advanced) == 90, "A lower score must not overwrite the stored best.")
    #expect(store.get(key: "bestScore.advanced") == "90")
  }

  @Test func theBestScoreAcrossLevelsIsRemoved() {
    let store = GetterSetterFake()
    store.set(key: Settings.retiredBestScoreKey, value: "450")

    let settings = SettingsTests.makeSettings(getterSetter: store)

    #expect(store.get(key: Settings.retiredBestScoreKey) == nil)
    for level in QuizLevel.allCases {
      #expect(settings.bestScore(at: level) == 0)
    }
  }

  @Test func testReviewCardSuppressionDefaultsToOff() {
    let store = GetterSetterFake()

    let settings = SettingsTests.makeSettings(getterSetter: store)

    #expect(settings.reviewCardSuppression == .off)
    #expect(store.get(key: Settings.reviewCardSuppressionKey) == "off")
  }

  @Test func testAllPropertiesRoundTrip() {
    let store = GetterSetterFake()
    let date = Date(timeIntervalSince1970: 1_000_000)

    let settings = SettingsTests.makeSettings(getterSetter: store)
    settings.verbSort = .alphabetical
    settings.modelSort = .identifier
    settings.quizLevel = .intermediate
    settings.recordScore(42, at: .advanced)
    settings.pronounGender = .masculine
    settings.promptActionCount = 7
    settings.lastReviewPromptDate = date
    settings.reviewCardSuppression = .on

    let reloaded = SettingsTests.makeSettings(getterSetter: store)
    #expect(reloaded.verbSort == .alphabetical)
    #expect(reloaded.modelSort == .identifier)
    #expect(reloaded.quizLevel == .intermediate)
    #expect(reloaded.bestScore(at: .advanced) == 42)
    #expect(reloaded.pronounGender == .masculine)
    #expect(reloaded.promptActionCount == 7)
    #expect(reloaded.lastReviewPromptDate == date)
    #expect(reloaded.reviewCardSuppression == .on)
  }
}
