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
    // Use feminine pronouns regardless of user preference.
    Current.settings = Settings(getterSetter: DictionaryGetterSetter())
    let aller = "aller"
    let avoir = "avoir"

    var personNumbersIndex = 0

    for conjugation in ["SUIs allée", "Es allée", "ESt allée", "SOMMEs allées", "êteS allées", "SOnt allées"] {
      T.testConjugation(infinitif: aller, tense: .passéComposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aI EU", "As EU", "A EU", "avons EU", "avez EU", "Ont EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéComposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Étais allée", "Étais allée", "Était allée", "Étions allées", "Étiez allées", "Étaient allées"] {
      T.testConjugation(infinitif: aller, tense: .plusQueParfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["avais EU", "avais EU", "avait EU", "avions EU", "aviez EU", "avaient EU"] {
      T.testConjugation(infinitif: avoir, tense: .plusQueParfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Fus allée", "Fus allée", "Fut allée", "Fûmes allées", "Fûtes allées", "Furent allées"] {
      T.testConjugation(infinitif: aller, tense: .passéAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Eus EU", "Eus EU", "Eut EU", "Eûmes EU", "Eûtes EU", "Eurent EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aI ÉtÉ allée", "As ÉtÉ allée", "A ÉtÉ allée", "avons ÉtÉ allées", "avez ÉtÉ allées", "Ont ÉtÉ allées"] {
      T.testConjugation(infinitif: aller, tense: .passéSurcomposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aI EU EU", "As EU EU", "A EU EU", "avons EU EU", "avez EU EU", "Ont EU EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéSurcomposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SErai allée", "SEras allée", "SEra allée", "SErons allées", "SErez allées", "SEront allées"] {
      T.testConjugation(infinitif: aller, tense: .futurAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aUrai EU", "aUras EU", "aUra EU", "aUrons EU", "aUrez EU", "aUront EU"] {
      T.testConjugation(infinitif: avoir, tense: .futurAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SErais allée", "SErais allée", "SErait allée", "SErions allées", "SEriez allées", "SEraient allées"] {
      T.testConjugation(infinitif: aller, tense: .conditionnelPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aUrais EU", "aUrais EU", "aUrait EU", "aUrions EU", "aUriez EU", "aUraient EU"] {
      T.testConjugation(infinitif: avoir, tense: .conditionnelPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SOIS allée", "SOIs allée", "SOIT allée", "SOYons allées", "SOYez allées", "SOIent allées"] {
      T.testConjugation(infinitif: aller, tense: .subjonctifPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aIE EU", "aIES EU", "aIT EU", "aYons EU", "aYez EU", "aIENT EU"] {
      T.testConjugation(infinitif: avoir, tense: .subjonctifPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Fusse allée", "Fusses allée", "Fût allée", "Fussions allées", "Fussiez allées", "Fussent allées"] {
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

    for conjugation in ["SOIs allée", "SOYons allées", "SOYez allées"] {
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
