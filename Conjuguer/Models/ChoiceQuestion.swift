//
//  ChoiceQuestion.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation

/// A setting and the same sentence in two tenses or moods, of which the learner picks the one a
/// French speaker or writer would use: "Si j’{avais} plus de temps" over "Si j’{aurais} plus de
/// temps". The items live in `choice_questions.json`. Claude drafts them, `ChoiceQuestionTests`
/// confirms both sentences against the Conjugator, and each is reread before it ships, which
/// `reviewed` records.
struct ChoiceQuestion: Decodable, Identifiable, Hashable {
  struct Option: Decodable, Hashable {
    /// A `QuizTenseSlot` case name.
    let tenseKey: String
    /// The sentence, with the conjugation in braces.
    let french: String

    private enum CodingKeys: String, CodingKey {
      case french = "fr"
      case tenseKey = "tense"
    }
  }

  let id: String
  /// A key of `Verb.verbs`.
  let verbKey: String
  /// A `PersonNumber` raw value, which both sentences share.
  let personKey: String
  /// "f" or "m" where an être verb's agreement shows in either sentence.
  let genderKey: String?
  let settingKey: String
  let reasonKey: String
  let right: Option
  let other: Option
  let english: String
  let reviewed: Bool

  private enum CodingKeys: String, CodingKey {
    case english = "en"
    case genderKey = "gender"
    case id
    case other
    case personKey = "person"
    case reasonKey = "reason"
    case reviewed
    case right
    case settingKey = "setting"
    case verbKey = "verb"
  }

  var setting: ChoiceSetting? {
    ChoiceSetting(rawValue: settingKey)
  }

  var reason: ChoiceReason? {
    ChoiceReason(rawValue: reasonKey)
  }

  /// The right sentence, read as a Phrases à trous sentence reads, so that one machine check
  /// confirms both.
  var rightSentence: GapSentence {
    sentence(right, suffix: "right")
  }

  var otherSentence: GapSentence {
    sentence(other, suffix: "other")
  }

  private func sentence(_ option: Option, suffix: String) -> GapSentence {
    GapSentence(
      id: "\(id).\(suffix)",
      verbKey: verbKey,
      tenseKey: option.tenseKey,
      personKey: personKey,
      genderKey: genderKey,
      french: option.french,
      english: english,
      reviewed: reviewed
    )
  }

  /// Whether a level asks this item: its reason's level or a later one, which asks the right
  /// sentence's verb in its tense. The other sentence's tense may be one the level does not ask,
  /// since the learner reads it and is never asked to write it.
  @MainActor func isAskable(at level: QuizLevel) -> Bool {
    guard
      let from = reason.flatMap({ QuizLevel.allCases.firstIndex(of: $0.level) }),
      let at = QuizLevel.allCases.firstIndex(of: level),
      at >= from
    else {
      return false
    }
    return rightSentence.isAskable(at: level)
  }
}

/// Where the sentence is said or written, shown in French with its English gloss, as a verb is.
enum ChoiceSetting: String, CaseIterable {
  case conversation
  case request
  case story
  case history

  var french: String {
    switch self {
    case .conversation:
      return "Dans une conversation"
    case .request:
      return "Pour demander poliment"
    case .story:
      return "Dans un récit écrit"
    case .history:
      return "Dans un livre d’histoire"
    }
  }

  var english: String {
    switch self {
    case .conversation:
      return "In conversation"
    case .request:
      return "Asking politely"
    case .story:
      return "In a written story"
    case .history:
      return "In a history book"
    }
  }
}

/// Why a speaker or writer uses the right sentence's tense or mood. Few reasons serve many items,
/// so each is written and translated once, in `Localizable.xcstrings`. A reason fixes the level
/// from which its items are asked and the tenses its two sentences may take.
enum ChoiceReason: String, CaseIterable {
  case completedEvent
  case pastDescription
  case pastHabit
  case actionInProgress
  case siImparfait
  case conditionnelAfterSi
  case futurAfterSiPrésent
  case politeRequest
  case necessity
  case wish
  case emotion
  case conjunction
  case doubt
  case certainty
  case hope
  case siPlusQueParfait
  case passéSimpleInWriting
  case passéComposéInSpeech

  var level: QuizLevel {
    switch self {
    case .completedEvent, .pastDescription, .pastHabit, .actionInProgress, .siImparfait, .conditionnelAfterSi, .futurAfterSiPrésent, .politeRequest:
      return .elementary
    case .necessity, .wish, .emotion, .conjunction, .doubt, .certainty, .hope, .siPlusQueParfait:
      return .intermediate
    case .passéSimpleInWriting, .passéComposéInSpeech:
      return .advanced
    }
  }

  var rightSlots: [QuizTenseSlot] {
    switch self {
    case .completedEvent, .passéComposéInSpeech:
      return [.passéComposé]
    case .pastDescription, .pastHabit, .actionInProgress, .siImparfait:
      return [.imparfait]
    case .conditionnelAfterSi, .politeRequest:
      return [.conditionnelPrésent]
    case .futurAfterSiPrésent:
      return [.futurSimple]
    case .necessity, .wish, .emotion, .conjunction, .doubt:
      return [.subjonctifPrésent]
    case .certainty, .hope:
      return [.indicatifPrésent, .futurSimple]
    case .siPlusQueParfait:
      return [.plusQueParfait]
    case .passéSimpleInWriting:
      return [.passéSimple]
    }
  }

