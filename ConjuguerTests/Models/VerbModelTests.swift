//
//  VerbModelTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 1/13/21.
//

@testable import Conjuguer
import XCTest

/*
class GenerateVerbModelTests: XCTestCase {
  func testGenerateVerbModelTests() {
    T.generateVerbModelTests()
  }
}
*/

class VerbModelTests: XCTestCase {
  func testAbsoudre() {
    // ID: 5-13
    var personNumbersIndex = 0

    for conjugation in ["absoUs", "absoUs", "absoUt", "absoLVons", "absoLVez", "absoLVent"] {
      T.testConjugation(infinitif: "absoudre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoLVais", "absoLVais", "absoLVait", "absoLVions", "absoLViez", "absoLVaient"] {
      T.testConjugation(infinitif: "absoudre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoudrai", "absoudras", "absoudra", "absoudrons", "absoudrez", "absoudront"] {
      T.testConjugation(infinitif: "absoudre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoudrais", "absoudrais", "absoudrait", "absoudrions", "absoudriez", "absoudraient"] {
      T.testConjugation(infinitif: "absoudre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoLus", "absoLus", "absoLut", "absoLûmes", "absoLûtes", "absoLurent"] {
      T.testConjugation(infinitif: "absoudre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoLVe", "absoLVes", "absoLVe", "absoLVions", "absoLViez", "absoLVent"] {
      T.testConjugation(infinitif: "absoudre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoLusse", "absoLusses", "absoLût", "absoLussions", "absoLussiez", "absoLussent"] {
      T.testConjugation(infinitif: "absoudre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "absoudre", tense: .participePassé, expected: "absouS", extraLetters: nil)
    T.testConjugation(infinitif: "absoudre", tense: .participePrésent, expected: "absoLVant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["absoUs", "absoLVons", "absoLVez"] {
      T.testConjugation(infinitif: "absoudre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAccroître() {
    // ID: 5-19B
    var personNumbersIndex = 0

    for conjugation in ["accroIs", "accroIs", "accroÎt", "accroISSons", "accroISSez", "accroISSent"] {
      T.testConjugation(infinitif: "accroître", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accroISSais", "accroISSais", "accroISSait", "accroISSions", "accroISSiez", "accroISSaient"] {
      T.testConjugation(infinitif: "accroître", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accroîtrai", "accroîtras", "accroîtra", "accroîtrons", "accroîtrez", "accroîtront"] {
      T.testConjugation(infinitif: "accroître", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accroîtrais", "accroîtrais", "accroîtrait", "accroîtrions", "accroîtriez", "accroîtraient"] {
      T.testConjugation(infinitif: "accroître", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accrUs", "accrUs", "accrUt", "accrÛmes", "accrÛtes", "accrUrent"] {
      T.testConjugation(infinitif: "accroître", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accroISSe", "accroISSes", "accroISSe", "accroISSions", "accroISSiez", "accroISSent"] {
      T.testConjugation(infinitif: "accroître", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accrUsse", "accrUsses", "accrÛt", "accrUssions", "accrUssiez", "accrUssent"] {
      T.testConjugation(infinitif: "accroître", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "accroître", tense: .participePassé, expected: "accRU", extraLetters: nil)
    T.testConjugation(infinitif: "accroître", tense: .participePrésent, expected: "accroISSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["accroIs", "accroISSons", "accroISSez"] {
      T.testConjugation(infinitif: "accroître", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAcquérir() {
    // ID: 6-3
    var personNumbersIndex = 0

    for conjugation in ["acquIErs", "acquIErs", "acquIErt", "acquérons", "acquérez", "acquIÈrent"] {
      T.testConjugation(infinitif: "acquérir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["acquérais", "acquérais", "acquérait", "acquérions", "acquériez", "acquéraient"] {
      T.testConjugation(infinitif: "acquérir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["acquERrai", "acquERras", "acquERra", "acquERrons", "acquERrez", "acquERront"] {
      T.testConjugation(infinitif: "acquérir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["acquERrais", "acquERrais", "acquERrait", "acquERrions", "acquERriez", "acquERraient"] {
      T.testConjugation(infinitif: "acquérir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["acqUis", "acqUis", "acqUit", "acqUîmes", "acqUîtes", "acqUirent"] {
      T.testConjugation(infinitif: "acquérir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["acquIÈre", "acquIÈres", "acquIÈre", "acquérions", "acquériez", "acquIÈrent"] {
      T.testConjugation(infinitif: "acquérir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["acqUisse", "acqUisses", "acqUît", "acqUissions", "acqUissiez", "acqUissent"] {
      T.testConjugation(infinitif: "acquérir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "acquérir", tense: .participePassé, expected: "acqUiS", extraLetters: nil)
    T.testConjugation(infinitif: "acquérir", tense: .participePrésent, expected: "acquérant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["acquIErs", "acquérons", "acquérez"] {
      T.testConjugation(infinitif: "acquérir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAller() {
    // ID: 1-9
    var personNumbersIndex = 0

    for conjugation in ["VAIS", "VAs", "VA", "allons", "allez", "VOnt"] {
      T.testConjugation(infinitif: "aller", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["allais", "allais", "allait", "allions", "alliez", "allaient"] {
      T.testConjugation(infinitif: "aller", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Irai", "Iras", "Ira", "Irons", "Irez", "Iront"] {
      T.testConjugation(infinitif: "aller", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Irais", "Irais", "Irait", "Irions", "Iriez", "Iraient"] {
      T.testConjugation(infinitif: "aller", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["allai", "allas", "alla", "allâmes", "allâtes", "allèrent"] {
      T.testConjugation(infinitif: "aller", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aIlle", "aIlles", "aIlle", "allions", "alliez", "aIllent"] {
      T.testConjugation(infinitif: "aller", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["allasse", "allasses", "allât", "allassions", "allassiez", "allassent"] {
      T.testConjugation(infinitif: "aller", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "aller", tense: .participePassé, expected: "allé", extraLetters: nil)
    T.testConjugation(infinitif: "aller", tense: .participePrésent, expected: "allant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["VA", "allons", "allez"] {
      T.testConjugation(infinitif: "aller", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testApparoir() {
    // ID: 4-1D
    var personNumbersIndex = 0

    for conjugation in ["apparOIs", "apparOIs", "appErt", "apparOYons", "apparOYez", "apparOIent"] {
      T.testConjugation(infinitif: "apparoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["apparOYais", "apparOYais", "apparOYait", "apparOYions", "apparOYiez", "apparOYaient"] {
      T.testConjugation(infinitif: "apparoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["apparoirai", "apparoiras", "apparoira", "apparoirons", "apparoirez", "apparoiront"] {
      T.testConjugation(infinitif: "apparoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["apparoirais", "apparoirais", "apparoirait", "apparoirions", "apparoiriez", "apparoiraient"] {
      T.testConjugation(infinitif: "apparoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["apparis", "apparis", "apparit", "apparîmes", "apparîtes", "apparirent"] {
      T.testConjugation(infinitif: "apparoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["apparOIE", "apparOIES", "apparOIE", "apparOYIONS", "apparOYIEZ", "apparOIENT"] {
      T.testConjugation(infinitif: "apparoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["apparisse", "apparisses", "apparît", "apparissions", "apparissiez", "apparissent"] {
      T.testConjugation(infinitif: "apparoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "apparoir", tense: .participePassé, expected: "apparU", extraLetters: nil)
    T.testConjugation(infinitif: "apparoir", tense: .participePrésent, expected: "apparOYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["apparOIs", "apparOYons", "apparOYez"] {
      T.testConjugation(infinitif: "apparoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAppeler() {
    // ID: 1-3A
    var personNumbersIndex = 0

    for conjugation in ["appelLe", "appelLes", "appelLe", "appelons", "appelez", "appelLent"] {
      T.testConjugation(infinitif: "appeler", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appelais", "appelais", "appelait", "appelions", "appeliez", "appelaient"] {
      T.testConjugation(infinitif: "appeler", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appeLlerai", "appeLleras", "appeLlera", "appeLlerons", "appeLlerez", "appeLleront"] {
      T.testConjugation(infinitif: "appeler", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appeLlerais", "appeLlerais", "appeLlerait", "appeLlerions", "appeLleriez", "appeLleraient"] {
      T.testConjugation(infinitif: "appeler", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appelai", "appelas", "appela", "appelâmes", "appelâtes", "appelèrent"] {
      T.testConjugation(infinitif: "appeler", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appelLe", "appelLes", "appelLe", "appelions", "appeliez", "appelLent"] {
      T.testConjugation(infinitif: "appeler", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appelasse", "appelasses", "appelât", "appelassions", "appelassiez", "appelassent"] {
      T.testConjugation(infinitif: "appeler", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "appeler", tense: .participePassé, expected: "appelé", extraLetters: nil)
    T.testConjugation(infinitif: "appeler", tense: .participePrésent, expected: "appelant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["appelLe", "appelons", "appelez"] {
      T.testConjugation(infinitif: "appeler", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAssaillir() {
    // ID: 3-2A
    var personNumbersIndex = 0

    for conjugation in ["assaillE", "assaillES", "assaillE", "assaillONS", "assaillEZ", "assaillENT"] {
      T.testConjugation(infinitif: "assaillir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillais", "assaillais", "assaillait", "assaillions", "assailliez", "assaillaient"] {
      T.testConjugation(infinitif: "assaillir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillirai", "assailliras", "assaillira", "assaillirons", "assaillirez", "assailliront"] {
      T.testConjugation(infinitif: "assaillir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillirais", "assaillirais", "assaillirait", "assaillirions", "assailliriez", "assailliraient"] {
      T.testConjugation(infinitif: "assaillir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillis", "assaillis", "assaillit", "assaillîmes", "assaillîtes", "assaillirent"] {
      T.testConjugation(infinitif: "assaillir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillE", "assaillES", "assaillE", "assaillIONS", "assaillIEZ", "assaillENT"] {
      T.testConjugation(infinitif: "assaillir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillisse", "assaillisses", "assaillît", "assaillissions", "assaillissiez", "assaillissent"] {
      T.testConjugation(infinitif: "assaillir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "assaillir", tense: .participePassé, expected: "assailli", extraLetters: nil)
    T.testConjugation(infinitif: "assaillir", tense: .participePrésent, expected: "assaillant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["assaillE", "assaillOns", "assaillEz"] {
      T.testConjugation(infinitif: "assaillir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAsseoir() {
    // ID: 4-9AB
    var personNumbersIndex = 0

    for conjugation in ["assIEDs/assOIs", "assIEDs/assOIs", "assIED/assOIt", "asseYons/assOYons", "asseYez/assOYez", "asseYent/assOIent"] {
      T.testConjugation(infinitif: "asseoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["asseYais/assOYais", "asseYais/assOYais", "asseYait/assOYait", "asseYions/assOYions", "asseYiez/assOYiez", "asseYaient/assOYaient"] {
      T.testConjugation(infinitif: "asseoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assIÉrai/asSoirai", "assIÉras/asSoiras", "assIÉra/asSoira", "assIÉrons/asSoirons", "assIÉrez/asSoirez", "assIÉront/asSoiront"] {
      T.testConjugation(infinitif: "asseoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assIÉrais/asSoirais", "assIÉrais/asSoirais", "assIÉrait/asSoirait", "assIÉrions/asSoirions", "assIÉriez/asSoiriez", "assIÉraient/asSoiraient"] {
      T.testConjugation(infinitif: "asseoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["asSis", "asSis", "asSit", "asSîmes", "asSîtes", "asSirent"] {
      T.testConjugation(infinitif: "asseoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["asseYE/assOIE", "asseYES/assOIES", "asseYE/assOIE", "asseYIONS/assOYIONS", "asseYIEZ/assOYIEZ", "asseYENT/assOIENT"] {
      T.testConjugation(infinitif: "asseoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["asSisse", "asSisses", "asSît", "asSissions", "asSissiez", "asSissent"] {
      T.testConjugation(infinitif: "asseoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "asseoir", tense: .participePassé, expected: "asSIS", extraLetters: nil)
    T.testConjugation(infinitif: "asseoir", tense: .participePrésent, expected: "asseY/assOYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["assIEDs/assOIs", "asseYons/assOYons", "asseYez/assOYez"] {
      T.testConjugation(infinitif: "asseoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAvoir() {
    // ID: 4-10
    var personNumbersIndex = 0

    for conjugation in ["aI", "As", "A", "avons", "avez", "Ont"] {
      T.testConjugation(infinitif: "avoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["avais", "avais", "avait", "avions", "aviez", "avaient"] {
      T.testConjugation(infinitif: "avoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aUrai", "aUras", "aUra", "aUrons", "aUrez", "aUront"] {
      T.testConjugation(infinitif: "avoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aUrais", "aUrais", "aUrait", "aUrions", "aUriez", "aUraient"] {
      T.testConjugation(infinitif: "avoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Eus", "Eus", "Eut", "Eûmes", "Eûtes", "Eurent"] {
      T.testConjugation(infinitif: "avoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aIE", "aIES", "aIT", "aYons", "aYez", "aIENT"] {
      T.testConjugation(infinitif: "avoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Eusse", "Eusses", "Eût", "Eussions", "Eussiez", "Eussent"] {
      T.testConjugation(infinitif: "avoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "avoir", tense: .participePassé, expected: "EU", extraLetters: nil)
    T.testConjugation(infinitif: "avoir", tense: .participePrésent, expected: "aYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["aIE", "aYons", "aYez"] {
      T.testConjugation(infinitif: "avoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testBattre() {
    // ID: 5-3
    var personNumbersIndex = 0

    for conjugation in ["baTs", "baTs", "baT", "battons", "battez", "battent"] {
      T.testConjugation(infinitif: "battre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["battais", "battais", "battait", "battions", "battiez", "battaient"] {
      T.testConjugation(infinitif: "battre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["battrai", "battras", "battra", "battrons", "battrez", "battront"] {
      T.testConjugation(infinitif: "battre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["battrais", "battrais", "battrait", "battrions", "battriez", "battraient"] {
      T.testConjugation(infinitif: "battre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["battis", "battis", "battit", "battîmes", "battîtes", "battirent"] {
      T.testConjugation(infinitif: "battre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["batte", "battes", "batte", "battions", "battiez", "battent"] {
      T.testConjugation(infinitif: "battre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["battisse", "battisses", "battît", "battissions", "battissiez", "battissent"] {
      T.testConjugation(infinitif: "battre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "battre", tense: .participePassé, expected: "battu", extraLetters: nil)
    T.testConjugation(infinitif: "battre", tense: .participePrésent, expected: "battant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["baTs", "battons", "battez"] {
      T.testConjugation(infinitif: "battre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testBoire() {
    // ID: 5-17
    var personNumbersIndex = 0

    for conjugation in ["bois", "bois", "boit", "bUVons", "bUVez", "boiVent"] {
      T.testConjugation(infinitif: "boire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bUVais", "bUVais", "bUVait", "bUVions", "bUViez", "bUVaient"] {
      T.testConjugation(infinitif: "boire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["boirai", "boiras", "boira", "boirons", "boirez", "boiront"] {
      T.testConjugation(infinitif: "boire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["boirais", "boirais", "boirait", "boirions", "boiriez", "boiraient"] {
      T.testConjugation(infinitif: "boire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Bus", "Bus", "But", "Bûmes", "Bûtes", "Burent"] {
      T.testConjugation(infinitif: "boire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["boiVe", "boiVes", "boiVe", "bUVions", "bUViez", "boiVent"] {
      T.testConjugation(infinitif: "boire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Busse", "Busses", "Bût", "Bussions", "Bussiez", "Bussent"] {
      T.testConjugation(infinitif: "boire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "boire", tense: .participePassé, expected: "Bu", extraLetters: nil)
    T.testConjugation(infinitif: "boire", tense: .participePrésent, expected: "bUVant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["bois", "bUVons", "bUVez"] {
      T.testConjugation(infinitif: "boire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testBouillir() {
    // ID: 3-2C
    var personNumbersIndex = 0

    for conjugation in ["bouS", "bouS", "bouT", "bouillONS", "bouillEZ", "bouillENT"] {
      T.testConjugation(infinitif: "bouillir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillais", "bouillais", "bouillait", "bouillions", "bouilliez", "bouillaient"] {
      T.testConjugation(infinitif: "bouillir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillirai", "bouilliras", "bouillira", "bouillirons", "bouillirez", "bouilliront"] {
      T.testConjugation(infinitif: "bouillir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillirais", "bouillirais", "bouillirait", "bouillirions", "bouilliriez", "bouilliraient"] {
      T.testConjugation(infinitif: "bouillir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillis", "bouillis", "bouillit", "bouillîmes", "bouillîtes", "bouillirent"] {
      T.testConjugation(infinitif: "bouillir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillE", "bouillES", "bouillE", "bouillIONS", "bouillIEZ", "bouillENT"] {
      T.testConjugation(infinitif: "bouillir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillisse", "bouillisses", "bouillît", "bouillissions", "bouillissiez", "bouillissent"] {
      T.testConjugation(infinitif: "bouillir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "bouillir", tense: .participePassé, expected: "bouilli", extraLetters: nil)
    T.testConjugation(infinitif: "bouillir", tense: .participePrésent, expected: "bouillant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["bouillE", "bouillOns", "bouillEz"] {
      T.testConjugation(infinitif: "bouillir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCéder() {
    // ID: 1-5
    var personNumbersIndex = 0

    for conjugation in ["cÈde", "cÈdes", "cÈde", "cédons", "cédez", "cÈdent"] {
      T.testConjugation(infinitif: "céder", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cédais", "cédais", "cédait", "cédions", "cédiez", "cédaient"] {
      T.testConjugation(infinitif: "céder", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["céderai", "céderas", "cédera", "céderons", "céderez", "céderont"] {
      T.testConjugation(infinitif: "céder", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["céderais", "céderais", "céderait", "céderions", "céderiez", "céderaient"] {
      T.testConjugation(infinitif: "céder", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cédai", "cédas", "céda", "cédâmes", "cédâtes", "cédèrent"] {
      T.testConjugation(infinitif: "céder", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cÈde", "cÈdes", "cÈde", "cédions", "cédiez", "cÈdent"] {
      T.testConjugation(infinitif: "céder", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cédasse", "cédasses", "cédât", "cédassions", "cédassiez", "cédassent"] {
      T.testConjugation(infinitif: "céder", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "céder", tense: .participePassé, expected: "cédé", extraLetters: nil)
    T.testConjugation(infinitif: "céder", tense: .participePrésent, expected: "cédant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["cÈde", "cédons", "cédez"] {
      T.testConjugation(infinitif: "céder", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testChauvir() {
    // ID: 6-1A
    var personNumbersIndex = 0

    for conjugation in ["chauvIs", "chauvIs", "chauvIt", "chauvons", "chauvez", "chauvent"] {
      T.testConjugation(infinitif: "chauvir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["chauvais", "chauvais", "chauvait", "chauvions", "chauviez", "chauvaient"] {
      T.testConjugation(infinitif: "chauvir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["chauvirai", "chauviras", "chauvira", "chauvirons", "chauvirez", "chauviront"] {
      T.testConjugation(infinitif: "chauvir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["chauvirais", "chauvirais", "chauvirait", "chauvirions", "chauviriez", "chauviraient"] {
      T.testConjugation(infinitif: "chauvir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["chauvis", "chauvis", "chauvit", "chauvîmes", "chauvîtes", "chauvirent"] {
      T.testConjugation(infinitif: "chauvir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["chauvE", "chauvES", "chauvE", "chauvIONS", "chauvIEZ", "chauvENT"] {
      T.testConjugation(infinitif: "chauvir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["chauvisse", "chauvisses", "chauvît", "chauvissions", "chauvissiez", "chauvissent"] {
      T.testConjugation(infinitif: "chauvir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "chauvir", tense: .participePassé, expected: "chauvi", extraLetters: nil)
    T.testConjugation(infinitif: "chauvir", tense: .participePrésent, expected: "chauvant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["chauvIs", "chauvons", "chauvez"] {
      T.testConjugation(infinitif: "chauvir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testChoir() {
    // ID: 4-11A
    var personNumbersIndex = 0

    for conjugation in ["chOIs", "chOIs", "chOIt", "chOYons", "chOYez", "chOIent"] {
      T.testConjugation(infinitif: "choir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["chOYais", "chOYais", "chOYait", "chOYions", "chOYiez", "chOYaient"] {
      T.testConjugation(infinitif: "choir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["choirai/chERrai", "choiras/chERras", "choira/chERra", "choirons/chERrons", "choirez/chERrez", "choiront/chERront"] {
      T.testConjugation(infinitif: "choir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["choirais/chERrais", "choirais/chERrais", "choirait/chERrait", "choirions/chERrions", "choiriez/chERriez", "choiraient/chERraient"] {
      T.testConjugation(infinitif: "choir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["chus", "chus", "chut", "chûmes", "chûtes", "churent"] {
      T.testConjugation(infinitif: "choir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["chOIE", "chOIES", "chOIE", "chOYIONS", "chOYIEZ", "chOIENT"] {
      T.testConjugation(infinitif: "choir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["chusse", "chusses", "chût", "chussions", "chussiez", "chussent"] {
      T.testConjugation(infinitif: "choir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "choir", tense: .participePassé, expected: "chU", extraLetters: nil)
    T.testConjugation(infinitif: "choir", tense: .participePrésent, expected: "chOYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["chOIs", "chOYons", "chOYez"] {
      T.testConjugation(infinitif: "choir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCirconcire() {
    // ID: 5-8D
    var personNumbersIndex = 0

    for conjugation in ["circoncis", "circoncis", "circoncit", "circonciSons", "circonciSez", "circonciSent"] {
      T.testConjugation(infinitif: "circoncire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circonciSais", "circonciSais", "circonciSait", "circonciSions", "circonciSiez", "circonciSaient"] {
      T.testConjugation(infinitif: "circoncire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circoncirai", "circonciras", "circoncira", "circoncirons", "circoncirez", "circonciront"] {
      T.testConjugation(infinitif: "circoncire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circoncirais", "circoncirais", "circoncirait", "circoncirions", "circonciriez", "circonciraient"] {
      T.testConjugation(infinitif: "circoncire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circoncis", "circoncis", "circoncit", "circoncîmes", "circoncîtes", "circoncirent"] {
      T.testConjugation(infinitif: "circoncire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circonciSe", "circonciSes", "circonciSe", "circonciSions", "circonciSiez", "circonciSent"] {
      T.testConjugation(infinitif: "circoncire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circoncisse", "circoncisses", "circoncît", "circoncissions", "circoncissiez", "circoncissent"] {
      T.testConjugation(infinitif: "circoncire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "circoncire", tense: .participePassé, expected: "circonciS", extraLetters: nil)
    T.testConjugation(infinitif: "circoncire", tense: .participePrésent, expected: "circonciSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["circoncis", "circonciSons", "circonciSez"] {
      T.testConjugation(infinitif: "circoncire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testClore() {
    // ID: 5-27
    var personNumbersIndex = 0

    for conjugation in ["clos", "clos", "clÔt", "cloSons", "cloSez", "cloSent"] {
      T.testConjugation(infinitif: "clore", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cloSais", "cloSais", "cloSait", "cloSions", "cloSiez", "cloSaient"] {
      T.testConjugation(infinitif: "clore", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["clorai", "cloras", "clora", "clorons", "clorez", "cloront"] {
      T.testConjugation(infinitif: "clore", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["clorais", "clorais", "clorait", "clorions", "cloriez", "cloraient"] {
      T.testConjugation(infinitif: "clore", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["clos", "clos", "clot", "clômes", "clôtes", "clorent"] {
      T.testConjugation(infinitif: "clore", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cloSe", "cloSes", "cloSe", "cloSions", "cloSiez", "cloSent"] {
      T.testConjugation(infinitif: "clore", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["closse", "closses", "clôt", "clossions", "clossiez", "clossent"] {
      T.testConjugation(infinitif: "clore", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "clore", tense: .participePassé, expected: "cloS", extraLetters: nil)
    T.testConjugation(infinitif: "clore", tense: .participePrésent, expected: "cloSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["clos", "cloSons", "cloSez"] {
      T.testConjugation(infinitif: "clore", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testConduire() {
    // ID: 5-9A
    var personNumbersIndex = 0

    for conjugation in ["conduis", "conduis", "conduit", "conduiSons", "conduiSez", "conduiSent"] {
      T.testConjugation(infinitif: "conduire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduiSais", "conduiSais", "conduiSait", "conduiSions", "conduiSiez", "conduiSaient"] {
      T.testConjugation(infinitif: "conduire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduirai", "conduiras", "conduira", "conduirons", "conduirez", "conduiront"] {
      T.testConjugation(infinitif: "conduire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduirais", "conduirais", "conduirait", "conduirions", "conduiriez", "conduiraient"] {
      T.testConjugation(infinitif: "conduire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduiSis", "conduiSis", "conduiSit", "conduiSîmes", "conduiSîtes", "conduiSirent"] {
      T.testConjugation(infinitif: "conduire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduiSe", "conduiSes", "conduiSe", "conduiSions", "conduiSiez", "conduiSent"] {
      T.testConjugation(infinitif: "conduire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduiSisse", "conduiSisses", "conduiSît", "conduiSissions", "conduiSissiez", "conduiSissent"] {
      T.testConjugation(infinitif: "conduire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "conduire", tense: .participePassé, expected: "conduiT", extraLetters: nil)
    T.testConjugation(infinitif: "conduire", tense: .participePrésent, expected: "conduiSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["conduis", "conduiSons", "conduiSez"] {
      T.testConjugation(infinitif: "conduire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testConnaître() {
    // ID: 5-20
    var personNumbersIndex = 0

    for conjugation in ["connaIs", "connaIs", "connaÎt", "connaISSons", "connaISSez", "connaISSent"] {
      T.testConjugation(infinitif: "connaître", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["connaISSais", "connaISSais", "connaISSait", "connaISSions", "connaISSiez", "connaISSaient"] {
      T.testConjugation(infinitif: "connaître", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["connaîtrai", "connaîtras", "connaîtra", "connaîtrons", "connaîtrez", "connaîtront"] {
      T.testConjugation(infinitif: "connaître", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["connaîtrais", "connaîtrais", "connaîtrait", "connaîtrions", "connaîtriez", "connaîtraient"] {
      T.testConjugation(infinitif: "connaître", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conNus", "conNus", "conNut", "conNûmes", "conNûtes", "conNurent"] {
      T.testConjugation(infinitif: "connaître", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["connaISSe", "connaISSes", "connaISSe", "connaISSions", "connaISSiez", "connaISSent"] {
      T.testConjugation(infinitif: "connaître", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conNusse", "conNusses", "conNût", "conNussions", "conNussiez", "conNussent"] {
      T.testConjugation(infinitif: "connaître", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "connaître", tense: .participePassé, expected: "conNu", extraLetters: nil)
    T.testConjugation(infinitif: "connaître", tense: .participePrésent, expected: "connaISSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["connaIs", "connaISSons", "connaISSez"] {
      T.testConjugation(infinitif: "connaître", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCoudre() {
    // ID: 5-14
    var personNumbersIndex = 0

    for conjugation in ["couds", "couds", "couD", "couSons", "couSez", "couSent"] {
      T.testConjugation(infinitif: "coudre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couSais", "couSais", "couSait", "couSions", "couSiez", "couSaient"] {
      T.testConjugation(infinitif: "coudre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["coudrai", "coudras", "coudra", "coudrons", "coudrez", "coudront"] {
      T.testConjugation(infinitif: "coudre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["coudrais", "coudrais", "coudrait", "coudrions", "coudriez", "coudraient"] {
      T.testConjugation(infinitif: "coudre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couSis", "couSis", "couSit", "couSîmes", "couSîtes", "couSirent"] {
      T.testConjugation(infinitif: "coudre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couSe", "couSes", "couSe", "couSions", "couSiez", "couSent"] {
      T.testConjugation(infinitif: "coudre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couSisse", "couSisses", "couSît", "couSissions", "couSissiez", "couSissent"] {
      T.testConjugation(infinitif: "coudre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "coudre", tense: .participePassé, expected: "couSu", extraLetters: nil)
    T.testConjugation(infinitif: "coudre", tense: .participePrésent, expected: "couSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["couds", "couSons", "couSez"] {
      T.testConjugation(infinitif: "coudre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCourir() {
    // ID: 6-4
    var personNumbersIndex = 0

    for conjugation in ["cours", "cours", "court", "courons", "courez", "courent"] {
      T.testConjugation(infinitif: "courir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["courais", "courais", "courait", "courions", "couriez", "couraient"] {
      T.testConjugation(infinitif: "courir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couRrai", "couRras", "couRra", "couRrons", "couRrez", "couRront"] {
      T.testConjugation(infinitif: "courir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couRrais", "couRrais", "couRrait", "couRrions", "couRriez", "couRraient"] {
      T.testConjugation(infinitif: "courir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["courus", "courus", "courut", "courûmes", "courûtes", "coururent"] {
      T.testConjugation(infinitif: "courir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["courE", "courES", "courE", "courIONS", "courIEZ", "courENT"] {
      T.testConjugation(infinitif: "courir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["courusse", "courusses", "courût", "courussions", "courussiez", "courussent"] {
      T.testConjugation(infinitif: "courir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "courir", tense: .participePassé, expected: "courU", extraLetters: nil)
    T.testConjugation(infinitif: "courir", tense: .participePrésent, expected: "courant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["cours", "courons", "courez"] {
      T.testConjugation(infinitif: "courir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCouvrir() {
    // ID: 3-1
    var personNumbersIndex = 0

    for conjugation in ["couvrE", "couvrES", "couvrE", "couvrONS", "couvrEZ", "couvrENT"] {
      T.testConjugation(infinitif: "couvrir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvrais", "couvrais", "couvrait", "couvrions", "couvriez", "couvraient"] {
      T.testConjugation(infinitif: "couvrir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvrirai", "couvriras", "couvrira", "couvrirons", "couvrirez", "couvriront"] {
      T.testConjugation(infinitif: "couvrir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvrirais", "couvrirais", "couvrirait", "couvririons", "couvririez", "couvriraient"] {
      T.testConjugation(infinitif: "couvrir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvris", "couvris", "couvrit", "couvrîmes", "couvrîtes", "couvrirent"] {
      T.testConjugation(infinitif: "couvrir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvrE", "couvrES", "couvrE", "couvrIONS", "couvrIEZ", "couvrENT"] {
      T.testConjugation(infinitif: "couvrir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvrisse", "couvrisses", "couvrît", "couvrissions", "couvrissiez", "couvrissent"] {
      T.testConjugation(infinitif: "couvrir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "couvrir", tense: .participePassé, expected: "couvERT", extraLetters: nil)
    T.testConjugation(infinitif: "couvrir", tense: .participePrésent, expected: "couvrant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["couvrE", "couvrOns", "couvrEz"] {
      T.testConjugation(infinitif: "couvrir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCroire() {
    // ID: 5-18
    var personNumbersIndex = 0

    for conjugation in ["crois", "crois", "croit", "croYons", "croYez", "croient"] {
      T.testConjugation(infinitif: "croire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croYais", "croYais", "croYait", "croYions", "croYiez", "croYaient"] {
      T.testConjugation(infinitif: "croire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croirai", "croiras", "croira", "croirons", "croirez", "croiront"] {
      T.testConjugation(infinitif: "croire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croirais", "croirais", "croirait", "croirions", "croiriez", "croiraient"] {
      T.testConjugation(infinitif: "croire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cRus", "cRus", "cRut", "cRûmes", "cRûtes", "cRurent"] {
      T.testConjugation(infinitif: "croire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croie", "croies", "croie", "croYions", "croYiez", "croient"] {
      T.testConjugation(infinitif: "croire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cRusse", "cRusses", "cRût", "cRussions", "cRussiez", "cRussent"] {
      T.testConjugation(infinitif: "croire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "croire", tense: .participePassé, expected: "cRu", extraLetters: nil)
    T.testConjugation(infinitif: "croire", tense: .participePrésent, expected: "croYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["crois", "croYons", "croYez"] {
      T.testConjugation(infinitif: "croire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCroître() {
    // ID: 5-19A
    var personNumbersIndex = 0

    for conjugation in ["croÎs", "croÎs", "croÎt", "croISSons", "croISSez", "croISSent"] {
      T.testConjugation(infinitif: "croître", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croISSais", "croISSais", "croISSait", "croISSions", "croISSiez", "croISSaient"] {
      T.testConjugation(infinitif: "croître", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croîtrai", "croîtras", "croîtra", "croîtrons", "croîtrez", "croîtront"] {
      T.testConjugation(infinitif: "croître", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croîtrais", "croîtrais", "croîtrait", "croîtrions", "croîtriez", "croîtraient"] {
      T.testConjugation(infinitif: "croître", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["crÛs", "crÛs", "crÛt", "crÛmes", "crÛtes", "crÛrent"] {
      T.testConjugation(infinitif: "croître", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croISSe", "croISSes", "croISSe", "croISSions", "croISSiez", "croISSent"] {
      T.testConjugation(infinitif: "croître", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["crÛsse", "crÛsses", "crÛt", "crÛssions", "crÛssiez", "crÛssent"] {
      T.testConjugation(infinitif: "croître", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "croître", tense: .participePassé, expected: "cRÛ", extraLetters: nil)
    T.testConjugation(infinitif: "croître", tense: .participePrésent, expected: "croISSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["croÎs", "croISSons", "croISSez"] {
      T.testConjugation(infinitif: "croître", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCueillir() {
    // ID: 3-2B
    var personNumbersIndex = 0

    for conjugation in ["cueillE", "cueillES", "cueillE", "cueillONS", "cueillEZ", "cueillENT"] {
      T.testConjugation(infinitif: "cueillir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillais", "cueillais", "cueillait", "cueillions", "cueilliez", "cueillaient"] {
      T.testConjugation(infinitif: "cueillir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillErai", "cueillEras", "cueillEra", "cueillErons", "cueillErez", "cueillEront"] {
      T.testConjugation(infinitif: "cueillir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillErais", "cueillErais", "cueillErait", "cueillErions", "cueillEriez", "cueillEraient"] {
      T.testConjugation(infinitif: "cueillir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillis", "cueillis", "cueillit", "cueillîmes", "cueillîtes", "cueillirent"] {
      T.testConjugation(infinitif: "cueillir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillE", "cueillES", "cueillE", "cueillIONS", "cueillIEZ", "cueillENT"] {
      T.testConjugation(infinitif: "cueillir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillisse", "cueillisses", "cueillît", "cueillissions", "cueillissiez", "cueillissent"] {
      T.testConjugation(infinitif: "cueillir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "cueillir", tense: .participePassé, expected: "cueilli", extraLetters: nil)
    T.testConjugation(infinitif: "cueillir", tense: .participePrésent, expected: "cueillant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["cueillE", "cueillOns", "cueillEz"] {
      T.testConjugation(infinitif: "cueillir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testDevoir() {
    // ID: 4-2A
    var personNumbersIndex = 0

    for conjugation in ["dOIs", "dOIs", "dOIt", "devons", "devez", "dOIvent"] {
      T.testConjugation(infinitif: "devoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["devais", "devais", "devait", "devions", "deviez", "devaient"] {
      T.testConjugation(infinitif: "devoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["devRai", "devRas", "devRa", "devRons", "devRez", "devRont"] {
      T.testConjugation(infinitif: "devoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["devRais", "devRais", "devRait", "devRions", "devRiez", "devRaient"] {
      T.testConjugation(infinitif: "devoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Dus", "Dus", "Dut", "Dûmes", "Dûtes", "Durent"] {
      T.testConjugation(infinitif: "devoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dOIvE", "dOIvES", "dOIvE", "devIONS", "devIEZ", "dOIvENT"] {
      T.testConjugation(infinitif: "devoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Dusse", "Dusses", "Dût", "Dussions", "Dussiez", "Dussent"] {
      T.testConjugation(infinitif: "devoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "devoir", tense: .participePassé, expected: "DÛ", extraLetters: nil)
    T.testConjugation(infinitif: "devoir", tense: .participePrésent, expected: "devant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["dOIs", "devons", "devez"] {
      T.testConjugation(infinitif: "devoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testDépecer() {
    // ID: 1-6A
    var personNumbersIndex = 0

    for conjugation in ["dépÈce", "dépÈces", "dépÈce", "dépeÇons", "dépecez", "dépÈcent"] {
      T.testConjugation(infinitif: "dépecer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépeÇais", "dépeÇais", "dépeÇait", "dépeCions", "dépeCiez", "dépeÇaient"] {
      T.testConjugation(infinitif: "dépecer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépÈcerai", "dépÈceras", "dépÈcera", "dépÈcerons", "dépÈcerez", "dépÈceront"] {
      T.testConjugation(infinitif: "dépecer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépÈcerais", "dépÈcerais", "dépÈcerait", "dépÈcerions", "dépÈceriez", "dépÈceraient"] {
      T.testConjugation(infinitif: "dépecer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépeÇai", "dépeÇas", "dépeÇa", "dépeÇâmes", "dépeÇâtes", "dépecèrent"] {
      T.testConjugation(infinitif: "dépecer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépÈce", "dépÈces", "dépÈce", "dépeCions", "dépeCiez", "dépÈcent"] {
      T.testConjugation(infinitif: "dépecer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépeÇasse", "dépeÇasses", "dépeÇât", "dépeÇassions", "dépeÇassiez", "dépeÇassent"] {
      T.testConjugation(infinitif: "dépecer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "dépecer", tense: .participePassé, expected: "dépecé", extraLetters: nil)
    T.testConjugation(infinitif: "dépecer", tense: .participePrésent, expected: "dépeÇant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["dépÈce", "dépeÇons", "dépecez"] {
      T.testConjugation(infinitif: "dépecer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testDire() {
    // ID: 5-8A
    var personNumbersIndex = 0

    for conjugation in ["dis", "dis", "dit", "diSons", "dÎTES", "diSent"] {
      T.testConjugation(infinitif: "dire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["diSais", "diSais", "diSait", "diSions", "diSiez", "diSaient"] {
      T.testConjugation(infinitif: "dire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dirai", "diras", "dira", "dirons", "direz", "diront"] {
      T.testConjugation(infinitif: "dire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dirais", "dirais", "dirait", "dirions", "diriez", "diraient"] {
      T.testConjugation(infinitif: "dire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dis", "dis", "dit", "dîmes", "dîtes", "dirent"] {
      T.testConjugation(infinitif: "dire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["diSe", "diSes", "diSe", "diSions", "diSiez", "diSent"] {
      T.testConjugation(infinitif: "dire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["disse", "disses", "dît", "dissions", "dissiez", "dissent"] {
      T.testConjugation(infinitif: "dire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "dire", tense: .participePassé, expected: "diT", extraLetters: nil)
    T.testConjugation(infinitif: "dire", tense: .participePrésent, expected: "diSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["dis", "diSons", "dÎTES"] {
      T.testConjugation(infinitif: "dire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testEmployer() {
    // ID: 1-7A
    var personNumbersIndex = 0

    for conjugation in ["emploIe", "emploIes", "emploIe", "employons", "employez", "emploIent"] {
      T.testConjugation(infinitif: "employer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["employais", "employais", "employait", "employions", "employiez", "employaient"] {
      T.testConjugation(infinitif: "employer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["emploIerai", "emploIeras", "emploIera", "emploIerons", "emploIerez", "emploIeront"] {
      T.testConjugation(infinitif: "employer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["emploIerais", "emploIerais", "emploIerait", "emploIerions", "emploIeriez", "emploIeraient"] {
      T.testConjugation(infinitif: "employer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["employai", "employas", "employa", "employâmes", "employâtes", "employèrent"] {
      T.testConjugation(infinitif: "employer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["emploIe", "emploIes", "emploIe", "employions", "employiez", "emploIent"] {
      T.testConjugation(infinitif: "employer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["employasse", "employasses", "employât", "employassions", "employassiez", "employassent"] {
      T.testConjugation(infinitif: "employer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "employer", tense: .participePassé, expected: "employé", extraLetters: nil)
    T.testConjugation(infinitif: "employer", tense: .participePrésent, expected: "employant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["emploIe", "employons", "employez"] {
      T.testConjugation(infinitif: "employer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testEnvoyer() {
    // ID: 1-8
    var personNumbersIndex = 0

    for conjugation in ["envoIe", "envoIes", "envoIe", "envoyons", "envoyez", "envoIent"] {
      T.testConjugation(infinitif: "envoyer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envoyais", "envoyais", "envoyait", "envoyions", "envoyiez", "envoyaient"] {
      T.testConjugation(infinitif: "envoyer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envERrai", "envERras", "envERra", "envERrons", "envERrez", "envERront"] {
      T.testConjugation(infinitif: "envoyer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envERrais", "envERrais", "envERrait", "envERrions", "envERriez", "envERraient"] {
      T.testConjugation(infinitif: "envoyer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envoyai", "envoyas", "envoya", "envoyâmes", "envoyâtes", "envoyèrent"] {
      T.testConjugation(infinitif: "envoyer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envoIe", "envoIes", "envoIe", "envoyions", "envoyiez", "envoIent"] {
      T.testConjugation(infinitif: "envoyer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envoyasse", "envoyasses", "envoyât", "envoyassions", "envoyassiez", "envoyassent"] {
      T.testConjugation(infinitif: "envoyer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "envoyer", tense: .participePassé, expected: "envoyé", extraLetters: nil)
    T.testConjugation(infinitif: "envoyer", tense: .participePrésent, expected: "envoyant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["envoIe", "envoyons", "envoyez"] {
      T.testConjugation(infinitif: "envoyer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testEster() {
    // ID: 1-10
    var personNumbersIndex = 0

    for conjugation in ["estOIS", "estes", "este", "estons", "estez", "estent"] {
      T.testConjugation(infinitif: "ester", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["estais", "estais", "estait", "estions", "estiez", "estaient"] {
      T.testConjugation(infinitif: "ester", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["esterai", "esteras", "estera", "esterons", "esterez", "esteront"] {
      T.testConjugation(infinitif: "ester", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["esterais", "esterais", "esterait", "esterions", "esteriez", "esteraient"] {
      T.testConjugation(infinitif: "ester", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["estus", "estus", "estut", "estûmes", "estûtes", "esturent"] {
      T.testConjugation(infinitif: "ester", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["estOISe", "estOISes", "estOISe", "estions", "estiez", "estOISent"] {
      T.testConjugation(infinitif: "ester", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["estusse", "estusses", "estût", "estussions", "estussiez", "estussent"] {
      T.testConjugation(infinitif: "ester", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "ester", tense: .participePassé, expected: "esté", extraLetters: nil)
    T.testConjugation(infinitif: "ester", tense: .participePrésent, expected: "estant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["este", "estons", "estez"] {
      T.testConjugation(infinitif: "ester", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testExclure() {
    // ID: 5-16A
    var personNumbersIndex = 0

    for conjugation in ["exclus", "exclus", "exclut", "excluons", "excluez", "excluent"] {
      T.testConjugation(infinitif: "exclure", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["excluais", "excluais", "excluait", "excluions", "excluiez", "excluaient"] {
      T.testConjugation(infinitif: "exclure", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["exclurai", "excluras", "exclura", "exclurons", "exclurez", "excluront"] {
      T.testConjugation(infinitif: "exclure", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["exclurais", "exclurais", "exclurait", "exclurions", "excluriez", "excluraient"] {
      T.testConjugation(infinitif: "exclure", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["exclus", "exclus", "exclut", "exclûmes", "exclûtes", "exclurent"] {
      T.testConjugation(infinitif: "exclure", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["exclue", "exclues", "exclue", "excluions", "excluiez", "excluent"] {
      T.testConjugation(infinitif: "exclure", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["exclusse", "exclusses", "exclût", "exclussions", "exclussiez", "exclussent"] {
      T.testConjugation(infinitif: "exclure", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "exclure", tense: .participePassé, expected: "exclU", extraLetters: nil)
    T.testConjugation(infinitif: "exclure", tense: .participePrésent, expected: "excluant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["exclus", "excluons", "excluez"] {
      T.testConjugation(infinitif: "exclure", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testÉchoir() {
    // ID: 4-11B
    var personNumbersIndex = 0

    for conjugation in ["échOIs", "échOIs", "échOIt/échEt", "échOYons", "échOYez", "échOIent/échÉent"] {
      T.testConjugation(infinitif: "échoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["échOYais", "échOYais", "échOYait", "échOYions", "échOYiez", "échOYaient"] {
      T.testConjugation(infinitif: "échoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["échoirai/échERrai", "échoiras/échERras", "échoira/échERra", "échoirons/échERrons", "échoirez/échERrez", "échoiront/échERront"] {
      T.testConjugation(infinitif: "échoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["échoirais/échERrais", "échoirais/échERrais", "échoirait/échERrait", "échoirions/échERrions", "échoiriez/échERriez", "échoiraient/échERraient"] {
      T.testConjugation(infinitif: "échoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["échus", "échus", "échut", "échûmes", "échûtes", "échurent"] {
      T.testConjugation(infinitif: "échoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["échOIE", "échOIES", "échOIE", "échOYIONS", "échOYIEZ", "échOIENT"] {
      T.testConjugation(infinitif: "échoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["échusse", "échusses", "échût", "échussions", "échussiez", "échussent"] {
      T.testConjugation(infinitif: "échoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "échoir", tense: .participePassé, expected: "échU", extraLetters: nil)
    T.testConjugation(infinitif: "échoir", tense: .participePrésent, expected: "échOYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["échOIs", "échOYons", "échOYez"] {
      T.testConjugation(infinitif: "échoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testÉcrire() {
    // ID: 5-7
    var personNumbersIndex = 0

    for conjugation in ["écris", "écris", "écrit", "écriVons", "écriVez", "écriVent"] {
      T.testConjugation(infinitif: "écrire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écriVais", "écriVais", "écriVait", "écriVions", "écriViez", "écriVaient"] {
      T.testConjugation(infinitif: "écrire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écrirai", "écriras", "écrira", "écrirons", "écrirez", "écriront"] {
      T.testConjugation(infinitif: "écrire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écrirais", "écrirais", "écrirait", "écririons", "écririez", "écriraient"] {
      T.testConjugation(infinitif: "écrire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écriVis", "écriVis", "écriVit", "écriVîmes", "écriVîtes", "écriVirent"] {
      T.testConjugation(infinitif: "écrire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écriVe", "écriVes", "écriVe", "écriVions", "écriViez", "écriVent"] {
      T.testConjugation(infinitif: "écrire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écriVisse", "écriVisses", "écriVît", "écriVissions", "écriVissiez", "écriVissent"] {
      T.testConjugation(infinitif: "écrire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "écrire", tense: .participePassé, expected: "écriT", extraLetters: nil)
    T.testConjugation(infinitif: "écrire", tense: .participePrésent, expected: "écriVant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["écris", "écriVons", "écriVez"] {
      T.testConjugation(infinitif: "écrire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testÊtre() {
    // ID: 5-26
    var personNumbersIndex = 0

    for conjugation in ["SUIs", "Es", "ESt", "SOMMEs", "êteS", "SOnt"] {
      T.testConjugation(infinitif: "être", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Étais", "Étais", "Était", "Étions", "Étiez", "Étaient"] {
      T.testConjugation(infinitif: "être", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SErai", "SEras", "SEra", "SErons", "SErez", "SEront"] {
      T.testConjugation(infinitif: "être", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SErais", "SErais", "SErait", "SErions", "SEriez", "SEraient"] {
      T.testConjugation(infinitif: "être", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Fus", "Fus", "Fut", "Fûmes", "Fûtes", "Furent"] {
      T.testConjugation(infinitif: "être", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SOIS", "SOIs", "SOIT", "SOYons", "SOYez", "SOIent"] {
      T.testConjugation(infinitif: "être", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Fusse", "Fusses", "Fût", "Fussions", "Fussiez", "Fussent"] {
      T.testConjugation(infinitif: "être", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "être", tense: .participePassé, expected: "ÉtÉ", extraLetters: nil)
    T.testConjugation(infinitif: "être", tense: .participePrésent, expected: "Étant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["SOIs", "SOYons", "SOYez"] {
      T.testConjugation(infinitif: "être", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFaillir() {
    // ID: 4-12
    var personNumbersIndex = 0

    for conjugation in ["faUX", "faUX", "faUT", "faillons", "faillez", "faillent"] {
      T.testConjugation(infinitif: "faillir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faillais", "faillais", "faillait", "faillions", "failliez", "faillaient"] {
      T.testConjugation(infinitif: "faillir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faillirai/faUDrai", "failliras/faUDras", "faillira/faUDra", "faillirons/faUDrons", "faillirez/faUDrez", "failliront/faUDront"] {
      T.testConjugation(infinitif: "faillir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faillirais/faUDrais", "faillirais/faUDrais", "faillirait/faUDrait", "faillirions/faUDrions", "failliriez/faUDriez", "failliraient/faUDraient"] {
      T.testConjugation(infinitif: "faillir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faillis", "faillis", "faillit", "faillîmes", "faillîtes", "faillirent"] {
      T.testConjugation(infinitif: "faillir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faillE", "faillES", "faillE", "faillIONS", "faillIEZ", "faillENT"] {
      T.testConjugation(infinitif: "faillir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faillisse", "faillisses", "faillît", "faillissions", "faillissiez", "faillissent"] {
      T.testConjugation(infinitif: "faillir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "faillir", tense: .participePassé, expected: "faillU", extraLetters: nil)
    T.testConjugation(infinitif: "faillir", tense: .participePrésent, expected: "faillant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["faUX", "faillons", "faillez"] {
      T.testConjugation(infinitif: "faillir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFaire() {
    // ID: 5-23
    var personNumbersIndex = 0

    for conjugation in ["fais", "fais", "fait", "faiSons", "faiTeS", "fONT"] {
      T.testConjugation(infinitif: "faire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faiSais", "faiSais", "faiSait", "faiSions", "faiSiez", "faiSaient"] {
      T.testConjugation(infinitif: "faire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fErai", "fEras", "fEra", "fErons", "fErez", "fEront"] {
      T.testConjugation(infinitif: "faire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fErais", "fErais", "fErait", "fErions", "fEriez", "fEraient"] {
      T.testConjugation(infinitif: "faire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Fis", "Fis", "Fit", "Fîmes", "Fîtes", "Firent"] {
      T.testConjugation(infinitif: "faire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faSSe", "faSSes", "faSSe", "faSSions", "faSSiez", "faSSent"] {
      T.testConjugation(infinitif: "faire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Fisse", "Fisses", "Fît", "Fissions", "Fissiez", "Fissent"] {
      T.testConjugation(infinitif: "faire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "faire", tense: .participePassé, expected: "faiT", extraLetters: nil)
    T.testConjugation(infinitif: "faire", tense: .participePrésent, expected: "faiSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["fais", "faiSons", "faiTeS"] {
      T.testConjugation(infinitif: "faire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFalloir() {
    // ID: 4-5C
    var personNumbersIndex = 0

    for conjugation in ["faUX", "faUX", "faUt", "fallons", "fallez", "fallent"] {
      T.testConjugation(infinitif: "falloir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fallais", "fallais", "fallait", "fallions", "falliez", "fallaient"] {
      T.testConjugation(infinitif: "falloir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faUDrai", "faUDras", "faUDra", "faUDrons", "faUDrez", "faUDront"] {
      T.testConjugation(infinitif: "falloir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faUDrais", "faUDrais", "faUDrait", "faUDrions", "faUDriez", "faUDraient"] {
      T.testConjugation(infinitif: "falloir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fallus", "fallus", "fallut", "fallûmes", "fallûtes", "fallurent"] {
      T.testConjugation(infinitif: "falloir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faILlE", "faILlES", "faILlE", "fallIONS", "fallIEZ", "faILlENT"] {
      T.testConjugation(infinitif: "falloir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fallusse", "fallusses", "fallût", "fallussions", "fallussiez", "fallussent"] {
      T.testConjugation(infinitif: "falloir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "falloir", tense: .participePassé, expected: "fallU", extraLetters: nil)
    T.testConjugation(infinitif: "falloir", tense: .participePrésent, expected: "fallant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["faUX", "fallons", "fallez"] {
      T.testConjugation(infinitif: "falloir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFérir() {
    // ID: 2-4
    var personNumbersIndex = 0

    for conjugation in ["féris", "féris", "férit", "férissons", "férissez", "férissent"] {
      T.testConjugation(infinitif: "férir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["férissais", "férissais", "férissait", "férissions", "férissiez", "férissaient"] {
      T.testConjugation(infinitif: "férir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["férirai", "fériras", "férira", "férirons", "férirez", "fériront"] {
      T.testConjugation(infinitif: "férir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["férirais", "férirais", "férirait", "féririons", "féririez", "fériraient"] {
      T.testConjugation(infinitif: "férir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["féris", "féris", "férit", "férîmes", "férîtes", "férirent"] {
      T.testConjugation(infinitif: "férir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["férisse", "férisses", "férisse", "férissions", "férissiez", "férissent"] {
      T.testConjugation(infinitif: "férir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["férisse", "férisses", "férît", "férissions", "férissiez", "férissent"] {
      T.testConjugation(infinitif: "férir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "férir", tense: .participePassé, expected: "férU", extraLetters: nil)
    T.testConjugation(infinitif: "férir", tense: .participePrésent, expected: "férissant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["féris", "férissons", "férissez"] {
      T.testConjugation(infinitif: "férir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFiche() {
    // ID: 1-11
    var personNumbersIndex = 0

    for conjugation in ["fiche", "fiches", "fiche", "fichons", "fichez", "fichent"] {
      T.testConjugation(infinitif: "fiche", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fichais", "fichais", "fichait", "fichions", "fichiez", "fichaient"] {
      T.testConjugation(infinitif: "fiche", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["ficheRai", "ficheRas", "ficheRa", "ficheRons", "ficheRez", "ficheRont"] {
      T.testConjugation(infinitif: "fiche", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["ficheRais", "ficheRais", "ficheRait", "ficheRions", "ficheRiez", "ficheRaient"] {
      T.testConjugation(infinitif: "fiche", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fichai", "fichas", "ficha", "fichâmes", "fichâtes", "fichèrent"] {
      T.testConjugation(infinitif: "fiche", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fiche", "fiches", "fiche", "fichions", "fichiez", "fichent"] {
      T.testConjugation(infinitif: "fiche", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fichasse", "fichasses", "fichât", "fichassions", "fichassiez", "fichassent"] {
      T.testConjugation(infinitif: "fiche", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "fiche", tense: .participePassé, expected: "fichU", extraLetters: nil)
    T.testConjugation(infinitif: "fiche", tense: .participePrésent, expected: "fichant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["fiche", "fichons", "fichez"] {
      T.testConjugation(infinitif: "fiche", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFinir() {
    // ID: 2-1
    var personNumbersIndex = 0

    for conjugation in ["finis", "finis", "finit", "finissons", "finissez", "finissent"] {
      T.testConjugation(infinitif: "finir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finissais", "finissais", "finissait", "finissions", "finissiez", "finissaient"] {
      T.testConjugation(infinitif: "finir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finirai", "finiras", "finira", "finirons", "finirez", "finiront"] {
      T.testConjugation(infinitif: "finir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finirais", "finirais", "finirait", "finirions", "finiriez", "finiraient"] {
      T.testConjugation(infinitif: "finir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finis", "finis", "finit", "finîmes", "finîtes", "finirent"] {
      T.testConjugation(infinitif: "finir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finisse", "finisses", "finisse", "finissions", "finissiez", "finissent"] {
      T.testConjugation(infinitif: "finir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finisse", "finisses", "finît", "finissions", "finissiez", "finissent"] {
      T.testConjugation(infinitif: "finir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "finir", tense: .participePassé, expected: "fini", extraLetters: nil)
    T.testConjugation(infinitif: "finir", tense: .participePrésent, expected: "finissant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["finis", "finissons", "finissez"] {
      T.testConjugation(infinitif: "finir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testForclore() {
    // ID: 5-27A
    var personNumbersIndex = 0

    for conjugation in ["forclos", "forclos", "forclot", "forcloSons", "forcloSez", "forcloSent"] {
      T.testConjugation(infinitif: "forclore", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["forcloSais", "forcloSais", "forcloSait", "forcloSions", "forcloSiez", "forcloSaient"] {
      T.testConjugation(infinitif: "forclore", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["forclorai", "forcloras", "forclora", "forclorons", "forclorez", "forcloront"] {
      T.testConjugation(infinitif: "forclore", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["forclorais", "forclorais", "forclorait", "forclorions", "forcloriez", "forcloraient"] {
      T.testConjugation(infinitif: "forclore", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["forclos", "forclos", "forclot", "forclômes", "forclôtes", "forclorent"] {
      T.testConjugation(infinitif: "forclore", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["forcloSe", "forcloSes", "forcloSe", "forcloSions", "forcloSiez", "forcloSent"] {
      T.testConjugation(infinitif: "forclore", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["forclosse", "forclosses", "forclôt", "forclossions", "forclossiez", "forclossent"] {
      T.testConjugation(infinitif: "forclore", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "forclore", tense: .participePassé, expected: "forcloS", extraLetters: nil)
    T.testConjugation(infinitif: "forclore", tense: .participePrésent, expected: "forcloSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["forclos", "forcloSons", "forcloSez"] {
      T.testConjugation(infinitif: "forclore", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFoutre() {
    // ID: 5-1C
    var personNumbersIndex = 0

    for conjugation in ["foUs", "foUs", "fout", "foutons", "foutez", "foutent"] {
      T.testConjugation(infinitif: "foutre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["foutais", "foutais", "foutait", "foutions", "foutiez", "foutaient"] {
      T.testConjugation(infinitif: "foutre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["foutrai", "foutras", "foutra", "foutrons", "foutrez", "foutront"] {
      T.testConjugation(infinitif: "foutre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["foutrais", "foutrais", "foutrait", "foutrions", "foutriez", "foutraient"] {
      T.testConjugation(infinitif: "foutre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["foutis", "foutis", "foutit", "foutîmes", "foutîtes", "foutirent"] {
      T.testConjugation(infinitif: "foutre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["foute", "foutes", "foute", "foutions", "foutiez", "foutent"] {
      T.testConjugation(infinitif: "foutre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["foutisse", "foutisses", "foutît", "foutissions", "foutissiez", "foutissent"] {
      T.testConjugation(infinitif: "foutre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "foutre", tense: .participePassé, expected: "foutu", extraLetters: nil)
    T.testConjugation(infinitif: "foutre", tense: .participePrésent, expected: "foutant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["foUs", "foutons", "foutez"] {
      T.testConjugation(infinitif: "foutre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFrire() {
    // ID: 5-11A
    var personNumbersIndex = 0

    for conjugation in ["fris", "fris", "frit", "frions", "friez", "frient"] {
      T.testConjugation(infinitif: "frire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["friais", "friais", "friait", "friions", "friiez", "friaient"] {
      T.testConjugation(infinitif: "frire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["frirai", "friras", "frira", "frirons", "frirez", "friront"] {
      T.testConjugation(infinitif: "frire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["frirais", "frirais", "frirait", "fririons", "fririez", "friraient"] {
      T.testConjugation(infinitif: "frire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fris", "fris", "frit", "frîmes", "frîtes", "frirent"] {
      T.testConjugation(infinitif: "frire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["frie", "fries", "frie", "friions", "friiez", "frient"] {
      T.testConjugation(infinitif: "frire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["frisse", "frisses", "frît", "frissions", "frissiez", "frissent"] {
      T.testConjugation(infinitif: "frire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "frire", tense: .participePassé, expected: "friT", extraLetters: nil)
    T.testConjugation(infinitif: "frire", tense: .participePrésent, expected: "friant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["fris", "frions", "friez"] {
      T.testConjugation(infinitif: "frire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFuir() {
    // ID: 6-2
    var personNumbersIndex = 0

    for conjugation in ["fuIs", "fuIs", "fuIt", "fuYons", "fuYez", "fuIent"] {
      T.testConjugation(infinitif: "fuir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fuYais", "fuYais", "fuYait", "fuYions", "fuYiez", "fuYaient"] {
      T.testConjugation(infinitif: "fuir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fuirai", "fuiras", "fuira", "fuirons", "fuirez", "fuiront"] {
      T.testConjugation(infinitif: "fuir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fuirais", "fuirais", "fuirait", "fuirions", "fuiriez", "fuiraient"] {
      T.testConjugation(infinitif: "fuir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fuis", "fuis", "fuit", "fuîmes", "fuîtes", "fuirent"] {
      T.testConjugation(infinitif: "fuir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fuIe", "fuIes", "fuIe", "fuYions", "fuYiez", "fuIent"] {
      T.testConjugation(infinitif: "fuir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fuisse", "fuisses", "fuît", "fuissions", "fuissiez", "fuissent"] {
      T.testConjugation(infinitif: "fuir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "fuir", tense: .participePassé, expected: "fuI", extraLetters: nil)
    T.testConjugation(infinitif: "fuir", tense: .participePrésent, expected: "fuYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["fuIs", "fuYons", "fuYez"] {
      T.testConjugation(infinitif: "fuir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testGésir() {
    // ID: 5-28
    var personNumbersIndex = 0

    for conjugation in ["gIs", "gIs", "gÎt", "gIsons", "gIsez", "gIsent"] {
      T.testConjugation(infinitif: "gésir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["gIsais", "gIsais", "gIsait", "gIsions", "gIsiez", "gIsaient"] {
      T.testConjugation(infinitif: "gésir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["gésirai", "gésiras", "gésira", "gésirons", "gésirez", "gésiront"] {
      T.testConjugation(infinitif: "gésir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["gésirais", "gésirais", "gésirait", "gésirions", "gésiriez", "gésiraient"] {
      T.testConjugation(infinitif: "gésir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Jus", "géÜs", "Jut", "géûmes", "géûtes", "Jurent"] {
      T.testConjugation(infinitif: "gésir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["gIse", "gIses", "gIse", "gIsions", "gIsiez", "gIsent"] {
      T.testConjugation(infinitif: "gésir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Jusse", "géÜs", "Jût", "géussions", "géussiez", "Jussent"] {
      T.testConjugation(infinitif: "gésir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "gésir", tense: .participePassé, expected: "gÉÜ", extraLetters: nil)
    T.testConjugation(infinitif: "gésir", tense: .participePrésent, expected: "gIsant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["gIs", "gIsons", "gIsez"] {
      T.testConjugation(infinitif: "gésir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testHaïrFrance() {
    // ID: 2-3A
    var personNumbersIndex = 0

    for conjugation in ["hais", "hais", "hait", "haÏssons", "haÏssez", "haÏssent"] {
      T.testConjugation(infinitif: "haïr", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "France")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haÏssais", "haÏssais", "haÏssait", "haÏssions", "haÏssiez", "haÏssaient"] {
      T.testConjugation(infinitif: "haïr", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "France")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïrai", "haïras", "haïra", "haïrons", "haïrez", "haïront"] {
      T.testConjugation(infinitif: "haïr", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "France")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïrais", "haïrais", "haïrait", "haïrions", "haïriez", "haïraient"] {
      T.testConjugation(infinitif: "haïr", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "France")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïs", "haïs", "haït", "haïmes", "haïtes", "haïrent"] {
      T.testConjugation(infinitif: "haïr", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "France")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïsse", "haïsses", "haïsse", "haïssions", "haïssiez", "haïssent"] {
      T.testConjugation(infinitif: "haïr", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "France")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïsse", "haïsses", "haït", "haïssions", "haïssiez", "haïssent"] {
      T.testConjugation(infinitif: "haïr", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "France")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "haïr", tense: .participePassé, expected: "haï", extraLetters: "France")
    T.testConjugation(infinitif: "haïr", tense: .participePrésent, expected: "haÏssant", extraLetters: "France")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["hais", "haÏssons", "haÏssez"] {
      T.testConjugation(infinitif: "haïr", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: "France")
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testHaïrQuébec() {
    // ID: 2-3B
    var personNumbersIndex = 0

    for conjugation in ["haïs", "haïs", "haït", "haïssons", "haïssez", "haïssent"] {
      T.testConjugation(infinitif: "haïr", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "Québec")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïssais", "haïssais", "haïssait", "haïssions", "haïssiez", "haïssaient"] {
      T.testConjugation(infinitif: "haïr", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "Québec")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïrai", "haïras", "haïra", "haïrons", "haïrez", "haïront"] {
      T.testConjugation(infinitif: "haïr", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "Québec")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïrais", "haïrais", "haïrait", "haïrions", "haïriez", "haïraient"] {
      T.testConjugation(infinitif: "haïr", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "Québec")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïs", "haïs", "haït", "haïmes", "haïtes", "haïrent"] {
      T.testConjugation(infinitif: "haïr", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "Québec")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïsse", "haïsses", "haïsse", "haïssions", "haïssiez", "haïssent"] {
      T.testConjugation(infinitif: "haïr", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "Québec")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïsse", "haïsses", "haït", "haïssions", "haïssiez", "haïssent"] {
      T.testConjugation(infinitif: "haïr", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "Québec")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "haïr", tense: .participePassé, expected: "haï", extraLetters: "Québec")
    T.testConjugation(infinitif: "haïr", tense: .participePrésent, expected: "haïssant", extraLetters: "Québec")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["haïs", "haïssons", "haïssez"] {
      T.testConjugation(infinitif: "haïr", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: "Québec")
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testInclure() {
    // ID: 5-16B
    var personNumbersIndex = 0

    for conjugation in ["inclus", "inclus", "inclut", "incluons", "incluez", "incluent"] {
      T.testConjugation(infinitif: "inclure", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["incluais", "incluais", "incluait", "incluions", "incluiez", "incluaient"] {
      T.testConjugation(infinitif: "inclure", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["inclurai", "incluras", "inclura", "inclurons", "inclurez", "incluront"] {
      T.testConjugation(infinitif: "inclure", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["inclurais", "inclurais", "inclurait", "inclurions", "incluriez", "incluraient"] {
      T.testConjugation(infinitif: "inclure", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["inclus", "inclus", "inclut", "inclûmes", "inclûtes", "inclurent"] {
      T.testConjugation(infinitif: "inclure", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["inclue", "inclues", "inclue", "incluions", "incluiez", "incluent"] {
      T.testConjugation(infinitif: "inclure", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["inclusse", "inclusses", "inclût", "inclussions", "inclussiez", "inclussent"] {
      T.testConjugation(infinitif: "inclure", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "inclure", tense: .participePassé, expected: "incluS", extraLetters: nil)
    T.testConjugation(infinitif: "inclure", tense: .participePrésent, expected: "incluant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["inclus", "incluons", "incluez"] {
      T.testConjugation(infinitif: "inclure", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testIssir() {
    // ID: 6-8
    var personNumbersIndex = 0

    for conjugation in ["Is", "Is", "Ît", "issons", "issez", "issent"] {
      T.testConjugation(infinitif: "issir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["issais", "issais", "issait", "issions", "issiez", "issaient"] {
      T.testConjugation(infinitif: "issir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["isTrai", "isTras", "isTra", "isTrons", "isTrez", "isTront"] {
      T.testConjugation(infinitif: "issir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["isTrais", "isTrais", "isTrait", "isTrions", "isTriez", "isTraient"] {
      T.testConjugation(infinitif: "issir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["issis", "issis", "issit", "issîmes", "issîtes", "issirent"] {
      T.testConjugation(infinitif: "issir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["issE", "issES", "issE", "issIONS", "issIEZ", "issENT"] {
      T.testConjugation(infinitif: "issir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["ississe", "ississes", "issît", "ississions", "ississiez", "ississent"] {
      T.testConjugation(infinitif: "issir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "issir", tense: .participePassé, expected: "issU", extraLetters: nil)
    T.testConjugation(infinitif: "issir", tense: .participePrésent, expected: "issant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["Is", "issons", "issez"] {
      T.testConjugation(infinitif: "issir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testJeter() {
    // ID: 1-3B
    var personNumbersIndex = 0

    for conjugation in ["jetTe", "jetTes", "jetTe", "jetons", "jetez", "jetTent"] {
      T.testConjugation(infinitif: "jeter", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetais", "jetais", "jetait", "jetions", "jetiez", "jetaient"] {
      T.testConjugation(infinitif: "jeter", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetTerai", "jetTeras", "jetTera", "jetTerons", "jetTerez", "jetTeront"] {
      T.testConjugation(infinitif: "jeter", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetTerais", "jetTerais", "jetTerait", "jetTerions", "jetTeriez", "jetTeraient"] {
      T.testConjugation(infinitif: "jeter", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetai", "jetas", "jeta", "jetâmes", "jetâtes", "jetèrent"] {
      T.testConjugation(infinitif: "jeter", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetTe", "jetTes", "jetTe", "jetions", "jetiez", "jetTent"] {
      T.testConjugation(infinitif: "jeter", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetasse", "jetasses", "jetât", "jetassions", "jetassiez", "jetassent"] {
      T.testConjugation(infinitif: "jeter", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "jeter", tense: .participePassé, expected: "jeté", extraLetters: nil)
    T.testConjugation(infinitif: "jeter", tense: .participePrésent, expected: "jetant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["jetTe", "jetons", "jetez"] {
      T.testConjugation(infinitif: "jeter", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testLancer() {
    // ID: 1-2A
    var personNumbersIndex = 0

    for conjugation in ["lance", "lances", "lance", "lanÇons", "lancez", "lancent"] {
      T.testConjugation(infinitif: "lancer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lanÇais", "lanÇais", "lanÇait", "lanCions", "lanCiez", "lanÇaient"] {
      T.testConjugation(infinitif: "lancer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lancerai", "lanceras", "lancera", "lancerons", "lancerez", "lanceront"] {
      T.testConjugation(infinitif: "lancer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lancerais", "lancerais", "lancerait", "lancerions", "lanceriez", "lanceraient"] {
      T.testConjugation(infinitif: "lancer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lanÇai", "lanÇas", "lanÇa", "lanÇâmes", "lanÇâtes", "lancèrent"] {
      T.testConjugation(infinitif: "lancer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lance", "lances", "lance", "lanCions", "lanCiez", "lancent"] {
      T.testConjugation(infinitif: "lancer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lanÇasse", "lanÇasses", "lanÇât", "lanÇassions", "lanÇassiez", "lanÇassent"] {
      T.testConjugation(infinitif: "lancer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "lancer", tense: .participePassé, expected: "lancé", extraLetters: nil)
    T.testConjugation(infinitif: "lancer", tense: .participePrésent, expected: "lanÇant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["lance", "lanÇons", "lancez"] {
      T.testConjugation(infinitif: "lancer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testLire() {
    // ID: 5-10
    var personNumbersIndex = 0

    for conjugation in ["lis", "lis", "lit", "liSons", "liSez", "liSent"] {
      T.testConjugation(infinitif: "lire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["liSais", "liSais", "liSait", "liSions", "liSiez", "liSaient"] {
      T.testConjugation(infinitif: "lire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lirai", "liras", "lira", "lirons", "lirez", "liront"] {
      T.testConjugation(infinitif: "lire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lirais", "lirais", "lirait", "lirions", "liriez", "liraient"] {
      T.testConjugation(infinitif: "lire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Lus", "Lus", "Lut", "Lûmes", "Lûtes", "Lurent"] {
      T.testConjugation(infinitif: "lire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["liSe", "liSes", "liSe", "liSions", "liSiez", "liSent"] {
      T.testConjugation(infinitif: "lire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Lusse", "Lusses", "Lût", "Lussions", "Lussiez", "Lussent"] {
      T.testConjugation(infinitif: "lire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "lire", tense: .participePassé, expected: "Lu", extraLetters: nil)
    T.testConjugation(infinitif: "lire", tense: .participePrésent, expected: "liSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["lis", "liSons", "liSez"] {
      T.testConjugation(infinitif: "lire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testManger() {
    // ID: 1-2B
    var personNumbersIndex = 0

    for conjugation in ["mange", "manges", "mange", "mangEons", "mangez", "mangent"] {
      T.testConjugation(infinitif: "manger", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mangEais", "mangEais", "mangEait", "mangions", "mangiez", "mangEaient"] {
      T.testConjugation(infinitif: "manger", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mangerai", "mangeras", "mangera", "mangerons", "mangerez", "mangeront"] {
      T.testConjugation(infinitif: "manger", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mangerais", "mangerais", "mangerait", "mangerions", "mangeriez", "mangeraient"] {
      T.testConjugation(infinitif: "manger", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mangEai", "mangEas", "mangEa", "mangEâmes", "mangEâtes", "mangèrent"] {
      T.testConjugation(infinitif: "manger", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mange", "manges", "mange", "mangions", "mangiez", "mangent"] {
      T.testConjugation(infinitif: "manger", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mangEasse", "mangEasses", "mangEât", "mangEassions", "mangEassiez", "mangEassent"] {
      T.testConjugation(infinitif: "manger", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "manger", tense: .participePassé, expected: "mangé", extraLetters: nil)
    T.testConjugation(infinitif: "manger", tense: .participePrésent, expected: "mangEant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["mange", "mangEons", "mangez"] {
      T.testConjugation(infinitif: "manger", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testMaudire() {
    // ID: 2-2
    var personNumbersIndex = 0

    for conjugation in ["maudIs", "maudIs", "maudIt", "maudISSons", "maudISSez", "maudISSent"] {
      T.testConjugation(infinitif: "maudire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudISSais", "maudISSais", "maudISSait", "maudISSions", "maudISSiez", "maudISSaient"] {
      T.testConjugation(infinitif: "maudire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudirai", "maudiras", "maudira", "maudirons", "maudirez", "maudiront"] {
      T.testConjugation(infinitif: "maudire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudirais", "maudirais", "maudirait", "maudirions", "maudiriez", "maudiraient"] {
      T.testConjugation(infinitif: "maudire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudis", "maudis", "maudit", "maudîmes", "maudîtes", "maudirent"] {
      T.testConjugation(infinitif: "maudire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudISSe", "maudISSes", "maudISSe", "maudISSions", "maudISSiez", "maudISSent"] {
      T.testConjugation(infinitif: "maudire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudisse", "maudisses", "maudît", "maudissions", "maudissiez", "maudissent"] {
      T.testConjugation(infinitif: "maudire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "maudire", tense: .participePassé, expected: "maudiT", extraLetters: nil)
    T.testConjugation(infinitif: "maudire", tense: .participePrésent, expected: "maudISSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["maudIs", "maudISSons", "maudISSez"] {
      T.testConjugation(infinitif: "maudire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testMettre() {
    // ID: 5-4
    var personNumbersIndex = 0

    for conjugation in ["meTs", "meTs", "meT", "mettons", "mettez", "mettent"] {
      T.testConjugation(infinitif: "mettre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mettais", "mettais", "mettait", "mettions", "mettiez", "mettaient"] {
      T.testConjugation(infinitif: "mettre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mettrai", "mettras", "mettra", "mettrons", "mettrez", "mettront"] {
      T.testConjugation(infinitif: "mettre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mettrais", "mettrais", "mettrait", "mettrions", "mettriez", "mettraient"] {
      T.testConjugation(infinitif: "mettre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mis", "mis", "mit", "mîmes", "mîtes", "mirent"] {
      T.testConjugation(infinitif: "mettre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mette", "mettes", "mette", "mettions", "mettiez", "mettent"] {
      T.testConjugation(infinitif: "mettre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["misse", "misses", "mît", "missions", "missiez", "missent"] {
      T.testConjugation(infinitif: "mettre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "mettre", tense: .participePassé, expected: "mIS", extraLetters: nil)
    T.testConjugation(infinitif: "mettre", tense: .participePrésent, expected: "mettant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["meTs", "mettons", "mettez"] {
      T.testConjugation(infinitif: "mettre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testMoudre() {
    // ID: 5-15
    var personNumbersIndex = 0

    for conjugation in ["mouds", "mouds", "mouD", "mouLons", "mouLez", "mouLent"] {
      T.testConjugation(infinitif: "moudre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouLais", "mouLais", "mouLait", "mouLions", "mouLiez", "mouLaient"] {
      T.testConjugation(infinitif: "moudre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["moudrai", "moudras", "moudra", "moudrons", "moudrez", "moudront"] {
      T.testConjugation(infinitif: "moudre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["moudrais", "moudrais", "moudrait", "moudrions", "moudriez", "moudraient"] {
      T.testConjugation(infinitif: "moudre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouLus", "mouLus", "mouLut", "mouLûmes", "mouLûtes", "mouLurent"] {
      T.testConjugation(infinitif: "moudre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouLe", "mouLes", "mouLe", "mouLions", "mouLiez", "mouLent"] {
      T.testConjugation(infinitif: "moudre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouLusse", "mouLusses", "mouLût", "mouLussions", "mouLussiez", "mouLussent"] {
      T.testConjugation(infinitif: "moudre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "moudre", tense: .participePassé, expected: "mouLu", extraLetters: nil)
    T.testConjugation(infinitif: "moudre", tense: .participePrésent, expected: "mouLant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["mouds", "mouLons", "mouLez"] {
      T.testConjugation(infinitif: "moudre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testMourir() {
    // ID: 6-5
    var personNumbersIndex = 0

    for conjugation in ["mEurs", "mEurs", "mEurt", "mourons", "mourez", "mEurent"] {
      T.testConjugation(infinitif: "mourir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mourais", "mourais", "mourait", "mourions", "mouriez", "mouraient"] {
      T.testConjugation(infinitif: "mourir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouRrai", "mouRras", "mouRra", "mouRrons", "mouRrez", "mouRront"] {
      T.testConjugation(infinitif: "mourir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouRrais", "mouRrais", "mouRrait", "mouRrions", "mouRriez", "mouRraient"] {
      T.testConjugation(infinitif: "mourir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mourus", "mourus", "mourut", "mourûmes", "mourûtes", "moururent"] {
      T.testConjugation(infinitif: "mourir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mEurE", "mEurES", "mEurE", "mourIONS", "mourIEZ", "mEurENT"] {
      T.testConjugation(infinitif: "mourir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mourusse", "mourusses", "mourût", "mourussions", "mourussiez", "mourussent"] {
      T.testConjugation(infinitif: "mourir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "mourir", tense: .participePassé, expected: "mOrT", extraLetters: nil)
    T.testConjugation(infinitif: "mourir", tense: .participePrésent, expected: "mourant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["mEurs", "mourons", "mourez"] {
      T.testConjugation(infinitif: "mourir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testMouvoir() {
    // ID: 4-3A
    var personNumbersIndex = 0

    for conjugation in ["mEUs", "mEUs", "mEUt", "mouvons", "mouvez", "mEuvent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouvais", "mouvais", "mouvait", "mouvions", "mouviez", "mouvaient"] {
      T.testConjugation(infinitif: "mouvoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouvRai", "mouvRas", "mouvRa", "mouvRons", "mouvRez", "mouvRont"] {
      T.testConjugation(infinitif: "mouvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouvRais", "mouvRais", "mouvRait", "mouvRions", "mouvRiez", "mouvRaient"] {
      T.testConjugation(infinitif: "mouvoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Mus", "Mus", "Mut", "Mûmes", "Mûtes", "Murent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mEuvE", "mEuvES", "mEuvE", "mouvIONS", "mouvIEZ", "mEuvENT"] {
      T.testConjugation(infinitif: "mouvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Musse", "Musses", "Mût", "Mussions", "Mussiez", "Mussent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "mouvoir", tense: .participePassé, expected: "MÛ", extraLetters: nil)
    T.testConjugation(infinitif: "mouvoir", tense: .participePrésent, expected: "mouvant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["mEUs", "mouvons", "mouvez"] {
      T.testConjugation(infinitif: "mouvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testNaître() {
    // ID: 5-21
    var personNumbersIndex = 0

    for conjugation in ["naIs", "naIs", "naÎt", "naISSons", "naISSez", "naISSent"] {
      T.testConjugation(infinitif: "naître", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naISSais", "naISSais", "naISSait", "naISSions", "naISSiez", "naISSaient"] {
      T.testConjugation(infinitif: "naître", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naîtrai", "naîtras", "naîtra", "naîtrons", "naîtrez", "naîtront"] {
      T.testConjugation(infinitif: "naître", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naîtrais", "naîtrais", "naîtrait", "naîtrions", "naîtriez", "naîtraient"] {
      T.testConjugation(infinitif: "naître", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naQUis", "naQUis", "naQUit", "naQUîmes", "naQUîtes", "naQUirent"] {
      T.testConjugation(infinitif: "naître", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naISSe", "naISSes", "naISSe", "naISSions", "naISSiez", "naISSent"] {
      T.testConjugation(infinitif: "naître", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naQUisse", "naQUisses", "naQUît", "naQUissions", "naQUissiez", "naQUissent"] {
      T.testConjugation(infinitif: "naître", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "naître", tense: .participePassé, expected: "NÉ", extraLetters: nil)
    T.testConjugation(infinitif: "naître", tense: .participePrésent, expected: "naISSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["naIs", "naISSons", "naISSez"] {
      T.testConjugation(infinitif: "naître", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testNuire() {
    // ID: 5-9B
    var personNumbersIndex = 0

    for conjugation in ["nuis", "nuis", "nuit", "nuiSons", "nuiSez", "nuiSent"] {
      T.testConjugation(infinitif: "nuire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuiSais", "nuiSais", "nuiSait", "nuiSions", "nuiSiez", "nuiSaient"] {
      T.testConjugation(infinitif: "nuire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuirai", "nuiras", "nuira", "nuirons", "nuirez", "nuiront"] {
      T.testConjugation(infinitif: "nuire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuirais", "nuirais", "nuirait", "nuirions", "nuiriez", "nuiraient"] {
      T.testConjugation(infinitif: "nuire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuiSis", "nuiSis", "nuiSit", "nuiSîmes", "nuiSîtes", "nuiSirent"] {
      T.testConjugation(infinitif: "nuire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuiSe", "nuiSes", "nuiSe", "nuiSions", "nuiSiez", "nuiSent"] {
      T.testConjugation(infinitif: "nuire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuiSisse", "nuiSisses", "nuiSît", "nuiSissions", "nuiSissiez", "nuiSissent"] {
      T.testConjugation(infinitif: "nuire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "nuire", tense: .participePassé, expected: "nuI", extraLetters: nil)
    T.testConjugation(infinitif: "nuire", tense: .participePrésent, expected: "nuiSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["nuis", "nuiSons", "nuiSez"] {
      T.testConjugation(infinitif: "nuire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testOuïrTrad() {
    // ID: 2-5
    var personNumbersIndex = 0

    for conjugation in ["oIs", "oIs", "oIt", "oYons", "oYez", "oIent"] {
      T.testConjugation(infinitif: "ouïr", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "trad.")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["oYais", "oYais", "oYait", "oYions", "oYiez", "oYaient"] {
      T.testConjugation(infinitif: "ouïr", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "trad.")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["orRai/oIrai", "orRas/oIras", "orRa/oIra", "orRons/oIrons", "orRez/oIrez", "orRont/oIront"] {
      T.testConjugation(infinitif: "ouïr", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "trad.")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["orRais/oIrais", "orRais/oIrais", "orRait/oIrait", "orRions/oIrions", "orRiez/oIriez", "orRaient/oIraient"] {
      T.testConjugation(infinitif: "ouïr", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "trad.")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["ouïs", "ouïs", "ouït", "ouïmes", "ouïtes", "ouïrent"] {
      T.testConjugation(infinitif: "ouïr", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "trad.")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["oIE", "oIES", "oIE", "oYIONS", "oYIEZ", "oIENT"] {
      T.testConjugation(infinitif: "ouïr", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "trad.")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["ouïsse", "ouïsses", "ouït", "ouïssions", "ouïssiez", "ouïssent"] {
      T.testConjugation(infinitif: "ouïr", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: "trad.")
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "ouïr", tense: .participePassé, expected: "ouï", extraLetters: "trad.")
    T.testConjugation(infinitif: "ouïr", tense: .participePrésent, expected: "oYant", extraLetters: "trad.")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["oIs", "oYons", "oYez"] {
      T.testConjugation(infinitif: "ouïr", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: "trad.")
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testParler() {
    // ID: 1-1
    var personNumbersIndex = 0

    for conjugation in ["parle", "parles", "parle", "parlons", "parlez", "parlent"] {
      T.testConjugation(infinitif: "parler", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parlais", "parlais", "parlait", "parlions", "parliez", "parlaient"] {
      T.testConjugation(infinitif: "parler", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parlerai", "parleras", "parlera", "parlerons", "parlerez", "parleront"] {
      T.testConjugation(infinitif: "parler", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parlerais", "parlerais", "parlerait", "parlerions", "parleriez", "parleraient"] {
      T.testConjugation(infinitif: "parler", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parlai", "parlas", "parla", "parlâmes", "parlâtes", "parlèrent"] {
      T.testConjugation(infinitif: "parler", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parle", "parles", "parle", "parlions", "parliez", "parlent"] {
      T.testConjugation(infinitif: "parler", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parlasse", "parlasses", "parlât", "parlassions", "parlassiez", "parlassent"] {
      T.testConjugation(infinitif: "parler", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "parler", tense: .participePassé, expected: "parlé", extraLetters: nil)
    T.testConjugation(infinitif: "parler", tense: .participePrésent, expected: "parlant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["parle", "parlons", "parlez"] {
      T.testConjugation(infinitif: "parler", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPartir() {
    // ID: 6-1
    var personNumbersIndex = 0

    for conjugation in ["paRs", "paRs", "paRt", "partons", "partez", "partent"] {
      T.testConjugation(infinitif: "partir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["partais", "partais", "partait", "partions", "partiez", "partaient"] {
      T.testConjugation(infinitif: "partir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["partirai", "partiras", "partira", "partirons", "partirez", "partiront"] {
      T.testConjugation(infinitif: "partir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["partirais", "partirais", "partirait", "partirions", "partiriez", "partiraient"] {
      T.testConjugation(infinitif: "partir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["partis", "partis", "partit", "partîmes", "partîtes", "partirent"] {
      T.testConjugation(infinitif: "partir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["partE", "partES", "partE", "partIONS", "partIEZ", "partENT"] {
      T.testConjugation(infinitif: "partir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["partisse", "partisses", "partît", "partissions", "partissiez", "partissent"] {
      T.testConjugation(infinitif: "partir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "partir", tense: .participePassé, expected: "parti", extraLetters: nil)
    T.testConjugation(infinitif: "partir", tense: .participePrésent, expected: "partant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["paRs", "partons", "partez"] {
      T.testConjugation(infinitif: "partir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPayer() {
    // ID: 1-7B
    var personNumbersIndex = 0

    for conjugation in ["paye/paIe", "payes/paIes", "paye/paIe", "payons", "payez", "payent/paIent"] {
      T.testConjugation(infinitif: "payer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payais", "payais", "payait", "payions", "payiez", "payaient"] {
      T.testConjugation(infinitif: "payer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payerai/paIerai", "payeras/paIeras", "payera/paIera", "payerons/paIerons", "payerez/paIerez", "payeront/paIeront"] {
      T.testConjugation(infinitif: "payer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payerais/paIerais", "payerais/paIerais", "payerait/paIerait", "payerions/paIerions", "payeriez/paIeriez", "payeraient/paIeraient"] {
      T.testConjugation(infinitif: "payer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payai", "payas", "paya", "payâmes", "payâtes", "payèrent"] {
      T.testConjugation(infinitif: "payer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["paye/paIe", "payes/paIes", "paye/paIe", "payions", "payiez", "payent/paIent"] {
      T.testConjugation(infinitif: "payer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payasse", "payasses", "payât", "payassions", "payassiez", "payassent"] {
      T.testConjugation(infinitif: "payer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "payer", tense: .participePassé, expected: "payé", extraLetters: nil)
    T.testConjugation(infinitif: "payer", tense: .participePrésent, expected: "payant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["paye/paIe", "payons", "payez"] {
      T.testConjugation(infinitif: "payer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPeser() {
    // ID: 1-4
    var personNumbersIndex = 0

    for conjugation in ["pÈse", "pÈses", "pÈse", "pesons", "pesez", "pÈsent"] {
      T.testConjugation(infinitif: "peser", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pesais", "pesais", "pesait", "pesions", "pesiez", "pesaient"] {
      T.testConjugation(infinitif: "peser", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pÈserai", "pÈseras", "pÈsera", "pÈserons", "pÈserez", "pÈseront"] {
      T.testConjugation(infinitif: "peser", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pÈserais", "pÈserais", "pÈserait", "pÈserions", "pÈseriez", "pÈseraient"] {
      T.testConjugation(infinitif: "peser", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pesai", "pesas", "pesa", "pesâmes", "pesâtes", "pesèrent"] {
      T.testConjugation(infinitif: "peser", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pÈse", "pÈses", "pÈse", "pesions", "pesiez", "pÈsent"] {
      T.testConjugation(infinitif: "peser", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pesasse", "pesasses", "pesât", "pesassions", "pesassiez", "pesassent"] {
      T.testConjugation(infinitif: "peser", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "peser", tense: .participePassé, expected: "pesé", extraLetters: nil)
    T.testConjugation(infinitif: "peser", tense: .participePrésent, expected: "pesant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["pÈse", "pesons", "pesez"] {
      T.testConjugation(infinitif: "peser", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPlaindre() {
    // ID: 5-12
    var personNumbersIndex = 0

    for conjugation in ["plaiNs", "plaiNs", "plaiNt", "plaiGNons", "plaiGNez", "plaiGNent"] {
      T.testConjugation(infinitif: "plaindre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaiGNais", "plaiGNais", "plaiGNait", "plaiGNions", "plaiGNiez", "plaiGNaient"] {
      T.testConjugation(infinitif: "plaindre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaindrai", "plaindras", "plaindra", "plaindrons", "plaindrez", "plaindront"] {
      T.testConjugation(infinitif: "plaindre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaindrais", "plaindrais", "plaindrait", "plaindrions", "plaindriez", "plaindraient"] {
      T.testConjugation(infinitif: "plaindre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaiGNis", "plaiGNis", "plaiGNit", "plaiGNîmes", "plaiGNîtes", "plaiGNirent"] {
      T.testConjugation(infinitif: "plaindre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaiGNe", "plaiGNes", "plaiGNe", "plaiGNions", "plaiGNiez", "plaiGNent"] {
      T.testConjugation(infinitif: "plaindre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaiGNisse", "plaiGNisses", "plaiGNît", "plaiGNissions", "plaiGNissiez", "plaiGNissent"] {
      T.testConjugation(infinitif: "plaindre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "plaindre", tense: .participePassé, expected: "plaiNT", extraLetters: nil)
    T.testConjugation(infinitif: "plaindre", tense: .participePrésent, expected: "plaiGNant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["plaiNs", "plaiGNons", "plaiGNez"] {
      T.testConjugation(infinitif: "plaindre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPlaire() {
    // ID: 5-22A
    var personNumbersIndex = 0

    for conjugation in ["plais", "plais", "plaÎt", "plaiSons", "plaiSez", "plaiSent"] {
      T.testConjugation(infinitif: "plaire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaiSais", "plaiSais", "plaiSait", "plaiSions", "plaiSiez", "plaiSaient"] {
      T.testConjugation(infinitif: "plaire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plairai", "plairas", "plaira", "plairons", "plairez", "plairont"] {
      T.testConjugation(infinitif: "plaire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plairais", "plairais", "plairait", "plairions", "plairiez", "plairaient"] {
      T.testConjugation(infinitif: "plaire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pLus", "pLus", "pLut", "pLûmes", "pLûtes", "pLurent"] {
      T.testConjugation(infinitif: "plaire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaiSe", "plaiSes", "plaiSe", "plaiSions", "plaiSiez", "plaiSent"] {
      T.testConjugation(infinitif: "plaire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pLusse", "pLusses", "pLût", "pLussions", "pLussiez", "pLussent"] {
      T.testConjugation(infinitif: "plaire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "plaire", tense: .participePassé, expected: "pLu", extraLetters: nil)
    T.testConjugation(infinitif: "plaire", tense: .participePrésent, expected: "plaiSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["plais", "plaiSons", "plaiSez"] {
      T.testConjugation(infinitif: "plaire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPleuvoir() {
    // ID: 4-4
    var personNumbersIndex = 0

    for conjugation in ["pleUs", "pleUs", "pleUt", "pleuvons", "pleuvez", "pleuvent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pleuvais", "pleuvais", "pleuvait", "pleuvions", "pleuviez", "pleuvaient"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pleuvRai", "pleuvRas", "pleuvRa", "pleuvRons", "pleuvRez", "pleuvRont"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pleuvRais", "pleuvRais", "pleuvRait", "pleuvRions", "pleuvRiez", "pleuvRaient"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pLus", "pLus", "pLut", "pLûmes", "pLûtes", "pLurent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pleuvE", "pleuvES", "pleuvE", "pleuvIONS", "pleuvIEZ", "pleuvENT"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pLusse", "pLusses", "pLût", "pLussions", "pLussiez", "pLussent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "pleuvoir", tense: .participePassé, expected: "pLU", extraLetters: nil)
    T.testConjugation(infinitif: "pleuvoir", tense: .participePrésent, expected: "pleuvant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["pleUs", "pleuvons", "pleuvez"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPourvoir() {
    // ID: 4-1C
    var personNumbersIndex = 0

    for conjugation in ["pourvOIs", "pourvOIs", "pourvOIt", "pourvOYons", "pourvOYez", "pourvOIent"] {
      T.testConjugation(infinitif: "pourvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvOYais", "pourvOYais", "pourvOYait", "pourvOYions", "pourvOYiez", "pourvOYaient"] {
      T.testConjugation(infinitif: "pourvoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvoirai", "pourvoiras", "pourvoira", "pourvoirons", "pourvoirez", "pourvoiront"] {
      T.testConjugation(infinitif: "pourvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvoirais", "pourvoirais", "pourvoirait", "pourvoirions", "pourvoiriez", "pourvoiraient"] {
      T.testConjugation(infinitif: "pourvoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvus", "pourvus", "pourvut", "pourvûmes", "pourvûtes", "pourvurent"] {
      T.testConjugation(infinitif: "pourvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvOIE", "pourvOIES", "pourvOIE", "pourvOYIONS", "pourvOYIEZ", "pourvOIENT"] {
      T.testConjugation(infinitif: "pourvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvusse", "pourvusses", "pourvût", "pourvussions", "pourvussiez", "pourvussent"] {
      T.testConjugation(infinitif: "pourvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "pourvoir", tense: .participePassé, expected: "pourvU", extraLetters: nil)
    T.testConjugation(infinitif: "pourvoir", tense: .participePrésent, expected: "pourvOYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["pourvOIs", "pourvOYons", "pourvOYez"] {
      T.testConjugation(infinitif: "pourvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPouvoir() {
    // ID: 4-6
    var personNumbersIndex = 0

    for conjugation in ["pEUX/pUIs", "pEUX", "pEUt", "pouvons", "pouvez", "pouvent"] {
      T.testConjugation(infinitif: "pouvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pouvais", "pouvais", "pouvait", "pouvions", "pouviez", "pouvaient"] {
      T.testConjugation(infinitif: "pouvoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pouRrai", "pouRras", "pouRra", "pouRrons", "pouRrez", "pouRront"] {
      T.testConjugation(infinitif: "pouvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pouRrais", "pouRrais", "pouRrait", "pouRrions", "pouRriez", "pouRraient"] {
      T.testConjugation(infinitif: "pouvoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Pus", "Pus", "Put", "Pûmes", "Pûtes", "Purent"] {
      T.testConjugation(infinitif: "pouvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pUISSE", "pUISSES", "pUISSE", "pUISSIONS", "pUISSIEZ", "pUISSENT"] {
      T.testConjugation(infinitif: "pouvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Pusse", "Pusses", "Pût", "Pussions", "Pussiez", "Pussent"] {
      T.testConjugation(infinitif: "pouvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "pouvoir", tense: .participePassé, expected: "PU", extraLetters: nil)
    T.testConjugation(infinitif: "pouvoir", tense: .participePrésent, expected: "pouvant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["pUISSes", "pUISSIons", "pUISSIez"] {
      T.testConjugation(infinitif: "pouvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPrendre() {
    // ID: 5-2
    var personNumbersIndex = 0

    for conjugation in ["prends", "prends", "prend", "preNons", "preNez", "prenNent"] {
      T.testConjugation(infinitif: "prendre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["preNais", "preNais", "preNait", "preNions", "preNiez", "preNaient"] {
      T.testConjugation(infinitif: "prendre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prendrai", "prendras", "prendra", "prendrons", "prendrez", "prendront"] {
      T.testConjugation(infinitif: "prendre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prendrais", "prendrais", "prendrait", "prendrions", "prendriez", "prendraient"] {
      T.testConjugation(infinitif: "prendre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pris", "pris", "prit", "prîmes", "prîtes", "prirent"] {
      T.testConjugation(infinitif: "prendre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prenNe", "prenNes", "prenNe", "preNions", "preNiez", "prenNent"] {
      T.testConjugation(infinitif: "prendre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prisse", "prisses", "prît", "prissions", "prissiez", "prissent"] {
      T.testConjugation(infinitif: "prendre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "prendre", tense: .participePassé, expected: "prIS", extraLetters: nil)
    T.testConjugation(infinitif: "prendre", tense: .participePrésent, expected: "preNant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["prends", "preNons", "preNez"] {
      T.testConjugation(infinitif: "prendre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPrédire() {
    // ID: 5-8B
    var personNumbersIndex = 0

    for conjugation in ["prédis", "prédis", "prédit", "prédiSons", "prédiSez", "prédiSent"] {
      T.testConjugation(infinitif: "prédire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédiSais", "prédiSais", "prédiSait", "prédiSions", "prédiSiez", "prédiSaient"] {
      T.testConjugation(infinitif: "prédire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédirai", "prédiras", "prédira", "prédirons", "prédirez", "prédiront"] {
      T.testConjugation(infinitif: "prédire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédirais", "prédirais", "prédirait", "prédirions", "prédiriez", "prédiraient"] {
      T.testConjugation(infinitif: "prédire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédis", "prédis", "prédit", "prédîmes", "prédîtes", "prédirent"] {
      T.testConjugation(infinitif: "prédire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédiSe", "prédiSes", "prédiSe", "prédiSions", "prédiSiez", "prédiSent"] {
      T.testConjugation(infinitif: "prédire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédisse", "prédisses", "prédît", "prédissions", "prédissiez", "prédissent"] {
      T.testConjugation(infinitif: "prédire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "prédire", tense: .participePassé, expected: "prédiT", extraLetters: nil)
    T.testConjugation(infinitif: "prédire", tense: .participePrésent, expected: "prédiSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["prédis", "prédiSons", "prédiSez"] {
      T.testConjugation(infinitif: "prédire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPrévaloir() {
    // ID: 4-5B
    var personNumbersIndex = 0

    for conjugation in ["prévaUX", "prévaUX", "prévaUt", "prévalons", "prévalez", "prévalent"] {
      T.testConjugation(infinitif: "prévaloir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévalais", "prévalais", "prévalait", "prévalions", "prévaliez", "prévalaient"] {
      T.testConjugation(infinitif: "prévaloir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévaUDrai", "prévaUDras", "prévaUDra", "prévaUDrons", "prévaUDrez", "prévaUDront"] {
      T.testConjugation(infinitif: "prévaloir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévaUDrais", "prévaUDrais", "prévaUDrait", "prévaUDrions", "prévaUDriez", "prévaUDraient"] {
      T.testConjugation(infinitif: "prévaloir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévalus", "prévalus", "prévalut", "prévalûmes", "prévalûtes", "prévalurent"] {
      T.testConjugation(infinitif: "prévaloir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévaLE", "prévaLES", "prévaLE", "prévalIONS", "prévalIEZ", "prévaLENT"] {
      T.testConjugation(infinitif: "prévaloir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévalusse", "prévalusses", "prévalût", "prévalussions", "prévalussiez", "prévalussent"] {
      T.testConjugation(infinitif: "prévaloir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "prévaloir", tense: .participePassé, expected: "prévalU", extraLetters: nil)
    T.testConjugation(infinitif: "prévaloir", tense: .participePrésent, expected: "prévalant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["prévaUX", "prévalons", "prévalez"] {
      T.testConjugation(infinitif: "prévaloir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPrévoir() {
    // ID: 4-1B
    var personNumbersIndex = 0

    for conjugation in ["prévOIs", "prévOIs", "prévOIt", "prévOYons", "prévOYez", "prévOIent"] {
      T.testConjugation(infinitif: "prévoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévOYais", "prévOYais", "prévOYait", "prévOYions", "prévOYiez", "prévOYaient"] {
      T.testConjugation(infinitif: "prévoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévoirai", "prévoiras", "prévoira", "prévoirons", "prévoirez", "prévoiront"] {
      T.testConjugation(infinitif: "prévoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévoirais", "prévoirais", "prévoirait", "prévoirions", "prévoiriez", "prévoiraient"] {
      T.testConjugation(infinitif: "prévoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévis", "prévis", "prévit", "prévîmes", "prévîtes", "prévirent"] {
      T.testConjugation(infinitif: "prévoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévOIE", "prévOIES", "prévOIE", "prévOYIONS", "prévOYIEZ", "prévOIENT"] {
      T.testConjugation(infinitif: "prévoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévisse", "prévisses", "prévît", "prévissions", "prévissiez", "prévissent"] {
      T.testConjugation(infinitif: "prévoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "prévoir", tense: .participePassé, expected: "prévU", extraLetters: nil)
    T.testConjugation(infinitif: "prévoir", tense: .participePrésent, expected: "prévOYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["prévOIs", "prévOYons", "prévOYez"] {
      T.testConjugation(infinitif: "prévoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPromouvoir() {
    // ID: 4-3B
    var personNumbersIndex = 0

    for conjugation in ["promEUs", "promEUs", "promEUt", "promouvons", "promouvez", "promEuvent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promouvais", "promouvais", "promouvait", "promouvions", "promouviez", "promouvaient"] {
      T.testConjugation(infinitif: "promouvoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promouvRai", "promouvRas", "promouvRa", "promouvRons", "promouvRez", "promouvRont"] {
      T.testConjugation(infinitif: "promouvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promouvRais", "promouvRais", "promouvRait", "promouvRions", "promouvRiez", "promouvRaient"] {
      T.testConjugation(infinitif: "promouvoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["proMus", "proMus", "proMut", "proMûmes", "proMûtes", "proMurent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promEuvE", "promEuvES", "promEuvE", "promouvIONS", "promouvIEZ", "promEuvENT"] {
      T.testConjugation(infinitif: "promouvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["proMusse", "proMusses", "proMût", "proMussions", "proMussiez", "proMussent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "promouvoir", tense: .participePassé, expected: "proMU", extraLetters: nil)
    T.testConjugation(infinitif: "promouvoir", tense: .participePrésent, expected: "promouvant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["promEUs", "promouvons", "promouvez"] {
      T.testConjugation(infinitif: "promouvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testProtéger() {
    // ID: 1-6C
    var personNumbersIndex = 0

    for conjugation in ["protÈge", "protÈges", "protÈge", "protégEons", "protégez", "protÈgent"] {
      T.testConjugation(infinitif: "protéger", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protégEais", "protégEais", "protégEait", "protégions", "protégiez", "protégEaient"] {
      T.testConjugation(infinitif: "protéger", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protégerai", "protégeras", "protégera", "protégerons", "protégerez", "protégeront"] {
      T.testConjugation(infinitif: "protéger", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protégerais", "protégerais", "protégerait", "protégerions", "protégeriez", "protégeraient"] {
      T.testConjugation(infinitif: "protéger", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protégEai", "protégEas", "protégEa", "protégEâmes", "protégEâtes", "protégèrent"] {
      T.testConjugation(infinitif: "protéger", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protÈge", "protÈges", "protÈge", "protégions", "protégiez", "protÈgent"] {
      T.testConjugation(infinitif: "protéger", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protégEasse", "protégEasses", "protégEât", "protégEassions", "protégEassiez", "protégEassent"] {
      T.testConjugation(infinitif: "protéger", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "protéger", tense: .participePassé, expected: "protégé", extraLetters: nil)
    T.testConjugation(infinitif: "protéger", tense: .participePrésent, expected: "protégEant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["protÈge", "protégEons", "protégez"] {
      T.testConjugation(infinitif: "protéger", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRapiécer() {
    // ID: 1-6B
    var personNumbersIndex = 0

    for conjugation in ["rapiÈce", "rapiÈces", "rapiÈce", "rapiéÇons", "rapiécez", "rapiÈcent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiéÇais", "rapiéÇais", "rapiéÇait", "rapiéCions", "rapiéCiez", "rapiéÇaient"] {
      T.testConjugation(infinitif: "rapiécer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiécerai", "rapiéceras", "rapiécera", "rapiécerons", "rapiécerez", "rapiéceront"] {
      T.testConjugation(infinitif: "rapiécer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiécerais", "rapiécerais", "rapiécerait", "rapiécerions", "rapiéceriez", "rapiéceraient"] {
      T.testConjugation(infinitif: "rapiécer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiéÇai", "rapiéÇas", "rapiéÇa", "rapiéÇâmes", "rapiéÇâtes", "rapiécèrent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiÈce", "rapiÈces", "rapiÈce", "rapiéCions", "rapiéCiez", "rapiÈcent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiéÇasse", "rapiéÇasses", "rapiéÇât", "rapiéÇassions", "rapiéÇassiez", "rapiéÇassent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "rapiécer", tense: .participePassé, expected: "rapiécé", extraLetters: nil)
    T.testConjugation(infinitif: "rapiécer", tense: .participePrésent, expected: "rapiéÇant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["rapiÈce", "rapiéÇons", "rapiécez"] {
      T.testConjugation(infinitif: "rapiécer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRecevoir() {
    // ID: 4-2B
    var personNumbersIndex = 0

    for conjugation in ["reÇOIs", "reÇOIs", "reÇOIt", "recevons", "recevez", "reÇOIvent"] {
      T.testConjugation(infinitif: "recevoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["recevais", "recevais", "recevait", "recevions", "receviez", "recevaient"] {
      T.testConjugation(infinitif: "recevoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["recevRai", "recevRas", "recevRa", "recevRons", "recevRez", "recevRont"] {
      T.testConjugation(infinitif: "recevoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["recevRais", "recevRais", "recevRait", "recevRions", "recevRiez", "recevRaient"] {
      T.testConjugation(infinitif: "recevoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["reÇus", "reÇus", "reÇut", "reÇûmes", "reÇûtes", "reÇurent"] {
      T.testConjugation(infinitif: "recevoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["reÇOIvE", "reÇOIvES", "reÇOIvE", "recevIONS", "recevIEZ", "reÇOIvENT"] {
      T.testConjugation(infinitif: "recevoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["reÇusse", "reÇusses", "reÇût", "reÇussions", "reÇussiez", "reÇussent"] {
      T.testConjugation(infinitif: "recevoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "recevoir", tense: .participePassé, expected: "reÇU", extraLetters: nil)
    T.testConjugation(infinitif: "recevoir", tense: .participePrésent, expected: "recevant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["reÇOIs", "recevons", "recevez"] {
      T.testConjugation(infinitif: "recevoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRendre() {
    // ID: 5-1A
    var personNumbersIndex = 0

    for conjugation in ["rends", "rends", "rend", "rendons", "rendez", "rendent"] {
      T.testConjugation(infinitif: "rendre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rendais", "rendais", "rendait", "rendions", "rendiez", "rendaient"] {
      T.testConjugation(infinitif: "rendre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rendrai", "rendras", "rendra", "rendrons", "rendrez", "rendront"] {
      T.testConjugation(infinitif: "rendre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rendrais", "rendrais", "rendrait", "rendrions", "rendriez", "rendraient"] {
      T.testConjugation(infinitif: "rendre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rendis", "rendis", "rendit", "rendîmes", "rendîtes", "rendirent"] {
      T.testConjugation(infinitif: "rendre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rende", "rendes", "rende", "rendions", "rendiez", "rendent"] {
      T.testConjugation(infinitif: "rendre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rendisse", "rendisses", "rendît", "rendissions", "rendissiez", "rendissent"] {
      T.testConjugation(infinitif: "rendre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "rendre", tense: .participePassé, expected: "rendu", extraLetters: nil)
    T.testConjugation(infinitif: "rendre", tense: .participePrésent, expected: "rendant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["rends", "rendons", "rendez"] {
      T.testConjugation(infinitif: "rendre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRire() {
    // ID: 5-11
    var personNumbersIndex = 0

    for conjugation in ["ris", "ris", "rit", "rions", "riez", "rient"] {
      T.testConjugation(infinitif: "rire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["riais", "riais", "riait", "riions", "riiez", "riaient"] {
      T.testConjugation(infinitif: "rire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rirai", "riras", "rira", "rirons", "rirez", "riront"] {
      T.testConjugation(infinitif: "rire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rirais", "rirais", "rirait", "ririons", "ririez", "riraient"] {
      T.testConjugation(infinitif: "rire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["ris", "ris", "rit", "rîmes", "rîtes", "rirent"] {
      T.testConjugation(infinitif: "rire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rie", "ries", "rie", "riions", "riiez", "rient"] {
      T.testConjugation(infinitif: "rire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["risse", "risses", "rît", "rissions", "rissiez", "rissent"] {
      T.testConjugation(infinitif: "rire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "rire", tense: .participePassé, expected: "rI", extraLetters: nil)
    T.testConjugation(infinitif: "rire", tense: .participePrésent, expected: "riant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["ris", "rions", "riez"] {
      T.testConjugation(infinitif: "rire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRompre() {
    // ID: 5-1B
    var personNumbersIndex = 0

    for conjugation in ["romps", "romps", "rompT", "rompons", "rompez", "rompent"] {
      T.testConjugation(infinitif: "rompre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rompais", "rompais", "rompait", "rompions", "rompiez", "rompaient"] {
      T.testConjugation(infinitif: "rompre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["romprai", "rompras", "rompra", "romprons", "romprez", "rompront"] {
      T.testConjugation(infinitif: "rompre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["romprais", "romprais", "romprait", "romprions", "rompriez", "rompraient"] {
      T.testConjugation(infinitif: "rompre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rompis", "rompis", "rompit", "rompîmes", "rompîtes", "rompirent"] {
      T.testConjugation(infinitif: "rompre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rompe", "rompes", "rompe", "rompions", "rompiez", "rompent"] {
      T.testConjugation(infinitif: "rompre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rompisse", "rompisses", "rompît", "rompissions", "rompissiez", "rompissent"] {
      T.testConjugation(infinitif: "rompre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "rompre", tense: .participePassé, expected: "rompu", extraLetters: nil)
    T.testConjugation(infinitif: "rompre", tense: .participePrésent, expected: "rompant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["romps", "rompons", "rompez"] {
      T.testConjugation(infinitif: "rompre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testSavoir() {
    // ID: 4-7
    var personNumbersIndex = 0

    for conjugation in ["saIs", "saIs", "saIt", "savons", "savez", "savent"] {
      T.testConjugation(infinitif: "savoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["savais", "savais", "savait", "savions", "saviez", "savaient"] {
      T.testConjugation(infinitif: "savoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["saUrai", "saUras", "saUra", "saUrons", "saUrez", "saUront"] {
      T.testConjugation(infinitif: "savoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["saUrais", "saUrais", "saUrait", "saUrions", "saUriez", "saUraient"] {
      T.testConjugation(infinitif: "savoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Sus", "Sus", "Sut", "Sûmes", "Sûtes", "Surent"] {
      T.testConjugation(infinitif: "savoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["saCHE", "saCHES", "saCHE", "saCHIONS", "saCHIEZ", "saCHENT"] {
      T.testConjugation(infinitif: "savoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Susse", "Susses", "Sût", "Sussions", "Sussiez", "Sussent"] {
      T.testConjugation(infinitif: "savoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "savoir", tense: .participePassé, expected: "SU", extraLetters: nil)
    T.testConjugation(infinitif: "savoir", tense: .participePrésent, expected: "saCHant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["saCHE", "saCHons", "saCHez"] {
      T.testConjugation(infinitif: "savoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testSuffire() {
    // ID: 5-8C
    var personNumbersIndex = 0

    for conjugation in ["suffis", "suffis", "suffit", "suffiSons", "suffiSez", "suffiSent"] {
      T.testConjugation(infinitif: "suffire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffiSais", "suffiSais", "suffiSait", "suffiSions", "suffiSiez", "suffiSaient"] {
      T.testConjugation(infinitif: "suffire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffirai", "suffiras", "suffira", "suffirons", "suffirez", "suffiront"] {
      T.testConjugation(infinitif: "suffire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffirais", "suffirais", "suffirait", "suffirions", "suffiriez", "suffiraient"] {
      T.testConjugation(infinitif: "suffire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffis", "suffis", "suffit", "suffîmes", "suffîtes", "suffirent"] {
      T.testConjugation(infinitif: "suffire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffiSe", "suffiSes", "suffiSe", "suffiSions", "suffiSiez", "suffiSent"] {
      T.testConjugation(infinitif: "suffire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffisse", "suffisses", "suffît", "suffissions", "suffissiez", "suffissent"] {
      T.testConjugation(infinitif: "suffire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "suffire", tense: .participePassé, expected: "suffI", extraLetters: nil)
    T.testConjugation(infinitif: "suffire", tense: .participePrésent, expected: "suffiSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["suffis", "suffiSons", "suffiSez"] {
      T.testConjugation(infinitif: "suffire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testSuivre() {
    // ID: 5-5
    var personNumbersIndex = 0

    for conjugation in ["suIs", "suIs", "suIt", "suivons", "suivez", "suivent"] {
      T.testConjugation(infinitif: "suivre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suivais", "suivais", "suivait", "suivions", "suiviez", "suivaient"] {
      T.testConjugation(infinitif: "suivre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suivrai", "suivras", "suivra", "suivrons", "suivrez", "suivront"] {
      T.testConjugation(infinitif: "suivre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suivrais", "suivrais", "suivrait", "suivrions", "suivriez", "suivraient"] {
      T.testConjugation(infinitif: "suivre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suivis", "suivis", "suivit", "suivîmes", "suivîtes", "suivirent"] {
      T.testConjugation(infinitif: "suivre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suive", "suives", "suive", "suivions", "suiviez", "suivent"] {
      T.testConjugation(infinitif: "suivre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suivisse", "suivisses", "suivît", "suivissions", "suivissiez", "suivissent"] {
      T.testConjugation(infinitif: "suivre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "suivre", tense: .participePassé, expected: "suivIS", extraLetters: nil)
    T.testConjugation(infinitif: "suivre", tense: .participePrésent, expected: "suivant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["suIs", "suivons", "suivez"] {
      T.testConjugation(infinitif: "suivre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testSurseoir() {
    // ID: 4-9C
    var personNumbersIndex = 0

    for conjugation in ["sursOIs", "sursOIs", "sursOIt", "sursOYons", "sursOYez", "sursOIent"] {
      T.testConjugation(infinitif: "surseoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["sursOYais", "sursOYais", "sursOYait", "sursOYions", "sursOYiez", "sursOYaient"] {
      T.testConjugation(infinitif: "surseoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["surseoirai", "surseoiras", "surseoira", "surseoirons", "surseoirez", "surseoiront"] {
      T.testConjugation(infinitif: "surseoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["surseoirais", "surseoirais", "surseoirait", "surseoirions", "surseoiriez", "surseoiraient"] {
      T.testConjugation(infinitif: "surseoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["surSis", "surSis", "surSit", "surSîmes", "surSîtes", "surSirent"] {
      T.testConjugation(infinitif: "surseoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["sursOIE", "sursOIES", "sursOIE", "sursOYIONS", "sursOYIEZ", "sursOIENT"] {
      T.testConjugation(infinitif: "surseoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["surSisse", "surSisses", "surSît", "surSissions", "surSissiez", "surSissent"] {
      T.testConjugation(infinitif: "surseoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "surseoir", tense: .participePassé, expected: "surSIS", extraLetters: nil)
    T.testConjugation(infinitif: "surseoir", tense: .participePrésent, expected: "sursOYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["sursOIs", "sursOYons", "sursOYez"] {
      T.testConjugation(infinitif: "surseoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testTaire() {
    // ID: 5-22B
    var personNumbersIndex = 0

    for conjugation in ["tais", "tais", "tait", "taiSons", "taiSez", "taiSent"] {
      T.testConjugation(infinitif: "taire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["taiSais", "taiSais", "taiSait", "taiSions", "taiSiez", "taiSaient"] {
      T.testConjugation(infinitif: "taire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["tairai", "tairas", "taira", "tairons", "tairez", "tairont"] {
      T.testConjugation(infinitif: "taire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["tairais", "tairais", "tairait", "tairions", "tairiez", "tairaient"] {
      T.testConjugation(infinitif: "taire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Tus", "Tus", "Tut", "Tûmes", "Tûtes", "Turent"] {
      T.testConjugation(infinitif: "taire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["taiSe", "taiSes", "taiSe", "taiSions", "taiSiez", "taiSent"] {
      T.testConjugation(infinitif: "taire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Tusse", "Tusses", "Tût", "Tussions", "Tussiez", "Tussent"] {
      T.testConjugation(infinitif: "taire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "taire", tense: .participePassé, expected: "Tu", extraLetters: nil)
    T.testConjugation(infinitif: "taire", tense: .participePrésent, expected: "taiSant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["tais", "taiSons", "taiSez"] {
      T.testConjugation(infinitif: "taire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testTraire() {
    // ID: 5-24
    var personNumbersIndex = 0

    for conjugation in ["trais", "trais", "trait", "traYons", "traYez", "traient"] {
      T.testConjugation(infinitif: "traire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["traYais", "traYais", "traYait", "traYions", "traYiez", "traYaient"] {
      T.testConjugation(infinitif: "traire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["trairai", "trairas", "traira", "trairons", "trairez", "trairont"] {
      T.testConjugation(infinitif: "traire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["trairais", "trairais", "trairait", "trairions", "trairiez", "trairaient"] {
      T.testConjugation(infinitif: "traire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["traYai", "traYas", "traYa", "traYâmes", "traYâtes", "traYèrent"] {
      T.testConjugation(infinitif: "traire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["traie", "traies", "traie", "traYions", "traYiez", "traient"] {
      T.testConjugation(infinitif: "traire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["traYasse", "traYasses", "traYât", "traYassions", "traYassiez", "traYassent"] {
      T.testConjugation(infinitif: "traire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "traire", tense: .participePassé, expected: "traiT", extraLetters: nil)
    T.testConjugation(infinitif: "traire", tense: .participePrésent, expected: "traYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["trais", "traYons", "traYez"] {
      T.testConjugation(infinitif: "traire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testVaincre() {
    // ID: 5-25
    var personNumbersIndex = 0

    for conjugation in ["vaincs", "vaincs", "vainc", "vainQUons", "vainQUez", "vainQUent"] {
      T.testConjugation(infinitif: "vaincre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vainQUais", "vainQUais", "vainQUait", "vainQUions", "vainQUiez", "vainQUaient"] {
      T.testConjugation(infinitif: "vaincre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vaincrai", "vaincras", "vaincra", "vaincrons", "vaincrez", "vaincront"] {
      T.testConjugation(infinitif: "vaincre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vaincrais", "vaincrais", "vaincrait", "vaincrions", "vaincriez", "vaincraient"] {
      T.testConjugation(infinitif: "vaincre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vainQUis", "vainQUis", "vainQUit", "vainQUîmes", "vainQUîtes", "vainQUirent"] {
      T.testConjugation(infinitif: "vaincre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vainQUe", "vainQUes", "vainQUe", "vainQUions", "vainQUiez", "vainQUent"] {
      T.testConjugation(infinitif: "vaincre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vainQUisse", "vainQUisses", "vainQUît", "vainQUissions", "vainQUissiez", "vainQUissent"] {
      T.testConjugation(infinitif: "vaincre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "vaincre", tense: .participePassé, expected: "vaincu", extraLetters: nil)
    T.testConjugation(infinitif: "vaincre", tense: .participePrésent, expected: "vainQUant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vaincs", "vainQUons", "vainQUez"] {
      T.testConjugation(infinitif: "vaincre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testValoir() {
    // ID: 4-5A
    var personNumbersIndex = 0

    for conjugation in ["vaUX", "vaUX", "vaUt", "valons", "valez", "valent"] {
      T.testConjugation(infinitif: "valoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["valais", "valais", "valait", "valions", "valiez", "valaient"] {
      T.testConjugation(infinitif: "valoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vaUDrai", "vaUDras", "vaUDra", "vaUDrons", "vaUDrez", "vaUDront"] {
      T.testConjugation(infinitif: "valoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vaUDrais", "vaUDrais", "vaUDrait", "vaUDrions", "vaUDriez", "vaUDraient"] {
      T.testConjugation(infinitif: "valoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["valus", "valus", "valut", "valûmes", "valûtes", "valurent"] {
      T.testConjugation(infinitif: "valoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vaILlE", "vaILlES", "vaILlE", "valIONS", "valIEZ", "vaILlENT"] {
      T.testConjugation(infinitif: "valoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["valusse", "valusses", "valût", "valussions", "valussiez", "valussent"] {
      T.testConjugation(infinitif: "valoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "valoir", tense: .participePassé, expected: "valU", extraLetters: nil)
    T.testConjugation(infinitif: "valoir", tense: .participePrésent, expected: "valant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vaUX", "valons", "valez"] {
      T.testConjugation(infinitif: "valoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testVenir() {
    // ID: 6-7
    var personNumbersIndex = 0

    for conjugation in ["vIens", "vIens", "vIent", "venons", "venez", "vIeNnent"] {
      T.testConjugation(infinitif: "venir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["venais", "venais", "venait", "venions", "veniez", "venaient"] {
      T.testConjugation(infinitif: "venir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vIenDrai", "vIenDras", "vIenDra", "vIenDrons", "vIenDrez", "vIenDront"] {
      T.testConjugation(infinitif: "venir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vIenDrais", "vIenDrais", "vIenDrait", "vIenDrions", "vIenDriez", "vIenDraient"] {
      T.testConjugation(infinitif: "venir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vIns", "vIns", "vInt", "vÎnmes", "vÎntes", "vInrent"] {
      T.testConjugation(infinitif: "venir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vIeNnE", "vIeNnES", "vIeNnE", "venIONS", "venIEZ", "vIeNnENT"] {
      T.testConjugation(infinitif: "venir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vInsse", "vInsses", "vÎnt", "vInssions", "vInssiez", "vInssent"] {
      T.testConjugation(infinitif: "venir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "venir", tense: .participePassé, expected: "venU", extraLetters: nil)
    T.testConjugation(infinitif: "venir", tense: .participePrésent, expected: "venant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vIens", "venons", "venez"] {
      T.testConjugation(infinitif: "venir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testVêtir() {
    // ID: 6-6
    var personNumbersIndex = 0

    for conjugation in ["vêts", "vêts", "vêt", "vêtons", "vêtez", "vêtent"] {
      T.testConjugation(infinitif: "vêtir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vêtais", "vêtais", "vêtait", "vêtions", "vêtiez", "vêtaient"] {
      T.testConjugation(infinitif: "vêtir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vêtirai", "vêtiras", "vêtira", "vêtirons", "vêtirez", "vêtiront"] {
      T.testConjugation(infinitif: "vêtir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vêtirais", "vêtirais", "vêtirait", "vêtirions", "vêtiriez", "vêtiraient"] {
      T.testConjugation(infinitif: "vêtir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vêtis", "vêtis", "vêtit", "vêtîmes", "vêtîtes", "vêtirent"] {
      T.testConjugation(infinitif: "vêtir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vêtE", "vêtES", "vêtE", "vêtIONS", "vêtIEZ", "vêtENT"] {
      T.testConjugation(infinitif: "vêtir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vêtisse", "vêtisses", "vêtît", "vêtissions", "vêtissiez", "vêtissent"] {
      T.testConjugation(infinitif: "vêtir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "vêtir", tense: .participePassé, expected: "vêtU", extraLetters: nil)
    T.testConjugation(infinitif: "vêtir", tense: .participePrésent, expected: "vêtant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vêts", "vêtons", "vêtez"] {
      T.testConjugation(infinitif: "vêtir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testVivre() {
    // ID: 5-6
    var personNumbersIndex = 0

    for conjugation in ["vIs", "vIs", "vIt", "vivons", "vivez", "vivent"] {
      T.testConjugation(infinitif: "vivre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vivais", "vivais", "vivait", "vivions", "viviez", "vivaient"] {
      T.testConjugation(infinitif: "vivre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vivrai", "vivras", "vivra", "vivrons", "vivrez", "vivront"] {
      T.testConjugation(infinitif: "vivre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vivrais", "vivrais", "vivrait", "vivrions", "vivriez", "vivraient"] {
      T.testConjugation(infinitif: "vivre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vivis", "vivis", "vivit", "vivîmes", "vivîtes", "vivirent"] {
      T.testConjugation(infinitif: "vivre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vive", "vives", "vive", "vivions", "viviez", "vivent"] {
      T.testConjugation(infinitif: "vivre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vivisse", "vivisses", "vivît", "vivissions", "vivissiez", "vivissent"] {
      T.testConjugation(infinitif: "vivre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "vivre", tense: .participePassé, expected: "vÉCu", extraLetters: nil)
    T.testConjugation(infinitif: "vivre", tense: .participePrésent, expected: "vivant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vIs", "vivons", "vivez"] {
      T.testConjugation(infinitif: "vivre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testVoir() {
    // ID: 4-1A
    var personNumbersIndex = 0

    for conjugation in ["vOIs", "vOIs", "vOIt", "vOYons", "vOYez", "vOIent"] {
      T.testConjugation(infinitif: "voir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vOYais", "vOYais", "vOYait", "vOYions", "vOYiez", "vOYaient"] {
      T.testConjugation(infinitif: "voir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vERrai", "vERras", "vERra", "vERrons", "vERrez", "vERront"] {
      T.testConjugation(infinitif: "voir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vERrais", "vERrais", "vERrait", "vERrions", "vERriez", "vERraient"] {
      T.testConjugation(infinitif: "voir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vis", "vis", "vit", "vîmes", "vîtes", "virent"] {
      T.testConjugation(infinitif: "voir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vOIE", "vOIES", "vOIE", "vOYIONS", "vOYIEZ", "vOIENT"] {
      T.testConjugation(infinitif: "voir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["visse", "visses", "vît", "vissions", "vissiez", "vissent"] {
      T.testConjugation(infinitif: "voir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "voir", tense: .participePassé, expected: "vU", extraLetters: nil)
    T.testConjugation(infinitif: "voir", tense: .participePrésent, expected: "vOYant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vOIs", "vOYons", "vOYez"] {
      T.testConjugation(infinitif: "voir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testVouloir() {
    // ID: 4-8
    var personNumbersIndex = 0

    for conjugation in ["vEUX", "vEUX", "vEUt", "voulons", "voulez", "vEUlent"] {
      T.testConjugation(infinitif: "vouloir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["voulais", "voulais", "voulait", "voulions", "vouliez", "voulaient"] {
      T.testConjugation(infinitif: "vouloir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vouDrai", "vouDras", "vouDra", "vouDrons", "vouDrez", "vouDront"] {
      T.testConjugation(infinitif: "vouloir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vouDrais", "vouDrais", "vouDrait", "vouDrions", "vouDriez", "vouDraient"] {
      T.testConjugation(infinitif: "vouloir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["voulus", "voulus", "voulut", "voulûmes", "voulûtes", "voulurent"] {
      T.testConjugation(infinitif: "vouloir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vEUILlE", "vEUILlES", "vEUILlE", "voulIONS", "voulIEZ", "vEUILlENT"] {
      T.testConjugation(infinitif: "vouloir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["voulusse", "voulusses", "voulût", "voulussions", "voulussiez", "voulussent"] {
      T.testConjugation(infinitif: "vouloir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "vouloir", tense: .participePassé, expected: "voulU", extraLetters: nil)
    T.testConjugation(infinitif: "vouloir", tense: .participePrésent, expected: "voulant", extraLetters: nil)

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vEUX/vEUILLE", "voulons", "voulez/vEUILlez"] {
      T.testConjugation(infinitif: "vouloir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }
}
