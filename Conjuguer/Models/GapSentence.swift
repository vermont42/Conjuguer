//
//  GapSentence.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// Phrases à trous: a short authored sentence with its verb blanked, "Hier soir, nous {sommes
/// allés} au cinéma.", which ties a conjugation to a meaning. The sentences live in
/// `gap_sentences.json`. Claude drafts them, `GapSentenceTests` confirms every blank against the
/// Conjugator, and each is reread before it ships, which `reviewed` records.
extension QuizScope {
  static let sentences = QuizScope(verbs: nil, questionCount: Quiz.questionCount, source: .sentences, isSentences: true)
}

struct GapSentence: Decodable, Identifiable, Hashable {
  let id: String
  /// A key of `Verb.verbs`.
  let verbKey: String
  /// A `QuizTenseSlot` case name.
  let tenseKey: String
  /// A `PersonNumber` raw value, absent for a participle.
  let personKey: String?
  /// "f" or "m" where the sentence's subject fixes an être verb's agreement. Elsewhere the
  /// learner's setting gives the gender, which then changes no answer.
  let genderKey: String?
  /// The sentence, with the conjugation in braces.
  let french: String
  let english: String
  let reviewed: Bool

  private enum CodingKeys: String, CodingKey {
    case english = "en"
    case french = "fr"
    case genderKey = "gender"
    case id
    case personKey = "person"
    case reviewed
    case tenseKey = "tense"
    case verbKey = "verb"
  }

  var verb: Verb? {
    Verb.verbs[verbKey]
  }

  var slot: QuizTenseSlot? {
    QuizTenseSlot.allCases.first { "\($0)" == tenseKey }
  }

  var personNumber: PersonNumber? {
    personKey.flatMap(PersonNumber.init(rawValue:))
  }

  /// The cell the braces conjugate, nil when the tense or the person names none.
  var tense: Tense? {
    guard let slot else {
      return nil
    }
    guard let constructor = slot.constructor else {
      return personKey == nil ? slot.cells.first : nil
    }
    guard let personNumber, slot.persons.contains(personNumber) else {
      return nil
    }
    return constructor(personNumber)
  }

  var pronounGender: PronounGender? {
    switch genderKey {
    case "f":
      return .feminine
    case "m":
      return .masculine
    default:
      return nil
    }
  }

  var answer: String {
    parts?.answer ?? ""
  }

  /// The sentence as it reads with its conjugation written in.
  var completed: String {
    french.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
  }

  /// The words before and after the braces, nil unless there is exactly one pair.
  var parts: (before: String, answer: String, after: String)? {
    let opening = french.split(separator: "{", omittingEmptySubsequences: false)
    guard opening.count == 2 else {
      return nil
    }
    let closing = opening[1].split(separator: "}", omittingEmptySubsequences: false)
    guard closing.count == 2, !closing[0].isEmpty else {
      return nil
    }
    return (String(opening[0]), String(closing[0]), String(closing[1]))
  }

  /// The sentence around one blank. An impératif names whom it addresses, since a sentence such as
  /// "{Viens} dîner chez nous" takes viens or venez alike. A compound tense whose pronoun does not
  /// show the gender marks it beside the blank, as the one-line frame does, whatever the
  /// auxiliary, so the mark reveals nothing.
  func frame(pronounGender: PronounGender) -> AnswerFrame {
    guard let parts, let tense else {
      return .bareBlank
    }
    var segments: [AnswerFrame.Segment] = []
    if !parts.before.isEmpty {
      segments.append(.context(parts.before))
    }
    if slot?.isImpératif == true, let personNumber {
      segments.append(.addressee(personNumber == .secondSingular ? "tu" : personNumber == .firstPlural ? "nous" : "vous"))
    }
    if tense.isCompound, let personNumber, personNumber != .thirdSingular, personNumber != .thirdPlural {
      segments.append(.gender(isFeminine: pronounGender.isFeminine(personNumber)))
    }
    segments.append(.blank)
    if !parts.after.isEmpty {
      segments.append(.context(parts.after))
    }
    return AnswerFrame(segments: segments)
  }

