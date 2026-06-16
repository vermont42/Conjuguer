//
//  CompoundTenseTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 1/1/21.
//

@testable import Conjuguer
import XCTest

@MainActor
class CompoundTenseTests: XCTestCase {
  private func assertFeminine(
    _ infinitif: String,
    _ tenseBuilder: (PersonNumber) -> Tense,
    _ expected: [String],
    personNumbers: [PersonNumber] = PersonNumber.allCases
  ) {
    XCTAssertEqual(expected.count, personNumbers.count, "Expected one conjugation per person-number.")
    for (personNumber, conjugation) in zip(personNumbers, expected) {
      T.testConjugation(infinitif: infinitif, tense: tenseBuilder(personNumber), expected: conjugation, extraLetters: nil, pronounGender: .feminine)
    }
  }

  func testCompoundTenses() {
    let aller = "aller"
    let avoir = "avoir"

    assertFeminine(aller, Tense.passéComposé, ["SUIs allée", "Es allée", "ESt allée", "SOMMEs allées", "êteS allées", "SOnt allées"])
    assertFeminine(avoir, Tense.passéComposé, ["aI EU", "As EU", "A EU", "avons EU", "avez EU", "Ont EU"])

    assertFeminine(aller, Tense.plusQueParfait, ["Étais allée", "Étais allée", "Était allée", "Étions allées", "Étiez allées", "Étaient allées"])
    assertFeminine(avoir, Tense.plusQueParfait, ["avais EU", "avais EU", "avait EU", "avions EU", "aviez EU", "avaient EU"])

    assertFeminine(aller, Tense.passéAntérieur, ["Fus allée", "Fus allée", "Fut allée", "Fûmes allées", "Fûtes allées", "Furent allées"])
    assertFeminine(avoir, Tense.passéAntérieur, ["Eus EU", "Eus EU", "Eut EU", "Eûmes EU", "Eûtes EU", "Eurent EU"])

    assertFeminine(aller, Tense.passéSurcomposé, ["aI ÉtÉ allée", "As ÉtÉ allée", "A ÉtÉ allée", "avons ÉtÉ allées", "avez ÉtÉ allées", "Ont ÉtÉ allées"])
    assertFeminine(avoir, Tense.passéSurcomposé, ["aI EU EU", "As EU EU", "A EU EU", "avons EU EU", "avez EU EU", "Ont EU EU"])

    assertFeminine(aller, Tense.futurAntérieur, ["SErai allée", "SEras allée", "SEra allée", "SErons allées", "SErez allées", "SEront allées"])
    assertFeminine(avoir, Tense.futurAntérieur, ["aUrai EU", "aUras EU", "aUra EU", "aUrons EU", "aUrez EU", "aUront EU"])

    assertFeminine(aller, Tense.conditionnelPassé, ["SErais allée", "SErais allée", "SErait allée", "SErions allées", "SEriez allées", "SEraient allées"])
    assertFeminine(avoir, Tense.conditionnelPassé, ["aUrais EU", "aUrais EU", "aUrait EU", "aUrions EU", "aUriez EU", "aUraient EU"])

    assertFeminine(aller, Tense.subjonctifPassé, ["SOIS allée", "SOIs allée", "SOIT allée", "SOYons allées", "SOYez allées", "SOIent allées"])
    assertFeminine(avoir, Tense.subjonctifPassé, ["aIE EU", "aIES EU", "aIT EU", "aYons EU", "aYez EU", "aIENT EU"])

    assertFeminine(aller, Tense.subjonctifPlusQueParfait, ["Fusse allée", "Fusses allée", "Fût allée", "Fussions allées", "Fussiez allées", "Fussent allées"])
    assertFeminine(avoir, Tense.subjonctifPlusQueParfait, ["Eusse EU", "Eusses EU", "Eût EU", "Eussions EU", "Eussiez EU", "Eussent EU"])

    assertFeminine(aller, Tense.impératifPassé, ["SOIs allée", "SOYons allées", "SOYez allées"], personNumbers: PersonNumber.impératifPersonNumbers)
    assertFeminine(avoir, Tense.impératifPassé, ["aIE EU", "aYons EU", "aYez EU"], personNumbers: PersonNumber.impératifPersonNumbers)
  }
}
