//
//  QuizScope.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// What a quiz asks about, how many questions it asks, and where it was begun.
struct QuizScope {
  /// Each place a quiz can start, which decides what is ranked, what continues, what starts a
  /// Live Activity, and which draw runs.
  enum Kind {
    /// The default quiz, the only one ranked.
    case allVerbs
    case myVerbs
    /// Test Me on a verb's page.
    case verbPage
    /// A collection's quiz, in a sheet over its page.
    case collection(VerbCollection)
    case custom(CustomQuiz)
    /// A practice set's quiz, in a sheet over the set. Nil asks at the learner's level.
    case practiceSet(CustomQuiz, level: QuizLevel?)
    /// Review or My Mistakes, which draw from the practice record.
    case recordSession(QuizRecordSession)
    case verbEssentials
    /// A model's practice, alone or mixed, in a sheet over the model's page or the hub's list of
    /// models, asked as Verb Essentials for a model learned verb by verb.
    case modelPractice(ModelPracticeSession, isVerbEssentials: Bool)
    case recognition
    case sentences
    case speedRound
    case daily
    /// A day's challenge, the same five questions on every device on the same date.
    case challenge(DailyChallenge.Key)
  }

  /// Nil asks a quiz whose verbs `QuizDraw` mixes from a band: the learner's level's, or the one a
  /// custom quiz chose.
  let verbs: [Verb]?

  let questionCount: Int
  let source: AnalyticsSource
  let kind: Kind

  /// Only the default quiz posts to its level's leaderboard and sets its best score: a score over
  /// the learner's own verbs, tenses, or practice record, or over three questions, compares with
  /// nothing.
  var isRanked: Bool {
    if case .allVerbs = kind {
      return true
    }
    return false
  }

  /// Review, My Mistakes, and the Speed Round ask whatever the record holds, beyond the level's
  /// tenses and band, and a model's practice asks its ten most frequent verbs at every level, so
  /// their results name no level.
  var asksByLevel: Bool {
    switch kind {
    case .recordSession, .modelPractice, .speedRound:
      return false
    case .allVerbs, .myVerbs, .verbPage, .collection, .custom, .practiceSet, .verbEssentials, .recognition, .sentences, .daily, .challenge:
      return true
    }
  }

  /// A Review or My Mistakes session shorter than ten is as long as the learner's due or missed
  /// items, so its signals carry neither the questions asked nor the question reached: either
  /// would tell how many answers were wrong. A mixed model practice's round is as long as the
  /// known models allow, and which models are known comes from the learner's answers. A Speed
  /// Round's length is how many questions the learner answered in a minute, which measures the
  /// answers themselves.
  var sendsQuestionCounts: Bool {
    switch kind {
    case .recordSession, .speedRound:
      return false
    case .modelPractice(let session, _):
      return session.mode != .mixed
    case .allVerbs, .myVerbs, .verbPage, .collection, .custom, .practiceSet, .verbEssentials, .recognition, .sentences, .daily, .challenge:
      return true
    }
  }

  /// The default quiz mixes in items the practice record says are due, up to
  /// `QuizDraw.dueItemLimit` a round, and a daily session fills itself with them. A quiz over chosen
  /// verbs or tenses, or a practice set's, asks what was chosen.
  var mixesDueItems: Bool {
    switch kind {
    case .allVerbs, .daily:
      return true
    case .myVerbs, .verbPage, .collection, .custom, .practiceSet, .recordSession, .verbEssentials, .modelPractice, .recognition, .sentences, .speedRound, .challenge:
      return false
    }
  }

  var dueItemLimit: Int {
    isDaily ? questionCount : QuizDraw.dueItemLimit
  }

  /// Only the default quiz, and its Ten More, asks a choice question, one a round from Elementary
  /// up, so that every ranked round of a level asks the same mix.
  var mixesChoiceQuestions: Bool {
    isRanked
  }

  /// Whether the results offer Ten More, or for Verb Essentials five more verbs. Test Me's three
  /// questions are a check, not a session, a Speed Round's results offer a fresh minute instead,
  /// a daily session's next session is one of its own, and a challenge is taken once.
  var continues: Bool {
    switch kind {
    case .verbPage, .speedRound, .daily, .challenge:
      return false
    case .allVerbs, .myVerbs, .collection, .custom, .practiceSet, .recordSession, .verbEssentials, .modelPractice, .recognition, .sentences:
      return true
    }
  }

  /// A quiz in a sheet starts no Live Activity, since a tap on the activity would open the Quiz
  /// tab instead, and a Speed Round or a challenge is over before one would be noticed.
  var startsLiveActivity: Bool {
    switch kind {
    case .allVerbs, .myVerbs, .custom, .recordSession, .verbEssentials, .recognition, .sentences, .daily:
      return true
    case .verbPage, .collection, .practiceSet, .modelPractice, .speedRound, .challenge:
      return false
    }
  }

  /// A correction offers the verb's page, except in Test Me, which runs over that page.
  var showsVerbLink: Bool {
    !isVerbPage
  }

