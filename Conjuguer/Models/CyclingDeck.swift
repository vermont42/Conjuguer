//
//  CyclingDeck.swift
//  Conjuguer
//

import Foundation

struct CyclingDeck<Element> {
  private var elements: [Element]
  private var index = 0

  init(_ elements: [Element]) {
    self.elements = elements
  }

  mutating func reset() {
    index = 0
  }

  mutating func shuffle() {
    elements.shuffle()
    index = 0
  }

  mutating func next() -> Element {
    let element = elements[index]
    index += 1
    if index == elements.count {
      index = 0
    }
    return element
  }
}
