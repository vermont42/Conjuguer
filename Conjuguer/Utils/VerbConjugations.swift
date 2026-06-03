//
//  VerbConjugations.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/2/26.
//

import SwiftUI

// Display-ready, precomputed conjugations for a verb. Built once (off `body`) so VerbView does
// not re-run Conjugator or rebuild colored AttributedStrings on every body evaluation, and so
// each form's colored display and its spoken (accessibility) text share a single conjugation
// pass.
struct VerbConjugations {
  // One conjugated form: the colored display string and the plain spoken string.
  struct Cell: Identifiable {
    let id: Int
    let display: AttributedString
    let accessibility: String
  }

  // One tense's worth of cells, with its title.
  struct Section: Identifiable {
    let id: Int
    let title: String
    let cells: [Cell]
  }

  // A tense and the person-numbers to present it for.
  struct TenseSpec {
    let builder: (PersonNumber) -> Tense
    let personNumbers: [PersonNumber]
  }

  let personlessDisplay: AttributedString
  let personlessAccessibility: String
  let simpleSections: [Section]

  // Builds the always-shown (personless + simple-tense) data. Compound tenses are built lazily
  // by the compound subview via `sections(verb:specs:)` only when that section is revealed.
  init(verb: Verb) {
    (personlessDisplay, personlessAccessibility) = Self.personless(verb: verb)
    simpleSections = Self.sections(verb: verb, specs: Self.simpleSpecs)
  }

  // The non-compound tenses, in display order.
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

  // The compound tenses, in display order.
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

  // Conjugates once and derives both the colored display and the plain lowercased spoken string.
  static func cell(verb: Verb, tense: Tense, id: Int) -> Cell {
    let conjugation = conjugationString(verb: verb, tense: tense)
    var display = AttributedString(mixedCaseString: conjugation)
    if isDefective(verb: verb, tense: tense) {
      display.strikethroughStyle = Text.LineStyle.single
    }
    return Cell(id: id, display: display, accessibility: conjugation.lowercased())
  }

  // The pronoun-applied, mixed-case conjugation for a verb+tense (moved out of Text(verb:tense:)).
  static func conjugationString(verb: Verb, tense: Tense) -> String {
    var conjugation: String
    switch Conjugator.conjugate(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters) {
    case .success(let value):
      conjugation = value
    default:
      fatalError("Could not conjugate \(verb.infinitif) for \(tense.titleCaseName).")
    }

    switch tense {
    case .participePassé, .participePrésent, .radicalFutur, .impératifPassé:
      break
    case .impératif(let personNumber):
      conjugation = personNumber.impératifAndPossibleReflexivePronoun(conjugation, isReflexive: verb.isReflexive)
    case
      .indicatifPrésent(let personNumber),
      .passéSimple(let personNumber),
      .imparfait(let personNumber),
      .futurSimple(let personNumber),
      .conditionnelPrésent(let personNumber),
      .subjonctifPrésent(let personNumber),
      .subjonctifImparfait(let personNumber),
      .passéComposé(let personNumber),
      .plusQueParfait(let personNumber),
      .passéAntérieur(let personNumber),
      .passéSurcomposé(let personNumber),
      .futurAntérieur(let personNumber),
      .conditionnelPassé(let personNumber),
      .subjonctifPassé(let personNumber),
      .subjonctifPlusQueParfait(let personNumber):
      conjugation = personNumber.pronounAndConjugation(conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
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
