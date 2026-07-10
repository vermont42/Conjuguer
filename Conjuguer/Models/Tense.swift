//
//  Tense.swift
//  Conjuguer
//
//  Created by Josh Adams on 3/31/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

nonisolated enum Tense: Hashable {
  case participePassé
  case participePrésent
  case radicalFutur

  case indicatifPrésent(_ personNumber: PersonNumber)
  case passéSimple(_ personNumber: PersonNumber)
  case imparfait(_ personNumber: PersonNumber)
  case futurSimple(_ personNumber: PersonNumber)
  case conditionnelPrésent(_ personNumber: PersonNumber)
  case subjonctifPrésent(_ personNumber: PersonNumber)
  case subjonctifImparfait(_ personNumber: PersonNumber)
  case impératif(_ personNumber: PersonNumber)

  case passéComposé(_ personNumber: PersonNumber)
  case plusQueParfait(_ personNumber: PersonNumber)
  case passéAntérieur(_ personNumber: PersonNumber)
  case passéSurcomposé(_ personNumber: PersonNumber)
  case futurAntérieur(_ personNumber: PersonNumber)
  case conditionnelPassé(_ personNumber: PersonNumber)
  case subjonctifPassé(_ personNumber: PersonNumber)
  case subjonctifPlusQueParfait(_ personNumber: PersonNumber)
  case impératifPassé(_ personNumber: PersonNumber)

  static let participePrésentEnding = "ant"
  static let alternateConjugationSeparator = "/"
  static let irregularEndingMarker = "*"

  var titleCaseName: String {
    switch self {
    case .participePassé:
      return "Participe Passé"
    case .participePrésent:
      return "Participe Présent"
    case .radicalFutur:
      return "Radical du Futur"
    case .indicatifPrésent:
      return "Indicatif Présent"
    case .passéSimple:
      return "Passé Simple"
    case .imparfait:
      return "Imparfait"
    case .futurSimple:
      return "Futur Simple"
    case .conditionnelPrésent:
      return "Conditionnel Présent"
    case .subjonctifPrésent:
      return "Subjonctif Présent"
    case .subjonctifImparfait:
      return "Subjonctif Imparfait"
    case .impératif:
      return "Impératif"
    case .passéComposé:
      return "Passé Composé"
    case .plusQueParfait:
      return "Plus-que-parfait"
    case .passéAntérieur:
      return "Passé Antérieur"
    case .passéSurcomposé:
      return "Passé Surcomposé"
    case .futurAntérieur:
      return "Futur Antérieur"
    case .conditionnelPassé:
      return "Conditionnel Passé"
    case .subjonctifPassé:
      return "Subjonctif Passé"
    case .subjonctifPlusQueParfait:
      return "Subjonctif Plus-que-parfait"
    case .impératifPassé:
      return "Impératif Passé"
    }
  }

  var shortTitleCaseName: String {
    switch self {
    case .indicatifPrésent:
      return "Ind. Présent"
    case .subjonctifPrésent:
      return "Subj. Présent"
    case .subjonctifImparfait:
      return "Subj. Imp."
    default:
      return titleCaseName
    }
  }

  var isCompound: Bool {
    switch self {
    case .passéComposé, .plusQueParfait, .passéAntérieur, .passéSurcomposé, .futurAntérieur, .conditionnelPassé, .subjonctifPassé, .subjonctifPlusQueParfait, .impératifPassé:
      return true
    default:
      return false
    }
  }

  @MainActor func conjugatedAuxiliary(personNumber: PersonNumber, auxiliary: Auxiliary) -> String {
    let verb = auxiliary.verb
    let tense: Tense
    switch self {
    case .passéComposé:
      tense = .indicatifPrésent(personNumber)
    case .plusQueParfait:
      tense = .imparfait(personNumber)
    case .passéAntérieur:
      tense = .passéSimple(personNumber)
    case .passéSurcomposé:
      tense = .passéComposé(personNumber)
    case .futurAntérieur:
      tense = .futurSimple(personNumber)
    case .conditionnelPassé:
      tense = .conditionnelPrésent(personNumber)
    case .subjonctifPassé:
      tense = .subjonctifPrésent(personNumber)
    case .subjonctifPlusQueParfait:
      tense = .subjonctifImparfait(personNumber)
    case .impératifPassé:
      tense = .impératif(personNumber)
    default:
      return ""
    }

    return Conjugator.conjugatedString(infinitif: verb, tense: tense, extraLetters: nil) ?? ""
  }

  var shortDisplayName: String {
    switch self {
    case .participePassé:
      return "pp"
    case .participePrésent:
      return "rr"
    case .radicalFutur:
      return "sf"
    case .indicatifPrésent(let personNumber):
      return "r" + personNumber.shortDisplayName
    case .passéSimple(let personNumber):
      return "x" + personNumber.shortDisplayName
    case .imparfait(let personNumber):
      return "i" + personNumber.shortDisplayName
    case .futurSimple(let personNumber):
      return "f" + personNumber.shortDisplayName
    case .conditionnelPrésent(let personNumber):
      return "c" + personNumber.shortDisplayName
    case .subjonctifPrésent(let personNumber):
      return "b" + personNumber.shortDisplayName
    case .subjonctifImparfait(let personNumber):
      return "q" + personNumber.shortDisplayName
    case .impératif(let personNumber):
      return "h" + personNumber.shortDisplayName
    default:
      return ""
    }
  }

  var personNumber: PersonNumber? {
    switch self {
    case .indicatifPrésent(let personNumber), .passéSimple(let personNumber), .imparfait(let personNumber), .futurSimple(let personNumber), .conditionnelPrésent(let personNumber), .subjonctifPrésent(let personNumber), .subjonctifImparfait(let personNumber), .impératif(let personNumber), .passéComposé(let personNumber), .plusQueParfait(let personNumber), .passéAntérieur(let personNumber), .passéSurcomposé(let personNumber), .futurAntérieur(let personNumber), .conditionnelPassé(let personNumber), .subjonctifPassé(let personNumber), .subjonctifPlusQueParfait(let personNumber), .impératifPassé(let personNumber):
      return personNumber
    case .participePassé, .participePrésent, .radicalFutur:
      return nil
    }
  }

  @MainActor var pronounWithGender: String {
    personNumber?.pronounWithGender ?? L.QuizView.none
  }

  @MainActor var pronoun: String {
    personNumber?.pronoun ?? L.QuizView.none
  }

  @MainActor var gender: String {
    personNumber?.gender ?? L.QuizView.none
  }

  @MainActor var pronounDecorator: String {
    guard let personNumber else {
      return ""
    }
    return " - \(personNumber.pronounWithGender)"
  }

  // The single source of truth for the tense-shorthand grammar (e.g. "r1s", "bA", "pp")
  // hand-parsed by StemAlteration and DefectGroup. A shorthand is a tense letter followed by
  // a PersonNumber short name ("1s"…"3p") or "A" (all person-numbers for the family); the three
  // personless tenses use two-letter codes. shortDisplayName above encodes the inverse direction.

  static let personlessShorthands: [String: Tense] = [
    "pp": .participePassé,
    "rr": .participePrésent,
    "sf": .radicalFutur
  ]

  // The constructor for a person-bearing tense family, keyed by its shorthand letter.
  // (A function rather than a stored [String: (PersonNumber) -> Tense] so the closures need
  // not be stored in a Sendable static under strict concurrency.)
  static func tenseConstructor(forShorthandLetter letter: String) -> ((PersonNumber) -> Tense)? {
    switch letter {
    case "r":
      return Tense.indicatifPrésent
    case "x":
      return Tense.passéSimple
    case "i":
      return Tense.imparfait
    case "f":
      return Tense.futurSimple
    case "c":
      return Tense.conditionnelPrésent
    case "b":
      return Tense.subjonctifPrésent
    case "q":
      return Tense.subjonctifImparfait
    case "h":
      return Tense.impératif
    default:
      return nil
    }
  }

  // Decodes one shorthand into the simple tense(s) it denotes, or nil if unrecognized. "A"
  // expands to every PersonNumber for the family (impératif to its three valid ones).
  static func tensesForShorthand(_ shorthand: String) -> [Tense]? {
    if let tense = personlessShorthands[shorthand] {
      return [tense]
    }
    let letter = String(shorthand.prefix(1))
    guard let makeTense = tenseConstructor(forShorthandLetter: letter) else {
      return nil
    }
    let personPart = String(shorthand.dropFirst())
    if personPart == "A" {
      let personNumbers = letter == "h" ? PersonNumber.impératifPersonNumbers : PersonNumber.allCases
      return personNumbers.map(makeTense)
    }
    guard let personNumber = PersonNumber.byShortDisplayName[personPart] else {
      return nil
    }
    return [makeTense(personNumber)]
  }

  // Every concrete tense, matching DefectGroup's universe: impératif and impératifPassé only for
  // their three valid person-numbers, every other family for all six.
  static let allConcreteCases: [Tense] = {
    var cases: [Tense] = [.participePassé, .participePrésent, .radicalFutur]
    let sixPersonFamilies: [(PersonNumber) -> Tense] = [
      Tense.indicatifPrésent, Tense.passéSimple, Tense.imparfait, Tense.futurSimple,
      Tense.conditionnelPrésent, Tense.subjonctifPrésent, Tense.subjonctifImparfait,
      Tense.passéComposé, Tense.plusQueParfait, Tense.passéAntérieur, Tense.passéSurcomposé,
      Tense.futurAntérieur, Tense.conditionnelPassé, Tense.subjonctifPassé, Tense.subjonctifPlusQueParfait
    ]
    for family in sixPersonFamilies {
      cases += PersonNumber.allCases.map(family)
    }
    for family in [Tense.impératif, Tense.impératifPassé] {
      cases += PersonNumber.impératifPersonNumbers.map(family)
    }
    return cases
  }()

  static func shorthandForNonCompoundTense(appliesTo: Set<Tense>) -> String {
    var shorthands: Set<String> = Set()

    appliesTo.forEach {
      shorthands.insert($0.shortDisplayName)
    }

    let rA = ["r1s", "r2s", "r3s", "r1p", "r2p", "r3p"]
    let xA = ["x1s", "x2s", "x3s", "x1p", "x2p", "x3p"]
    let bA = ["b1s", "b2s", "b3s", "b1p", "b2p", "b3p"]
    let iA = ["i1s", "i2s", "i3s", "i1p", "i2p", "i3p"]

    [(rA, "rA"), (xA, "xA"), (bA, "bA"), (iA, "iA")].forEach { tup in
      if Set(tup.0).isSubset(of: shorthands) {
        tup.0.forEach {
          shorthands.remove($0)
        }
        shorthands.insert(tup.1)
      }
    }

    return shorthands.sorted().joined(separator: ", ")
  }
}
