//
//  VerbModel+Verbs.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/27/26.
//

import Foundation
import os

extension VerbModel {
  @MainActor private static var entriesCache: [String: [Verb]] = [:]
  @MainActor private static var linksCache: [LinksKey: AttributedString] = [:]

  private struct LinksKey: Hashable {
    let modelID: String
    let order: VerbSort
  }

  /// The model's entries, the most frequent first, read from its own list of dictionary keys.
  /// Each entry of a doubled infinitive counts.
  @MainActor var entriesByFrequency: [Verb] {
    if let cached = Self.entriesCache[id], !cached.isEmpty {
      return cached
    }
    let entries = verbs.compactMap { Verb.verbs[$0] }.sorted(by: Verb.byFrequency)
    Self.entriesCache[id] = entries
    return entries
  }

  /// The model's verbs as a run of `conjuguer://verb/` links, in either order, each named as every
  /// other screen names it: "haïr (France)", not its dictionary key. Built once per model and
  /// order, since parler's model alone has 4,859 links, and the page asks on every pass of `body`.
  @MainActor func verbsWithDeepLinks(order: VerbSort = .alphabetical) -> AttributedString {
    let key = LinksKey(modelID: id, order: order)
    if let cached = Self.linksCache[key] {
      return cached
    }
    let entries = entriesByFrequency.sorted(by: order.areInIncreasingOrder)
    guard !entries.isEmpty else {
      return AttributedString("")
    }
    let markdown = entries.map { verb in
      "[\(verb.infinitifWithPossibleExtraLetters)](\(Deeplink.verb(.key(verb.dictionaryKey)).url.absoluteString))"
    }
    .joined(separator: ", ")
    do {
      let links = try AttributedString(markdown: markdown)
      Self.linksCache[key] = links
      return links
    } catch {
      Log.verbModel.error("Could not build deep-linked verb list for model \(id, privacy: .public): \(error.localizedDescription, privacy: .public)")
      return AttributedString("")
    }
  }
}
