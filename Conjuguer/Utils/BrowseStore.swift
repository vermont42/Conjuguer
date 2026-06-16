//
//  BrowseStore.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/15/26.
//

import Observation

@Observable
final class BrowseStore<Item: Identifiable, Sort: Hashable> {
  var items: [Item]

  var sort: Sort {
    didSet {
      persistSort(sort)
      items = itemsBySort[sort] ?? items
    }
  }

  private let itemsBySort: [Sort: [Item]]
  private let persistSort: (Sort) -> Void

  init(itemsBySort: [Sort: [Item]], initialSort: Sort, persistSort: @escaping (Sort) -> Void) {
    self.itemsBySort = itemsBySort
    self.persistSort = persistSort
    self.items = itemsBySort[initialSort] ?? []
    self.sort = initialSort
  }
}
