//
//  ModelPractice.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// A conjugation model as its practice sees it: one model alone, then mixed with the models the
/// learner already knows. Practicing a pattern alone before mixing it did better in Pan et al.
/// (2019); for conjugation models as such there is no study, so this is a bet.
///
/// A model learned verb by verb (aller and the third group but rendre's family) is practiced
/// through Verb Essentials over its verbs. A spelling-change model (manger, appeler, céder) is
/// practiced through the cells its change marks (nous mangeons, j'appelle, j'appellerai), since
/// its other cells are parler's. The three bases have no practice of their own, since every quiz
/// asks them, and neither does a model whose change marks fewer than `minimumMarkedCells`.
struct ModelPractice: Identifiable {
  enum Kind {
    case verbEssentials
    case markedCells
  }

  /// A model is its ten most frequent verbs, at every level, for what its practice asks and for
  /// what "half of its items" counts, so that a round or two can make a model known.
  static let verbLimit = 10
  static let minimumMarkedCells = 5

  let modelID: String
  let kind: Kind
  /// The most frequent first.
  let verbs: [Verb]
  /// For a spelling-change model, the cells its change marks, in the verb page's order. Empty for
  /// a model practiced through Verb Essentials.
  let cells: [Tense]

  var id: String {
    modelID
  }

  var model: VerbModel? {
    VerbModel.models[modelID]
  }

  var exemplar: String {
    model?.exemplarWithPossibleExtraLetters ?? modelID
  }

  var collection: VerbCollection {
    .model(modelID)
  }

  /// One verb is not a pattern, so a single-verb model is not practiced alone. It joins other
  /// models' mixes once it is known.
  var offersPracticeAlone: Bool {
    verbs.count > 1
  }

  /// What `isKnown(in:)` counts: three key conjugations a verb for Verb Essentials, and one pattern
  /// a cell for a spelling-change model.
  var items: [PracticeItem] {
    switch kind {
    case .verbEssentials:
      return verbs.flatMap { verb in
        PracticeItem.Stem.shown.map { PracticeItem.keyConjugation(verb: verb.dictionaryKey, stem: $0) }
      }
    case .markedCells:
      guard let verb = verbs.first else {
        return []
      }
      return cells.map { PracticeItem.exercised(by: $0, of: verb) }
    }
  }

  /// A model is known once at least half of its items have moved past the first box. Nothing is
  /// stored, so a wrong answer, which sends an item back to the first box, can make a model
  /// unknown again.
  func isKnown(in record: PracticeRecord) -> Bool {
    let items = items
    guard !items.isEmpty else {
      return false
    }
    let climbed = items.filter(record.isPastFirstBox).count
    return 2 * climbed >= items.count
  }

  /// The models a mix adds to this one: every other known model of the same kind, since Verb
  /// Essentials' steps and a spelling change's single questions are different exercises. Mixed
  /// opens once there is one, whether or not this model is known, since nothing here is earned.
  func mixPartners(in record: PracticeRecord) -> [ModelPractice] {
    Self.all.filter { $0.kind == kind && $0.modelID != modelID && $0.isKnown(in: record) }
  }

  /// Every model with a practice, alone or as a partner, in `verbModels.xml`'s order. Built once,
  /// since the verbs do not change after launch.
  @MainActor static var all: [ModelPractice] {
    if let cachedAll {
      return cachedAll
    }
    let practices = VerbModel.models.values
      .sorted { $0.position < $1.position }
      .compactMap { model in
        practice(modelID: model.id, verbs: model.entriesByFrequency)
      }
    cachedAll = practices
    return practices
  }

  @MainActor private static var cachedAll: [ModelPractice]?

  @MainActor static func practice(_ modelID: String) -> ModelPractice? {
    all.first { $0.modelID == modelID }
  }

  /// The models that can be practiced alone, the most used first, by each model's most frequent
  /// verb: venir and mettre before bouillir. This is the hub's list.
  @MainActor static var practicedAloneByUse: [ModelPractice] {
    all
      .filter(\.offersPracticeAlone)
      .sorted { ($0.verbs.first?.frequency ?? .max) < ($1.verbs.first?.frequency ?? .max) }
  }

  /// Why a model's page offers no practice of its own.
  enum Absence {
    case base
    case fewMarkedCells
    case singleVerb
  }

