//
//  StemAlterationAuditTests.swift
//  ConjuguerTests
//
//  Created by Claude on 8/28/26.
//

@testable import Conjuguer
import Testing

// Guards a class of data error rather than one verb: an -er verb whose stem ends in é plus a
// consonant must sit on a model that opens that é to è before a mute ending. French has no
// *je considére; the vowel of a stressed final syllable cannot stay é. Assigning such a verb
// the plain `parler` model (1-1) leaves the stem untouched and produces exactly that non-word,
// which is how considérer, interpréter, décolérer, désaciérer and refréner shipped for years
// beside correctly modeled twins.
//
// The audit reads the conjugator's own output rather than the model id, so it also covers the
// -éger (1-6C) and -écer (1-6B) families, whose models open the stem while softening g or c.
@MainActor
struct StemAlterationAuditTests {
  // é immediately before the infinitive ending is a different matter and stays put: créer,
  // agréer and the rest of the -éer family give je crée, never *je crèe. So the é must be
  // separated from the ending by at least one consonant.
  private static let vowels = Set("aeiouyéèêëàâîïôûù")

  private static func stemEndsInÉPlusConsonant(_ infinitif: String) -> Bool {
    guard infinitif.hasSuffix("er") else {
      return false
    }
    let stem = infinitif.dropLast(2)
    guard let last = stem.last, !vowels.contains(last) else {
      return false
    }
    return stem.dropLast().last == "é"
  }

  @Test func testNoStressedStemKeepsItsÉ() {
    var examined = 0
    var offenders: [String] = []

    for verb in Verb.verbs.values where Self.stemEndsInÉPlusConsonant(verb.infinitif) {
      guard let présent = Conjugator.conjugatedString(
        infinitif: verb.infinitif,
        tense: .indicatifPrésent(.firstSingular),
        extraLetters: verb.extraLetters
      ) else {
        continue
      }
      examined += 1

      // The conjugator uppercases irregular characters, so an opened stem reads È. A form that
      // still carries a lowercase é and never opened one is a stem the model left alone.
      if présent.contains("é") && !présent.contains("È") {
        offenders.append("\(verb.infinitif) (model \(verb.model)) → \(présent)")
      }
    }

    // The filter is the load-bearing half of this audit; if a refactor were to stop matching,
    // the expectation below would pass vacuously. 176 verbs matched on 2026-08-28.
    #expect(examined > 150, "Audit examined only \(examined) verbs — the infinitive filter is broken.")
    #expect(offenders.isEmpty, "Stems that keep é before a mute ending:\n\(offenders.joined(separator: "\n"))")
  }

  // The pair that motivated the audit. Both spellings are one verb in the TLFi, which heads the
  // entry REFRÉNER, RÉFRÉNER, and both carry é in the stressed syllable, so neither may sit on
  // the regular model.
  @Test func testRefrénerConjugatesLikeItsTwin() {
    T.testConjugation(infinitif: "refréner", tense: .indicatifPrésent(.firstSingular), expected: "refrÈne", extraLetters: nil)
    T.testConjugation(infinitif: "refréner", tense: .indicatifPrésent(.firstPlural), expected: "refrénons", extraLetters: nil)
    T.testConjugation(infinitif: "refréner", tense: .futurSimple(.firstSingular), expected: "refrénerai", extraLetters: nil)
    T.testConjugation(infinitif: "refréner", tense: .participePassé, expected: "refréné", extraLetters: nil)

    T.testConjugation(infinitif: "réfréner", tense: .indicatifPrésent(.firstSingular), expected: "réfrÈne", extraLetters: nil)
    T.testConjugation(infinitif: "réfréner", tense: .indicatifPrésent(.firstPlural), expected: "réfrénons", extraLetters: nil)
    T.testConjugation(infinitif: "réfréner", tense: .futurSimple(.firstSingular), expected: "réfrénerai", extraLetters: nil)
    T.testConjugation(infinitif: "réfréner", tense: .participePassé, expected: "réfréné", extraLetters: nil)
  }

  // The four the audit turned up alongside refréner, two of them common verbs.
  @Test(arguments: [
    ("considérer", "considÈre", "considérons"),
    ("interpréter", "interprÈte", "interprétons"),
    ("décolérer", "décolÈre", "décolérons"),
    ("désaciérer", "désaciÈre", "désaciérons")
  ])
  func testFormerlyRegularStemsNowOpen(infinitif: String, singular: String, plural: String) {
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.firstSingular), expected: singular, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.firstPlural), expected: plural, extraLetters: nil)
  }
}
