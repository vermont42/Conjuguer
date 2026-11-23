//
//  KeyConjugations.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

extension Verb {
  /// The il forms of the présent, the passé composé, and the futur simple, as in "vient · est
  /// venu · viendra": with the participles and the futur stem that the page's personless card
  /// shows, they let a learner rebuild most of a verb. They are always shown with no heading.
  ///
  /// The forms stand without a subject pronoun, so the participle agrees with il whatever the
  /// pronoun-gender setting. A reflexive verb keeps its pronoun, as its cells show it (se souvient,
  /// s'est souvenu). Mixed case, as the Conjugator writes it, so that a caller can show the red
  /// letters. A form the verb's defect group marks unused, or the Conjugator cannot produce, is
  /// left out, so gésir gives only gît and accroire gives nothing.
  func keyConjugations() -> [String] {
    Self.keyTenses.compactMap { tense in
      guard
        !VerbConjugations.isDefective(verb: self, tense: tense),
        let conjugation = Conjugator.conjugatedString(infinitif: infinitif, tense: tense, extraLetters: extraLetters, pronounGender: .masculine)
      else {
        return nil
      }
      guard isReflexive else {
        return conjugation
      }
      return PersonNumber.thirdPersonReflexivePronoun(before: conjugation, hasAspiratedH: hasAspiratedH) + conjugation
    }
  }

  /// The infinitive as a dictionary cites it, with the pronoun of a verb that is only pronominal:
  /// se souvenir, s'évanouir. The page's heading shows the bare infinitive over a Reflexive note.
  var citationInfinitif: String {
    guard isReflexive else {
      return infinitif
    }
    return PersonNumber.thirdPersonReflexivePronoun(before: infinitif, hasAspiratedH: hasAspiratedH) + infinitif
  }

  /// What the verb page's share button sends: the verb, its gloss, its key conjugations, and the
  /// App Store link, in the learner's language.
  func shareText() -> String {
    var lines = [L.VerbView.shareGloss(infinitif: citationInfinitif, gloss: translation)]
    let conjugations = keyConjugations().map { $0.lowercased() }
    if !conjugations.isEmpty {
      lines.append(conjugations.joined(separator: " · "))
    }
    return lines.joined(separator: "\n") + "\n\n" + L.VerbView.shareInvitation(infinitif: citationInfinitif, link: URL.appStore.absoluteString)
  }

  /// Shared with the pedagogy plan's key-conjugations exercise and the review card.
  static let keyTenses: [Tense] = [.indicatifPrésent(.thirdSingular), .passéComposé(.thirdSingular), .futurSimple(.thirdSingular)]
}
