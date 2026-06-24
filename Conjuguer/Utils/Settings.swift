//
//  Settings.swift
//  Conjuger
//
//  Created by Josh Adams on 1/13/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import Foundation
import Observation
import UIKit

@Observable
class Settings {
  private let getterSetter: GetterSetter

  var verbSort: VerbSort = verbSortDefault {
    didSet {
      persist(verbSort, oldValue: oldValue, key: Settings.verbSortKey)
    }
  }
  static let verbSortKey = "verbSort"
  static let verbSortDefault: VerbSort = .frequency

  var modelSort: ModelSort = modelSortDefault {
    didSet {
      persist(modelSort, oldValue: oldValue, key: Settings.modelSortKey)
    }
  }
  static let modelSortKey = "modelSort"
  static let modelSortDefault: ModelSort = .irregularity

  var quizDifficulty: QuizDifficulty = quizDifficultyDefault {
    didSet {
      persist(quizDifficulty, oldValue: oldValue, key: Settings.quizDifficultyKey)
    }
  }
  static let quizDifficultyKey = "quizDifficulty"
  static let quizDifficultyDefault: QuizDifficulty = .regular

  var bestScore: Int = bestScoreDefault {
    didSet {
      persist(bestScore, oldValue: oldValue, key: Settings.bestScoreKey)
    }
  }
  static let bestScoreKey = "bestScore"
  static let bestScoreDefault = 0

  var gameHighScore: Int = gameHighScoreDefault {
    didSet {
      persist(gameHighScore, oldValue: oldValue, key: Settings.gameHighScoreKey)
    }
  }
  static let gameHighScoreKey = "gameHighScore"
  static let gameHighScoreDefault = 0

  var pronounGender: PronounGender = pronounGenderDefault {
    didSet {
      persist(pronounGender, oldValue: oldValue, key: Settings.pronounGenderKey)
    }
  }
  static let pronounGenderKey = "pronounGender"
  static let pronounGenderDefault: PronounGender = .feminine

  var promptActionCount: Int = promptActionCountDefault {
    didSet {
      persist(promptActionCount, oldValue: oldValue, key: Settings.promptActionCountKey)
    }
  }
  static let promptActionCountKey = "promptActionCount"
  static let promptActionCountDefault = 0

  var lastReviewPromptDate: Date = lastReviewPromptDateDefault {
    didSet {
      persist(lastReviewPromptDate, oldValue: oldValue, key: Settings.lastReviewPromptDateKey)
    }
  }
  static let lastReviewPromptDateKey = "lastReviewPromptDate"
  static let lastReviewPromptDateDefault = Date(timeIntervalSince1970: 0.0)

  var appIcon: AppIcon = appIconDefault {
    didSet {
      persist(appIcon, oldValue: oldValue, key: Settings.appIconKey)
      if appIcon != oldValue {
        setAppIcon(appIcon)
      }
    }
  }
  static let appIconKey = "appIcon"
  static let appIconDefault: AppIcon = .arcDeTriomphe

  var hasSeenOnboarding: Bool = hasSeenOnboardingDefault {
    didSet {
      persist(hasSeenOnboarding, oldValue: oldValue, key: Settings.hasSeenOnboardingKey)
    }
  }
  static let hasSeenOnboardingKey = "hasSeenOnboarding"
  static let hasSeenOnboardingDefault = false

  init(getterSetter: GetterSetter) {
    self.getterSetter = getterSetter
    verbSort = load(key: Settings.verbSortKey, default: Settings.verbSortDefault)
    modelSort = load(key: Settings.modelSortKey, default: Settings.modelSortDefault)
    quizDifficulty = load(key: Settings.quizDifficultyKey, default: Settings.quizDifficultyDefault)
    bestScore = load(key: Settings.bestScoreKey, default: Settings.bestScoreDefault)
    gameHighScore = load(key: Settings.gameHighScoreKey, default: Settings.gameHighScoreDefault)
    pronounGender = load(key: Settings.pronounGenderKey, default: Settings.pronounGenderDefault)
    promptActionCount = load(key: Settings.promptActionCountKey, default: Settings.promptActionCountDefault)
    lastReviewPromptDate = load(key: Settings.lastReviewPromptDateKey, default: Settings.lastReviewPromptDateDefault)
    appIcon = load(key: Settings.appIconKey, default: Settings.appIconDefault)
    hasSeenOnboarding = load(key: Settings.hasSeenOnboardingKey, default: Settings.hasSeenOnboardingDefault)
  }

  private func setAppIcon(_ icon: AppIcon) {
    guard UIApplication.shared.supportsAlternateIcons else {
      return
    }
    let desiredName = icon.alternateIconName
    guard UIApplication.shared.alternateIconName != desiredName else {
      return
    }
    UIApplication.shared.setAlternateIconName(desiredName) { error in
      if let error {
        print("Could not set alternate app icon: \(error.localizedDescription)")
      }
    }
  }

  private func load<T: SettingValue>(key: String, default defaultValue: T) -> T {
    guard let string = getterSetter.get(key: key) else {
      getterSetter.set(key: key, value: defaultValue.settingString)
      return defaultValue
    }
    return T(settingString: string) ?? defaultValue
  }

  private func persist<T: SettingValue & Equatable>(_ value: T, oldValue: T, key: String) {
    guard value != oldValue else {
      return
    }
    getterSetter.set(key: key, value: value.settingString)
  }
}

private protocol SettingValue {
  var settingString: String { get }
  init?(settingString: String)
}

extension SettingValue where Self: RawRepresentable, RawValue == String {
  var settingString: String {
    rawValue
  }

  init?(settingString: String) {
    self.init(rawValue: settingString)
  }
}

extension VerbSort: SettingValue {}
extension ModelSort: SettingValue {}
extension QuizDifficulty: SettingValue {}
extension PronounGender: SettingValue {}
extension AppIcon: SettingValue {}

extension Int: SettingValue {
  var settingString: String {
    String(self)
  }

  init?(settingString: String) {
    self.init(settingString)
  }
}

extension Bool: SettingValue {
  var settingString: String {
    self ? "true" : "false"
  }

  init?(settingString: String) {
    switch settingString {
    case "true":
      self = true
    case "false":
      self = false
    default:
      return nil
    }
  }
}

extension Date: SettingValue {
  var settingString: String {
    String(timeIntervalSince1970)
  }

  init?(settingString: String) {
    guard let interval = Double(settingString) else {
      return nil
    }
    self = Date(timeIntervalSince1970: interval)
  }
}
