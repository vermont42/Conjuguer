//
//  QuizScope.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// What a quiz asks about, how many questions it asks, and where it was begun.
struct QuizScope {
  /// Nil asks a quiz whose verbs `QuizDraw` mixes from a band: the learner's level's, or the one a
  /// custom quiz chose.
  let verbs: [Verb]?

  let questionCount: Int
  let source: AnalyticsSource

  /// What a sheet's quiz shows in place of "Quiz": a collection's title.
  var title: String?

  /// The collection a quiz over a collection asks about, which `quizStart` names.
  var collection: VerbCollection?

  var custom: CustomQuiz?

  /// A practice set's level, so that everyone who opens the set is asked the same quiz. Nil asks
  /// at the learner's own level.
  var level: QuizLevel?

  /// A practice set's quiz runs in a sheet over the set, as a collection's does.
  var isPracticeSet = false

  /// Review or My Mistakes, which draw from the practice record. Nil for every other quiz.
  var recordSession: QuizRecordSession?

  var isVerbEssentials = false

  /// A model's practice, alone or mixed, which runs in a sheet over the model's page or the hub's
  /// list of models.
  var modelPractice: ModelPracticeSession?

  var isRecognition = false

  var isSentences = false

  var isSpeedRound = false

  var isDaily = false

  /// A day's challenge, the same five questions on every device on the same date.
  var challenge: DailyChallenge.Key?

  /// Only the default quiz posts to its level's leaderboard and sets its best score: a score over
  /// the learner's own verbs, tenses, or practice record, or over three questions, compares with
  /// nothing.
  var isRanked: Bool {
    verbs == nil && custom == nil && recordSession == nil && !isVerbEssentials && modelPractice == nil && !isRecognition && !isSentences && !isSpeedRound && !isDaily && !isChallenge
  }

  /// Review, My Mistakes, and the Speed Round ask whatever the record holds, beyond the level's
  /// tenses and band, and a model's practice asks its ten most frequent verbs at every level, so
  /// their results name no level.
  var asksByLevel: Bool {
    recordSession == nil && modelPractice == nil && !isSpeedRound
  }

  /// A Review or My Mistakes session shorter than ten is as long as the learner's due or missed
  /// items, so its signals carry neither the questions asked nor the question reached: either
  /// would tell how many answers were wrong. A mixed model practice's round is as long as the
  /// known models allow, and which models are known comes from the learner's answers. A Speed
  /// Round's length is how many questions the learner answered in a minute, which measures the
  /// answers themselves.
  var sendsQuestionCounts: Bool {
    recordSession == nil && modelPractice?.mode != .mixed && !isSpeedRound
  }

  /// The default quiz mixes in items the practice record says are due, up to
  /// `QuizDraw.dueItemLimit` a round, and a daily session fills itself with them. A quiz over chosen
  /// verbs or tenses, or a practice set's, asks what was chosen.
  var mixesDueItems: Bool {
    (isRanked && level == nil) || isDaily
  }

  var dueItemLimit: Int {
    isDaily ? questionCount : QuizDraw.dueItemLimit
  }

  /// Only the default quiz, and its Ten More, asks a choice question, one a round from Elementary
  /// up, so that every ranked round of a level asks the same mix.
  var mixesChoiceQuestions: Bool {
    isRanked && level == nil
  }

  /// A practice set's own level wins over `level`, the learner's.
  func slots(at level: QuizLevel) -> [QuizTenseSlot] {
    let level = self.level ?? level
    return custom?.slots(at: level) ?? level.slots
  }

  /// The band a mixed quiz draws from, nil for every verb. A practice set's own level wins over
  /// `level`, the learner's.
  func band(at level: QuizLevel) -> FrequencyBand? {
    let level = self.level ?? level
    guard let verbSet = custom?.verbSet, verbSet.mixesVerbs else {
      return level.band
    }
    return verbSet.band
  }

  /// The collection `quizStart` names: a collection's own quiz, or a custom quiz over one.
  var namedCollection: VerbCollection? {
    collection ?? custom?.verbSet?.collection
  }

  /// Whether the results offer Ten More, or for Verb Essentials five more verbs. Test Me's three
  /// questions are a check, not a session, a Speed Round's results offer a fresh minute instead,
  /// a daily session's next session is one of its own, and a challenge is taken once.
  var continues: Bool {
    !isSpeedRound && !isDaily && !isChallenge && (isVerbEssentials || modelPractice != nil || questionCount == Quiz.questionCount)
  }

