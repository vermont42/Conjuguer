//
//  Mastery.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import Foundation

// Semantic ordering: up the ladder.
/// How far up the review ladder an item has come, as the Mastery page shows it.
enum MasteryState: Equatable, CaseIterable {
  case notPracticed
  case learning
  case mastered

  /// The third box, whose interval is seven days.
  static let masteredBox = 2

  init(_ entry: PracticeRecord.Entry?) {
    guard let entry else {
      self = .notPracticed
      return
    }
    self = entry.schedule.box >= Self.masteredBox ? .mastered : .learning
  }
}

extension PracticeRecord {
  func masteryState(of item: PracticeItem) -> MasteryState {
    MasteryState(entry(for: item))
  }
}

/// What the practice record has made secure at a level, in the two kinds of item it keeps. A
/// regular verb's cells are patterns that its family shares, so they appear once per family, and a
/// spelling-change model's own patterns, the cells its change marks, appear once per model. An
/// irregular verb shows its key conjugations, as far as the level asks them. Patterns are the ones
/// a verb of the level's band can be asked, so the page and the default quiz agree.
struct Mastery {
  struct Cell: Identifiable {
    let item: PracticeItem
    /// Nil for a participle.
    let person: PersonNumber?
    let state: MasteryState

    var id: String {
      item.key
    }
  }

  struct PatternRow: Identifiable {
    let modelID: String
    let takesÊtre: Bool
    let cells: [Cell]

    var id: String {
      "\(modelID):\(takesÊtre)"
    }
  }

  struct PatternTable: Identifiable {
    let slot: QuizTenseSlot
    let rows: [PatternRow]

    var id: String {
      slot.key
    }
  }

  struct ModelCard: Identifiable {
    let modelID: String
    let tables: [PatternTable]

    var id: String {
      modelID
    }

    var cells: [Cell] {
      tables.flatMap { $0.rows.flatMap(\.cells) }
    }
  }

  struct KeyConjugation: Identifiable {
    let verb: Verb
    let stem: PracticeItem.Stem
    let state: MasteryState

    var id: String {
      stem.rawValue
    }

