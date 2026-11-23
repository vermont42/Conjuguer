//
//  AnswerSlip.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// A wrong answer near enough to a right one to earn one more attempt: a typing slip or a dropped
/// accent, not a grammatical error.
enum AnswerSlip {
  /// In a shorter answer, one letter off is too large a share of it to call a slip.
  static let minimumLetterCount = 4

  /// Whether a normalized answer is one slip from an accepted spelling: one insertion, deletion,
  /// substitution, or swap, or only accents, cedillas, and diaereses that differ, however many
  /// (etes for êtes, prefere for préféré).
  static func isSlip(_ answer: String, of target: String) -> Bool {
    guard answer != target, target.filter(\.isLetter).count >= minimumLetterCount else {
      return false
    }
    return VerbSearch.editDistance(Array(answer), Array(target)) <= 1 || bareSpelling(answer) == bareSpelling(target)
  }

  /// Whether a wrong answer to `tense` of `verb` is a slip that earns a second attempt. An answer
  /// that is itself another cell of the verb is never one, however near: parle for parlé is the
  /// présent, and prit for prît is the passé simple. A participle agreed the other way is
  /// another spelling of the asked cell, so suis allé for suis allée is a slip.
  static func isSlip(proposedAnswer: String, correctAnswers: String, verb: Verb, tense: Tense) -> Bool {
    let candidates = AnswerSpelling.candidates(for: proposedAnswer, tense: tense, isReflexive: verb.isReflexive)
    var spellings: [String] = []
    for conjugation in correctAnswers.components(separatedBy: Tense.alternateConjugationSeparator).map({ $0.lowercased() }) {
      spellings.append(conjugation)
      spellings += StandardVariants.variants(of: conjugation, verb: verb, tense: tense)
    }
    let isNear = candidates.contains { candidate in
      spellings.contains { isSlip(candidate, of: $0) }
    }
    guard isNear else {
      return false
    }
    return candidates.allSatisfy { candidate in
      verb.conjugations(matching: candidate).allSatisfy { $0.tense == tense }
    }
  }

  private static func bareSpelling(_ text: String) -> String {
    text.folding(options: .diacriticInsensitive, locale: Util.french)
  }
}