  /// Nil for a model practiced alone, and for one with nothing to ask at all (gésir).
  @MainActor static func absence(of modelID: String) -> Absence? {
    if let practice = practice(modelID) {
      return practice.offersPracticeAlone ? nil : .singleVerb
    }
    if PracticeItem.patternBases.contains(modelID) {
      return .base
    }
    guard let verb = VerbModel.models[modelID]?.entriesByFrequency.first, PracticeItem.isLearnedByPattern(verb) else {
      return nil
    }
    return .fewMarkedCells
  }

  /// The exemplar of the family a spelling-change model departs from: parler, finir, or rendre.
  /// Nil for a model learned verb by verb.
  @MainActor static func baseExemplar(of modelID: String) -> String? {
    guard
      let verb = VerbModel.models[modelID]?.entriesByFrequency.first,
      let base = PracticeItem.patternBase(of: verb)
    else {
      return nil
    }
    return VerbModel.models[base]?.exemplarWithPossibleExtraLetters
  }

  @MainActor private static func practice(modelID: String, verbs modelVerbs: [Verb]) -> ModelPractice? {
    guard let first = modelVerbs.first else {
      return nil
    }
    guard PracticeItem.isLearnedByPattern(first) else {
      let verbs = Array(modelVerbs.filter(\.isAskedByVerbEssentials).prefix(verbLimit))
      return verbs.isEmpty ? nil : ModelPractice(modelID: modelID, kind: .verbEssentials, verbs: verbs, cells: [])
    }
    guard !PracticeItem.patternBases.contains(modelID) else {
      return nil
    }
    let verbs = Array(modelVerbs.filter { !QuizDraw.excludedEntries.contains($0.dictionaryKey) }.prefix(verbLimit))
    guard let verb = verbs.first else {
      return nil
    }
    let cells = Tense.allConcreteCases.filter { tense in
      isAskedAsMarkedCell(tense)
        && verb.hasCell(tense)
        && PracticeItem.exercised(by: tense, of: verb) == .pattern(model: modelID, tense: tense.articleKey, person: tense.personNumber?.rawValue, takesÊtre: false)
    }
    guard cells.count >= minimumMarkedCells else {
      return nil
    }
    return ModelPractice(modelID: modelID, kind: .markedCells, verbs: verbs, cells: cells)
  }

  /// A spelling-change model's practice asks its simple tenses, as Verb Essentials asks the
  /// présent, passé composé, and futur. The passé simple and the subjonctif imparfait, which the
  /// levels keep for Advanced, are left out, and a compound tense repeats its participle.
  private static func isAskedAsMarkedCell(_ tense: Tense) -> Bool {
    switch tense {
    case .passéSimple, .subjonctifImparfait, .radicalFutur:
      return false
    default:
      return !tense.isCompound
    }
  }
}

extension PracticeRecord {
  /// An item enters the first box and leaves it by a right answer given when it is due.
  func isPastFirstBox(_ item: PracticeItem) -> Bool {
    (entry(for: item)?.schedule.box ?? 0) > 0
  }
}

struct ModelPracticeSession: Hashable, Identifiable {
  enum Mode: String {
    case alone
    case mixed
  }

  let modelID: String
  let mode: Mode

  var id: String {
    "\(modelID)-\(mode.rawValue)"
  }

  var collection: VerbCollection {
    .model(modelID)
  }

  var title: String {
    switch mode {
    case .alone:
      return collection.title
    case .mixed:
      return L.ModelPractice.mixedTitle(collection.title)
    }
  }

  var source: AnalyticsSource {
    switch mode {
    case .alone:
      return .modelAlone
    case .mixed:
      return .modelMixed
    }
  }
}

extension QuizScope {
  /// A model's practice, alone or mixed with the known models: Verb Essentials for a model learned
  /// verb by verb, and ten questions for a spelling-change model. The draw reads the model and the
  /// record itself, so `verbs` is only the model's.
  @MainActor static func modelPractice(_ session: ModelPracticeSession) -> QuizScope {
    let practice = ModelPractice.practice(session.modelID)
    let isVerbEssentials = practice?.kind == .verbEssentials
    return QuizScope(
      verbs: practice?.verbs ?? [],
      questionCount: isVerbEssentials ? verbEssentialsVerbCount * PracticeItem.Stem.shown.count : Quiz.questionCount,
      source: session.source,
      title: session.title,
      collection: session.collection,
      isVerbEssentials: isVerbEssentials,
      modelPractice: session
    )
  }
}

extension QuizDraw {
  /// How many of a mixed round's verbs, for Verb Essentials, or questions, for a spelling change,
  /// are the model's own. The rest are the known models'. The session stays mostly about the model
  /// the learner chose, and the known models make them pick the pattern rather than repeat it.
  static let modelMixOwnVerbCount = 3
  static let modelMixOwnCellCount = 6

