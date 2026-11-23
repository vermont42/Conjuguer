//
//  ConjugationMatch.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// A cell of a verb's conjugation tables whose conjugation equals a given text. Search names a
/// result with these (vais: Indicatif Présent, je, of aller), and the quiz can use them to tell
/// a learner which other cell an answer belongs to.
struct ConjugationMatch: Hashable {
  let tense: Tense

  /// True when the text is the participe passé agreed (allée, allés, allées) rather than as
  /// its cell shows it (allé). Only the participe passé matches this way.
  let isAgreement: Bool
}

extension Verb {
  /// Every cell whose conjugation equals `text`, in the order the verb page shows them, case
  /// and spacing ignored. A compound cell matches with its participle agreed either way, so
  /// "est allé" and "est allée" both match aller's passé composé. An impératif matches as the
  /// quiz asks for it (souviens) and as the page shows it (souviens-toi). Accents must match:
  /// "etait" matches nothing, because a cell is spelled one way, and search folds accents
  /// before it gets here. A cell the verb's defect group lacks never matches, and neither
  /// does the infinitive, which is not a cell. `ConjugationResult.score` grades more
  /// leniently, since it forgives a missing circumflex.
  func conjugations(matching text: String) -> [ConjugationMatch] {
    let wanted = Self.normalizedConjugation(text)
    guard !wanted.isEmpty else {
      return []
    }
    let defectGroup = defectGroupId.flatMap { DefectGroup.defectGroups[$0] }
    var matches: [ConjugationMatch] = []
    for tense in Self.cellsInPageOrder where defectGroup?.isDefectiveForTense(tense) != true {
      let spellings = spellings(of: tense)
      if spellings.contains(wanted) {
        matches.append(ConjugationMatch(tense: tense, isAgreement: false))
      } else if tense == .participePassé, spellings.contains(where: { ConjugationMap.agreedForms(ofParticiple: $0).contains(wanted) }) {
        matches.append(ConjugationMatch(tense: tense, isAgreement: true))
      }
    }
    return matches
  }

  private func spellings(of tense: Tense) -> Set<String> {
    let genders: [PronounGender] = tense.isCompound ? [.masculine, .feminine] : [.masculine]
    var spellings: Set<String> = []
    for gender in genders {
      guard let conjugation = Conjugator.conjugatedString(infinitif: infinitif, tense: tense, extraLetters: extraLetters, pronounGender: gender) else {
        continue
      }
      for alternate in conjugation.components(separatedBy: Tense.alternateConjugationSeparator) {
        spellings.insert(Self.normalizedConjugation(alternate))
        if case .impératif(let personNumber) = tense, isReflexive {
          spellings.insert(Self.normalizedConjugation(personNumber.impératifAndPossibleReflexivePronoun(alternate, isReflexive: true)))
        }
      }
    }
    return spellings
  }

  private static func normalizedConjugation(_ text: String) -> String {
    text
      .lowercased()
      .precomposedStringWithCanonicalMapping
      .split(whereSeparator: \.isWhitespace)
      .joined(separator: " ")
  }

  private static let cellsInPageOrder = TenseTable.allTenses
}
