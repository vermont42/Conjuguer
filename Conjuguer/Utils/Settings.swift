//
//  Settings.swift
//  Conjuger
//
//  Created by Joshua Adams on 1/13/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import Foundation

class Settings {
  private let getterSetter: GetterSetter

  var verbSort: VerbSort {
    didSet {
      if verbSort != oldValue {
        getterSetter.set(key: Settings.verbSortKey, value: "\(verbSort)")
        print("@@@ set value to \(verbSort)")
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

  init(getterSetter: GetterSetter) {
    self.getterSetter = getterSetter

    if let verbSortString = getterSetter.get(key: Settings.verbSortKey) {
      verbSort = VerbSort(rawValue: verbSortString) ?? Settings.verbSortDefault
      print("@@@ got \(verbSortString) from UserDefaults")
    } else {
      verbSort = Settings.verbSortDefault
      getterSetter.set(key: Settings.verbSortKey, value: "\(verbSort)")
      print("@@@ UserDefaults empty; using \(verbSort)")
    }

    if let modelSortString = getterSetter.get(key: Settings.modelSortKey) {
      modelSort = ModelSort(rawValue: modelSortString) ?? Settings.modelSortDefault
    } else {
      modelSort = Settings.modelSortDefault
      getterSetter.set(key: Settings.modelSortKey, value: "\(modelSort)")
    }
  }
}
