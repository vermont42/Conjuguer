//
//  ConjugationQuery.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// A search query as the words of a conjugation, with what a sentence puts around one taken
/// away: "je vais" is vais, "j'ai mangé" is "ai mangé", "que je sois" is sois, "je ne sais pas"
/// is sais, and "je me suis levé" is "suis levé", remembered as reflexive. The verb page shows
/// subject and reflexive pronouns beside its cells rather than in them, so a query carrying them
/// could never match a cell.
nonisolated struct ConjugationQuery: Equatable {
  /// What is left to look up. Never empty unless the query was.
  let words: [String]

  /// The reflexive pronoun dropped, if one was: me, m', te, t', se, s', or a second nous or
  /// vous. A compound of an avoir verb then reads as its pronominal use, with être ("me suis
  /// levé", of lever).
  let reflexivePronoun: String?

  /// Whether every word is one that this drops, as in "je" or "j'" or "nous" on the way to a
  /// conjugation. Such a query is still being typed, and finding nothing is no failure.
  let isOnlyPronouns: Bool

  private static let subjects: Set<String> = ["je", "j'", "tu", "il", "elle", "on", "nous", "vous", "ils", "elles"]
  private static let reflexives: Set<String> = ["me", "m'", "te", "t'", "se", "s'"]
  private static let others: Set<String> = ["que", "qu'", "ne", "n'", "y", "en"]
  private static let negations: Set<String> = ["pas", "plus", "jamais", "rien", "point", "guère"]

  // Inverted and imperative pronouns follow a hyphen: vas-tu, a-t-il, lève-toi.
  private static let hyphenatedPronouns: Set<String> = [
    "je", "tu", "il", "elle", "on", "nous", "vous", "ils", "elles", "t",
    "moi", "toi", "le", "la", "les", "lui", "leur", "y", "en"
  ]

  init(_ query: String) {
    let tokens = query
      .lowercased()
      .replacingOccurrences(of: "’", with: "'")
      .replacingOccurrences(of: "'", with: "' ")
      .split(whereSeparator: \.isWhitespace)
      .map(String.init)

    isOnlyPronouns = !tokens.isEmpty && tokens.allSatisfy {
      Self.subjects.contains($0) || Self.reflexives.contains($0) || Self.others.contains($0)
    }

    var words = tokens
    var reflexivePronoun: String?
    var isNegated = false
    var nousOrVousCount = 0
    while words.count > 1 {
      let word = words[0]
      if word == "nous" || word == "vous" {
        nousOrVousCount += 1
        if nousOrVousCount > 1 {
          reflexivePronoun = word
        }
      } else if Self.reflexives.contains(word) {
        reflexivePronoun = word
      } else if word == "ne" || word == "n'" {
        isNegated = true
      } else if !Self.subjects.contains(word) && !Self.others.contains(word) {
        break
      }
      words.removeFirst()
    }
    if isNegated {
      let affirmative = words.filter { !Self.negations.contains($0) }
      if !affirmative.isEmpty {
        words = affirmative
      }
    }
    self.words = words
    self.reflexivePronoun = reflexivePronoun
  }

  /// The verb in a word that carries hyphenated pronouns, as lève-toi carries lève, or nil if
  /// the word carries none. arc-boutait carries no pronoun and stays whole.
  static func verbPart(ofHyphenated word: String) -> String? {
    let parts = word.split(separator: "-").map(String.init)
    guard parts.count > 1, let head = parts.first, parts.dropFirst().allSatisfy({ hyphenatedPronouns.contains($0) }) else {
      return nil
    }
    return head
  }
}
