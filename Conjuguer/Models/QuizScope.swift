//
//  QuizScope.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// What a quiz asks about, how many questions it asks, and where it was begun. Later work adds
/// scopes as constructors: browse Phase 14's collections, and the pedagogy plan's levels.
struct QuizScope {
  /// Nil asks the default quiz, built from `QuizVerbs` at the learner's difficulty.
  let verbs: [Verb]?

  let questionCount: Int
  let source: AnalyticsSource

  /// Only the default quiz posts to the leaderboard and sets the best score, as Josh decided for
  /// Konjugieren on 2026-11-13: a score over the learner's own verbs, or over three questions,
  /// compares with nothing.
  var isRanked: Bool {
    verbs == nil
  }

  /// A quiz on a verb's page is over before a Live Activity would be noticed.
  var startsLiveActivity: Bool {
    questionCount == Quiz.questionCount
  }

  static let verbPageQuestionCount = 3

  static let allVerbs = QuizScope(verbs: nil, questionCount: Quiz.questionCount, source: .tab)

  static func myVerbs(_ verbs: [Verb]) -> QuizScope {
    QuizScope(verbs: verbs, questionCount: Quiz.questionCount, source: .myVerbs)
  }

  static func verbPage(_ verb: Verb) -> QuizScope {
    QuizScope(verbs: [verb], questionCount: verbPageQuestionCount, source: .verbPage)
  }

  /// The questions of a quiz over `verbs`. Empty for the default quiz, which `Quiz` builds itself,
  /// and for verbs that have none of the cells a quiz asks.
  func questions(using generator: inout some RandomNumberGenerator) -> [QuizQuestion] {
    guard let verbs, !verbs.isEmpty else {
      return []
    }
    if questionCount < Quiz.questionCount {
      return Self.distinctCellQuestions(verbs: verbs, count: questionCount, using: &generator)
    }
    return Self.regularMixQuestions(verbs: verbs, using: &generator)
  }

  /// Regular's tense mix, each question's verb drawn in turn from a shuffled `verbs`. A cell
  /// already asked of a verb is asked again only when no verb has a fresh one, as happens with a
  /// single verb's seven présents. A tense that no verb has is dropped, so the quiz is shorter.
  private static func regularMixQuestions(verbs: [Verb], using generator: inout some RandomNumberGenerator) -> [QuizQuestion] {
    let deck = verbs.shuffled(using: &generator)
    var cursor = 0
    var asked: Set<AskedCell> = []
    var questions: [QuizQuestion] = []

    for slot in QuizTenseSlot.allCases {
      for _ in 0 ..< slot.regularQuota {
        var fresh: QuizQuestion?
        var repeated: QuizQuestion?
        for _ in 0 ..< deck.count {
          let verb = deck[cursor]
          cursor = (cursor + 1) % deck.count
          let cells = slot.cells.filter(verb.hasCell)
          if let tense = cells.filter({ !asked.contains(AskedCell(verbID: verb.id, tense: $0)) }).randomElement(using: &generator) {
            fresh = QuizQuestion(verb: verb, tense: tense)
            break
          }
          if repeated == nil, let tense = cells.randomElement(using: &generator) {
            repeated = QuizQuestion(verb: verb, tense: tense)
          }
        }
        if let question = fresh ?? repeated {
          questions.append(question)
          asked.insert(AskedCell(verbID: question.verb.id, tense: question.tense))
        }
      }
    }

    questions.shuffle(using: &generator)
    return questions
  }

