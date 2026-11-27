//
//  SpeedRound.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation

/// Sixty seconds of questions on what the practice record says is mastered, counting right
/// answers: speed for material already accurate, and the one place where the quiz's clock counts.
///
/// The round leaves the record untouched. A miss does not send an item down the ladder, since
/// speed errors are often haste, and a record that counted only a timed round's hits would be
/// one-sided.
enum SpeedRound {
  static let duration = 60

  /// The round opens once this many items are mastered, and repeats them as a round needs.
  static let minimumMasteredCount = 5

  /// Nobody knows in advance how many questions a learner answers in a minute, so the round draws
  /// this many at a time, and more as it reaches the last of them.
  static let batchSize = 10

  static let warningSecondsLeft = 10

  /// In key order, so that a seeded draw is the same in every process.
  static func masteredItems(in record: PracticeRecord) -> [PracticeItem] {
    record.entries
      .filter { $0.value.schedule.box >= MasteryState.masteredBox }
      .keys
      .sorted()
      .compactMap(PracticeItem.init(key:))
      .filter(\.isAskable)
  }

  /// The record's mastered items, or in DEBUG, with `-CONJUGUER_QUIZ_FIXTURE speedRound`, a fixed
  /// eight that open the round whatever the record holds.
  static func items(from practice: PracticeStore) -> [PracticeItem] {
    #if DEBUG
    if UserDefaults.standard.string(forKey: "CONJUGUER_QUIZ_FIXTURE") == "speedRound" {
      return fixtureItems
    }
    #endif
    return masteredItems(in: practice.record)
  }

  #if DEBUG
  // A pattern of each family, manger's spelling change, an être pattern, and four irregular verbs'
  // key conjugations. The cells are listed in docs/feature_architecture.md § Speed Round.
  static var fixtureItems: [PracticeItem] {
    let plan: [(infinitif: String, tense: Tense)] = [
      ("parler", .indicatifPrésent(.firstSingular)),
      ("finir", .indicatifPrésent(.firstPlural)),
      ("rendre", .imparfait(.thirdPlural)),
      ("manger", .indicatifPrésent(.firstPlural)),
      ("arriver", .passéComposé(.thirdSingular)),
      ("venir", .indicatifPrésent(.thirdSingular)),
      ("faire", .futurSimple(.thirdSingular)),
      ("être", .indicatifPrésent(.thirdSingular))
    ]
    return plan.map { PracticeItem.exercised(by: $0.tense, of: Verb.verbForInfinitif($0.infinitif)) }
  }
  #endif
}

/// A Speed Round's missed question as the next one shows it: "venir · il vient".
struct SpeedRoundMiss: Equatable {
  let infinitif: String
  /// Mixed case, as the Conjugator writes it, with the frame's pronoun or addressee around it.
  let answer: String

  init(question: QuizQuestion, correctAnswers: String) {
    infinitif = question.verb.infinitifWithPossibleExtraLetters
    let first = correctAnswers.components(separatedBy: Tense.alternateConjugationSeparator).first ?? correctAnswers
    answer = question.answerFrame.writtenOut(with: first)
  }
}

extension AnswerFrame {
  /// The frame with `answer` in its blank, as it would be written: j'aime, (tu) viens !, je me
  /// souviens. A gender, which the written form already shows, is left out.
  func writtenOut(with answer: String) -> String {
    var text = ""
    func append(_ word: String) {
      if !text.isEmpty, !text.hasSuffix("'") {
        text += " "
      }
      text += word
    }
    for segment in segments {
      switch segment {
      case .addressee(let addressee):
        append("(\(addressee))")
      case .blank:
        append(answer)
      case .context(let context):
        text += context
      case .gender:
        continue
      case .pronoun(let pronoun):
        append(pronoun)
      case .punctuation(let mark):
        text += "\u{202F}" + mark
      case .reflexiveSuffix(let suffix):
        text += suffix
      }
    }
    return text
  }
}

