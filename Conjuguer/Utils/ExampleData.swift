//
//  ExampleData.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/16/26.
//

import Foundation

enum ExampleData {
  @MainActor private static var examples: [String: Example]?

  @MainActor private static func loadIfNeeded() {
    guard examples == nil else {
      return
    }
    guard
      let url = Bundle.main.url(forResource: "literature_examples", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let decoded = try? JSONDecoder().decode([String: Example].self, from: data)
    else {
      examples = [:]
      return
    }
    examples = decoded
  }

  @MainActor static func example(for verb: Verb) -> Example? {
    loadIfNeeded()
    return examples?[verb.infinitifWithPossibleExtraLetters] ?? examples?[verb.infinitif]
  }
}
