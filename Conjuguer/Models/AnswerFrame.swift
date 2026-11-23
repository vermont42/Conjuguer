//
//  AnswerFrame.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// The shape of an expected answer: the blank the learner fills, and the words around it that the
/// learner does not type, as in `nous ______` or `(tu) ______-toi !`.
struct AnswerFrame: Equatable {
  enum Segment: Equatable {
    /// Whom an impératif addresses, shown as (tu). The impératif takes no subject pronoun, but tu
    /// and vous take different answers.
    case addressee(String)
    case blank
    /// The gender a compound tense's participle may agree with, for a person whose pronoun does
    /// not show it.
    case gender(isFeminine: Bool)
    /// The subject pronoun and any reflexive one, elided as the answer requires: j', je me, tu t'.
    case pronoun(String)
    case punctuation(String)
    /// The reflexive pronoun that a pronominal impératif takes after a hyphen.
    case reflexiveSuffix(String)
  }

  let segments: [Segment]

  static let bareBlank = AnswerFrame(segments: [.blank])

  var leadingSegments: [Segment] {
    Array(segments.prefix { $0 != .blank })
  }

  var trailingSegments: [Segment] {
    guard let blankIndex = segments.firstIndex(of: .blank) else {
      return []
    }
    return Array(segments[segments.index(after: blankIndex)...])
  }

  /// The frame for one quiz question.
  ///
  /// The pronoun elides as the answer's first letter requires, so a learner may read from j' that
  /// the answer begins with a vowel, and, for je in a compound tense, that its auxiliary is avoir.
  /// That hint is deliberate, since the quiz is practice. The gender shows for every compound
  /// tense, whatever the auxiliary, so it reveals nothing.
  ///
  /// - Parameter answer: The conjugation, or its "/"-separated alternates, which share a first
  ///   letter.
  static func quizFrame(for tense: Tense, answer: String, isReflexive: Bool, hasAspiratedH: Bool, pronounGender: PronounGender) -> AnswerFrame {
    guard let personNumber = tense.personNumber else {
      return bareBlank
    }

    let showsGender = tense.isCompound && personNumber != .thirdSingular && personNumber != .thirdPlural
    let gender: [Segment] = showsGender ? [.gender(isFeminine: pronounGender.isFeminine(personNumber))] : []

    switch tense {
    case .impératif, .impératifPassé:
      let addressee = Segment.addressee(personNumber == .secondSingular ? "tu" : personNumber == .firstPlural ? "nous" : "vous")
      var reflexive: [Segment] = []
      if case .impératif = tense, isReflexive, let suffix = AnswerSpelling.impératifReflexiveSuffix(for: personNumber) {
        reflexive = [.reflexiveSuffix(suffix)]
      }
      return AnswerFrame(segments: [addressee] + gender + [.blank] + reflexive + [.punctuation("!")])
    default:
      let firstAnswer = answer.components(separatedBy: Tense.alternateConjugationSeparator).first ?? answer
      let pronoun = personNumber.preamble(forConjugation: firstAnswer, isReflexive: isReflexive, hasAspiratedH: hasAspiratedH, pronounGender: pronounGender)
      return AnswerFrame(segments: [.pronoun(pronoun.trimmingCharacters(in: .whitespaces))] + gender + [.blank])
    }
  }

  /// The frame as VoiceOver reads it, as one prompt: "je, feminine, blank". An elided pronoun is
  /// read whole, and il and ils, which sound alike, are told apart by number.
  var spokenPrompt: String {
    segments.flatMap { segment -> [String] in
      switch segment {
      case .addressee(let text):
        return [text]
      case .blank:
        return [L.QuizView.blank]
      case .gender(let isFeminine):
        return [(isFeminine ? L.PronounGender.feminine : L.PronounGender.masculine).lowercased()]
      case .pronoun(let text):
        let words = text.replacingOccurrences(of: "'", with: "e ").split(separator: " ").map(String.init)
        switch words.first {
        case "il", "elle":
          return [words.joined(separator: " "), L.QuizView.singular]
        case "ils", "elles":
          return [words.joined(separator: " "), L.QuizView.plural]
        default:
          return [words.joined(separator: " ")]
        }
      case .reflexiveSuffix(let text):
        return [String(text.drop { $0 == "-" })]
      case .punctuation:
        return []
      }
    }
    .joined(separator: ", ")
  }
}

extension QuizQuestion {
  var answerFrame: AnswerFrame {
    let answer = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters) ?? ""
    return .quizFrame(for: tense, answer: answer, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH, pronounGender: Current.settings.pronounGender)
  }
}
