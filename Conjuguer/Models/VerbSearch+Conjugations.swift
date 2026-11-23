//
//  VerbSearch+Conjugations.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

extension VerbSearch {
  /// The verbs that `query` is a conjugation of, each with the cells it fills. One word is
  /// looked up in the conjugation map, as typed and then folded. More than one is a compound
  /// conjugation: its last word, the participle, is looked up, and the verb's own cells confirm
  /// the whole ("ai mangé", "avions fini"). Pronouns and negation are dropped first
  /// (`ConjugationQuery`).
  static func conjugationMatches(for query: String, index: ConjugationIndex, verbNamed: (String) -> Verb?) -> [Match] {
    let parsed = ConjugationQuery(query)
    guard let lastWord = parsed.words.last else {
      return []
    }
    if parsed.words.count == 1 {
      return simpleMatches(for: lastWord, index: index, verbNamed: verbNamed)
    }
    return compoundMatches(
      auxiliaryWords: Array(parsed.words.dropLast()),
      participle: lastWord,
      reflexivePronoun: parsed.reflexivePronoun,
      index: index,
      verbNamed: verbNamed
    )
  }

  /// A hyphenated word is looked up whole first, since arc-boutait is one conjugation, and then
  /// by its verb alone: lève-toi is lève, and vas-tu is vas. Whole, souviens-toi matches only
  /// souvenir's impératif, as the page shows it.
  private static func simpleMatches(for word: String, index: ConjugationIndex, verbNamed: (String) -> Verb?) -> [Match] {
    var lookups = [(key: word, confirmation: word)]
    if let verbPart = ConjugationQuery.verbPart(ofHyphenated: word) {
      lookups.append((verbPart, word))
      lookups.append((verbPart, verbPart))
    }
    var found: [Match] = []
    var foundVerbs: Set<String> = []
    for lookup in lookups {
      for spelling in index.spellings(of: lookup.key) {
        let confirmation = lookup.key == lookup.confirmation ? spelling.conjugation : ConjugationMap.key(lookup.confirmation)
        for verbKey in index.map.verbs(for: spelling.conjugation) {
          guard let verb = verbNamed(verbKey), !foundVerbs.contains(verb.id) else {
            continue
          }
          // An infinitive is in the map but is no cell, and the infinitive search finds it.
          let cells = verb.conjugations(matching: confirmation)
          guard !cells.isEmpty else {
            continue
          }
          foundVerbs.insert(verb.id)
          found.append(Match(
            verb: verb,
            kind: spelling.isFolded ? .foldedConjugation : .conjugation,
            conjugation: MatchedConjugation(text: confirmation, cells: cells)
          ))
        }
      }
    }
    return found
  }

  private static func compoundMatches(
    auxiliaryWords: [String],
    participle: String,
    reflexivePronoun: String?,
    index: ConjugationIndex,
    verbNamed: (String) -> Verb?
  ) -> [Match] {
    let auxiliaries = auxiliarySpellings(of: auxiliaryWords, index: index)
    var found: [Match] = []
    var foundVerbs: Set<String> = []
    for participleSpelling in index.spellings(of: participle) {
      for verbKey in index.map.verbs(for: participleSpelling.conjugation) {
        guard let verb = verbNamed(verbKey), !foundVerbs.contains(verb.id) else {
          continue
        }
        for auxiliary in auxiliaries {
          var text = "\(auxiliary.text) \(participleSpelling.conjugation)"
          var cells = verb.conjugations(matching: text).filter(\.tense.isCompound)
          if cells.isEmpty, let reflexivePronoun {
            cells = pronominalCells(of: verb, auxiliary: auxiliary.text, participle: participleSpelling.conjugation)
            text = reflexivePronoun.hasSuffix("'") ? reflexivePronoun + text : "\(reflexivePronoun) \(text)"
          }
          guard !cells.isEmpty else {
            continue
          }
          foundVerbs.insert(verb.id)
          let isFolded = participleSpelling.isFolded || auxiliary.isFolded
          found.append(Match(
            verb: verb,
            kind: isFolded ? .foldedConjugation : .conjugation,
            conjugation: MatchedConjugation(
              text: text,
              cells: cells,
              isFeminine: isFeminine(participleSpelling.conjugation, of: verb)
            )
          ))
          break
        }
      }
    }
    return found
  }

  /// Every spelling of the auxiliary's words, as typed and folded, so that "etait allee" finds
  /// "était allée". A word the map lacks stays as typed, and the verb's cells reject it.
  private static func auxiliarySpellings(of words: [String], index: ConjugationIndex) -> [(text: String, isFolded: Bool)] {
    var spellings: [(text: String, isFolded: Bool)] = [("", false)]
    for word in words {
      let wordSpellings = index.spellings(of: word)
      let options = wordSpellings.isEmpty ? [ConjugationIndex.Spelling(conjugation: ConjugationMap.key(word), isFolded: false)] : wordSpellings
      spellings = spellings.flatMap { prefix in
        options.map { option in
          (prefix.text.isEmpty ? option.conjugation : "\(prefix.text) \(option.conjugation)", prefix.isFolded || option.isFolded)
        }
      }
    }
    return spellings
  }

  /// Whether `participle` is the verb's participe passé agreed in the feminine: allée or allées,
  /// but not allé or allés, and not pris, which is both masculine forms.
  private static func isFeminine(_ participle: String, of verb: Verb) -> Bool {
    guard let masculine = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .participePassé, extraLetters: verb.extraLetters, pronounGender: .masculine) else {
      return false
    }
    return masculine.components(separatedBy: Tense.alternateConjugationSeparator).contains { alternate in
      let forms = ConjugationMap.agreedForms(ofParticiple: ConjugationMap.key(alternate))
      return participle == forms[0] || participle == forms[2]
    }
  }

  /// The compound cells that a pronominal use of an avoir verb fills: "me suis levé" is
  /// lever's passé composé, je, though the page shows "j'ai levé", because the verb page
  /// conjugates lever as it is stored, with avoir. Only when the query carried a reflexive
  /// pronoun, since "est levé" alone is a passive.
  private static func pronominalCells(of verb: Verb, auxiliary: String, participle: String) -> [ConjugationMatch] {
    guard
      !verb.isReflexive,
      verb.auxiliary == .avoir,
      verb.conjugations(matching: participle).contains(where: { $0.tense == .participePassé })
    else {
      return []
    }
    return TenseTable.compound
      .flatMap(\.tenses)
      .filter { tense in
        guard let personNumber = tense.personNumber else {
          return false
        }
        return ConjugationMap.key(tense.conjugatedAuxiliary(personNumber: personNumber, auxiliary: .être)) == auxiliary
      }
      .map { ConjugationMatch(tense: $0, isAgreement: false) }
  }
}
