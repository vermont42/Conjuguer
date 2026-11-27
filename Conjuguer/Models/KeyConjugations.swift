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
    keyConjugationsByStem().map { _, conjugation in
      guard isReflexive else {
        return conjugation
      }
      return PersonNumber.thirdPersonReflexivePronoun(before: conjugation, hasAspiratedH: hasAspiratedH) + conjugation
    }
  }

  /// Which key conjugations the verb has, and each one's bare form. The page's forms and the
  /// practice schedule's items both come from here, so the review card never shows a form the
  /// schedule does not hold.
  func keyConjugationsByStem() -> [(stem: PracticeItem.Stem, conjugation: String)] {
    PracticeItem.Stem.shown.compactMap { stem in
      guard
        !VerbConjugations.isDefective(verb: self, tense: stem.keyTense),
        let conjugation = Conjugator.conjugatedString(infinitif: infinitif, tense: stem.keyTense, extraLetters: extraLetters, pronounGender: .masculine)
      else {
        return nil
      }
      return (stem, conjugation)
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

  static let keyTenses = PracticeItem.Stem.shown.map(\.keyTense)
}