  var isVerbPage: Bool {
    source == .verbPage
  }

  /// A quiz on a verb's page is over before a Live Activity would be noticed. A collection's quiz
  /// runs in a sheet over its page, and a tap on the activity would open the Quiz tab instead.
  var startsLiveActivity: Bool {
    (continues || isDaily) && collection == nil && !isPracticeSet
  }

  static let verbPageQuestionCount = 3

  static let allVerbs = QuizScope(verbs: nil, questionCount: Quiz.questionCount, source: .tab)

  static func myVerbs(_ verbs: [Verb]) -> QuizScope {
    QuizScope(verbs: verbs, questionCount: Quiz.questionCount, source: .myVerbs)
  }

  static func verbPage(_ verb: Verb) -> QuizScope {
    QuizScope(verbs: [verb], questionCount: verbPageQuestionCount, source: .verbPage)
  }

  /// The questions of a quiz over `verbs` at `level`. Empty for a mixed quiz, which `Quiz` draws
  /// through `QuizDraw`, and for verbs that have none of the cells the quiz asks.
  func questions(level: QuizLevel, using generator: inout some RandomNumberGenerator) -> [QuizQuestion] {
    guard let verbs, !verbs.isEmpty else {
      return []
    }
    let slots = slots(at: level)
    if questionCount < Quiz.questionCount {
      return Self.distinctCellQuestions(verbs: verbs, slots: slots, count: questionCount, using: &generator)
    }
    return Self.levelMixQuestions(verbs: verbs, slots: slots, count: questionCount, using: &generator)
  }

  /// Tenses drawn by weight from those that some verb has, each question's verb drawn in turn
  /// from a shuffled `verbs`. A cell already asked of a verb is asked again only when no verb has
  /// a fresh one, as happens with a single verb's seven présents.
  private static func levelMixQuestions(
    verbs: [Verb],
    slots: [QuizTenseSlot],
    count: Int,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizQuestion] {
    let deck = verbs.shuffled(using: &generator)
    let askable = slots.filter { slot in
      verbs.contains { verb in
        slot.cells.contains(where: verb.hasCell)
      }
    }
    var cursor = 0
    var asked: Set<AskedCell> = []
    var questions: [QuizQuestion] = []

    while questions.count < count, let slot = QuizTenseSlot.drawWeighted(from: askable, using: &generator) {
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
      guard let question = fresh ?? repeated else {
        break
      }
      questions.append(question)
      asked.insert(AskedCell(verbID: question.verb.id, tense: question.tense))
    }

    return questions
  }

  /// A few questions in different tenses of the level, drawn by weight and without participles,
  /// since a participe passé is tested by any passé composé. A verb that lacks enough tenses is
  /// asked more cells of the tenses it has, and then its participles.
  private static func distinctCellQuestions(
    verbs: [Verb],
    slots levelSlots: [QuizTenseSlot],
    count: Int,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizQuestion] {
    var questions: [QuizQuestion] = []
    let personalSlots = levelSlots.filter { !$0.isParticiple }
    var slots = personalSlots

    while questions.count < count, let slot = QuizTenseSlot.drawWeighted(from: slots, using: &generator) {
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
      func unasked(_ tenses: [Tense]) -> [QuizQuestion] {
        verbs.flatMap { verb in
          tenses
            .filter { verb.hasCell($0) && !asked.contains(AskedCell(verbID: verb.id, tense: $0)) }
            .map { QuizQuestion(verb: verb, tense: $0) }
        }
      }
      let participles = levelSlots.filter(\.isParticiple).flatMap(\.cells)
      let fallbacks = unasked(personalSlots.flatMap(\.cells)).shuffled(using: &generator) + unasked(participles).shuffled(using: &generator)
      questions += fallbacks.prefix(count - questions.count)
    }

    return questions
  }

  private struct AskedCell: Hashable {
    let verbID: String
    let tense: Tense
  }
}

extension Verb {
  func hasCell(_ tense: Tense) -> Bool {
    guard let defectGroupId, let defectGroup = DefectGroup.defectGroups[defectGroupId] else {
      return true
    }
    return !defectGroup.isDefectiveForTense(tense)
  }

  /// Whether a quiz at `level` has anything to ask of this verb. Six verbs use only the
  /// infinitif, and a few have no présent or impératif to ask a beginner.
  func canBeQuizzed(at level: QuizLevel) -> Bool {
    level.slots.flatMap(\.cells).contains(where: hasCell)
  }
}