  /// A collection's quiz asks the collection's verbs of the learner's band before the rest, since
  /// most of a large model's verbs are rare. My Verbs and a shared list are the learner's or a
  /// teacher's choice, asked as they are.
  var prefersBandVerbs: Bool {
    switch kind {
    case .collection:
      return true
    case .custom(let custom), .practiceSet(let custom, _):
      return custom.verbSet?.collection != nil
    case .allVerbs, .myVerbs, .verbPage, .recordSession, .verbEssentials, .modelPractice, .recognition, .sentences, .speedRound, .daily, .challenge:
      return false
    }
  }

  /// What a sheet's quiz shows in place of "Quiz": a collection's title.
  var title: String? {
    switch kind {
    case .collection(let collection):
      return collection.title
    case .practiceSet:
      return L.PracticeSet.title
    case .modelPractice(let session, _):
      return session.title
    case .allVerbs, .myVerbs, .verbPage, .custom, .recordSession, .verbEssentials, .recognition, .sentences, .speedRound, .daily, .challenge:
      return nil
    }
  }

  /// A practice set's or a challenge's level, so that everyone who opens it is asked the same
  /// quiz. Nil asks at the learner's own level.
  var level: QuizLevel? {
    switch kind {
    case .practiceSet(_, let level):
      return level
    case .challenge(let key):
      return key.level
    case .allVerbs, .myVerbs, .verbPage, .collection, .custom, .recordSession, .verbEssentials, .modelPractice, .recognition, .sentences, .speedRound, .daily:
      return nil
    }
  }

  var custom: CustomQuiz? {
    switch kind {
    case .custom(let custom), .practiceSet(let custom, _):
      return custom
    case .allVerbs, .myVerbs, .verbPage, .collection, .recordSession, .verbEssentials, .modelPractice, .recognition, .sentences, .speedRound, .daily, .challenge:
      return nil
    }
  }

  /// The collection of a collection's own quiz.
  var collection: VerbCollection? {
    if case .collection(let collection) = kind {
      return collection
    }
    return nil
  }

  /// The collection `quizStart` names: a collection's own quiz, a model's practice, or a custom
  /// quiz over one.
  var namedCollection: VerbCollection? {
    switch kind {
    case .collection(let collection):
      return collection
    case .modelPractice(let session, _):
      return session.collection
    case .custom(let custom), .practiceSet(let custom, _):
      return custom.verbSet?.collection
    case .allVerbs, .myVerbs, .verbPage, .recordSession, .verbEssentials, .recognition, .sentences, .speedRound, .daily, .challenge:
      return nil
    }
  }

  var recordSession: QuizRecordSession? {
    if case .recordSession(let session) = kind {
      return session
    }
    return nil
  }

  var modelPractice: ModelPracticeSession? {
    if case .modelPractice(let session, _) = kind {
      return session
    }
    return nil
  }

  var challenge: DailyChallenge.Key? {
    if case .challenge(let key) = kind {
      return key
    }
    return nil
  }

  /// Verb Essentials, or a model's practice asked as Verb Essentials: questions shown as steps of
  /// three.
  var isVerbEssentials: Bool {
    switch kind {
    case .verbEssentials:
      return true
    case .modelPractice(_, let isVerbEssentials):
      return isVerbEssentials
    case .allVerbs, .myVerbs, .verbPage, .collection, .custom, .practiceSet, .recordSession, .recognition, .sentences, .speedRound, .daily, .challenge:
      return false
    }
  }

  var isPracticeSet: Bool {
    if case .practiceSet = kind {
      return true
    }
    return false
  }

  var isVerbPage: Bool {
    if case .verbPage = kind {
      return true
    }
    return false
  }

  var isRecognition: Bool {
    if case .recognition = kind {
      return true
    }
    return false
  }

  var isSentences: Bool {
    if case .sentences = kind {
      return true
    }
    return false
  }

  var isSpeedRound: Bool {
    if case .speedRound = kind {
      return true
    }
    return false
  }

  var isDaily: Bool {
    if case .daily = kind {
      return true
    }
    return false
  }

