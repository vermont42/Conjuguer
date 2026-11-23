//
//  GetterSetter.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/13/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

protocol GetterSetter {
  func get(key: String) -> String?
  func set(key: String, value: String)
  func remove(key: String)
}
