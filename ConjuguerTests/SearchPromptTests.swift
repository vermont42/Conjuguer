//
//  SearchPromptTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/28/26.
//

@testable import Conjuguer
import SwiftUI
import Testing

@MainActor
struct SearchPromptTests {
  struct Field: Sendable {
    let width: CGFloat
    let size: DynamicTypeSize
    var sizeClass = UserInterfaceSizeClass.compact
  }

  nonisolated private static let english = ["Verb, conjugation, or English meaning", "Verb, conjugation, or meaning", "Verb or meaning"]
  nonisolated private static let french = ["Verbe, conjugaison ou sens anglais", "Verbe, conjugaison ou sens", "Verbe ou sens"]

  @Test("The longest prompt that fits the field", arguments: [
    (english, Field(width: 375, size: .xxxLarge), english[2]),
    (english, Field(width: 375, size: .xLarge), english[1]),
    (english, Field(width: 375, size: .large), english[0]),
    (english, Field(width: 402, size: .xLarge), english[0]),
    (english, Field(width: 402, size: .xxxLarge), english[1]),
    (english, Field(width: 375, size: .accessibility1), english[0]),
    (english, Field(width: 375, size: .accessibility5), english[0]),
    (french, Field(width: 375, size: .large), french[0]),
    (french, Field(width: 375, size: .xxLarge), french[1]),
    (french, Field(width: 375, size: .xxxLarge), french[1]),
    (english, Field(width: 834, size: .xxxLarge, sizeClass: .regular), english[0]),
    (english, Field(width: 0, size: .xxxLarge), english[0]),
    (english, Field(width: 100, size: .xxxLarge), english[2])
  ])
  func longestFitting(ladder: [String], field: Field, expected: String) {
    let prompt = SearchPrompt.longestFitting(ladder, containerWidth: field.width, dynamicTypeSize: field.size, sizeClass: field.sizeClass)
    #expect(prompt == expected)
  }
}
