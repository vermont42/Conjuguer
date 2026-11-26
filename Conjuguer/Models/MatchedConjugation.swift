//
//  MatchedConjugation.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// The conjugation that a search result matched, and the cells of the verb's page it fills.
struct MatchedConjugation: Hashable {
  /// As the app spells it, which is not always as typed: était for etait, "ai mangé" for
  /// "j'ai mangé".
  let text: String

  /// In page order. Never empty.
  let cells: [ConjugationMatch]

  /// Whether the text agrees a participle in the feminine, as "est allée" does, so that a third
  /// person is named elle or elles whatever the pronoun setting.
  var isFeminine = false

  // French, like the tense names beside it, which the app never translates.
  static let agreementName = "accordé"

  /// "Indicatif Présent (je, tu) · Impératif (tu)": each tense once, with the persons whose
  /// cells match, as the verb page names them.
  func cellNames(pronounGender: PronounGender) -> String {
    var sections: [(name: String, persons: [String])] = []
    for cell in cells {
      let name = cell.tense.titleCaseName
      let gender = isFeminine ? .feminine : pronounGender
      var persons = cell.tense.personNumber.map { [$0.searchLabel(pronounGender: gender)] } ?? []
      if cell.isAgreement {
        persons.append(Self.agreementName)
      }
      if let index = sections.firstIndex(where: { $0.name == name }) {
        sections[index].persons += persons.filter { !sections[index].persons.contains($0) }
      } else {
        sections.append((name, persons))
      }
    }
    return sections
      .map { $0.persons.isEmpty ? $0.name : "\($0.name) (\($0.persons.joined(separator: ", ")))" }
      .joined(separator: " · ")
  }

  /// "vais : Indicatif Présent (je)", the line a search result shows under its verb. The line is
  /// French in either interface language, so it takes French punctuation: a narrow no-break
  /// space before the colon.
  func line(pronounGender: PronounGender) -> String {
    "\(text)\u{202F}: \(cellNames(pronounGender: pronounGender))"
  }

  var marks: MarkedConjugations {
    MarkedConjugations(tenses: cells.map(\.tense))
  }
}

/// The cells of a verb page that a search matched. The page scrolls to the first, shows the
/// compound tenses if any is compound, and marks them all.
struct MarkedConjugations: Hashable {
  /// In page order, so that the first is the one to scroll to.
  let tenses: [Tense]

  func contains(_ tense: Tense) -> Bool {
    tenses.contains(tense)
  }

  var includesCompoundTense: Bool {
    tenses.contains(where: \.isCompound)
  }
}

extension PersonNumber {
  /// The person as a search result names it: the subject pronoun, with the third person's
  /// gender as the verb page shows it, and no elision.
  func searchLabel(pronounGender: PronounGender) -> String {
    switch self {
    case .firstSingular:
      return "je"
    case .secondSingular:
      return "tu"
    case .thirdSingular:
      return pronounGender.thirdSingular
    case .firstPlural:
      return "nous"
    case .secondPlural:
      return "vous"
    case .thirdPlural:
      return pronounGender.thirdPlural
    }
  }
}

extension MarkedConjugations {
  /// The cells of `verb`'s page that `text` fills, read as search reads it, so that a link's
  /// `match` item can carry whatever a search row matched: vais, "ai mangé", or "me suis levé" on
  /// lever. Nil when the text fills none of them.
  init?(text: String, on verb: Verb, index: ConjugationIndex = .bundled) {
    let matches = VerbSearch.conjugationMatches(for: text, index: index) { key in
      key == verb.dictionaryKey ? verb : nil
    }
    guard let conjugation = matches.first(where: { $0.verb == verb })?.conjugation else {
      return nil
    }
    self = conjugation.marks
  }
}
