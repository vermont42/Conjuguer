//
//  VerbConjugations.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/2/26.
//

import SwiftUI

struct VerbConjugations {
  struct Cell: Identifiable {
    let id: Int
    let tense: Tense
    let pronoun: String
    let display: AttributedString
    let accessibility: String
    let hasRedLetters: Bool

    /// What a long press copies: the form as the cell shows it, without the pronoun beside it and
    /// in lowercase, since the capitals only mark red letters. An empty cell copies nothing.
    var copyText: String? {
      let text = String(display.characters)
      return text.isEmpty ? nil : text
    }
  }

  struct Section: Identifiable {
    let table: TenseTable
    let cells: [Cell]

    var id: TenseTable {
      table
    }
  }

  let personlessCells: [Cell]
  let simpleSections: [Section]
  let compoundSections: [Section]

  /// Whether the verb's own conjugations, not only its auxiliary's, have red letters.
  let hasIrregularLetters: Bool

  /// The cells bake in the pronouns of `pronounGender`, the learner's setting: il or elle, ils or
  /// elles, and the agreement of an être participle.
  init(verb: Verb, pronounGender: PronounGender) {
    personlessCells = Self.sections(verb: verb, tables: [.personless], pronounGender: pronounGender)[0].cells
    simpleSections = Self.sections(verb: verb, tables: TenseTable.simple, pronounGender: pronounGender)
    compoundSections = Self.sections(verb: verb, tables: TenseTable.compound, pronounGender: pronounGender)
    hasIrregularLetters = (personlessCells + simpleSections.flatMap(\.cells)).contains(where: \.hasRedLetters)
  }

  private struct CacheKey: Hashable {
    let verb: String
    let pronounGender: PronounGender
  }

  @MainActor private static var cache: [CacheKey: VerbConjugations] = [:]

  /// A page reads this from `body`, so a change of the pronoun-gender setting reaches every
  /// open page whole. The key holds the gender, so nothing needs clearing when it changes.
  @MainActor static func memoized(for verb: Verb, pronounGender: PronounGender) -> VerbConjugations {
    let key = CacheKey(verb: verb.id, pronounGender: pronounGender)
    if let cached = cache[key] {
      return cached
    }
    let conjugations = VerbConjugations(verb: verb, pronounGender: pronounGender)
    cache[key] = conjugations
    return conjugations
  }

  static func sections(verb: Verb, tables: [TenseTable], pronounGender: PronounGender) -> [Section] {
    tables.map { table in
      let cells = table.tenses.enumerated().map { cellIndex, tense in
        cell(verb: verb, tense: tense, id: cellIndex, pronounGender: pronounGender)
      }
      return Section(table: table, cells: cells)
    }
  }

  static func cell(verb: Verb, tense: Tense, id: Int, pronounGender: PronounGender) -> Cell {
    let parts = conjugationParts(verb: verb, tense: tense, pronounGender: pronounGender)
    var display = AttributedString(mixedCaseString: parts.form)
    if isDefective(verb: verb, tense: tense) {
      display.strikethroughStyle = Text.LineStyle.single
    }
    return Cell(
      id: id,
      tense: tense,
      pronoun: parts.pronoun,
      display: display,
      accessibility: parts.spoken,
      hasRedLetters: parts.form.contains(where: \.isUppercase)
    )
  }

  /// `pronounGender` is the learner's setting, which an impersonal verb overrides.
  static func conjugationParts(verb: Verb, tense: Tense, pronounGender setting: PronounGender) -> (pronoun: String, form: String, spoken: String) {
    let pronounGender = verb.pronounGender(for: setting)
    let conjugation = rawConjugation(verb: verb, tense: tense, pronounGender: pronounGender)

    switch tense {
    case .impératifPassé:
      return ("", conjugation, conjugation.lowercased())
    case .impératif(let personNumber):
      let form = personNumber.impératifAndPossibleReflexivePronoun(conjugation, isReflexive: verb.isReflexive)
      return ("", form, form.lowercased())
    default:
      guard let personNumber = tense.personNumber else {
        return ("", conjugation, conjugation.lowercased())
      }
      let preamble = personNumber.preamble(forConjugation: conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH, pronounGender: pronounGender)
      let pronoun = preamble.trimmingCharacters(in: .whitespaces)
      return (pronoun, conjugation, (preamble + conjugation).lowercased())
    }
  }

  private static func rawConjugation(verb: Verb, tense: Tense, pronounGender: PronounGender) -> String {
    guard let conjugation = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: pronounGender) else {
      // Unreachable with today's data; a future data typo degrades to an empty cell
      // rather than crashing the user mid-browse.
      assertionFailure("Could not conjugate \(verb.infinitif) for \(tense.titleCaseName).")
      return ""
    }
    return conjugation
  }

  static func isDefective(verb: Verb, tense: Tense) -> Bool {
    guard
      let defectGroupId = verb.defectGroupId,
      let defectGroup = DefectGroup.defectGroups[defectGroupId]
    else {
      return false
    }
    return defectGroup.isDefectiveForTense(tense)
  }
}
