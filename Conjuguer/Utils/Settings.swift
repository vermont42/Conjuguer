//
//  Settings.swift
//  Conjuger
//
//  Created by Josh Adams on 1/13/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import Foundation
import Observation

@Observable
class Settings {
  private let getterSetter: GetterSetter

  var verbSort: VerbSort = verbSortDefault {
    didSet {
      if verbSort != oldValue {
        getterSetter.set(key: Settings.verbSortKey, value: "\(verbSort)")
      }
    }
  }
  static let verbSortKey = "verbSort"
  static let verbSortDefault: VerbSort = .frequency

  var modelSort: ModelSort = modelSortDefault {
    didSet {
      if modelSort != oldValue {
        getterSetter.set(key: Settings.modelSortKey, value: "\(modelSort)")
      }
    }
  }
  static let modelSortKey = "modelSort"
  static let modelSortDefault: ModelSort = .irregularity

  var quizDifficulty: QuizDifficulty = quizDifficultyDefault {
    didSet {
      if quizDifficulty != oldValue {
        getterSetter.set(key: Settings.quizDifficultyKey, value: quizDifficulty.rawValue)
      }
    }
  }
  static let quizDifficultyKey = "quizDifficulty"
  static let quizDifficultyDefault: QuizDifficulty = .regular

  var pronounGender: PronounGender = pronounGenderDefault {
    didSet {
      if pronounGender != oldValue {
        getterSetter.set(key: Settings.pronounGenderKey, value: pronounGender.rawValue)
      }
    }
  }
  static let pronounGenderKey = "pronounGender"
  static let pronounGenderDefault: PronounGender = .feminine

  var promptActionCount: Int = promptActionCountDefault {
    didSet {
      if promptActionCount != oldValue {
        getterSetter.set(key: Settings.promptActionCountKey, value: "\(promptActionCount)")
      }
    }
  }
  static let promptActionCountKey = "promptActionCount"
  static let promptActionCountDefault = 0

  var lastReviewPromptDate: Date = lastReviewPromptDateDefault {
    didSet {
      if lastReviewPromptDate != oldValue {
        getterSetter.set(key: Settings.lastReviewPromptDateKey, value: formatter.string(from: lastReviewPromptDate))
      }
    }
  }
  static let lastReviewPromptDateKey = "lastReviewPromptDate"
  static let lastReviewPromptDateDefault = Date(timeIntervalSince1970: 0.0)
  private let formatter = DateFormatter()
  private static let format = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"

  init(getterSetter: GetterSetter) {
    self.getterSetter = getterSetter
    formatter.dateFormat = Settings.format

    // Load saved values after all properties are initialized
    if let verbSortString = getterSetter.get(key: Settings.verbSortKey) {
      verbSort = VerbSort(rawValue: verbSortString) ?? Settings.verbSortDefault
    } else {
      getterSetter.set(key: Settings.verbSortKey, value: "\(verbSort)")
    }

    if let modelSortString = getterSetter.get(key: Settings.modelSortKey) {
      modelSort = ModelSort(rawValue: modelSortString) ?? Settings.modelSortDefault
    } else {
      getterSetter.set(key: Settings.modelSortKey, value: "\(modelSort)")
    }

    if let quizDifficultyString = getterSetter.get(key: Settings.quizDifficultyKey) {
      quizDifficulty = QuizDifficulty(rawValue: quizDifficultyString) ?? Settings.quizDifficultyDefault
    } else {
      getterSetter.set(key: Settings.quizDifficultyKey, value: quizDifficulty.rawValue)
    }

    if let pronounGenderString = getterSetter.get(key: Settings.pronounGenderKey) {
      pronounGender = PronounGender(rawValue: pronounGenderString) ?? Settings.pronounGenderDefault
    } else {
      getterSetter.set(key: Settings.pronounGenderKey, value: pronounGender.rawValue)
    }

    if let promptActionCountString = getterSetter.get(key: Settings.promptActionCountKey) {
      promptActionCount = Int((promptActionCountString as NSString).intValue)
    } else {
      getterSetter.set(key: Settings.promptActionCountKey, value: "\(promptActionCount)")
    }

    if let lastReviewPromptDateString = getterSetter.get(key: Settings.lastReviewPromptDateKey) {
      lastReviewPromptDate = formatter.date(from: lastReviewPromptDateString) ?? Settings.lastReviewPromptDateDefault
    } else {
      getterSetter.set(key: Settings.lastReviewPromptDateKey, value: formatter.string(from: lastReviewPromptDate))
    }
  }
}
