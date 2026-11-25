//
//  VerbLookup.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// What the Look Up a Verb shortcut says about a word, and where it then opens the app. It reads
/// the same search the verb list does, so the two cannot disagree.
struct VerbLookup {
  enum Finding: Equatable {
    case infinitive(Verb)

    /// The word is a conjugation of this verb: vais, of aller.
    case conjugation(MatchedConjugation, of: Verb)

    /// The word is neither an infinitive nor a conjugation, but other kinds of match found verbs:
    /// an English meaning, or part of an infinitive.
    case otherMatches(first: Verb, count: Int)

    /// Nothing matched, and this is the empty state's guess.
    case guess(Verb, conjugation: MatchedConjugation?)

    case nothing
  }

  /// At most this many verbs are named, so that a spoken answer stays short.
  static let maxNamedVerbs = 4

  private static let literalAnswerKinds: Set<VerbSearch.MatchKind> = [.exactInfinitive, .exactFoldedInfinitive, .conjugation]

  let word: String
  let findings: [Finding]

  /// A verb's page, when one verb answers; otherwise the verb list searched for the word, which
  /// shows every match and, failing them, the guess. suis answers for être and suivre, so it
  /// opens the search.
  let destination: Deeplink

  init(word: String, verbs: [Verb], index: ConjugationIndex? = .bundled) {
    let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
    self.word = trimmed
    let matches = VerbSearch.matches(for: trimmed, in: verbs, includeGlosses: true, conjugations: index)

    // An infinitive and a conjugation answer the question equally, so a word that is both names
    // both verbs. A folded spelling answers only when nothing literal does, as it ranks in the
    // list.
    let literalAnswers = matches.filter { Self.literalAnswerKinds.contains($0.kind) }
    let answers = literalAnswers.isEmpty ? matches.filter { $0.kind == .foldedConjugation } : literalAnswers

    var findings: [Finding] = answers.prefix(Self.maxNamedVerbs).map { match in
      if let conjugation = match.conjugation, match.kind.isConjugation {
        return .conjugation(conjugation, of: match.verb)
      }
      return .infinitive(match.verb)
    }
    if findings.isEmpty {
      if let first = matches.first {
        findings.append(.otherMatches(first: first.verb, count: matches.count))
      } else if !trimmed.isEmpty, let guess = VerbSearch.guess(for: trimmed, in: verbs, conjugations: index) {
        findings.append(.guess(guess.verb, conjugation: guess.conjugation))
      } else {
        findings.append(.nothing)
      }
    }
    self.findings = findings

    if answers.count == 1, let answer = answers.first {
      destination = .verb(.key(answer.verb.dictionaryKey), source: .lookup, match: answer.conjugation?.text)
    } else {
      destination = .search(text: trimmed, source: .lookup)
    }
  }

  func answer(pronounGender: PronounGender) -> String {
    findings.map { finding in
      switch finding {
      case .infinitive(let verb):
        let heading = Self.verbWithGloss(verb)
        let conjugations = verb.keyConjugations().map { $0.lowercased() }
        return conjugations.isEmpty ? heading : "\(heading): \(conjugations.joined(separator: " · "))"
      case .conjugation(let conjugation, let verb):
        return L.Lookup.conjugation(conjugation.line(pronounGender: verb.pronounGender(for: pronounGender)), infinitif: verb.citationInfinitif)
      case .otherMatches(let first, let count):
        let firstVerb = Self.verbWithGloss(first)
        return count == 1
          ? L.Lookup.otherMatchesOne(word, verb: firstVerb)
          : L.Lookup.otherMatchesMany(word, count: count, verb: firstVerb)
      case .guess(let verb, let conjugation):
        if let conjugation {
          return L.Lookup.guessConjugation(word, conjugation: conjugation.text, infinitif: verb.citationInfinitif)
        }
        return L.Lookup.guessVerb(word, infinitif: verb.citationInfinitif)
      case .nothing:
        return L.Lookup.nothing(word)
      }
    }
    .joined(separator: "\n")
  }

  private static func verbWithGloss(_ verb: Verb) -> String {
    L.Lookup.verbWithGloss(infinitif: verb.citationInfinitif, gloss: verb.translation)
  }
}