  /// Whether a level asks this sentence: its verb is in the level's band, and its tense is one of
  /// the level's that the verb has.
  @MainActor func isAskable(at level: QuizLevel) -> Bool {
    guard let verb, let slot, let tense, level.slots.contains(slot), verb.hasCell(tense) else {
      return false
    }
    guard let band = level.band else {
      return true
    }
    return verb.isIn(band)
  }
}

enum GapSentences {
  @MainActor private static var loaded: [GapSentence]?

  /// Every sentence in the bundle, drafts included.
  @MainActor static var all: [GapSentence] {
    if let loaded {
      return loaded
    }
    let sentences = Bundle.main.url(forResource: "gap_sentences", withExtension: "json")
      .flatMap { try? Data(contentsOf: $0) }
      .map(decode) ?? []
    loaded = sentences
    return sentences
  }

  static func decode(_ data: Data) -> [GapSentence] {
    (try? JSONDecoder().decode([GapSentence].self, from: data)) ?? []
  }

  // A debug build asks drafts too, marked as drafts on the card, so that a sentence can be tried
  // in the app before it is approved. A release build asks only approved sentences.
  #if DEBUG
  static let includesDrafts = true
  #else
  static let includesDrafts = false
  #endif

  @MainActor static func askable(at level: QuizLevel, from sentences: [GapSentence]? = nil, includesDrafts: Bool = includesDrafts) -> [GapSentence] {
    (sentences ?? all).filter { ($0.reviewed || includesDrafts) && $0.isAskable(at: level) }
  }
}

extension QuizDraw {
  /// A round of sentences: the session's unasked ones first, and one sentence a verb where the
  /// sentences allow, so that a round of ten is not four of être's. A pool smaller than the round
  /// makes a shorter round, and once every sentence has been asked, Ten More asks them again.
  static func sentences(
    from candidates: [GapSentence],
    count: Int,
    excluded: Set<String>,
    using generator: inout some RandomNumberGenerator
  ) -> [GapSentence] {
    let shuffled = candidates.sorted { $0.id < $1.id }.shuffled(using: &generator)
    var round: [GapSentence] = []
    var verbs: Set<String> = []
    for group in [shuffled.filter { !excluded.contains($0.id) }, shuffled.filter { excluded.contains($0.id) }] {
      for sentence in group where round.count < count && !verbs.contains(sentence.verbKey) {
        round.append(sentence)
        verbs.insert(sentence.verbKey)
      }
      for sentence in group where round.count < count && !round.contains(sentence) {
        round.append(sentence)
      }
    }
    return round
  }
}

extension AnswerFrame {
  /// Whether the frame is a sentence's, which is laid out word by word.
  var isSentence: Bool {
    segments.contains { segment in
      if case .context = segment {
        return true
      }
      return false
    }
  }

  /// A sentence's words, split for a layout that wraps between words. The word that touches the
  /// blank without a space, such as j’ or a hyphenated pronoun, stays beside the field.
  var sentenceWords: (before: [String], touchingBefore: String?, touchingAfter: String?, after: [String]) {
    func text(_ segments: [Segment]) -> String {
      segments.compactMap { segment in
        if case .context(let text) = segment {
          return text
        }
        return nil
      }
      .joined()
    }
    let leading = text(leadingSegments)
    let trailing = text(trailingSegments)
    var before = leading.split(separator: " ").map(String.init)
    var after = trailing.split(separator: " ").map(String.init)
    var touchingBefore: String?
    var touchingAfter: String?
    if let last = leading.last, last != " ", !before.isEmpty {
      touchingBefore = before.removeLast()
    }
    if let first = trailing.first, first != " ", !after.isEmpty {
      touchingAfter = after.removeFirst()
    }
    return (before, touchingBefore, touchingAfter, after)
  }
}

extension QuizQuestion {
  init?(sentence: GapSentence) {
    guard let verb = sentence.verb, let tense = sentence.tense else {
      return nil
    }
    self.init(verb: verb, tense: tense, sentence: sentence)
  }
}
