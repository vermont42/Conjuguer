//
//  BrowseSearch.swift
//  Conjuguer
//
//  The one piece the Verb and Model browse screens genuinely share: return every item
//  when the query is blank, otherwise what the screen's search finds, playing the sad
//  trombone once when an active query finds nothing. Each screen supplies its own search,
//  so the rest of its view stays self-contained.
//

import Foundation

enum BrowseSearch {
  static func results<Item>(
    in items: [Item],
    query: String,
    playSoundIfEmpty: Bool,
    search: (String) -> [Item]
  ) -> [Item] {
    guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return items
    }
    let found = search(query)
    if found.isEmpty && playSoundIfEmpty {
      Current.soundPlayer.play(.randomSadTrombone)
    }
    return found
  }
}
