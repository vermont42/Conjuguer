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
    settings.bestScore = 42
    settings.pronounGender = .masculine
    settings.promptActionCount = 7
    settings.lastReviewPromptDate = date
    settings.reviewCardSuppression = .on

    let reloaded = SettingsTests.makeSettings(getterSetter: store)
    #expect(reloaded.verbSort == .alphabetical)
    #expect(reloaded.modelSort == .identifier)
    #expect(reloaded.quizLevel == .intermediate)
    #expect(reloaded.bestScore == 42)
    #expect(reloaded.pronounGender == .masculine)
    #expect(reloaded.promptActionCount == 7)
    #expect(reloaded.lastReviewPromptDate == date)
    #expect(reloaded.reviewCardSuppression == .on)
  }
}
