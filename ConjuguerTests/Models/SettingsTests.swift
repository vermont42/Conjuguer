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

  @Test func testAllPropertiesRoundTrip() {
    let store = GetterSetterFake()
    let date = Date(timeIntervalSince1970: 1_000_000)

    let settings = SettingsTests.makeSettings(getterSetter: store)
    settings.verbSort = .alphabetical
    settings.modelSort = .identifier
    settings.quizDifficulty = .ridiculous
    settings.bestScore = 42
    settings.pronounGender = .masculine
    settings.promptActionCount = 7
    settings.lastReviewPromptDate = date

    let reloaded = SettingsTests.makeSettings(getterSetter: store)
    #expect(reloaded.verbSort == .alphabetical)
    #expect(reloaded.modelSort == .identifier)
    #expect(reloaded.quizDifficulty == .ridiculous)
    #expect(reloaded.bestScore == 42)
    #expect(reloaded.pronounGender == .masculine)
    #expect(reloaded.promptActionCount == 7)
    #expect(reloaded.lastReviewPromptDate == date)
  }
}
