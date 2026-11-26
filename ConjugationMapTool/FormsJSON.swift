//
//  FormsJSON.swift
//  ConjugationMapTool
//
//  Created by Josh Adams on 11/22/26.
//

// The three dumps the Python pipelines in corpus/working read. They follow their own rules
// rather than the conjugation map's: the form dumps keep the radical du futur and defective
// cells, drop one-letter forms, and agree only the compound tenses' participles, because the
// corpus index was built and tuned on exactly that. See docs/literature_example_corpus.md.
//
//   forms.json         { "<form>": ["<verb id>", …] } for the 1,000 most frequent verbs, which
//                      build_corpus_index.py and build_tail_index.py match whole tokens against
//   forms_all.json     the same over every verb, for the classical and Chanson mining
//   conjugations.json  { "<verb id>": { "<tense key>": "<conjugation>" } }, verbatim, which
//                      audit_conjugations.py diffs against Wiktionary's tables
//
// A verb id is `infinitifWithPossibleExtraLetters`: "haïr (France)".

import Foundation

enum FormsJSON {
  // Single-character forms ("a", "y", "e") are noise, and the verbs that emit them (avoir,
  // aller, …) are covered many times over by their longer forms.
  private static let minFormLength = 2

  // Every verb carries a rank, so the dump needs a cutoff of its own. 1,000 keeps the set the
  // size it was when the corpus index was first built against the 2021 ranks.
  private static let rankCutoff = 1000

  static func usageRankedForms() throws -> Data {
    try forms(of: Verb.verbs.values.filter { $0.frequency <= rankCutoff })
  }

  static func allForms() throws -> Data {
    try forms(of: Array(Verb.verbs.values))
  }

  private static func forms(of verbs: [Verb]) throws -> Data {
    var index: [String: Set<String>] = [:]
    for verb in verbs {
      let id = verb.infinitifWithPossibleExtraLetters
      for tense in Tense.allConcreteCases {
        // Both genders, so that the être and reflexive verbs' agreement (mangé, mangée, …)
        // is harvested. The simple tenses ignore the gender, and the set drops the repeat.
        for gender in [PronounGender.feminine, .masculine] {
          guard let conjugation = Conjugator.conjugatedString(
            infinitif: verb.infinitif,
            tense: tense,
            extraLetters: verb.extraLetters,
            pronounGender: gender
          ) else {
            continue
          }
          // Each "/"-separated alternate is its own form ("paie/paye"). A compound tense
          // contributes only its participle, because the auxiliary ("ai", "suis", "aura") is
          // a form of avoir or être, and mapping it to every verb would make every "j'ai …" a
          // false hit.
          for alternate in conjugation.split(separator: "/") {
            // Lowercase and NFC, so that forms compare equal to NFC-normalized corpus tokens however
            // their accents were encoded upstream.
            let words = alternate.split(separator: " ").map { ConjugationMap.key($0) }
            let forms = tense.isCompound ? Array(words.suffix(1)) : words
            for token in forms where token.count >= minFormLength {
              index[token, default: []].insert(id)
            }
          }
        }
      }
    }
    let sorted = index.reduce(into: [String: [String]]()) { accumulator, pair in
      accumulator[pair.key] = pair.value.sorted()
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return try encoder.encode(sorted)
  }

  // Unlike the form dumps, which are inverted (form → verbs, so a form's tense is lost),
  // lowercased, and agreement-flattened, this keeps each verb's table as the app shows it:
  // the uppercase irregular-letter markers survive, which the audit reads, and the
  // "/"-joined alternates stay joined.
  static func allConjugations() throws -> Data {
    var dump: [String: [String: String]] = [:]
    for verb in Verb.verbs.values {
      var table: [String: String] = [:]
      for (key, tense) in auditedTenses {
        // Masculine throughout: the simple tenses ignore the gender, and it keeps the passé
        // composé's participle unagreed, so the auxiliary reads as the app conjugates it.
        guard let conjugation = Conjugator.conjugatedString(
          infinitif: verb.infinitif,
          tense: tense,
          extraLetters: verb.extraLetters,
          pronounGender: .masculine
        ) else {
          continue
        }
        table[key] = conjugation.precomposedStringWithCanonicalMapping
      }
      dump[verb.infinitifWithPossibleExtraLetters] = table
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return try encoder.encode(dump)
  }

  // Every simple tense, both participles, and the first-person-singular passé composé, so that
  // the auxiliary is visible. The radical du futur is absent: it is a stem, not a form a
  // learner writes. A key is the Tense case name, a dot, and the PersonNumber case name.
  private static let auditedTenses: [(key: String, tense: Tense)] = {
    var entries: [(key: String, tense: Tense)] = [
      ("participePassé", .participePassé),
      ("participePrésent", .participePrésent)
    ]
    let simpleFamilies: [(name: String, make: (PersonNumber) -> Tense)] = [
      ("indicatifPrésent", Tense.indicatifPrésent),
      ("passéSimple", Tense.passéSimple),
      ("imparfait", Tense.imparfait),
      ("futurSimple", Tense.futurSimple),
      ("conditionnelPrésent", Tense.conditionnelPrésent),
      ("subjonctifPrésent", Tense.subjonctifPrésent),
      ("subjonctifImparfait", Tense.subjonctifImparfait)
    ]
    for family in simpleFamilies {
      entries += PersonNumber.allCases.map { personNumber in
        (family.name + "." + personNumberName(personNumber), family.make(personNumber))
      }
    }
    entries += PersonNumber.impératifPersonNumbers.map { personNumber in
      ("impératif." + personNumberName(personNumber), Tense.impératif(personNumber))
    }
    entries.append(("passéComposé.firstSingular", .passéComposé(.firstSingular)))
    return entries
  }()

  private static func personNumberName(_ personNumber: PersonNumber) -> String {
    switch personNumber {
    case .firstSingular:
      return "firstSingular"
    case .secondSingular:
      return "secondSingular"
    case .thirdSingular:
      return "thirdSingular"
    case .firstPlural:
      return "firstPlural"
    case .secondPlural:
      return "secondPlural"
    case .thirdPlural:
      return "thirdPlural"
    }
  }
}
