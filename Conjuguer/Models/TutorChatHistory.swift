//
//  TutorChatHistory.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/23/26.
//

import Foundation

enum TutorChatHistory {
  static let storageKey = "tutorChatHistory"
  static let maxMessages = 200

  static func save(_ messages: [TutorMessage], getterSetter: GetterSetter) {
    getterSetter.setCodable(key: storageKey, value: messages)
  }

  static func load(getterSetter: GetterSetter) -> [TutorMessage] {
    getterSetter.getCodable(key: storageKey) ?? []
  }

  static func clear(getterSetter: GetterSetter) {
    getterSetter.set(key: storageKey, value: "")
  }

  static func isEmpty(getterSetter: GetterSetter) -> Bool {
    load(getterSetter: getterSetter).isEmpty
  }
}