  /// A round of a model's practice. `asked` holds the session's questions so far, whose verbs and
  /// cells wait until every other has been asked.
  @MainActor static func modelPracticeQuestions(
    for session: ModelPracticeSession,
    record: PracticeRecord,
    asked: [QuizQuestion],
    using generator: inout some RandomNumberGenerator
  ) -> [QuizQuestion] {
    guard let practice = ModelPractice.practice(session.modelID) else {
      return []
    }
    let partners = session.mode == .mixed ? practice.mixPartners(in: record).shuffled(using: &generator) : []
    switch practice.kind {
    case .verbEssentials:
      let askedVerbs = Set(asked.map(\.verb.id))
      guard session.mode == .mixed else {
        return verbEssentialsSteps(verbs: practice.verbs, count: QuizScope.verbEssentialsVerbCount, asked: askedVerbs, using: &generator).flatMap { $0 }
      }
      let own = freshFirst(practice.verbs, isAsked: { askedVerbs.contains($0.id) }, using: &generator)
      let others = inTurn(partners.map { freshFirst($0.verbs, isAsked: { askedVerbs.contains($0.id) }, using: &generator) }, isAsked: { askedVerbs.contains($0.id) })
      return mix(own: own, others: others, count: QuizScope.verbEssentialsVerbCount, ownCount: modelMixOwnVerbCount, using: &generator)
        .flatMap(verbEssentialsStep)
    case .markedCells:
      let askedItems = Set(asked.map { PracticeItem.exercised(by: $0.tense, of: $0.verb).key })
      let isAsked: (QuizQuestion) -> Bool = { askedItems.contains(PracticeItem.exercised(by: $0.tense, of: $0.verb).key) }
      let own = markedCellQuestions(of: practice, isAsked: isAsked, using: &generator)
      guard session.mode == .mixed else {
        return Array(own.prefix(Quiz.questionCount))
      }
      let others = inTurn(partners.map { markedCellQuestions(of: $0, isAsked: isAsked, using: &generator) }, isAsked: isAsked)
      return mix(own: own, others: others, count: Quiz.questionCount, ownCount: modelMixOwnCellCount, using: &generator)
    }
  }

  /// Every marked cell of the model once, each asked of one of its verbs in turn, the cells the
  /// session has not asked first.
  @MainActor static func markedCellQuestions(
    of practice: ModelPractice,
    isAsked: (QuizQuestion) -> Bool,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizQuestion] {
    let verbs = practice.verbs.shuffled(using: &generator)
    guard !verbs.isEmpty else {
      return []
    }
    var cursor = 0
    let questions: [QuizQuestion] = practice.cells.shuffled(using: &generator).compactMap { tense in
      for _ in verbs.indices {
        let verb = verbs[cursor]
        cursor = (cursor + 1) % verbs.count
        if verb.hasCell(tense) {
          return QuizQuestion(verb: verb, tense: tense)
        }
      }
      return nil
    }
    return questions.filter { !isAsked($0) } + questions.filter(isAsked)
  }

  /// `ownCount` of `own` and the rest of `others`, shuffled. Whichever side cannot fill its share
  /// leaves the rest to the other.
  static func mix<Element>(own: [Element], others: [Element], count: Int, ownCount: Int, using generator: inout some RandomNumberGenerator) -> [Element] {
    let otherCount = min(max(count - min(ownCount, own.count), 0), others.count)
    let chosen = own.prefix(count - otherCount) + others.prefix(otherCount)
    return chosen.shuffled(using: &generator)
  }

  /// One from each partner in turn, so that a partner of ten verbs does not crowd out a partner of
  /// one, with the ones the session has not asked first, each keeping its turn.
  static func inTurn<Element>(_ queues: [[Element]], isAsked: (Element) -> Bool) -> [Element] {
    let longest = queues.map(\.count).max() ?? 0
    let turns = (0 ..< longest).flatMap { turn in
      queues.compactMap { $0.indices.contains(turn) ? $0[turn] : nil }
    }
    return turns.filter { !isAsked($0) } + turns.filter(isAsked)
  }

  private static func freshFirst<Element>(_ elements: [Element], isAsked: (Element) -> Bool, using generator: inout some RandomNumberGenerator) -> [Element] {
    let shuffled = elements.shuffled(using: &generator)
    return shuffled.filter { !isAsked($0) } + shuffled.filter(isAsked)
  }
}
