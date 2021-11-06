//
//  Settings.swift
//  Conjuger
//
//  Created by Josh Adams on 1/13/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import Foundation

class Settings {
  private let getterSetter: GetterSetter

  var verbSort: VerbSort {
    didSet {
      if verbSort != oldValue {
        getterSetter.set(key: Settings.verbSortKey, value: "\(verbSort)")
      }
    }
  }
  static let verbSortKey = "verbSort"
  static let verbSortDefault: VerbSort = .frequency

  var modelSort: ModelSort {
    didSet {
      if modelSort != oldValue {
        getterSetter.set(key: Settings.modelSortKey, value: "\(modelSort)")
      }
    }
  }
  static let modelSortKey = "modelSort"
  static let modelSortDefault: ModelSort = .irregularity

  var quizDifficulty: QuizDifficulty {
    didSet {
      if quizDifficulty != oldValue {
        getterSetter.set(key: Settings.quizDifficultyKey, value: quizDifficulty.rawValue)
      }
    }
  }
  static let quizDifficultyKey = "quizDifficulty"
  static let quizDifficultyDefault: QuizDifficulty = .regular

  init(getterSetter: GetterSetter) {
    self.getterSetter = getterSetter

    if let verbSortString = getterSetter.get(key: Settings.verbSortKey) {
      verbSort = VerbSort(rawValue: verbSortString) ?? Settings.verbSortDefault
    } else {
      verbSort = Settings.verbSortDefault
      getterSetter.set(key: Settings.verbSortKey, value: "\(verbSort)")
    }

    if let modelSortString = getterSetter.get(key: Settings.modelSortKey) {
      modelSort = ModelSort(rawValue: modelSortString) ?? Settings.modelSortDefault
    } else {
      modelSort = Settings.modelSortDefault
      getterSetter.set(key: Settings.modelSortKey, value: "\(modelSort)")
    }

    if let quizDifficultyString = getterSetter.get(key: Settings.quizDifficultyKey) {
      quizDifficulty = QuizDifficulty(rawValue: quizDifficultyString) ?? Settings.quizDifficultyDefault
    } else {
      quizDifficulty = Settings.quizDifficultyDefault
      getterSetter.set(key: Settings.quizDifficultyKey, value: quizDifficulty.rawValue)
    }
  }
}
