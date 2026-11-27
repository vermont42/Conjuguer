//
//  PracticeItemMapping.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

extension PracticeItem {
  /// The bases of the three regular families: parler's -er, finir's -ir, and rendre's -re.
  static let patternBases: Set<String> = [parlerModelID, finirModelID, rendreModelID]

  private static let parlerModelID = "1-1"
  private static let finirModelID = "2-1"
  private static let rendreModelID = QuizVerbPool.rendreModelID
  /// Rendre's own model, rompre's, and foutre's. Prendre's, battre's, and mettre's models are
  /// built on rendre's in `verbModels.xml` too, but their stems are irregular.
  private static let rendreFamily: Set<String> = [rendreModelID, "5-1B", "5-1C"]

  /// The base of the family whose patterns the verb shares, nil for a verb learned verb by verb
  /// through its key conjugations: aller and the third group but rendre's family. Every other
  /// model of the first two groups belongs to its group's family.
  static func patternBase(of verb: Verb) -> String? {
    if rendreFamily.contains(verb.model) {
      return rendreModelID
    }
    guard verb.model != VerbDraw.alleModelID else {
      return nil
    }
    switch verb.modelGroup {
    case 1:
      return parlerModelID
    case 2:
      return finirModelID
    default:
      return nil
    }
  }

  static func isLearnedByPattern(_ verb: Verb) -> Bool {
    patternBase(of: verb) != nil
  }

  /// The item a question exercises. An irregular verb's question exercises the key conjugation of
  /// the stem its tense is built on. A regular verb's question exercises its cell's pattern: its
  /// own model's where the model's spelling change marks the cell (nous mangeons, j'appelle), and
  /// its family's base's elsewhere (je mange, j'appelais), so that manger's verbs share parler's
  /// patterns except where they differ.
  static func exercised(by tense: Tense, of verb: Verb) -> PracticeItem {
    guard let base = patternBase(of: verb) else {
      return .keyConjugation(verb: verb.dictionaryKey, stem: Stem(tense))
    }
    let model = verb.model != base && isMarked(tense, of: verb) ? verb.model : base
    return .pattern(
      model: model,
      tense: tense.articleKey,
      person: tense.personNumber?.rawValue,
      takesÊtre: tense.isCompound && (verb.auxiliary == .être || verb.isReflexive)
    )
  }

  /// The items a lookup of the verb schedules: the key conjugations the review card shows. A
  /// regular verb has none, since its conjugations are patterns.
  static func keyConjugations(of verb: Verb) -> [PracticeItem] {
    guard !isLearnedByPattern(verb) else {
      return []
    }
    return verb.keyConjugationsByStem().map { .keyConjugation(verb: verb.dictionaryKey, stem: $0.stem) }
  }

  /// The cell a review of the item asks: a key conjugation's own cell, or the pattern's. Nil for a
  /// key this version cannot read.
  var tense: Tense? {
    switch self {
    case let .keyConjugation(_, stem):
      return stem.keyTense
    case let .pattern(_, tenseKey, person, _):
      guard let slot = QuizTenseSlot(key: tenseKey) else {
        return nil
      }
      guard let person else {
        return slot.constructor == nil ? slot.cells.first : nil
      }
      return PersonNumber(rawValue: person).flatMap { slot.constructor?($0) }
    }
  }

  /// The verb a key conjugation belongs to, if it is still in the verb list and still learned
  /// verb by verb. Nil for a pattern.
  var verb: Verb? {
    guard case let .keyConjugation(key, _) = self, let verb = Verb.verbs[key], !Self.isLearnedByPattern(verb) else {
      return nil
    }
    return verb
  }

  /// Whether the Conjugator marks an irregular letter in the cell. A compound tense is judged by
  /// its participle alone, since the auxiliary's own irregular letters say nothing of the verb.
  private static func isMarked(_ tense: Tense, of verb: Verb) -> Bool {
    let markedTense = tense.isCompound ? .participePassé : tense
    let conjugation = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: markedTense, extraLetters: verb.extraLetters, pronounGender: .masculine)
    return conjugation?.contains(where: \.isUppercase) == true
  }
}

extension PracticeItem.Stem {
  /// The stem a tense is built on. The imparfait, the subjonctif présent, and the participe
  /// présent are counted with the présent, whose stems they share (venions, viennent, venant), and
  /// the subjonctif imparfait with the passé simple (vînt from vint).
  init(_ tense: Tense) {
    switch tense {
    case .indicatifPrésent, .impératif, .imparfait, .subjonctifPrésent, .participePrésent:
      self = .présent
    case .participePassé, .passéComposé, .plusQueParfait, .passéAntérieur, .passéSurcomposé, .futurAntérieur, .conditionnelPassé, .subjonctifPassé, .subjonctifPlusQueParfait, .impératifPassé:
      self = .passéComposé
    case .futurSimple, .conditionnelPrésent, .radicalFutur:
      self = .futur
    case .passéSimple, .subjonctifImparfait:
      self = .passéSimple
    }
  }

  /// The il form, as the verb page's key conjugations show it.
  var keyTense: Tense {
    switch self {
    case .présent:
      return .indicatifPrésent(.thirdSingular)
    case .passéComposé:
      return .passéComposé(.thirdSingular)
    case .futur:
      return .futurSimple(.thirdSingular)
    case .passéSimple:
      return .passéSimple(.thirdSingular)
    }
  }
}