  /// A few questions in different tenses, drawn with Regular's weights and without participles,
  /// since a participe passé is tested by any passé composé. A verb that lacks enough tenses is
  /// asked more cells of the tenses it has, and then its participles.
  private static func distinctCellQuestions(verbs: [Verb], count: Int, using generator: inout some RandomNumberGenerator) -> [QuizQuestion] {
    var questions: [QuizQuestion] = []
    var slots = QuizTenseSlot.allCases.filter { $0 != .participePrésent }

    while questions.count < count, let slot = drawWeighted(from: slots, using: &generator) {
      slots.removeAll { $0 == slot }
      let candidates = verbs.flatMap { verb in
        slot.cells.filter(verb.hasCell).map { QuizQuestion(verb: verb, tense: $0) }
      }
      if let question = candidates.randomElement(using: &generator) {
        questions.append(question)
      }
    }

    if questions.count < count {
      let asked = Set(questions.map { AskedCell(verbID: $0.verb.id, tense: $0.tense) })
      let personal = QuizTenseSlot.allCases.filter { $0 != .participePrésent }.flatMap(\.cells)
      func unasked(_ tenses: [Tense]) -> [QuizQuestion] {
        verbs.flatMap { verb in
          tenses
            .filter { verb.hasCell($0) && !asked.contains(AskedCell(verbID: verb.id, tense: $0)) }
            .map { QuizQuestion(verb: verb, tense: $0) }
        }
      }
      let fallbacks = unasked(personal).shuffled(using: &generator) + unasked([.participePassé, .participePrésent]).shuffled(using: &generator)
      questions += fallbacks.prefix(count - questions.count)
    }

    return questions
  }

  private static func drawWeighted(from slots: [QuizTenseSlot], using generator: inout some RandomNumberGenerator) -> QuizTenseSlot? {
    let total = slots.reduce(0) { $0 + $1.regularQuota }
    guard total > 0 else {
      return nil
    }
    var roll = Int.random(in: 0 ..< total, using: &generator)
    for slot in slots {
      if roll < slot.regularQuota {
        return slot
      }
      roll -= slot.regularQuota
    }
    return nil
  }

  private struct AskedCell: Hashable {
    let verbID: String
    let tense: Tense
  }
}

/// The tenses of the Regular quiz, with how many questions it asks of each. `Quiz.buildQuiz` asks
/// these quotas from its curated pools; a scoped quiz asks them of its own verbs.
enum QuizTenseSlot: CaseIterable {
  case indicatifPrésent
  case passéComposé
  case subjonctifPrésent
  case imparfait
  case futurSimple
  case conditionnelPrésent
  case impératif
  case participePrésent

  init?(tense: Tense) {
    switch tense {
    case .indicatifPrésent:
      self = .indicatifPrésent
    case .passéComposé:
      self = .passéComposé
    case .subjonctifPrésent:
      self = .subjonctifPrésent
    case .imparfait:
      self = .imparfait
    case .futurSimple:
      self = .futurSimple
    case .conditionnelPrésent:
      self = .conditionnelPrésent
    case .impératif:
      self = .impératif
    case .participePrésent:
      self = .participePrésent
    default:
      return nil
    }
  }

  var regularQuota: Int {
    switch self {
    case .indicatifPrésent:
      return 7
    case .passéComposé:
      return 6
    case .subjonctifPrésent:
      return 4
    case .imparfait, .futurSimple, .conditionnelPrésent, .impératif:
      return 3
    case .participePrésent:
      return 1
    }
  }

  var cells: [Tense] {
    switch self {
    case .indicatifPrésent:
      return PersonNumber.allCases.map(Tense.indicatifPrésent)
    case .passéComposé:
      return PersonNumber.allCases.map(Tense.passéComposé)
    case .subjonctifPrésent:
      return PersonNumber.allCases.map(Tense.subjonctifPrésent)
    case .imparfait:
      return PersonNumber.allCases.map(Tense.imparfait)
    case .futurSimple:
      return PersonNumber.allCases.map(Tense.futurSimple)
    case .conditionnelPrésent:
      return PersonNumber.allCases.map(Tense.conditionnelPrésent)
    case .impératif:
      return PersonNumber.impératifPersonNumbers.map(Tense.impératif)
    case .participePrésent:
      return [.participePrésent]
    }
  }
}

extension Verb {
  /// Whether the verb has `tense`'s cell, which its defect group can lack.
  func hasCell(_ tense: Tense) -> Bool {
    guard let defectGroupId, let defectGroup = DefectGroup.defectGroups[defectGroupId] else {
      return true
    }
    return !defectGroup.isDefectiveForTense(tense)
  }

  /// Whether a quiz on this verb's page has anything to ask. Six verbs use only the infinitif.
  var canBeQuizzed: Bool {
    QuizTenseSlot.allCases.flatMap(\.cells).contains(where: hasCell) || hasCell(.participePassé)
  }
}