    /// Mixed case, as the Conjugator writes it. Conjugated when shown rather than when counted, so
    /// that the hub's row conjugates nothing.
    var conjugation: String {
      let form = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: stem.keyTense, extraLetters: verb.extraLetters, pronounGender: .masculine) ?? verb.infinitif
      guard verb.isReflexive else {
        return form
      }
      return PersonNumber.thirdPersonReflexivePronoun(before: form, hasAspiratedH: verb.hasAspiratedH) + form
    }
  }

  struct VerbRow: Identifiable {
    let verb: Verb
    let keyConjugations: [KeyConjugation]

    var id: String {
      verb.dictionaryKey
    }

    var isMastered: Bool {
      keyConjugations.allSatisfy { $0.state == .mastered }
    }
  }

  static let coreVerbCount = 50

  let level: QuizLevel
  let regular: [PatternTable]
  let spellingChanges: [ModelCard]
  let verbs: [VerbRow]

  init(level: QuizLevel, record: PracticeRecord) {
    self.level = level
    let layout = Self.layout(at: level)
    func table(_ slot: QuizTenseSlot, _ rows: [PatternLayout.Row]) -> PatternTable {
      PatternTable(
        slot: slot,
        rows: rows.map { row in
          PatternRow(
            modelID: row.modelID,
            takesÊtre: row.takesÊtre,
            cells: row.items.map { Cell(item: $0.item, person: $0.person, state: record.masteryState(of: $0.item)) }
          )
        }
      )
    }
    regular = layout.regular.map { table($0.slot, $0.rows) }
    spellingChanges = layout.models.map { model in
      ModelCard(modelID: model.modelID, tables: model.tables.map { table($0.slot, $0.rows) })
    }
    verbs = Self.coreVerbs(at: level).map { core in
      VerbRow(
        verb: core.verb,
        keyConjugations: core.stems.map { stem in
          KeyConjugation(verb: core.verb, stem: stem, state: record.masteryState(of: .keyConjugation(verb: core.verb.dictionaryKey, stem: stem)))
        }
      )
    }
  }

  var regularCells: [Cell] {
    regular.flatMap { $0.rows.flatMap(\.cells) }
  }

  var spellingChangeCells: [Cell] {
    spellingChanges.flatMap(\.cells)
  }

  var patternCount: Int {
    regularCells.count + spellingChangeCells.count
  }

  var masteredPatternCount: Int {
    (regularCells + spellingChangeCells).filter { $0.state == .mastered }.count
  }

  var masteredVerbCount: Int {
    verbs.filter(\.isMastered).count
  }

  /// The stems the level asks: the présent at Beginner, which asks only the présent and the
  /// impératif, the passé composé and the futur from Elementary, and the passé simple at Advanced.
  static func stems(askedAt level: QuizLevel) -> [PracticeItem.Stem] {
    let asked = Set(level.slots.flatMap(\.cells).map(PracticeItem.Stem.init))
    return PracticeItem.Stem.allCases.filter(asked.contains)
  }

  /// The stems the level asks that the verb has: gésir has no passé composé, and falloir has
  /// every stem in il alone.
  static func stems(askedAt level: QuizLevel, of verb: Verb) -> [PracticeItem.Stem] {
    stems(stems(askedAt: level), of: verb)
  }

  static func stems(_ candidates: [PracticeItem.Stem], of verb: Verb) -> [PracticeItem.Stem] {
    candidates.filter { stem in
      !VerbConjugations.isDefective(verb: verb, tense: stem.keyTense)
        && Conjugator.conjugatedString(infinitif: verb.infinitif, tense: stem.keyTense, extraLetters: verb.extraLetters, pronounGender: .masculine) != nil
    }
  }

  struct CoreVerb {
    let verb: Verb
    let stems: [PracticeItem.Stem]
  }

  /// The most frequent irregular verbs of the level's band, at most fifty: thirty-six at
  /// Beginner, whose band holds no more. Every one is a verb the level's quiz can ask.
  static func coreVerbs(at level: QuizLevel) -> [CoreVerb] {
    if let cached = coreVerbCache[level] {
      return cached
    }
    let core = Array(
      level.verbs.lazy
        .filter { !PracticeItem.isLearnedByPattern($0) }
        .map { CoreVerb(verb: $0, stems: stems(askedAt: level, of: $0)) }
        .filter { !$0.stems.isEmpty }
        .prefix(coreVerbCount)
    )
    coreVerbCache[level] = core
    return core
  }

  /// Every pattern a verb of the level's band can be asked at the level, in the order the page
  /// shows them.
  static func patterns(at level: QuizLevel) -> [PracticeItem] {
    let layout = layout(at: level)
    let regular = layout.regular.flatMap { $0.rows.flatMap(\.items) }
    let models = layout.models.flatMap { $0.tables.flatMap { $0.rows.flatMap(\.items) } }
    return (regular + models).map(\.item)
  }

  /// The family whose patterns a base model's row shows, as its row is labeled: -er for parler's,
  /// -ir for finir's, and -re for rendre's.
  static let familyOrder = ["1-1", "2-1", QuizVerbPool.rendreModelID]

  private struct PatternLayout {
    struct Item {
      let item: PracticeItem
      let person: PersonNumber?
    }

    struct Row {
      let modelID: String
      let takesÊtre: Bool
      var items: [Item]
    }

    struct Table {
      let slot: QuizTenseSlot
      var rows: [Row]
    }

    struct Model {
      let modelID: String
      var tables: [Table]
    }

    var regular: [Table] = []
    var models: [Model] = []
  }

  private static var layoutCache: [QuizLevel: PatternLayout] = [:]
  private static var coreVerbCache: [QuizLevel: [CoreVerb]] = [:]

  /// Which patterns exist depends only on a verb's model and on whether its compound tenses take
  /// être, apart from the cells a defect group removes, so one verb of each kind that has a cell
  /// stands for the rest. Measuring every verb of Advanced's band would take seconds.
  private static func layout(at level: QuizLevel) -> PatternLayout {
    if let cached = layoutCache[level] {
      return cached
    }
    var kinds: [String: [Verb]] = [:]
    var kindOrder: [String] = []
    for verb in level.verbs where PracticeItem.isLearnedByPattern(verb) {
      let kind = "\(verb.model):\(verb.auxiliary == .être || verb.isReflexive)"
      if kinds[kind] == nil {
        kindOrder.append(kind)
      }
      kinds[kind, default: []].append(verb)
    }

    var found: Set<String> = []
    var byModel: [String: [QuizTenseSlot: [Bool: [PatternLayout.Item]]]] = [:]
    for slot in level.slots {
      for kind in kindOrder {
        guard let verbs = kinds[kind] else {
          continue
        }
        for tense in slot.cells {
          guard let verb = verbs.first(where: { !VerbConjugations.isDefective(verb: $0, tense: tense) }) else {
            continue
          }
          let item = PracticeItem.exercised(by: tense, of: verb)
          guard case let .pattern(model, _, _, takesÊtre) = item, found.insert(item.key).inserted else {
            continue
          }
          byModel[model, default: [:]][slot, default: [:]][takesÊtre, default: []].append(PatternLayout.Item(item: item, person: tense.personNumber))
        }
      }
    }

    func tables(of model: String) -> [PatternLayout.Table] {
      level.slots.compactMap { slot in
        guard let rows = byModel[model]?[slot] else {
          return nil
        }
        let ordered = [false, true].compactMap { takesÊtre in
          rows[takesÊtre].map { items in
            PatternLayout.Row(modelID: model, takesÊtre: takesÊtre, items: items.sorted { personOrder($0.person) < personOrder($1.person) })
          }
        }
        return PatternLayout.Table(slot: slot, rows: ordered)
      }
    }

    var layout = PatternLayout()
    layout.regular = level.slots.compactMap { slot in
      let rows = familyOrder.flatMap { family in
        tables(of: family).first { $0.slot == slot }?.rows ?? []
      }
      return rows.isEmpty ? nil : PatternLayout.Table(slot: slot, rows: rows)
    }
    layout.models = byModel.keys
      .filter { !familyOrder.contains($0) }
      .sorted { (VerbModel.models[$0]?.position ?? .max, $0) < (VerbModel.models[$1]?.position ?? .max, $1) }
      .map { PatternLayout.Model(modelID: $0, tables: tables(of: $0)) }
    layoutCache[level] = layout
    return layout
  }

  private static func personOrder(_ person: PersonNumber?) -> Int {
    person.flatMap { PersonNumber.allCases.firstIndex(of: $0) } ?? 0
  }
}

