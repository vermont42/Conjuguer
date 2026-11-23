//
//  QuizLevel.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// What the quiz asks, chosen by the learner. Each level adds tenses to the one before, in the
/// order French courses teach them, and nothing unlocks. `docs/feature_architecture.md` § Quiz
/// gives the sources.
enum QuizLevel: String, CaseIterable {
  case beginner
  case elementary
  case intermediate
  case advanced

  var localizedName: String {
    switch self {
    case .beginner:
      return L.QuizLevel.beginner
    case .elementary:
      return L.QuizLevel.elementary
    case .intermediate:
      return L.QuizLevel.intermediate
    case .advanced:
      return L.QuizLevel.advanced
    }
  }

  var localizedNameWithLabel: String {
    L.QuizLevel.withLabel(localizedName)
  }

  var systemImage: String {
    switch self {
    case .beginner:
      return "gauge.with.dots.needle.0percent"
    case .elementary:
      return "gauge.with.dots.needle.33percent"
    case .intermediate:
      return "gauge.with.dots.needle.67percent"
    case .advanced:
      return "gauge.with.dots.needle.100percent"
    }
  }

  /// The most frequent verbs the default quiz asks at this level. Nil asks every verb.
  var band: FrequencyBand? {
    switch self {
    case .beginner:
      return .top100
    case .elementary:
      return .top300
    case .intermediate:
      return .top1000
    case .advanced:
      return nil
    }
  }

  @MainActor var verbs: [Verb] {
    QuizDraw.verbs(in: band)
  }

  var slots: [QuizTenseSlot] {
    switch self {
    case .beginner:
      return [.indicatifPrésent, .impératif]
    case .elementary:
      return QuizLevel.beginner.slots + [.passéComposé, .participePassé, .imparfait, .futurSimple, .conditionnelPrésent]
    case .intermediate:
      return QuizLevel.elementary.slots + [.subjonctifPrésent, .plusQueParfait, .conditionnelPassé, .participePrésent]
    case .advanced:
      return QuizLevel.intermediate.slots + [
        .futurAntérieur,
        .subjonctifPassé,
        .passéSimple,
        .subjonctifImparfait,
        .subjonctifPlusQueParfait,
        .passéAntérieur,
        .passéSurcomposé,
        .impératifPassé
      ]
    }
  }
}

/// A tense as the quiz asks it: its cells, how often it is drawn, and the verbs the default quiz
/// asks it of.
enum QuizTenseSlot: CaseIterable {
  case indicatifPrésent
  case impératif
  case passéComposé
  case participePassé
  case imparfait
  case futurSimple
  case conditionnelPrésent
  case subjonctifPrésent
  case plusQueParfait
  case conditionnelPassé
  case participePrésent
  case futurAntérieur
  case subjonctifPassé
  case passéSimple
  case subjonctifImparfait
  case subjonctifPlusQueParfait
  case passéAntérieur
  case passéSurcomposé
  case impératifPassé

  init?(tense: Tense) {
    guard let slot = Self.allCases.first(where: { $0.cells.contains(tense) }) else {
      return nil
    }
    self = slot
  }

  // A tense is weighted as a whole, whatever its number of cells. A compound tense other than the
  // passé composé is light because only its auxiliary is new. The weights never change with what
  // the learner has done.
  var weight: Int {
    switch self {
    case .indicatifPrésent, .passéComposé:
      return 3
    case .impératif, .imparfait, .futurSimple, .conditionnelPrésent, .subjonctifPrésent, .passéSimple, .subjonctifImparfait:
      return 2
    case .participePassé, .participePrésent, .plusQueParfait, .conditionnelPassé, .futurAntérieur, .subjonctifPassé, .subjonctifPlusQueParfait, .passéAntérieur, .passéSurcomposé, .impératifPassé:
      return 1
    }
  }

  var isParticiple: Bool {
    self == .participePassé || self == .participePrésent
  }

  var constructor: ((PersonNumber) -> Tense)? {
    switch self {
    case .indicatifPrésent:
      return Tense.indicatifPrésent
    case .impératif:
      return Tense.impératif
    case .passéComposé:
      return Tense.passéComposé
    case .imparfait:
      return Tense.imparfait
    case .futurSimple:
      return Tense.futurSimple
    case .conditionnelPrésent:
      return Tense.conditionnelPrésent
    case .subjonctifPrésent:
      return Tense.subjonctifPrésent
    case .plusQueParfait:
      return Tense.plusQueParfait
    case .conditionnelPassé:
      return Tense.conditionnelPassé
    case .futurAntérieur:
      return Tense.futurAntérieur
    case .subjonctifPassé:
      return Tense.subjonctifPassé
    case .passéSimple:
      return Tense.passéSimple
    case .subjonctifImparfait:
      return Tense.subjonctifImparfait
    case .subjonctifPlusQueParfait:
      return Tense.subjonctifPlusQueParfait
    case .passéAntérieur:
      return Tense.passéAntérieur
    case .passéSurcomposé:
      return Tense.passéSurcomposé
    case .impératifPassé:
      return Tense.impératifPassé
    case .participePassé, .participePrésent:
      return nil
    }
  }

  var isImpératif: Bool {
    self == .impératif || self == .impératifPassé
  }

  var persons: [PersonNumber] {
    isImpératif ? PersonNumber.impératifPersonNumbers : PersonNumber.allCases
  }

  var cells: [Tense] {
    switch self {
    case .participePassé:
      return [.participePassé]
    case .participePrésent:
      return [.participePrésent]
    default:
      guard let constructor else {
        return []
      }
      return persons.map(constructor)
    }
  }

  /// The pools the default quiz draws this tense's verbs from, one pool per question, repeated
  /// where a pool should come up more often.
  var verbPools: [QuizVerbPool] {
    switch self {
    case .indicatifPrésent:
      return [.regularEr, .regularEr, .regularIr, .regularIr, .regularRe, .bigThree, .indicatifPrésentStemChanger]
    case .passéComposé, .plusQueParfait, .conditionnelPassé, .futurAntérieur, .subjonctifPassé, .subjonctifPlusQueParfait, .passéAntérieur, .passéSurcomposé, .impératifPassé:
      return [.regularEr, .regularIr, .regularRe, .bigThree, .êtreAuxiliary, .irregularParticipePassé]
    case .participePassé:
      return [.regularEr, .regularIr, .regularRe, .irregularParticipePassé, .irregularParticipePassé]
    case .subjonctifPrésent:
      return [.regularEr, .regularIr, .regularRe, .bigThree]
    case .imparfait, .impératif, .participePrésent:
      return [.anyVerb]
    case .futurSimple, .conditionnelPrésent:
      return [.regularRadicalFutur, .regularRadicalFutur, .irregularRadicalFutur]
    case .passéSimple, .subjonctifImparfait:
      return [.regularEr, .regularIr, .regularRe, .bigThree, .irregularParticipePassé]
    }
  }

  static func drawWeighted(from slots: [QuizTenseSlot], using generator: inout some RandomNumberGenerator) -> QuizTenseSlot? {
    let total = slots.reduce(0) { $0 + $1.weight }
    guard total > 0 else {
      return nil
    }
    var roll = Int.random(in: 0 ..< total, using: &generator)
    for slot in slots {
      if roll < slot.weight {
        return slot
      }
      roll -= slot.weight
    }
    return nil
  }
}
