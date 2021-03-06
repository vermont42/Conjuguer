//
//  CompoundTenseTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 1/1/21.
//

@testable import Conjuguer
import XCTest

class CompoundTenseTests: XCTestCase {
  func testCompoundTenses() {
    let aller = "aller"
    let avoir = "avoir"

    var personNumbersIndex = 0

    for conjugation in ["SUIs allé", "Es allé", "ESt allé", "SOMMEs allé", "êteS allé", "SOnt allé"] {
      T.testConjugation(infinitif: aller, tense: .passéComposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aI EU", "As EU", "A EU", "avons EU", "avez EU", "Ont EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéComposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Étais allé", "Étais allé", "Était allé", "Étions allé", "Étiez allé", "Étaient allé"] {
      T.testConjugation(infinitif: aller, tense: .plusQueParfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["avais EU", "avais EU", "avait EU", "avions EU", "aviez EU", "avaient EU"] {
      T.testConjugation(infinitif: avoir, tense: .plusQueParfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Fus allé", "Fus allé", "Fut allé", "Fûmes allé", "Fûtes allé", "Furent allé"] {
      T.testConjugation(infinitif: aller, tense: .passéAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Eus EU", "Eus EU", "Eut EU", "Eûmes EU", "Eûtes EU", "Eurent EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aI ÉtÉ allé", "As ÉtÉ allé", "A ÉtÉ allé", "avons ÉtÉ allé", "avez ÉtÉ allé", "Ont ÉtÉ allé"] {
      T.testConjugation(infinitif: aller, tense: .passéSurcomposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aI EU EU", "As EU EU", "A EU EU", "avons EU EU", "avez EU EU", "Ont EU EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéSurcomposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SErai allé", "SEras allé", "SEra allé", "SErons allé", "SErez allé", "SEront allé"] {
      T.testConjugation(infinitif: aller, tense: .futurAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aUrai EU", "aUras EU", "aUra EU", "aUrons EU", "aUrez EU", "aUront EU"] {
      T.testConjugation(infinitif: avoir, tense: .futurAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SErais allé", "SErais allé", "SErait allé", "SErions allé", "SEriez allé", "SEraient allé"] {
      T.testConjugation(infinitif: aller, tense: .conditionnelPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aUrais EU", "aUrais EU", "aUrait EU", "aUrions EU", "aUriez EU", "aUraient EU"] {
      T.testConjugation(infinitif: avoir, tense: .conditionnelPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SOIS allé", "SOIs allé", "SOIT allé", "SOYons allé", "SOYez allé", "SOIent allé"] {
      T.testConjugation(infinitif: aller, tense: .subjonctifPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aIE EU", "aIES EU", "aIT EU", "aYons EU", "aYez EU", "aIENT EU"] {
      T.testConjugation(infinitif: avoir, tense: .subjonctifPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Fusse allé", "Fusses allé", "Fût allé", "Fussions allé", "Fussiez allé", "Fussent allé"] {
      T.testConjugation(infinitif: aller, tense: .subjonctifPlusQueParfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Eusse EU", "Eusses EU", "Eût EU", "Eussions EU", "Eussiez EU", "Eussent EU"] {
      T.testConjugation(infinitif: avoir, tense: .subjonctifPlusQueParfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    var impératifPersonNumbersIndex = 0

    for conjugation in ["SOIs allé", "SOYons allé", "SOYez allé"] {
      T.testConjugation(infinitif: aller, tense: .impératifPassé(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }

    for conjugation in ["aIE EU", "aYons EU", "aYez EU"] {
      T.testConjugation(infinitif: avoir, tense: .impératifPassé(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }
}
