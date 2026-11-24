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

    var scrollID: String {
      table.scrollID
    }
  }

  let personlessCells: [Cell]
  let simpleSections: [Section]

  /// Whether the verb's own conjugations, not only its auxiliary's, have red letters.
  let hasIrregularLetters: Bool

  init(verb: Verb) {
    personlessCells = Self.personlessCells(verb: verb)
    simpleSections = Self.sections(verb: verb, tables: TenseTable.simple)
    hasIrregularLetters = (personlessCells + simpleSections.flatMap(\.cells)).contains(where: \.hasRedLetters)
  }

  @MainActor private static var cache: [String: VerbConjugations] = [:]

  @MainActor static func memoized(for verb: Verb) -> VerbConjugations {
    let key = verb.infinitifWithPossibleExtraLetters
    if let cached = cache[key] {
      return cached
    }
    let conjugations = VerbConjugations(verb: verb)
    cache[key] = conjugations
    return conjugations
  }

  // The cached simple-tense cells bake in the pronoun (il/elle, ils/elles), which
  // depends on Current.settings.pronounGender at build time. Clear the cache when
  // that setting changes so already-viewed verbs re-render with the new pronouns.
  @MainActor static func clearCache() {
    cache.removeAll()
  }

  /// The card that shows `tense`, for a search's landing. The page and `sections` read the same
  /// `TenseTable`, so the two cannot disagree.
  static func scrollID(for tense: Tense) -> String {
    tense.table.scrollID
  }

  static func sections(verb: Verb, tables: [TenseTable]) -> [Section] {
    tables.map { table in
      let cells = table.tenses.enumerated().map { cellIndex, tense in
        cell(verb: verb, tense: tense, id: cellIndex)
      }
      return Section(table: table, cells: cells)
    }
  }

  static func personlessCells(verb: Verb) -> [Cell] {
    TenseTable.personless.tenses.enumerated().map { index, tense in
      cell(verb: verb, tense: tense, id: index)
    }
  }

  static func cell(verb: Verb, tense: Tense, id: Int) -> Cell {
    let parts = conjugationParts(verb: verb, tense: tense)
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

  static func conjugationParts(verb: Verb, tense: Tense) -> (pronoun: String, form: String, spoken: String) {
    let conjugation = rawConjugation(verb: verb, tense: tense)

    switch tense {
    case .participePassé, .participePrésent, .radicalFutur, .impératifPassé:
      return ("", conjugation, conjugation.lowercased())
    case .impératif(let personNumber):
      let form = personNumber.impératifAndPossibleReflexivePronoun(conjugation, isReflexive: verb.isReflexive)
      return ("", form, form.lowercased())
    default:
      // Every remaining case is a person-bearing simple/compound tense, so personNumber is non-nil.
      guard let personNumber = tense.personNumber else {
        return ("", conjugation, conjugation.lowercased())
      }
      let preamble = personNumber.preamble(forConjugation: conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH, pronounGender: verb.pronounGender)
      let pronoun = preamble.trimmingCharacters(in: .whitespaces)
      return (pronoun, conjugation, (preamble + conjugation).lowercased())
    }
  }

  static func rawConjugation(verb: Verb, tense: Tense) -> String {
    guard let conjugation = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: verb.pronounGender) else {
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
