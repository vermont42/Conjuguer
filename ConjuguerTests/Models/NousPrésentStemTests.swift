//
//  NousPrésentStemTests.swift
//  ConjuguerTests
//

@testable import Conjuguer
import Testing

// Regression coverage for the `nousPrésentStem` trailing-strip fix. The imparfait
// and participe présent stems are derived by stripping the -ons ending off the
// *nous* présent form. A prior global `replacingOccurrences(of: "ons", …)` removed
// EVERY "ons", mangling any verb whose stem contains an internal "ons"
// (consommer → "je commais" / "commant", conseiller → "je ceillais", …). These
// tests pin the correct forms and confirm the previously-correct cases still hold.
@MainActor
struct NousPrésentStemTests {
  private func assertImparfait(_ infinitif: String, _ expected: [String]) {
    #expect(expected.count == PersonNumber.allCases.count, "Expected one conjugation per person-number.")
    for (personNumber, conjugation) in zip(PersonNumber.allCases, expected) {
      T.testConjugation(infinitif: infinitif, tense: .imparfait(personNumber), expected: conjugation, extraLetters: nil)
    }
  }

  @Test func testStemWithInternalOnsIsPreserved() {
    // Verbs whose *nous* stem contains an internal "ons" — the core of the bug.
    assertImparfait("consommer", ["consommais", "consommais", "consommait", "consommions", "consommiez", "consommaient"])
    T.testConjugation(infinitif: "consommer", tense: .participePrésent, expected: "consommant", extraLetters: nil)

    assertImparfait("conseiller", ["conseillais", "conseillais", "conseillait", "conseillions", "conseilliez", "conseillaient"])
    T.testConjugation(infinitif: "conseiller", tense: .participePrésent, expected: "conseillant", extraLetters: nil)

    assertImparfait("considérer", ["considérais", "considérais", "considérait", "considérions", "considériez", "considéraient"])
    T.testConjugation(infinitif: "considérer", tense: .participePrésent, expected: "considérant", extraLetters: nil)
  }

  @Test func testStemWithoutInternalOnsStillCorrect() {
    // Verbs whose only "ons" was the ending must remain unchanged by the fix.
    assertImparfait("ronronner", ["ronronnais", "ronronnais", "ronronnait", "ronronnions", "ronronniez", "ronronnaient"])
    T.testConjugation(infinitif: "ronronner", tense: .participePrésent, expected: "ronronnant", extraLetters: nil)

    // Irregular-marked stems (couvrir, maudire) route through the same helper.
    T.testConjugation(infinitif: "couvrir", tense: .participePrésent, expected: "couvrant", extraLetters: nil)
    T.testConjugation(infinitif: "maudire", tense: .participePrésent, expected: "maudISSant", extraLetters: nil)

    // Alternate *nous* forms ("asseYons/assOYons") must strip the -ons ending off
    // EACH alternate, not just the trailing one.
    assertImparfait("asseoir", ["asseYais/assOYais", "asseYais/assOYais", "asseYait/assOYait", "asseYions/assOYions", "asseYiez/assOYiez", "asseYaient/assOYaient"])
    T.testConjugation(infinitif: "asseoir", tense: .participePrésent, expected: "asseY/assOYant", extraLetters: nil)
  }
}
