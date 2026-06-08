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
      let preamble = personNumber.preamble(forConjugation: conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
      let pronoun = preamble.trimmingCharacters(in: .whitespaces)
      return (pronoun, conjugation, (preamble + conjugation).lowercased())
    }
  }

  static func rawConjugation(verb: Verb, tense: Tense) -> String {
    switch Conjugator.conjugate(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters) {
    case .success(let value):
      return value
    default:
      fatalError("Could not conjugate \(verb.infinitif) for \(tense.titleCaseName).")
    }
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
