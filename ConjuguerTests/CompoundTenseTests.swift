//
//  ConjuguerTests.swift
//  ConjuguerTests
//
//  Created by Joshua Adams on 1/1/21.
//

@testable import Conjuguer
import XCTest

class ConjuguerTests: XCTestCase {
  func testCompoundTenses() {
    let aller = "aller"
    let avoir = "avoir"

    var personNumbersIndex = 0

    for conjugation in ["SUIS allé", "Es allé", "EST allé", "SOMMEs allé", "êteS allé", "SOnt allé"] {
      T.testConjugation(infinitif: aller, tense: .passéComposé(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["AI EU", "As EU", "A EU", "aVons EU", "aVez EU", "Ont EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéComposé(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["Étais allé", "Étais allé", "Était allé", "Étions allé", "Étiez allé", "Étaient allé"] {
      T.testConjugation(infinitif: aller, tense: .plusQueParfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["aVais EU", "aVais EU", "aVait EU", "aVions EU", "aViez EU", "aVaient EU"] {
      T.testConjugation(infinitif: avoir, tense: .plusQueParfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["FUs allé", "FUs allé", "FUt allé", "FÛmes allé", "FÛtes allé", "FUrent allé"] {
      T.testConjugation(infinitif: aller, tense: .passéAntérieur(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["Eus EU", "Eus EU", "Eut EU", "Eûmes EU", "Eûtes EU", "Eurent EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéAntérieur(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["AI ÉTÉ allé", "As ÉTÉ allé", "A ÉTÉ allé", "aVons ÉTÉ allé", "aVez ÉTÉ allé", "Ont ÉTÉ allé"] {
      T.testConjugation(infinitif: aller, tense: .passéSurcomposé(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["AI EU EU", "As EU EU", "A EU EU", "aVons EU EU", "aVez EU EU", "Ont EU EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéSurcomposé(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["SErai allé", "SEras allé", "SEra allé", "SErons allé", "SErez allé", "SEront allé"] {
      T.testConjugation(infinitif: aller, tense: .futurAntérieur(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["aUrai EU", "aUras EU", "aUra EU", "aUrons EU", "aUrez EU", "aUront EU"] {
      T.testConjugation(infinitif: avoir, tense: .futurAntérieur(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["SErais allé", "SErais allé", "SErait allé", "SErions allé", "SEriez allé", "SEraient allé"] {
      T.testConjugation(infinitif: aller, tense: .conditionnelPassé(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["aUrais EU", "aUrais EU", "aUrait EU", "aUrions EU", "aUriez EU", "aUraient EU"] {
      T.testConjugation(infinitif: avoir, tense: .conditionnelPassé(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["SOIS allé", "SOIs allé", "SOIT allé", "SOYons allé", "SOYez allé", "SOIent allé"] {
      T.testConjugation(infinitif: aller, tense: .subjonctifPassé(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["aIe EU", "aIes EU", "aIT EU", "aYons EU", "aYez EU", "aIent EU"] {
      T.testConjugation(infinitif: avoir, tense: .subjonctifPassé(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["FUsse allé", "FUsses allé", "FÛt allé", "FUssions allé", "FUssiez allé", "FUssent allé"] {
      T.testConjugation(infinitif: aller, tense: .subjonctifPlusQueParfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["Eusse EU", "Eusses EU", "Eût EU", "Eussions EU", "Eussiez EU", "Eussent EU"] {
      T.testConjugation(infinitif: avoir, tense: .subjonctifPlusQueParfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    var impératifPersonNumbersIndex = 0
    
    for conjugation in ["SOIs allé", "SOYons allé", "SOYez allé"] {
      T.testConjugation(infinitif: aller, tense: .impératifPassé(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }

    for conjugation in ["AIe EU", "AYons EU", "AYez EU"] {
      T.testConjugation(infinitif: avoir, tense: .impératifPassé(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }
}
