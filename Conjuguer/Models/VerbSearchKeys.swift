//
//  VerbSearchKeys.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import Foundation

/// A verb's infinitive and gloss as search compares them, computed once when the verb is made.
/// Part of the conjugation core, since `Verb` is, so it reaches no app-only type.
nonisolated struct VerbSearchKeys: Hashable, Sendable {
  let infinitif: String
  let foldedInfinitif: String
  let foldedInfinitifBytes: [UInt8]
  let gloss: String
  let meanings: [String]

  init(infinitif: String, translation: String) {
    self.infinitif = infinitif.lowercased()
    foldedInfinitif = Self.fold(infinitif)
    foldedInfinitifBytes = Array(foldedInfinitif.utf8)
    gloss = translation.lowercased()
    meanings = Self.meanings(of: translation)
  }

  /// Collapses what a learner without a French keyboard types: accents, the cedilla, and the
  /// ligatures, so that etre finds être and manoeuvrer finds manœuvrer. For matching only.
  static func fold(_ text: String) -> String {
    text.lowercased()
      .replacingOccurrences(of: "œ", with: "oe")
      .replacingOccurrences(of: "æ", with: "ae")
      .folding(options: .diacriticInsensitive, locale: nil)
  }

  /// The meanings a gloss lists, each without its parenthetical note: "can (food)" is a meaning
  /// "can", "hand over, pay, turn up (slang)" holds three, and "thank, fire (an employee,
  /// euphemistically)" holds two, since a note is dropped before the gloss is split.
  static func meanings(of gloss: String) -> [String] {
    gloss.lowercased()
      .replacingOccurrences(of: #"\([^)]*\)"#, with: "", options: .regularExpression)
      .split(whereSeparator: { $0 == "," || $0 == ";" })
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
  }
}
