//
//  SettingsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import XCTest

@MainActor
class SettingsTests: XCTestCase {
  // `Settings` is @MainActor-isolated (the module defaults to MainActor isolation), so
  // deallocating an instance routes through the isolated-deinit path
  // (swift_task_deinitOnExecutorImpl), which heap-corrupts on the current toolchain
  // (Swift 6.2). This is a general runtime bug, not specific to Settings — adding
  // `nonisolated deinit` to Settings just moves the crash to GetterSetterFake's isolated
  // deinit. Production never hits it: every Settings/GetterSetter lives forever as a static
  // let on World and is never released. Retaining each constructed Settings here keeps it
  // (and, transitively, its GetterSetter) alive past the test methods, so the buggy
  // isolated-deinit path is never exercised — confining the workaround to the test rather
  // than sprinkling `nonisolated deinit` across shipping types.
  private static var retained: [Settings] = []

  private static func makeSettings(getterSetter: GetterSetter) -> Settings {
    let settings = Settings(getterSetter: getterSetter)
    retained.append(settings)
    return settings
  }

  func testModelSortSurvivesReload() {
    let store = GetterSetterFake()

    let settings = SettingsTests.makeSettings(getterSetter: store)
    settings.modelSort = .alphabetical

    let reloaded = SettingsTests.makeSettings(getterSetter: store)
    XCTAssertEqual(reloaded.modelSort, .alphabetical, "modelSort must survive a relaunch.")
  }

  func testVerbSortSurvivesReload() {
    let store = GetterSetterFake()

    let settings = SettingsTests.makeSettings(getterSetter: store)
    settings.verbSort = .alphabetical

    let reloaded = SettingsTests.makeSettings(getterSetter: store)
    XCTAssertEqual(reloaded.verbSort, .alphabetical, "verbSort must survive a relaunch.")
  }

  func testAllPropertiesRoundTrip() {
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
    XCTAssertEqual(reloaded.verbSort, .alphabetical)
    XCTAssertEqual(reloaded.modelSort, .identifier)
    XCTAssertEqual(reloaded.quizDifficulty, .ridiculous)
    XCTAssertEqual(reloaded.bestScore, 42)
    XCTAssertEqual(reloaded.pronounGender, .masculine)
    XCTAssertEqual(reloaded.promptActionCount, 7)
    XCTAssertEqual(reloaded.lastReviewPromptDate, date)
  }
}
