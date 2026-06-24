//
//  BrowseSearch.swift
//  Conjuguer
//
//  The one piece the Verb and Model browse screens genuinely share: filter the
//  current items by the query, returning everything when the query is empty and
//  playing the sad trombone once when an active query finds nothing. Each screen
//  keeps its own `matches` keypath, so the rest of its view stays self-contained.
//

import Foundation

enum BrowseSearch {
  static func results<Item>(
    in items: [Item],
    query: String,
    playSoundIfEmpty: Bool,
    matches: (Item, String) -> Bool
  ) -> [Item] {
    guard !query.isEmpty else {
      return items
    }
    let filtered = items.filter { matches($0, query) }
    if filtered.isEmpty && playSoundIfEmpty {
      Current.soundPlayer.play(.randomSadTrombone)
    }
    return filtered
  }
}
