//
//  UserDefaultsGetterSetter.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/13/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import Foundation

class UserDefaultsGetterSetter: GetterSetter {
  private let userDefaults = UserDefaults.standard

  func get(key: String) -> String? {
    userDefaults.string(forKey: key)
  }

  func set(key: String, value: String) {
    userDefaults.set(value, forKey: key)
  }
}
