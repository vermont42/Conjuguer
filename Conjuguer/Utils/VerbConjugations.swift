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
    let pronoun: String
    let display: AttributedString
    let accessibility: String
  }

  struct Section: Identifiable {
    let id: Int
    let title: String
    let cells: [Cell]
  }

  struct TenseSpec {
    let builder: (PersonNumber) -> Tense
    let personNumbers: [PersonNumber]
  }

  let personlessDisplay: AttributedString
  let personlessAccessibility: String
  let simpleSections: [Section]

  init(verb: Verb) {
    (personlessDisplay, personlessAccessibility) = Self.personless(verb: verb)
    simpleSections = Self.sections(verb: verb, specs: Self.simpleSpecs)
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

  static let simpleSpecs: [TenseSpec] = [
    TenseSpec(builder: { .indicatifPrésent($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .passéSimple($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .imparfait($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .futurSimple($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .conditionnelPrésent($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .subjonctifPrésent($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .subjonctifImparfait($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .impératif($0) }, personNumbers: PersonNumber.impératifPersonNumbers)
  ]

  static let compoundSpecs: [TenseSpec] = [
    TenseSpec(builder: { .passéComposé($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .plusQueParfait($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .passéAntérieur($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .passéSurcomposé($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .futurAntérieur($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .conditionnelPassé($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .subjonctifPassé($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .subjonctifPlusQueParfait($0) }, personNumbers: PersonNumber.allCases),
    TenseSpec(builder: { .impératifPassé($0) }, personNumbers: PersonNumber.impératifPersonNumbers)
  ]

  static func sections(verb: Verb, specs: [TenseSpec]) -> [Section] {
    specs.enumerated().map { sectionIndex, spec in
      let cells = spec.personNumbers.enumerated().map { cellIndex, personNumber in
        cell(verb: verb, tense: spec.builder(personNumber), id: cellIndex)
      }
      return Section(
        id: sectionIndex,
        title: spec.builder(spec.personNumbers[0]).titleCaseName,
        cells: cells
      )
    }
  }

  static func personless(verb: Verb) -> (display: AttributedString, accessibility: String) {
    let passé = cell(verb: verb, tense: .participePassé, id: 0)
    let présent = cell(verb: verb, tense: .participePrésent, id: 1)
    let futur = cell(verb: verb, tense: .radicalFutur, id: 2)
    let display = passé.display + AttributedString(", ") + présent.display + AttributedString(", ") + futur.display
    let accessibility = "\(passé.accessibility), \(présent.accessibility), \(futur.accessibility)"
    return (display, accessibility)
  }

  static func cell(verb: Verb, tense: Tense, id: Int) -> Cell {
    let parts = conjugationParts(verb: verb, tense: tense)
    var display = AttributedString(mixedCaseString: parts.form)
    if isDefective(verb: verb, tense: tense) {
      display.strikethroughStyle = Text.LineStyle.single
    }
    return Cell(id: id, pronoun: parts.pronoun, display: display, accessibility: parts.spoken)
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
      let preamble = personNumber.preamble(forConjugation: conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
      let pronoun = preamble.trimmingCharacters(in: .whitespaces)
      return (pronoun, conjugation, (preamble + conjugation).lowercased())
    }
  }

  static func rawConjugation(verb: Verb, tense: Tense) -> String {
    guard let conjugation = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters) else {
      fatalError("Could not conjugate \(verb.infinitif) for \(tense.titleCaseName).")
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