extension QuizScope {
  /// From the hub's Exercises. Never ranked, never continued, and mixing in nothing.
  static let speedRound = QuizScope(verbs: nil, questionCount: SpeedRound.batchSize, source: .speedRound, kind: .speedRound)
}

extension QuizDraw {
  /// `count` questions on mastered items, each item asked once before any is asked again, and never
  /// the same item twice running, `previous` included, which is the last question of the batch
  /// before. A key conjugation asks any cell of its stem that `slots` ask of its verb, as
  /// `PracticeItem.exercised(by:of:)` credits them, or its own il cell, which is what was mastered:
  /// mastered vient can ask nous venions at Elementary. A pattern asks its cell of a verb from
  /// `band` that shares it, a different one each time where the band has more than one, or of any
  /// verb where the band has none. Neither is held to the level otherwise, since a mastered item
  /// stays mastered when the level changes.
  @MainActor static func speedRoundQuestions(
    for items: [PracticeItem],
    slots: [QuizTenseSlot],
    band: FrequencyBand?,
    count: Int,
    after previous: PracticeItem? = nil, // swiftlint:disable:this function_default_parameter_at_end
    using generator: inout some RandomNumberGenerator
  ) -> [QuizQuestion] {
    var bandVerbs: [Verb]?
    var everyVerb: [Verb]?
    var patternVerbsByItem: [String: [Verb]] = [:]
    var lastVerbByItem: [String: String] = [:]
    var askable = items
    var drawn: [QuizQuestion] = []
    var last = previous

    func patternVerbs(for item: PracticeItem, tense: Tense) -> [Verb] {
      if let cached = patternVerbsByItem[item.key] {
        return cached
      }
      let inBand = bandVerbs ?? verbs(in: band).filter { !excludedEntries.contains($0.dictionaryKey) }
      bandVerbs = inBand
      var fitting = QuizDraw.patternVerbs(for: item, tense: tense, from: inBand)
      if fitting.isEmpty {
        let all = everyVerb ?? verbs(in: nil).filter { !excludedEntries.contains($0.dictionaryKey) }
        everyVerb = all
        fitting = QuizDraw.patternVerbs(for: item, tense: tense, from: all)
      }
      patternVerbsByItem[item.key] = fitting
      return fitting
    }

    func question(for item: PracticeItem) -> QuizQuestion? {
      switch item {
      case let .keyConjugation(_, stem):
        guard let verb = item.verb, let cell = speedRoundCells(of: stem, verb: verb, slots: slots).randomElement(using: &generator) else {
          return nil
        }
        return QuizQuestion(verb: verb, tense: cell)
      case .pattern:
        guard let tense = item.tense else {
          return nil
        }
        let candidates = patternVerbs(for: item, tense: tense)
        let fresh = candidates.count > 1 ? candidates.filter { $0.id != lastVerbByItem[item.key] } : candidates
        guard let verb = fresh.randomElement(using: &generator) else {
          return nil
        }
        lastVerbByItem[item.key] = verb.id
        return QuizQuestion(verb: verb, tense: tense)
      }
    }

    while drawn.count < count, !askable.isEmpty {
      var cycle = askable.shuffled(using: &generator)
      if cycle.count > 1, let last, cycle.first == last {
        cycle.swapAt(0, Int.random(in: 1 ..< cycle.count, using: &generator))
      }
      for item in cycle where drawn.count < count {
        guard let question = question(for: item) else {
          askable.removeAll { $0 == item }
          continue
        }
        drawn.append(question)
        last = item
      }
    }
    return drawn
  }

  /// The cells a mastered key conjugation can ask: its own, and every cell of `slots` built on the
  /// same stem that the slot asks of this verb and the verb has.
  @MainActor static func speedRoundCells(of stem: PracticeItem.Stem, verb: Verb, slots: [QuizTenseSlot]) -> [Tense] {
    var cells = [stem.keyTense]
    for slot in slots where slot.verbPools.contains(where: { $0.admits(verb) }) {
      cells += slot.cells.filter { PracticeItem.Stem($0) == stem && verb.hasCell($0) && !cells.contains($0) }
    }
    return cells
  }
}
