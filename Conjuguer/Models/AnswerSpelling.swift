//
//  AnswerSpelling.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// How the quiz reads a typed answer before grading it. Search folds far more loosely
/// (`VerbSearchKeys.fold` reads parle as parlé), which is right for finding a verb and wrong for
/// grading one.
enum AnswerSpelling {
  /// Case, runs of whitespace, and the typographic apostrophe that the keyboard types are not
  /// part of an answer: "  J’ai   parlé " is j'ai parlé.
  static func normalized(_ answer: String) -> String {
    ConjugationMap.key(answer.replacingOccurrences(of: "’", with: "'"))
      .split(whereSeparator: \.isWhitespace)
      .joined(separator: " ")
  }

  /// The subject pronouns a learner may type before an answer for this person. Every
  /// third-person pronoun matches its person, whichever one the settings show.
  static func subjectPronouns(for personNumber: PersonNumber) -> [String] {
    switch personNumber {
    case .firstSingular:
      return ["je ", "j'"]
    case .secondSingular:
      return ["tu "]
    case .thirdSingular:
      return ["il ", "elle ", "on "]
    case .firstPlural:
      return ["nous "]
    case .secondPlural:
      return ["vous "]
    case .thirdPlural:
      return ["ils ", "elles "]
    }
  }

  static func reflexivePronouns(for personNumber: PersonNumber) -> [String] {
    switch personNumber {
    case .firstSingular:
      return ["me ", "m'"]
    case .secondSingular:
      return ["te ", "t'"]
    case .thirdSingular, .thirdPlural:
      return ["se ", "s'"]
    case .firstPlural:
      return ["nous "]
    case .secondPlural:
      return ["vous "]
    }
  }

  /// The pronoun a pronominal verb's impératif takes after a hyphen: souviens-toi.
  static func impératifReflexiveSuffix(for personNumber: PersonNumber) -> String? {
    switch personNumber {
    case .secondSingular:
      return "-toi"
    case .firstPlural:
      return "-nous"
    case .secondPlural:
      return "-vous"
    case .firstSingular, .thirdSingular, .thirdPlural:
      return nil
    }
  }

  /// A normalized answer, then the same answer without the pronouns of the asked person that a
  /// learner may type around it. The conjugator gives a pronominal verb's cells without their
  /// reflexive pronoun (souviens, suis souvenue), so "je me souviens", "me souviens", and, in the
  /// impératif, "souviens-toi" all yield souviens. No pronoun comes before an impératif or a
  /// participle.
  static func candidates(for answer: String, tense: Tense, isReflexive: Bool) -> [String] {
    let normalized = normalized(answer)
    var candidates = [normalized]
    guard let personNumber = tense.personNumber else {
      return candidates
    }

    switch tense {
    case .impératif, .impératifPassé:
      if isReflexive, let suffix = impératifReflexiveSuffix(for: personNumber), normalized.hasSuffix(suffix) {
        candidates.append(String(normalized.dropLast(suffix.count)))
      }
      return candidates
    default:
      break
    }

    candidates += strippingPrefix(of: normalized, from: subjectPronouns(for: personNumber))
    if isReflexive {
      let reflexive = reflexivePronouns(for: personNumber)
      candidates += candidates.flatMap { strippingPrefix(of: $0, from: reflexive) }
    }

    var seen: Set<String> = []
    return candidates.filter { !$0.isEmpty && seen.insert($0).inserted }
  }

  private static func strippingPrefix(of text: String, from prefixes: [String]) -> [String] {
    prefixes
      .filter { text.hasPrefix($0) }
      .map { String(text.dropFirst($0.count)).trimmingCharacters(in: .whitespaces) }
  }
}
