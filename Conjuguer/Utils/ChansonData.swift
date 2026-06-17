//
//  ChansonData.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/16/26.
//

import Foundation

enum ChansonData {
  @MainActor private static var examples: [String: [ChansonExample]]?

  @MainActor private static func loadIfNeeded() {
    guard examples == nil else {
      return
    }
    guard
      let url = Bundle.main.url(forResource: "chanson_examples", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let decoded = try? JSONDecoder().decode([String: [ChansonExample]].self, from: data)
    else {
      examples = [:]
      return
    }
    examples = decoded
  }

  @MainActor static func examples(for verb: Verb) -> [ChansonExample] {
    loadIfNeeded()
    return examples?[verb.infinitifWithPossibleExtraLetters] ?? examples?[verb.infinitif] ?? []
  }
}