  var otherSlots: [QuizTenseSlot] {
    switch self {
    case .completedEvent:
      return [.imparfait]
    case .pastDescription, .pastHabit, .actionInProgress, .passéSimpleInWriting:
      return [.passéComposé]
    case .siImparfait, .futurAfterSiPrésent:
      return [.conditionnelPrésent]
    case .conditionnelAfterSi:
      return [.futurSimple]
    case .politeRequest, .necessity, .wish, .emotion, .conjunction, .doubt:
      return [.indicatifPrésent]
    case .certainty, .hope:
      return [.subjonctifPrésent]
    case .siPlusQueParfait:
      return [.conditionnelPassé]
    case .passéComposéInSpeech:
      return [.passéSimple]
    }
  }

  var line: String {
    switch self {
    case .completedEvent:
      return L.Choice.reasonCompletedEvent
    case .pastDescription:
      return L.Choice.reasonPastDescription
    case .pastHabit:
      return L.Choice.reasonPastHabit
    case .actionInProgress:
      return L.Choice.reasonActionInProgress
    case .siImparfait:
      return L.Choice.reasonSiImparfait
    case .conditionnelAfterSi:
      return L.Choice.reasonConditionnelAfterSi
    case .futurAfterSiPrésent:
      return L.Choice.reasonFuturAfterSiPresent
    case .politeRequest:
      return L.Choice.reasonPoliteRequest
    case .necessity:
      return L.Choice.reasonNecessity
    case .wish:
      return L.Choice.reasonWish
    case .emotion:
      return L.Choice.reasonEmotion
    case .conjunction:
      return L.Choice.reasonConjunction
    case .doubt:
      return L.Choice.reasonDoubt
    case .certainty:
      return L.Choice.reasonCertainty
    case .hope:
      return L.Choice.reasonHope
    case .siPlusQueParfait:
      return L.Choice.reasonSiPlusQueParfait
    case .passéSimpleInWriting:
      return L.Choice.reasonPasseSimpleInWriting
    case .passéComposéInSpeech:
      return L.Choice.reasonPasseComposeInSpeech
    }
  }
}

/// A choice as asked: the item, and which of the two places shows the right sentence, so that the
/// right one is not always first.
struct ChoicePrompt: Hashable {
  let question: ChoiceQuestion
  let rightIndex: Int

  var options: [GapSentence] {
    rightIndex == 0 ? [question.rightSentence, question.otherSentence] : [question.otherSentence, question.rightSentence]
  }
}

enum ChoiceQuestions {
  @MainActor private static var loaded: [ChoiceQuestion]?

  /// Every item in the bundle, drafts included.
  @MainActor static var all: [ChoiceQuestion] {
    if let loaded {
      return loaded
    }
    let items = Bundle.main.url(forResource: "choice_questions", withExtension: "json")
      .flatMap { try? Data(contentsOf: $0) }
      .map(decode) ?? []
    loaded = items
    return items
  }

  static func decode(_ data: Data) -> [ChoiceQuestion] {
    (try? JSONDecoder().decode([ChoiceQuestion].self, from: data)) ?? []
  }

  /// The items a level asks. A debug build asks drafts too, as Phrases à trous does.
  @MainActor static func askable(at level: QuizLevel, from items: [ChoiceQuestion]? = nil, includesDrafts: Bool = GapSentences.includesDrafts) -> [ChoiceQuestion] {
    (items ?? all).filter { ($0.reviewed || includesDrafts) && $0.isAskable(at: level) }
  }
}

extension QuizDraw {
  /// One choice for a round, from those the session has not asked, or from all once every one has
  /// been. Nil when the level has none, as Beginner has none.
  static func choice(
    from candidates: [ChoiceQuestion],
    excluded: Set<String>,
    using generator: inout some RandomNumberGenerator
  ) -> ChoicePrompt? {
    let sorted = candidates.sorted { $0.id < $1.id }
    let unasked = sorted.filter { !excluded.contains($0.id) }
    guard let question = (unasked.isEmpty ? sorted : unasked).randomElement(using: &generator) else {
      return nil
    }
    return ChoicePrompt(question: question, rightIndex: Int.random(in: 0...1, using: &generator))
  }

  /// Where a round's choice goes: anywhere but first, so that a round opens on a typed question
  /// with the keyboard up.
  static func choicePosition(in count: Int, using generator: inout some RandomNumberGenerator) -> Int {
    count < 1 ? count : Int.random(in: 1...count, using: &generator)
  }
}

extension QuizQuestion {
  /// A choice question: the item's verb and the right sentence's cell, whose conjugation the
  /// results show as the answer. Nil for an item whose verb or cells this version cannot read.
  init?(choice: ChoicePrompt) {
    let right = choice.question.rightSentence
    guard let verb = right.verb, let tense = right.tense, choice.question.otherSentence.tense != nil else {
      return nil
    }
    self.init(verb: verb, tense: tense, choice: choice)
  }
}