extension Mastery.ModelCard {
  /// The model's first changed cell, conjugated from its exemplar, as in "nous mangeons" or
  /// "j'appelle": what the change is. Mixed case, as the Conjugator writes it. Nil when the
  /// exemplar cannot be conjugated.
  var example: String? {
    guard
      let model = VerbModel.models[modelID],
      let cell = cells.first,
      let tense = cell.item.tense,
      let form = Conjugator.conjugatedString(infinitif: model.exemplar, tense: tense, extraLetters: model.extraLetters, pronounGender: .masculine)
    else {
      return nil
    }
    if case .impératif = tense {
      return form
    }
    guard let person = cell.person else {
      return form
    }
    let key = model.extraLetters.map { "\(model.exemplar) \($0)" } ?? model.exemplar
    let hasAspiratedH = Verb.verbs[key]?.hasAspiratedH ?? false
    return Mastery.pronoun(person, before: form, hasAspiratedH: hasAspiratedH) + form
  }
}

extension Mastery {
  /// The masculine subject pronoun, je elided before a vowel or a mute h: "j'appelle".
  static func pronoun(_ person: PersonNumber, before form: String, hasAspiratedH: Bool) -> String {
    switch person {
    case .firstSingular:
      let elides = form.lowercased().first.map { "aeiouyéèêàâîïôûœ".contains($0) || ($0 == "h" && !hasAspiratedH) } ?? false
      return elides ? "j'" : "je "
    case .secondSingular:
      return "tu "
    case .thirdSingular:
      return "il "
    case .firstPlural:
      return "nous "
    case .secondPlural:
      return "vous "
    case .thirdPlural:
      return "ils "
    }
  }

  static func personLabel(_ person: PersonNumber) -> String {
    switch person {
    case .firstSingular:
      return "je"
    case .secondSingular:
      return "tu"
    case .thirdSingular:
      return "il"
    case .firstPlural:
      return "nous"
    case .secondPlural:
      return "vous"
    case .thirdPlural:
      return "ils"
    }
  }
}