  var isChallenge: Bool {
    challenge != nil
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

  static let verbPageQuestionCount = 3

  /// The fewest cells a quiz over chosen verbs needs before it is offered: Test Me's length.
  static let minimumCellCount = verbPageQuestionCount

  static let allVerbs = allVerbs(source: .tab)

  /// The default quiz begun from somewhere other than the Quiz tab, such as a link.
  static func allVerbs(source: AnalyticsSource) -> QuizScope {
    QuizScope(verbs: nil, questionCount: Quiz.questionCount, source: source, kind: .allVerbs)
  }

  static func myVerbs(_ verbs: [Verb]) -> QuizScope {
    QuizScope(verbs: verbs, questionCount: Quiz.questionCount, source: .myVerbs, kind: .myVerbs)
  }

  static func verbPage(_ verb: Verb) -> QuizScope {
    QuizScope(verbs: [verb], questionCount: verbPageQuestionCount, source: .verbPage, kind: .verbPage)
  }

  /// How many distinct cells a quiz over `verbs` can ask at `level`, counted up to `limit`. Nil
  /// `verbs`, a mixed quiz, counts as `limit`.
  func askableCellCount(at level: QuizLevel, limit: Int) -> Int {
    guard let verbs else {
      return limit
    }
    return Self.cellCount(of: verbs, slots: slots(at: level), limit: limit)
  }

  /// How many distinct cells of `slots` `verbs` have, counted up to `limit`.
  static func cellCount(of verbs: [Verb], slots: [QuizTenseSlot], limit: Int) -> Int {
    let cells = slots.flatMap(\.cells)
    var count = 0
    for verb in verbs {
      count += cells.count(where: verb.hasCell)
      if count >= limit {
        return limit
      }
    }
    return count
  }

  /// Whether a quiz over chosen verbs has enough to ask at `level` to be offered.
  func hasEnoughCells(at level: QuizLevel) -> Bool {
    askableCellCount(at: level, limit: Self.minimumCellCount) >= Self.minimumCellCount
  }

  /// Whether some cell of the scope's verbs at `level` is not among `asked`, which Ten More needs.
  func hasUnaskedCell(at level: QuizLevel, asked: [QuizQuestion]) -> Bool {
    guard let verbs else {
      return true
    }
    let asked = Set(asked.map(AskedCell.init))
    let cells = slots(at: level).flatMap(\.cells)
    return verbs.contains { verb in
      cells.contains { verb.hasCell($0) && !asked.contains(AskedCell(verbID: verb.id, tense: $0)) }
    }
  }

  /// The questions of a quiz over `verbs` at `level`, none a cell of `asked`, the session's
  /// questions so far. A round is as long as the unasked cells allow, so it may be shorter than
  /// `questionCount`. Empty for a mixed quiz, which `Quiz` draws through `QuizDraw`, and for verbs
  /// that have none of the cells the quiz asks.
  func questions(level: QuizLevel, asked: [QuizQuestion], using generator: inout some RandomNumberGenerator) -> [QuizQuestion] {
    guard let verbs, !verbs.isEmpty else {
      return []
    }
    let slots = slots(at: level)
    if questionCount < Quiz.questionCount {
      return Self.distinctCellQuestions(verbs: verbs, slots: slots, count: questionCount, using: &generator)
    }
    let deck = Self.deck(of: verbs, asked: Set(asked.map(\.verb.id)), band: prefersBandVerbs ? band(at: level) : nil, using: &generator)
    return Self.levelMixQuestions(deck: deck, slots: slots, count: questionCount, asked: Set(asked.map(AskedCell.init)), using: &generator)
  }

  /// The verbs in the order a round takes them: those the session has not asked before those it
  /// has, and within each, those of `band` first. Each group is shuffled.
  private static func deck(
    of verbs: [Verb],
    asked: Set<String>,
    band: FrequencyBand?,
    using generator: inout some RandomNumberGenerator
  ) -> [Verb] {
    let groups = Dictionary(grouping: verbs) { verb in
      let isInBand = band.map(verb.isIn) ?? true
      return (asked.contains(verb.id) ? 2 : 0) + (isInBand ? 0 : 1)
    }
    return (0 ... 3).flatMap { groups[$0, default: []].shuffled(using: &generator) }
  }

  /// Tenses drawn by weight from those that some verb has unasked, each question's verb taken in
  /// turn from `deck`. A cell is never asked twice: a tense whose cells are all asked is drawn no
  /// more, and the round ends early when every tense is spent.
  private static func levelMixQuestions(
    deck: [Verb],
    slots: [QuizTenseSlot],
    count: Int,
    asked earlier: Set<AskedCell>,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizQuestion] {
    var asked = earlier
    func freshCells(of slot: QuizTenseSlot, for verb: Verb) -> [Tense] {
      slot.cells.filter { verb.hasCell($0) && !asked.contains(AskedCell(verbID: verb.id, tense: $0)) }
    }
    var askable = slots.filter { slot in
      deck.contains { !freshCells(of: slot, for: $0).isEmpty }
    }
    var cursor = 0
    var questions: [QuizQuestion] = []

    while questions.count < count, let slot = QuizTenseSlot.drawWeighted(from: askable, using: &generator) {
      var question: QuizQuestion?
      for _ in 0 ..< deck.count {
        let verb = deck[cursor]
        cursor = (cursor + 1) % deck.count
        if let tense = freshCells(of: slot, for: verb).randomElement(using: &generator) {
          question = QuizQuestion(verb: verb, tense: tense)
          break
        }
      }
      guard let question else {
        askable.removeAll { $0 == slot }
        continue
      }
      questions.append(question)
      asked.insert(AskedCell(question))
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

    init(verbID: String, tense: Tense) {
      self.verbID = verbID
      self.tense = tense
    }

    init(_ question: QuizQuestion) {
      self.init(verbID: question.verb.id, tense: question.tense)
    }
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
