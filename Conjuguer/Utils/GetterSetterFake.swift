//
//  GetterSetterFake.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/13/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import Foundation

class GetterSetterFake: GetterSetter {
  var dictionary: [String: String] = [:]

  init() {}

  init(dictionary: [String: String]) {
    self.dictionary = dictionary
  }

  func get(key: String) -> String? {
    dictionary[key]
  }

  func set(key: String, value: String) {
    dictionary[key] = value
  }
}
