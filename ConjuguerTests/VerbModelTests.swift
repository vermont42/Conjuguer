//
//  VerbModelTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 1/13/21.
//

@testable import Conjuguer
import XCTest

class GenerateVerbModelTests: XCTestCase {
  func testGenerateVerbModelTests() {
    T.generateVerbModelTests()
  }
}

class VerbModelTests: XCTestCase {
  func testAbsoudre() {
    // ID: 5-13A
    var personNumbersIndex = 0

    for conjugation in ["absoUs", "absoUs", "absoUt", "absoLVons", "absoLVez", "absoLVent"] {
      T.testConjugation(infinitif: "absoudre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoLVais", "absoLVais", "absoLVait", "absoLVions", "absoLViez", "absoLVaient"] {
      T.testConjugation(infinitif: "absoudre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoudrai", "absoudras", "absoudra", "absoudrons", "absoudrez", "absoudront"] {
      T.testConjugation(infinitif: "absoudre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoudrais", "absoudrais", "absoudrait", "absoudrions", "absoudriez", "absoudraient"] {
      T.testConjugation(infinitif: "absoudre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoLus", "absoLus", "absoLut", "absoLûmes", "absoLûtes", "absoLurent"] {
      T.testConjugation(infinitif: "absoudre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoLVe", "absoLVes", "absoLVe", "absoLVions", "absoLViez", "absoLVent"] {
      T.testConjugation(infinitif: "absoudre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["absoLusse", "absoLusses", "absoLût", "absoLussions", "absoLussiez", "absoLussent"] {
      T.testConjugation(infinitif: "absoudre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "absoudre", tense: .participePassé, expected: "absouS")
    T.testConjugation(infinitif: "absoudre", tense: .participePrésent, expected: "absoLVant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["absoUs", "absoLVons", "absoLVez"] {
      T.testConjugation(infinitif: "absoudre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAccroître() {
    // ID: 5-19B
    var personNumbersIndex = 0

    for conjugation in ["accroIs", "accroIs", "accroÎt", "accroISSons", "accroISSez", "accroISSent"] {
      T.testConjugation(infinitif: "accroître", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accroISSais", "accroISSais", "accroISSait", "accroISSions", "accroISSiez", "accroISSaient"] {
      T.testConjugation(infinitif: "accroître", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accroîtrai", "accroîtras", "accroîtra", "accroîtrons", "accroîtrez", "accroîtront"] {
      T.testConjugation(infinitif: "accroître", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accroîtrais", "accroîtrais", "accroîtrait", "accroîtrions", "accroîtriez", "accroîtraient"] {
      T.testConjugation(infinitif: "accroître", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accrUs", "accrUs", "accrUt", "accrÛmes", "accrÛtes", "accrUrent"] {
      T.testConjugation(infinitif: "accroître", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accroISSe", "accroISSes", "accroISSe", "accroISSions", "accroISSiez", "accroISSent"] {
      T.testConjugation(infinitif: "accroître", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["accrUsse", "accrUsses", "accrÛt", "accrUssions", "accrUssiez", "accrUssent"] {
      T.testConjugation(infinitif: "accroître", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "accroître", tense: .participePassé, expected: "accRU")
    T.testConjugation(infinitif: "accroître", tense: .participePrésent, expected: "accroISSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["accroIs", "accroISSons", "accroISSez"] {
      T.testConjugation(infinitif: "accroître", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAller() {
    // ID: 9
    var personNumbersIndex = 0

    for conjugation in ["VAIS", "VAs", "VA", "allons", "allez", "VOnt"] {
      T.testConjugation(infinitif: "aller", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["allais", "allais", "allait", "allions", "alliez", "allaient"] {
      T.testConjugation(infinitif: "aller", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["IRai", "IRas", "IRa", "IRons", "IRez", "IRont"] {
      T.testConjugation(infinitif: "aller", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["IRais", "IRais", "IRait", "IRions", "IRiez", "IRaient"] {
      T.testConjugation(infinitif: "aller", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["allai", "allas", "alla", "allâmes", "allâtes", "allèrent"] {
      T.testConjugation(infinitif: "aller", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aIlle", "aIlles", "aIlle", "aLlions", "aLliez", "aIllent"] {
      T.testConjugation(infinitif: "aller", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["allasse", "allasses", "allât", "allassions", "allassiez", "allassent"] {
      T.testConjugation(infinitif: "aller", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "aller", tense: .participePassé, expected: "allé")
    T.testConjugation(infinitif: "aller", tense: .participePrésent, expected: "allant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["VA", "allons", "allez"] {
      T.testConjugation(infinitif: "aller", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAppeler() {
    // ID: 1-3A
    var personNumbersIndex = 0

    for conjugation in ["appelLe", "appelLes", "appelLe", "appelons", "appelez", "appelLent"] {
      T.testConjugation(infinitif: "appeler", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appelais", "appelais", "appelait", "appelions", "appeliez", "appelaient"] {
      T.testConjugation(infinitif: "appeler", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appelLerai", "appelLeras", "appelLera", "appelLerons", "appelLerez", "appelLeront"] {
      T.testConjugation(infinitif: "appeler", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appelLerais", "appelLerais", "appelLerait", "appelLerions", "appelLeriez", "appelLeraient"] {
      T.testConjugation(infinitif: "appeler", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appelai", "appelas", "appela", "appelâmes", "appelâtes", "appelèrent"] {
      T.testConjugation(infinitif: "appeler", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appelLe", "appelLes", "appelLe", "appelions", "appeliez", "appelLent"] {
      T.testConjugation(infinitif: "appeler", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["appelasse", "appelasses", "appelât", "appelassions", "appelassiez", "appelassent"] {
      T.testConjugation(infinitif: "appeler", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "appeler", tense: .participePassé, expected: "appelé")
    T.testConjugation(infinitif: "appeler", tense: .participePrésent, expected: "appelant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["appelLe", "appelons", "appelez"] {
      T.testConjugation(infinitif: "appeler", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAssaillir() {
    // ID: 3-2A
    var personNumbersIndex = 0

    for conjugation in ["assaillE", "assaillES", "assaillE", "assaillONS", "assaillEZ", "assaillENT"] {
      T.testConjugation(infinitif: "assaillir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillais", "assaillais", "assaillait", "assaillions", "assailliez", "assaillaient"] {
      T.testConjugation(infinitif: "assaillir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillirai", "assailliras", "assaillira", "assaillirons", "assaillirez", "assailliront"] {
      T.testConjugation(infinitif: "assaillir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillirais", "assaillirais", "assaillirait", "assaillirions", "assailliriez", "assailliraient"] {
      T.testConjugation(infinitif: "assaillir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillis", "assaillis", "assaillit", "assaillîmes", "assaillîtes", "assaillirent"] {
      T.testConjugation(infinitif: "assaillir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaille", "assailles", "assaille", "assaillions", "assailliez", "assaillent"] {
      T.testConjugation(infinitif: "assaillir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assaillisse", "assaillisses", "assaillît", "assaillissions", "assaillissiez", "assaillissent"] {
      T.testConjugation(infinitif: "assaillir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "assaillir", tense: .participePassé, expected: "assailLi")
    T.testConjugation(infinitif: "assaillir", tense: .participePrésent, expected: "assaillant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["assaillE", "assaillOns", "assaillEz"] {
      T.testConjugation(infinitif: "assaillir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAsseoir() {
    // ID: 4-9AB
    var personNumbersIndex = 0

    for conjugation in ["assIEDs/assOIs", "assIEDs/assOIs", "assIED/assOIt", "asseYons/assOYons", "asseYez/assOYez", "asseYent/assOIent"] {
      T.testConjugation(infinitif: "asseoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["asseYais/assOYais", "asseYais/assOYais", "asseYait/assOYait", "asseYions/assOYions", "asseYiez/assOYiez", "asseYaient/assOYaient"] {
      T.testConjugation(infinitif: "asseoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assIÉrai/asSoirai", "assIÉras/asSoiras", "assIÉra/asSoira", "assIÉrons/asSoirons", "assIÉrez/asSoirez", "assIÉront/asSoiront"] {
      T.testConjugation(infinitif: "asseoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["assIÉrais/asSoirais", "assIÉrais/asSoirais", "assIÉrait/asSoirait", "assIÉrions/asSoirions", "assIÉriez/asSoiriez", "assIÉraient/asSoiraient"] {
      T.testConjugation(infinitif: "asseoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["asSis", "asSis", "asSit", "asSîmes", "asSîtes", "asSirent"] {
      T.testConjugation(infinitif: "asseoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["asseYe/assOIe", "asseYes/assOIes", "asseYe/assOIe", "asseYions/assOYions", "asseYiez/assOYiez", "asseYent/assOIent"] {
      T.testConjugation(infinitif: "asseoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["asSisse", "asSisses", "asSît", "asSissions", "asSissiez", "asSissent"] {
      T.testConjugation(infinitif: "asseoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "asseoir", tense: .participePassé, expected: "asSIS")
    T.testConjugation(infinitif: "asseoir", tense: .participePrésent, expected: "asseY/assOYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["assIEDs/assOIs", "asseYons/assOYons", "asseYez/assOYez"] {
      T.testConjugation(infinitif: "asseoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testAvoir() {
    // ID: 8
    var personNumbersIndex = 0

    for conjugation in ["aI", "As", "A", "avons", "avez", "Ont"] {
      T.testConjugation(infinitif: "avoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["avais", "avais", "avait", "avions", "aviez", "avaient"] {
      T.testConjugation(infinitif: "avoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aUrai", "aUras", "aUra", "aUrons", "aUrez", "aUront"] {
      T.testConjugation(infinitif: "avoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aUrais", "aUrais", "aUrait", "aUrions", "aUriez", "aUraient"] {
      T.testConjugation(infinitif: "avoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Eus", "Eus", "Eut", "Eûmes", "Eûtes", "Eurent"] {
      T.testConjugation(infinitif: "avoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aIe", "aIes", "aIT", "aYons", "aYez", "aIent"] {
      T.testConjugation(infinitif: "avoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Eusse", "Eusses", "Eût", "Eussions", "Eussiez", "Eussent"] {
      T.testConjugation(infinitif: "avoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "avoir", tense: .participePassé, expected: "EU")
    T.testConjugation(infinitif: "avoir", tense: .participePrésent, expected: "aYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["aIE", "aYons", "aYez"] {
      T.testConjugation(infinitif: "avoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testBattre() {
    // ID: 5-3
    var personNumbersIndex = 0

    for conjugation in ["baTs", "baTs", "baT", "battons", "battez", "battent"] {
      T.testConjugation(infinitif: "battre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["battais", "battais", "battait", "battions", "battiez", "battaient"] {
      T.testConjugation(infinitif: "battre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["battrai", "battras", "battra", "battrons", "battrez", "battront"] {
      T.testConjugation(infinitif: "battre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["battrais", "battrais", "battrait", "battrions", "battriez", "battraient"] {
      T.testConjugation(infinitif: "battre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["battis", "battis", "battit", "battîmes", "battîtes", "battirent"] {
      T.testConjugation(infinitif: "battre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["batte", "battes", "batte", "battions", "battiez", "battent"] {
      T.testConjugation(infinitif: "battre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["battisse", "battisses", "battît", "battissions", "battissiez", "battissent"] {
      T.testConjugation(infinitif: "battre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "battre", tense: .participePassé, expected: "battu")
    T.testConjugation(infinitif: "battre", tense: .participePrésent, expected: "battant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["baTs", "battons", "battez"] {
      T.testConjugation(infinitif: "battre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testBoire() {
    // ID: 5-17
    var personNumbersIndex = 0

    for conjugation in ["bois", "bois", "boit", "bUVons", "bUVez", "boiVent"] {
      T.testConjugation(infinitif: "boire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bUVais", "bUVais", "bUVait", "bUVions", "bUViez", "bUVaient"] {
      T.testConjugation(infinitif: "boire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["boirai", "boiras", "boira", "boirons", "boirez", "boiront"] {
      T.testConjugation(infinitif: "boire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["boirais", "boirais", "boirait", "boirions", "boiriez", "boiraient"] {
      T.testConjugation(infinitif: "boire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Bus", "Bus", "But", "Bûmes", "Bûtes", "Burent"] {
      T.testConjugation(infinitif: "boire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["boiVe", "boiVes", "boiVe", "bUVions", "bUViez", "boiVent"] {
      T.testConjugation(infinitif: "boire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Busse", "Busses", "Bût", "Bussions", "Bussiez", "Bussent"] {
      T.testConjugation(infinitif: "boire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "boire", tense: .participePassé, expected: "Bu")
    T.testConjugation(infinitif: "boire", tense: .participePrésent, expected: "bUVant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["bois", "bUVons", "bUVez"] {
      T.testConjugation(infinitif: "boire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testBouillir() {
    // ID: 3-2C
    var personNumbersIndex = 0

    for conjugation in ["bouS", "bouS", "bouT", "bouillONS", "bouillEZ", "bouillENT"] {
      T.testConjugation(infinitif: "bouillir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillais", "bouillais", "bouillait", "bouillions", "bouilliez", "bouillaient"] {
      T.testConjugation(infinitif: "bouillir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillirai", "bouilliras", "bouillira", "bouillirons", "bouillirez", "bouilliront"] {
      T.testConjugation(infinitif: "bouillir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillirais", "bouillirais", "bouillirait", "bouillirions", "bouilliriez", "bouilliraient"] {
      T.testConjugation(infinitif: "bouillir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillis", "bouillis", "bouillit", "bouillîmes", "bouillîtes", "bouillirent"] {
      T.testConjugation(infinitif: "bouillir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouille", "bouilles", "bouille", "bouillions", "bouilliez", "bouillent"] {
      T.testConjugation(infinitif: "bouillir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["bouillisse", "bouillisses", "bouillît", "bouillissions", "bouillissiez", "bouillissent"] {
      T.testConjugation(infinitif: "bouillir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "bouillir", tense: .participePassé, expected: "bouilLi")
    T.testConjugation(infinitif: "bouillir", tense: .participePrésent, expected: "bouillant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["bouillE", "bouillOns", "bouillEz"] {
      T.testConjugation(infinitif: "bouillir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCéder() {
    // ID: 1-5
    var personNumbersIndex = 0

    for conjugation in ["cÈde", "cÈdes", "cÈde", "cédons", "cédez", "cÈdent"] {
      T.testConjugation(infinitif: "céder", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cédais", "cédais", "cédait", "cédions", "cédiez", "cédaient"] {
      T.testConjugation(infinitif: "céder", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["céderai", "céderas", "cédera", "céderons", "céderez", "céderont"] {
      T.testConjugation(infinitif: "céder", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["céderais", "céderais", "céderait", "céderions", "céderiez", "céderaient"] {
      T.testConjugation(infinitif: "céder", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cédai", "cédas", "céda", "cédâmes", "cédâtes", "cédèrent"] {
      T.testConjugation(infinitif: "céder", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cÈde", "cÈdes", "cÈde", "cédions", "cédiez", "cÈdent"] {
      T.testConjugation(infinitif: "céder", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cédasse", "cédasses", "cédât", "cédassions", "cédassiez", "cédassent"] {
      T.testConjugation(infinitif: "céder", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "céder", tense: .participePassé, expected: "cédé")
    T.testConjugation(infinitif: "céder", tense: .participePrésent, expected: "cédant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["cÈde", "cédons", "cédez"] {
      T.testConjugation(infinitif: "céder", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCirconcire() {
    // ID: 5-8D
    var personNumbersIndex = 0

    for conjugation in ["circoncis", "circoncis", "circoncit", "circonciSons", "circonciSez", "circonciSent"] {
      T.testConjugation(infinitif: "circoncire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circonciSais", "circonciSais", "circonciSait", "circonciSions", "circonciSiez", "circonciSaient"] {
      T.testConjugation(infinitif: "circoncire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circoncirai", "circonciras", "circoncira", "circoncirons", "circoncirez", "circonciront"] {
      T.testConjugation(infinitif: "circoncire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circoncirais", "circoncirais", "circoncirait", "circoncirions", "circonciriez", "circonciraient"] {
      T.testConjugation(infinitif: "circoncire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circoncis", "circoncis", "circoncit", "circoncîmes", "circoncîtes", "circoncirent"] {
      T.testConjugation(infinitif: "circoncire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circonciSe", "circonciSes", "circonciSe", "circonciSions", "circonciSiez", "circonciSent"] {
      T.testConjugation(infinitif: "circoncire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["circoncisse", "circoncisses", "circoncît", "circoncissions", "circoncissiez", "circoncissent"] {
      T.testConjugation(infinitif: "circoncire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "circoncire", tense: .participePassé, expected: "circonciS")
    T.testConjugation(infinitif: "circoncire", tense: .participePrésent, expected: "circonciSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["circoncis", "circonciSons", "circonciSez"] {
      T.testConjugation(infinitif: "circoncire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testConduire() {
    // ID: 5-9A
    var personNumbersIndex = 0

    for conjugation in ["conduis", "conduis", "conduit", "conduiSons", "conduiSez", "conduiSent"] {
      T.testConjugation(infinitif: "conduire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduiSais", "conduiSais", "conduiSait", "conduiSions", "conduiSiez", "conduiSaient"] {
      T.testConjugation(infinitif: "conduire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduirai", "conduiras", "conduira", "conduirons", "conduirez", "conduiront"] {
      T.testConjugation(infinitif: "conduire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduirais", "conduirais", "conduirait", "conduirions", "conduiriez", "conduiraient"] {
      T.testConjugation(infinitif: "conduire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduiSis", "conduiSis", "conduiSit", "conduiSîmes", "conduiSîtes", "conduiSirent"] {
      T.testConjugation(infinitif: "conduire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduiSe", "conduiSes", "conduiSe", "conduiSions", "conduiSiez", "conduiSent"] {
      T.testConjugation(infinitif: "conduire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conduiSisse", "conduiSisses", "conduiSît", "conduiSissions", "conduiSissiez", "conduiSissent"] {
      T.testConjugation(infinitif: "conduire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "conduire", tense: .participePassé, expected: "conduiT")
    T.testConjugation(infinitif: "conduire", tense: .participePrésent, expected: "conduiSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["conduis", "conduiSons", "conduiSez"] {
      T.testConjugation(infinitif: "conduire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testConnaître() {
    // ID: 5-20
    var personNumbersIndex = 0

    for conjugation in ["connaIs", "connaIs", "connaÎt", "connaISSons", "connaISSez", "connaISSent"] {
      T.testConjugation(infinitif: "connaître", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["connaISSais", "connaISSais", "connaISSait", "connaISSions", "connaISSiez", "connaISSaient"] {
      T.testConjugation(infinitif: "connaître", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["connaîtrai", "connaîtras", "connaîtra", "connaîtrons", "connaîtrez", "connaîtront"] {
      T.testConjugation(infinitif: "connaître", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["connaîtrais", "connaîtrais", "connaîtrait", "connaîtrions", "connaîtriez", "connaîtraient"] {
      T.testConjugation(infinitif: "connaître", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conNus", "conNus", "conNut", "conNûmes", "conNûtes", "conNurent"] {
      T.testConjugation(infinitif: "connaître", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["connaISSe", "connaISSes", "connaISSe", "connaISSions", "connaISSiez", "connaISSent"] {
      T.testConjugation(infinitif: "connaître", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["conNusse", "conNusses", "conNût", "conNussions", "conNussiez", "conNussent"] {
      T.testConjugation(infinitif: "connaître", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "connaître", tense: .participePassé, expected: "conNu")
    T.testConjugation(infinitif: "connaître", tense: .participePrésent, expected: "connaISSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["connaIs", "connaISSons", "connaISSez"] {
      T.testConjugation(infinitif: "connaître", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCoudre() {
    // ID: 5-14
    var personNumbersIndex = 0

    for conjugation in ["couds", "couds", "couD", "couSons", "couSez", "couSent"] {
      T.testConjugation(infinitif: "coudre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couSais", "couSais", "couSait", "couSions", "couSiez", "couSaient"] {
      T.testConjugation(infinitif: "coudre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["coudrai", "coudras", "coudra", "coudrons", "coudrez", "coudront"] {
      T.testConjugation(infinitif: "coudre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["coudrais", "coudrais", "coudrait", "coudrions", "coudriez", "coudraient"] {
      T.testConjugation(infinitif: "coudre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couSis", "couSis", "couSit", "couSîmes", "couSîtes", "couSirent"] {
      T.testConjugation(infinitif: "coudre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couSe", "couSes", "couSe", "couSions", "couSiez", "couSent"] {
      T.testConjugation(infinitif: "coudre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couSisse", "couSisses", "couSît", "couSissions", "couSissiez", "couSissent"] {
      T.testConjugation(infinitif: "coudre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "coudre", tense: .participePassé, expected: "couSu")
    T.testConjugation(infinitif: "coudre", tense: .participePrésent, expected: "couSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["couds", "couSons", "couSez"] {
      T.testConjugation(infinitif: "coudre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCouvrir() {
    // ID: 3-1
    var personNumbersIndex = 0

    for conjugation in ["couvrE", "couvrES", "couvrE", "couvrONS", "couvrEZ", "couvrENT"] {
      T.testConjugation(infinitif: "couvrir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvrais", "couvrais", "couvrait", "couvrions", "couvriez", "couvraient"] {
      T.testConjugation(infinitif: "couvrir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvrirai", "couvriras", "couvrira", "couvrirons", "couvrirez", "couvriront"] {
      T.testConjugation(infinitif: "couvrir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvrirais", "couvrirais", "couvrirait", "couvririons", "couvririez", "couvriraient"] {
      T.testConjugation(infinitif: "couvrir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvris", "couvris", "couvrit", "couvrîmes", "couvrîtes", "couvrirent"] {
      T.testConjugation(infinitif: "couvrir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvre", "couvres", "couvre", "couvrions", "couvriez", "couvrent"] {
      T.testConjugation(infinitif: "couvrir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["couvrisse", "couvrisses", "couvrît", "couvrissions", "couvrissiez", "couvrissent"] {
      T.testConjugation(infinitif: "couvrir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "couvrir", tense: .participePassé, expected: "couverT")
    T.testConjugation(infinitif: "couvrir", tense: .participePrésent, expected: "couvrant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["couvrE", "couvrOns", "couvrEz"] {
      T.testConjugation(infinitif: "couvrir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCroire() {
    // ID: 5-18
    var personNumbersIndex = 0

    for conjugation in ["crois", "crois", "croit", "croYons", "croYez", "croient"] {
      T.testConjugation(infinitif: "croire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croYais", "croYais", "croYait", "croYions", "croYiez", "croYaient"] {
      T.testConjugation(infinitif: "croire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croirai", "croiras", "croira", "croirons", "croirez", "croiront"] {
      T.testConjugation(infinitif: "croire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croirais", "croirais", "croirait", "croirions", "croiriez", "croiraient"] {
      T.testConjugation(infinitif: "croire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cRus", "cRus", "cRut", "cRûmes", "cRûtes", "cRurent"] {
      T.testConjugation(infinitif: "croire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croie", "croies", "croie", "croYions", "croYiez", "croient"] {
      T.testConjugation(infinitif: "croire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cRusse", "cRusses", "cRût", "cRussions", "cRussiez", "cRussent"] {
      T.testConjugation(infinitif: "croire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "croire", tense: .participePassé, expected: "cRu")
    T.testConjugation(infinitif: "croire", tense: .participePrésent, expected: "croYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["crois", "croYons", "croYez"] {
      T.testConjugation(infinitif: "croire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCroître() {
    // ID: 5-19A
    var personNumbersIndex = 0

    for conjugation in ["croÎs", "croÎs", "croÎt", "croISSons", "croISSez", "croISSent"] {
      T.testConjugation(infinitif: "croître", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croISSais", "croISSais", "croISSait", "croISSions", "croISSiez", "croISSaient"] {
      T.testConjugation(infinitif: "croître", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croîtrai", "croîtras", "croîtra", "croîtrons", "croîtrez", "croîtront"] {
      T.testConjugation(infinitif: "croître", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croîtrais", "croîtrais", "croîtrait", "croîtrions", "croîtriez", "croîtraient"] {
      T.testConjugation(infinitif: "croître", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["crÛs", "crÛs", "crÛt", "crÛmes", "crÛtes", "crÛrent"] {
      T.testConjugation(infinitif: "croître", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["croISSe", "croISSes", "croISSe", "croISSions", "croISSiez", "croISSent"] {
      T.testConjugation(infinitif: "croître", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["crÛsse", "crÛsses", "crÛt", "crÛssions", "crÛssiez", "crÛssent"] {
      T.testConjugation(infinitif: "croître", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "croître", tense: .participePassé, expected: "cRÛ")
    T.testConjugation(infinitif: "croître", tense: .participePrésent, expected: "croISSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["croÎs", "croISSons", "croISSez"] {
      T.testConjugation(infinitif: "croître", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testCueillir() {
    // ID: 3-2B
    var personNumbersIndex = 0

    for conjugation in ["cueillE", "cueillES", "cueillE", "cueillONS", "cueillEZ", "cueillENT"] {
      T.testConjugation(infinitif: "cueillir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillais", "cueillais", "cueillait", "cueillions", "cueilliez", "cueillaient"] {
      T.testConjugation(infinitif: "cueillir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillErai", "cueillEras", "cueillEra", "cueillErons", "cueillErez", "cueillEront"] {
      T.testConjugation(infinitif: "cueillir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillErais", "cueillErais", "cueillErait", "cueillErions", "cueillEriez", "cueillEraient"] {
      T.testConjugation(infinitif: "cueillir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillis", "cueillis", "cueillit", "cueillîmes", "cueillîtes", "cueillirent"] {
      T.testConjugation(infinitif: "cueillir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueille", "cueilles", "cueille", "cueillions", "cueilliez", "cueillent"] {
      T.testConjugation(infinitif: "cueillir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["cueillisse", "cueillisses", "cueillît", "cueillissions", "cueillissiez", "cueillissent"] {
      T.testConjugation(infinitif: "cueillir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "cueillir", tense: .participePassé, expected: "cueilLi")
    T.testConjugation(infinitif: "cueillir", tense: .participePrésent, expected: "cueillant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["cueillE", "cueillOns", "cueillEz"] {
      T.testConjugation(infinitif: "cueillir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testDevoir() {
    // ID: 4-2A
    var personNumbersIndex = 0

    for conjugation in ["dOIs", "dOIs", "dOIt", "devons", "devez", "dOIvent"] {
      T.testConjugation(infinitif: "devoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["devais", "devais", "devait", "devions", "deviez", "devaient"] {
      T.testConjugation(infinitif: "devoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["devRai", "devRas", "devRa", "devRons", "devRez", "devRont"] {
      T.testConjugation(infinitif: "devoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["devRais", "devRais", "devRait", "devRions", "devRiez", "devRaient"] {
      T.testConjugation(infinitif: "devoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Dus", "Dus", "Dut", "Dûmes", "Dûtes", "Durent"] {
      T.testConjugation(infinitif: "devoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dOIve", "dOIves", "dOIve", "devions", "deviez", "dOIvent"] {
      T.testConjugation(infinitif: "devoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Dusse", "Dusses", "Dût", "Dussions", "Dussiez", "Dussent"] {
      T.testConjugation(infinitif: "devoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "devoir", tense: .participePassé, expected: "DÛ")
    T.testConjugation(infinitif: "devoir", tense: .participePrésent, expected: "devant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["dOIs", "devons", "devez"] {
      T.testConjugation(infinitif: "devoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testDépecer() {
    // ID: 1-6A
    var personNumbersIndex = 0

    for conjugation in ["dépÈce", "dépÈces", "dépÈce", "dépeÇons", "dépecez", "dépÈcent"] {
      T.testConjugation(infinitif: "dépecer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépeÇais", "dépeÇais", "dépeÇait", "dépeCions", "dépeCiez", "dépeÇaient"] {
      T.testConjugation(infinitif: "dépecer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépÈcerai", "dépÈceras", "dépÈcera", "dépÈcerons", "dépÈcerez", "dépÈceront"] {
      T.testConjugation(infinitif: "dépecer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépÈcerais", "dépÈcerais", "dépÈcerait", "dépÈcerions", "dépÈceriez", "dépÈceraient"] {
      T.testConjugation(infinitif: "dépecer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépeÇai", "dépeÇas", "dépeÇa", "dépeÇâmes", "dépeÇâtes", "dépecèrent"] {
      T.testConjugation(infinitif: "dépecer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépÈce", "dépÈces", "dépÈce", "dépeCions", "dépeCiez", "dépÈcent"] {
      T.testConjugation(infinitif: "dépecer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dépeÇasse", "dépeÇasses", "dépeÇât", "dépeÇassions", "dépeÇassiez", "dépeÇassent"] {
      T.testConjugation(infinitif: "dépecer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "dépecer", tense: .participePassé, expected: "dépecé")
    T.testConjugation(infinitif: "dépecer", tense: .participePrésent, expected: "dépeÇant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["dépÈce", "dépeÇons", "dépecez"] {
      T.testConjugation(infinitif: "dépecer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testDire() {
    // ID: 5-8A
    var personNumbersIndex = 0

    for conjugation in ["dis", "dis", "dit", "diSons", "dÎTES", "diSent"] {
      T.testConjugation(infinitif: "dire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["diSais", "diSais", "diSait", "diSions", "diSiez", "diSaient"] {
      T.testConjugation(infinitif: "dire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dirai", "diras", "dira", "dirons", "direz", "diront"] {
      T.testConjugation(infinitif: "dire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dirais", "dirais", "dirait", "dirions", "diriez", "diraient"] {
      T.testConjugation(infinitif: "dire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dis", "dis", "dit", "dîmes", "dîtes", "dirent"] {
      T.testConjugation(infinitif: "dire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["diSe", "diSes", "diSe", "diSions", "diSiez", "diSent"] {
      T.testConjugation(infinitif: "dire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["disse", "disses", "dît", "dissions", "dissiez", "dissent"] {
      T.testConjugation(infinitif: "dire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "dire", tense: .participePassé, expected: "diT")
    T.testConjugation(infinitif: "dire", tense: .participePrésent, expected: "diSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["dis", "diSons", "dÎTES"] {
      T.testConjugation(infinitif: "dire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testEmployer() {
    // ID: 1-7A
    var personNumbersIndex = 0

    for conjugation in ["emploIe", "emploIes", "emploIe", "employons", "employez", "emploIent"] {
      T.testConjugation(infinitif: "employer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["employais", "employais", "employait", "employions", "employiez", "employaient"] {
      T.testConjugation(infinitif: "employer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["emploIerai", "emploIeras", "emploIera", "emploIerons", "emploIerez", "emploIeront"] {
      T.testConjugation(infinitif: "employer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["emploIerais", "emploIerais", "emploIerait", "emploIerions", "emploIeriez", "emploIeraient"] {
      T.testConjugation(infinitif: "employer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["employai", "employas", "employa", "employâmes", "employâtes", "employèrent"] {
      T.testConjugation(infinitif: "employer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["emploIe", "emploIes", "emploIe", "employions", "employiez", "emploIent"] {
      T.testConjugation(infinitif: "employer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["employasse", "employasses", "employât", "employassions", "employassiez", "employassent"] {
      T.testConjugation(infinitif: "employer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "employer", tense: .participePassé, expected: "employé")
    T.testConjugation(infinitif: "employer", tense: .participePrésent, expected: "employant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["emploIe", "employons", "employez"] {
      T.testConjugation(infinitif: "employer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testEnvoyer() {
    // ID: 1-8
    var personNumbersIndex = 0

    for conjugation in ["envoIe", "envoIes", "envoIe", "envoyons", "envoyez", "envoIent"] {
      T.testConjugation(infinitif: "envoyer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envoyais", "envoyais", "envoyait", "envoyions", "envoyiez", "envoyaient"] {
      T.testConjugation(infinitif: "envoyer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envERrai", "envERras", "envERra", "envERrons", "envERrez", "envERront"] {
      T.testConjugation(infinitif: "envoyer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envERrais", "envERrais", "envERrait", "envERrions", "envERriez", "envERraient"] {
      T.testConjugation(infinitif: "envoyer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envoyai", "envoyas", "envoya", "envoyâmes", "envoyâtes", "envoyèrent"] {
      T.testConjugation(infinitif: "envoyer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envoIe", "envoIes", "envoIe", "envoyions", "envoyiez", "envoIent"] {
      T.testConjugation(infinitif: "envoyer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["envoyasse", "envoyasses", "envoyât", "envoyassions", "envoyassiez", "envoyassent"] {
      T.testConjugation(infinitif: "envoyer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "envoyer", tense: .participePassé, expected: "envoyé")
    T.testConjugation(infinitif: "envoyer", tense: .participePrésent, expected: "envoyant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["envoIe", "envoyons", "envoyez"] {
      T.testConjugation(infinitif: "envoyer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testExclure() {
    // ID: 5-16A
    var personNumbersIndex = 0

    for conjugation in ["exclus", "exclus", "exclut", "excluons", "excluez", "excluent"] {
      T.testConjugation(infinitif: "exclure", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["excluais", "excluais", "excluait", "excluions", "excluiez", "excluaient"] {
      T.testConjugation(infinitif: "exclure", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["exclurai", "excluras", "exclura", "exclurons", "exclurez", "excluront"] {
      T.testConjugation(infinitif: "exclure", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["exclurais", "exclurais", "exclurait", "exclurions", "excluriez", "excluraient"] {
      T.testConjugation(infinitif: "exclure", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["exclus", "exclus", "exclut", "exclûmes", "exclûtes", "exclurent"] {
      T.testConjugation(infinitif: "exclure", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["exclue", "exclues", "exclue", "excluions", "excluiez", "excluent"] {
      T.testConjugation(infinitif: "exclure", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["exclusse", "exclusses", "exclût", "exclussions", "exclussiez", "exclussent"] {
      T.testConjugation(infinitif: "exclure", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "exclure", tense: .participePassé, expected: "exclU")
    T.testConjugation(infinitif: "exclure", tense: .participePrésent, expected: "excluant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["exclus", "excluons", "excluez"] {
      T.testConjugation(infinitif: "exclure", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testÉcrire() {
    // ID: 5-7
    var personNumbersIndex = 0

    for conjugation in ["écris", "écris", "écrit", "écriVons", "écriVez", "écriVent"] {
      T.testConjugation(infinitif: "écrire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écriVais", "écriVais", "écriVait", "écriVions", "écriViez", "écriVaient"] {
      T.testConjugation(infinitif: "écrire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écrirai", "écriras", "écrira", "écrirons", "écrirez", "écriront"] {
      T.testConjugation(infinitif: "écrire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écrirais", "écrirais", "écrirait", "écririons", "écririez", "écriraient"] {
      T.testConjugation(infinitif: "écrire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écriVis", "écriVis", "écriVit", "écriVîmes", "écriVîtes", "écriVirent"] {
      T.testConjugation(infinitif: "écrire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écriVe", "écriVes", "écriVe", "écriVions", "écriViez", "écriVent"] {
      T.testConjugation(infinitif: "écrire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["écriVisse", "écriVisses", "écriVît", "écriVissions", "écriVissiez", "écriVissent"] {
      T.testConjugation(infinitif: "écrire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "écrire", tense: .participePassé, expected: "écriT")
    T.testConjugation(infinitif: "écrire", tense: .participePrésent, expected: "écriVant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["écris", "écriVons", "écriVez"] {
      T.testConjugation(infinitif: "écrire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testÊtre() {
    // ID: 7
    var personNumbersIndex = 0

    for conjugation in ["SUIS", "Es", "EST", "SOMMEs", "êteS", "SOnt"] {
      T.testConjugation(infinitif: "être", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Étais", "Étais", "Était", "Étions", "Étiez", "Étaient"] {
      T.testConjugation(infinitif: "être", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SErai", "SEras", "SEra", "SErons", "SErez", "SEront"] {
      T.testConjugation(infinitif: "être", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SErais", "SErais", "SErait", "SErions", "SEriez", "SEraient"] {
      T.testConjugation(infinitif: "être", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["FUs", "FUs", "FUt", "FÛmes", "FÛtes", "FUrent"] {
      T.testConjugation(infinitif: "être", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SOIS", "SOIs", "SOIT", "SOYons", "SOYez", "SOIent"] {
      T.testConjugation(infinitif: "être", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["FUsse", "FUsses", "FÛt", "FUssions", "FUssiez", "FUssent"] {
      T.testConjugation(infinitif: "être", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "être", tense: .participePassé, expected: "ÉtÉ")
    T.testConjugation(infinitif: "être", tense: .participePrésent, expected: "Étant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["SOIs", "SOYons", "SOYez"] {
      T.testConjugation(infinitif: "être", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFalloir() {
    // ID: 4-5C
    var personNumbersIndex = 0

    for conjugation in ["faUX", "faUX", "faUt", "fallons", "fallez", "fallent"] {
      T.testConjugation(infinitif: "falloir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fallais", "fallais", "fallait", "fallions", "falliez", "fallaient"] {
      T.testConjugation(infinitif: "falloir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faUDrai", "faUDras", "faUDra", "faUDrons", "faUDrez", "faUDront"] {
      T.testConjugation(infinitif: "falloir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faUDrais", "faUDrais", "faUDrait", "faUDrions", "faUDriez", "faUDraient"] {
      T.testConjugation(infinitif: "falloir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fallus", "fallus", "fallut", "fallûmes", "fallûtes", "fallurent"] {
      T.testConjugation(infinitif: "falloir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["faILle", "faILles", "faILle", "fallions", "falliez", "faILlent"] {
      T.testConjugation(infinitif: "falloir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["fallusse", "fallusses", "fallût", "fallussions", "fallussiez", "fallussent"] {
      T.testConjugation(infinitif: "falloir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "falloir", tense: .participePassé, expected: "fallU")
    T.testConjugation(infinitif: "falloir", tense: .participePrésent, expected: "fallant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["faUX", "fallons", "fallez"] {
      T.testConjugation(infinitif: "falloir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testFinir() {
    // ID: 2-1
    var personNumbersIndex = 0

    for conjugation in ["finis", "finis", "finit", "finissons", "finissez", "finissent"] {
      T.testConjugation(infinitif: "finir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finissais", "finissais", "finissait", "finissions", "finissiez", "finissaient"] {
      T.testConjugation(infinitif: "finir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finirai", "finiras", "finira", "finirons", "finirez", "finiront"] {
      T.testConjugation(infinitif: "finir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finirais", "finirais", "finirait", "finirions", "finiriez", "finiraient"] {
      T.testConjugation(infinitif: "finir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finis", "finis", "finit", "finîmes", "finîtes", "finirent"] {
      T.testConjugation(infinitif: "finir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finisse", "finisses", "finisse", "finissions", "finissiez", "finissent"] {
      T.testConjugation(infinitif: "finir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["finisse", "finisses", "finît", "finissions", "finissiez", "finissent"] {
      T.testConjugation(infinitif: "finir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "finir", tense: .participePassé, expected: "fini")
    T.testConjugation(infinitif: "finir", tense: .participePrésent, expected: "finissant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["finis", "finissons", "finissez"] {
      T.testConjugation(infinitif: "finir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testHaïr() {
    // ID: 2-3
    var personNumbersIndex = 0

    for conjugation in ["haIs", "haIs", "haIt", "haïssons", "haïssez", "haïssent"] {
      T.testConjugation(infinitif: "haïr", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïssais", "haïssais", "haïssait", "haïssions", "haïssiez", "haïssaient"] {
      T.testConjugation(infinitif: "haïr", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïrai", "haïras", "haïra", "haïrons", "haïrez", "haïront"] {
      T.testConjugation(infinitif: "haïr", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïrais", "haïrais", "haïrait", "haïrions", "haïriez", "haïraient"] {
      T.testConjugation(infinitif: "haïr", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïs", "haïs", "haït", "haÏmes", "haÏtes", "haïrent"] {
      T.testConjugation(infinitif: "haïr", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïsse", "haïsses", "haïsse", "haïssions", "haïssiez", "haïssent"] {
      T.testConjugation(infinitif: "haïr", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["haïsse", "haïsses", "haÏt", "haïssions", "haïssiez", "haïssent"] {
      T.testConjugation(infinitif: "haïr", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "haïr", tense: .participePassé, expected: "haï")
    T.testConjugation(infinitif: "haïr", tense: .participePrésent, expected: "haïssant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["haIs", "haïssons", "haïssez"] {
      T.testConjugation(infinitif: "haïr", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testInclure() {
    // ID: 5-16B
    var personNumbersIndex = 0

    for conjugation in ["inclus", "inclus", "inclut", "incluons", "incluez", "incluent"] {
      T.testConjugation(infinitif: "inclure", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["incluais", "incluais", "incluait", "incluions", "incluiez", "incluaient"] {
      T.testConjugation(infinitif: "inclure", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["inclurai", "incluras", "inclura", "inclurons", "inclurez", "incluront"] {
      T.testConjugation(infinitif: "inclure", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["inclurais", "inclurais", "inclurait", "inclurions", "incluriez", "incluraient"] {
      T.testConjugation(infinitif: "inclure", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["inclus", "inclus", "inclut", "inclûmes", "inclûtes", "inclurent"] {
      T.testConjugation(infinitif: "inclure", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["inclue", "inclues", "inclue", "incluions", "incluiez", "incluent"] {
      T.testConjugation(infinitif: "inclure", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["inclusse", "inclusses", "inclût", "inclussions", "inclussiez", "inclussent"] {
      T.testConjugation(infinitif: "inclure", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "inclure", tense: .participePassé, expected: "incluS")
    T.testConjugation(infinitif: "inclure", tense: .participePrésent, expected: "incluant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["inclus", "incluons", "incluez"] {
      T.testConjugation(infinitif: "inclure", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testJeter() {
    // ID: 1-3B
    var personNumbersIndex = 0

    for conjugation in ["jetTe", "jetTes", "jetTe", "jetons", "jetez", "jetTent"] {
      T.testConjugation(infinitif: "jeter", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetais", "jetais", "jetait", "jetions", "jetiez", "jetaient"] {
      T.testConjugation(infinitif: "jeter", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetTerai", "jetTeras", "jetTera", "jetTerons", "jetTerez", "jetTeront"] {
      T.testConjugation(infinitif: "jeter", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetTerais", "jetTerais", "jetTerait", "jetTerions", "jetTeriez", "jetTeraient"] {
      T.testConjugation(infinitif: "jeter", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetai", "jetas", "jeta", "jetâmes", "jetâtes", "jetèrent"] {
      T.testConjugation(infinitif: "jeter", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetTe", "jetTes", "jetTe", "jetions", "jetiez", "jetTent"] {
      T.testConjugation(infinitif: "jeter", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["jetasse", "jetasses", "jetât", "jetassions", "jetassiez", "jetassent"] {
      T.testConjugation(infinitif: "jeter", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "jeter", tense: .participePassé, expected: "jeté")
    T.testConjugation(infinitif: "jeter", tense: .participePrésent, expected: "jetant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["jetTe", "jetons", "jetez"] {
      T.testConjugation(infinitif: "jeter", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testLancer() {
    // ID: 1-2A
    var personNumbersIndex = 0

    for conjugation in ["lance", "lances", "lance", "lanÇons", "lancez", "lancent"] {
      T.testConjugation(infinitif: "lancer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lanÇais", "lanÇais", "lanÇait", "lanCions", "lanCiez", "lanÇaient"] {
      T.testConjugation(infinitif: "lancer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lancerai", "lanceras", "lancera", "lancerons", "lancerez", "lanceront"] {
      T.testConjugation(infinitif: "lancer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lancerais", "lancerais", "lancerait", "lancerions", "lanceriez", "lanceraient"] {
      T.testConjugation(infinitif: "lancer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lanÇai", "lanÇas", "lanÇa", "lanÇâmes", "lanÇâtes", "lancèrent"] {
      T.testConjugation(infinitif: "lancer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lance", "lances", "lance", "lanCions", "lanCiez", "lancent"] {
      T.testConjugation(infinitif: "lancer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lanÇasse", "lanÇasses", "lanÇât", "lanÇassions", "lanÇassiez", "lanÇassent"] {
      T.testConjugation(infinitif: "lancer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "lancer", tense: .participePassé, expected: "lancé")
    T.testConjugation(infinitif: "lancer", tense: .participePrésent, expected: "lanÇant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["lance", "lanÇons", "lancez"] {
      T.testConjugation(infinitif: "lancer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testLire() {
    // ID: 5-10
    var personNumbersIndex = 0

    for conjugation in ["lis", "lis", "lit", "liSons", "liSez", "liSent"] {
      T.testConjugation(infinitif: "lire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["liSais", "liSais", "liSait", "liSions", "liSiez", "liSaient"] {
      T.testConjugation(infinitif: "lire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lirai", "liras", "lira", "lirons", "lirez", "liront"] {
      T.testConjugation(infinitif: "lire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["lirais", "lirais", "lirait", "lirions", "liriez", "liraient"] {
      T.testConjugation(infinitif: "lire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Lus", "Lus", "Lut", "Lûmes", "Lûtes", "Lurent"] {
      T.testConjugation(infinitif: "lire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["liSe", "liSes", "liSe", "liSions", "liSiez", "liSent"] {
      T.testConjugation(infinitif: "lire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Lusse", "Lusses", "Lût", "Lussions", "Lussiez", "Lussent"] {
      T.testConjugation(infinitif: "lire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "lire", tense: .participePassé, expected: "Lu")
    T.testConjugation(infinitif: "lire", tense: .participePrésent, expected: "liSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["lis", "liSons", "liSez"] {
      T.testConjugation(infinitif: "lire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testManger() {
    // ID: 1-2B
    var personNumbersIndex = 0

    for conjugation in ["mange", "manges", "mange", "mangEons", "mangez", "mangent"] {
      T.testConjugation(infinitif: "manger", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mangEais", "mangEais", "mangEait", "mangions", "mangiez", "mangEaient"] {
      T.testConjugation(infinitif: "manger", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mangerai", "mangeras", "mangera", "mangerons", "mangerez", "mangeront"] {
      T.testConjugation(infinitif: "manger", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mangerais", "mangerais", "mangerait", "mangerions", "mangeriez", "mangeraient"] {
      T.testConjugation(infinitif: "manger", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mangEai", "mangEas", "mangEa", "mangEâmes", "mangEâtes", "mangèrent"] {
      T.testConjugation(infinitif: "manger", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mange", "manges", "mange", "mangions", "mangiez", "mangent"] {
      T.testConjugation(infinitif: "manger", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mangEasse", "mangEasses", "mangEât", "mangEassions", "mangEassiez", "mangEassent"] {
      T.testConjugation(infinitif: "manger", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "manger", tense: .participePassé, expected: "mangé")
    T.testConjugation(infinitif: "manger", tense: .participePrésent, expected: "mangEant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["mange", "mangEons", "mangez"] {
      T.testConjugation(infinitif: "manger", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testMaudire() {
    // ID: 2-2
    var personNumbersIndex = 0

    for conjugation in ["maudIs", "maudIs", "maudIt", "maudISSons", "maudISSez", "maudISSent"] {
      T.testConjugation(infinitif: "maudire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudISSais", "maudISSais", "maudISSait", "maudISSions", "maudISSiez", "maudISSaient"] {
      T.testConjugation(infinitif: "maudire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudirai", "maudiras", "maudira", "maudirons", "maudirez", "maudiront"] {
      T.testConjugation(infinitif: "maudire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudirais", "maudirais", "maudirait", "maudirions", "maudiriez", "maudiraient"] {
      T.testConjugation(infinitif: "maudire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudis", "maudis", "maudit", "maudîmes", "maudîtes", "maudirent"] {
      T.testConjugation(infinitif: "maudire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudISSe", "maudISSes", "maudISSe", "maudISSions", "maudISSiez", "maudISSent"] {
      T.testConjugation(infinitif: "maudire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["maudisse", "maudisses", "maudît", "maudissions", "maudissiez", "maudissent"] {
      T.testConjugation(infinitif: "maudire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "maudire", tense: .participePassé, expected: "maudiT")
    T.testConjugation(infinitif: "maudire", tense: .participePrésent, expected: "maudISSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["maudIs", "maudISSons", "maudISSez"] {
      T.testConjugation(infinitif: "maudire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testMettre() {
    // ID: 5-4
    var personNumbersIndex = 0

    for conjugation in ["meTs", "meTs", "meT", "mettons", "mettez", "mettent"] {
      T.testConjugation(infinitif: "mettre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mettais", "mettais", "mettait", "mettions", "mettiez", "mettaient"] {
      T.testConjugation(infinitif: "mettre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mettrai", "mettras", "mettra", "mettrons", "mettrez", "mettront"] {
      T.testConjugation(infinitif: "mettre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mettrais", "mettrais", "mettrait", "mettrions", "mettriez", "mettraient"] {
      T.testConjugation(infinitif: "mettre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mis", "mis", "mit", "mîmes", "mîtes", "mirent"] {
      T.testConjugation(infinitif: "mettre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mette", "mettes", "mette", "mettions", "mettiez", "mettent"] {
      T.testConjugation(infinitif: "mettre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["misse", "misses", "mît", "missions", "missiez", "missent"] {
      T.testConjugation(infinitif: "mettre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "mettre", tense: .participePassé, expected: "mIS")
    T.testConjugation(infinitif: "mettre", tense: .participePrésent, expected: "mettant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["meTs", "mettons", "mettez"] {
      T.testConjugation(infinitif: "mettre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testMoudre() {
    // ID: 5-15
    var personNumbersIndex = 0

    for conjugation in ["mouds", "mouds", "mouD", "mouLons", "mouLez", "mouLent"] {
      T.testConjugation(infinitif: "moudre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouLais", "mouLais", "mouLait", "mouLions", "mouLiez", "mouLaient"] {
      T.testConjugation(infinitif: "moudre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["moudrai", "moudras", "moudra", "moudrons", "moudrez", "moudront"] {
      T.testConjugation(infinitif: "moudre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["moudrais", "moudrais", "moudrait", "moudrions", "moudriez", "moudraient"] {
      T.testConjugation(infinitif: "moudre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouLus", "mouLus", "mouLut", "mouLûmes", "mouLûtes", "mouLurent"] {
      T.testConjugation(infinitif: "moudre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouLe", "mouLes", "mouLe", "mouLions", "mouLiez", "mouLent"] {
      T.testConjugation(infinitif: "moudre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouLusse", "mouLusses", "mouLût", "mouLussions", "mouLussiez", "mouLussent"] {
      T.testConjugation(infinitif: "moudre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "moudre", tense: .participePassé, expected: "mouLu")
    T.testConjugation(infinitif: "moudre", tense: .participePrésent, expected: "mouLant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["mouds", "mouLons", "mouLez"] {
      T.testConjugation(infinitif: "moudre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testMouvoir() {
    // ID: 4-3A
    var personNumbersIndex = 0

    for conjugation in ["mEUs", "mEUs", "mEUt", "mouvons", "mouvez", "mEuvent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouvais", "mouvais", "mouvait", "mouvions", "mouviez", "mouvaient"] {
      T.testConjugation(infinitif: "mouvoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouvRai", "mouvRas", "mouvRa", "mouvRons", "mouvRez", "mouvRont"] {
      T.testConjugation(infinitif: "mouvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouvRais", "mouvRais", "mouvRait", "mouvRions", "mouvRiez", "mouvRaient"] {
      T.testConjugation(infinitif: "mouvoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Mus", "Mus", "Mut", "Mûmes", "Mûtes", "Murent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mEuve", "mEuves", "mEuve", "mouvions", "mouviez", "mEuvent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Musse", "Musses", "Mût", "Mussions", "Mussiez", "Mussent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "mouvoir", tense: .participePassé, expected: "MÛ")
    T.testConjugation(infinitif: "mouvoir", tense: .participePrésent, expected: "mouvant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["mEUs", "mouvons", "mouvez"] {
      T.testConjugation(infinitif: "mouvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testNaître() {
    // ID: 5-21
    var personNumbersIndex = 0

    for conjugation in ["naIs", "naIs", "naÎt", "naISSons", "naISSez", "naISSent"] {
      T.testConjugation(infinitif: "naître", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naISSais", "naISSais", "naISSait", "naISSions", "naISSiez", "naISSaient"] {
      T.testConjugation(infinitif: "naître", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naîtrai", "naîtras", "naîtra", "naîtrons", "naîtrez", "naîtront"] {
      T.testConjugation(infinitif: "naître", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naîtrais", "naîtrais", "naîtrait", "naîtrions", "naîtriez", "naîtraient"] {
      T.testConjugation(infinitif: "naître", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naQUis", "naQUis", "naQUit", "naQUîmes", "naQUîtes", "naQUirent"] {
      T.testConjugation(infinitif: "naître", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naISSe", "naISSes", "naISSe", "naISSions", "naISSiez", "naISSent"] {
      T.testConjugation(infinitif: "naître", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["naQUisse", "naQUisses", "naQUît", "naQUissions", "naQUissiez", "naQUissent"] {
      T.testConjugation(infinitif: "naître", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "naître", tense: .participePassé, expected: "NÉ")
    T.testConjugation(infinitif: "naître", tense: .participePrésent, expected: "naISSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["naIs", "naISSons", "naISSez"] {
      T.testConjugation(infinitif: "naître", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testNuire() {
    // ID: 5-9B
    var personNumbersIndex = 0

    for conjugation in ["nuis", "nuis", "nuit", "nuiSons", "nuiSez", "nuiSent"] {
      T.testConjugation(infinitif: "nuire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuiSais", "nuiSais", "nuiSait", "nuiSions", "nuiSiez", "nuiSaient"] {
      T.testConjugation(infinitif: "nuire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuirai", "nuiras", "nuira", "nuirons", "nuirez", "nuiront"] {
      T.testConjugation(infinitif: "nuire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuirais", "nuirais", "nuirait", "nuirions", "nuiriez", "nuiraient"] {
      T.testConjugation(infinitif: "nuire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuiSis", "nuiSis", "nuiSit", "nuiSîmes", "nuiSîtes", "nuiSirent"] {
      T.testConjugation(infinitif: "nuire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuiSe", "nuiSes", "nuiSe", "nuiSions", "nuiSiez", "nuiSent"] {
      T.testConjugation(infinitif: "nuire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["nuiSisse", "nuiSisses", "nuiSît", "nuiSissions", "nuiSissiez", "nuiSissent"] {
      T.testConjugation(infinitif: "nuire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "nuire", tense: .participePassé, expected: "nuI")
    T.testConjugation(infinitif: "nuire", tense: .participePrésent, expected: "nuiSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["nuis", "nuiSons", "nuiSez"] {
      T.testConjugation(infinitif: "nuire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testParler() {
    // ID: 1-1
    var personNumbersIndex = 0

    for conjugation in ["parle", "parles", "parle", "parlons", "parlez", "parlent"] {
      T.testConjugation(infinitif: "parler", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parlais", "parlais", "parlait", "parlions", "parliez", "parlaient"] {
      T.testConjugation(infinitif: "parler", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parlerai", "parleras", "parlera", "parlerons", "parlerez", "parleront"] {
      T.testConjugation(infinitif: "parler", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parlerais", "parlerais", "parlerait", "parlerions", "parleriez", "parleraient"] {
      T.testConjugation(infinitif: "parler", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parlai", "parlas", "parla", "parlâmes", "parlâtes", "parlèrent"] {
      T.testConjugation(infinitif: "parler", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parle", "parles", "parle", "parlions", "parliez", "parlent"] {
      T.testConjugation(infinitif: "parler", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["parlasse", "parlasses", "parlât", "parlassions", "parlassiez", "parlassent"] {
      T.testConjugation(infinitif: "parler", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "parler", tense: .participePassé, expected: "parlé")
    T.testConjugation(infinitif: "parler", tense: .participePrésent, expected: "parlant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["parle", "parlons", "parlez"] {
      T.testConjugation(infinitif: "parler", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPayer() {
    // ID: 1-7B
    var personNumbersIndex = 0

    for conjugation in ["paye/paIe", "payes/paIes", "paye/paIe", "payons", "payez", "payent/paIent"] {
      T.testConjugation(infinitif: "payer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payais", "payais", "payait", "payions", "payiez", "payaient"] {
      T.testConjugation(infinitif: "payer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payerai/paIerai", "payeras/paIeras", "payera/paIera", "payerons/paIerons", "payerez/paIerez", "payeront/paIeront"] {
      T.testConjugation(infinitif: "payer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payerais/paIerais", "payerais/paIerais", "payerait/paIerait", "payerions/paIerions", "payeriez/paIeriez", "payeraient/paIeraient"] {
      T.testConjugation(infinitif: "payer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payai", "payas", "paya", "payâmes", "payâtes", "payèrent"] {
      T.testConjugation(infinitif: "payer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["paye/paIe", "payes/paIes", "paye/paIe", "payions", "payiez", "payent/paIent"] {
      T.testConjugation(infinitif: "payer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payasse", "payasses", "payât", "payassions", "payassiez", "payassent"] {
      T.testConjugation(infinitif: "payer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "payer", tense: .participePassé, expected: "payé")
    T.testConjugation(infinitif: "payer", tense: .participePrésent, expected: "payant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["paye/paIe", "payons", "payez"] {
      T.testConjugation(infinitif: "payer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPeser() {
    // ID: 1-4
    var personNumbersIndex = 0

    for conjugation in ["pÈse", "pÈses", "pÈse", "pesons", "pesez", "pÈsent"] {
      T.testConjugation(infinitif: "peser", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pesais", "pesais", "pesait", "pesions", "pesiez", "pesaient"] {
      T.testConjugation(infinitif: "peser", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pÈserai", "pÈseras", "pÈsera", "pÈserons", "pÈserez", "pÈseront"] {
      T.testConjugation(infinitif: "peser", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pÈserais", "pÈserais", "pÈserait", "pÈserions", "pÈseriez", "pÈseraient"] {
      T.testConjugation(infinitif: "peser", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pesai", "pesas", "pesa", "pesâmes", "pesâtes", "pesèrent"] {
      T.testConjugation(infinitif: "peser", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pÈse", "pÈses", "pÈse", "pesions", "pesiez", "pÈsent"] {
      T.testConjugation(infinitif: "peser", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pesasse", "pesasses", "pesât", "pesassions", "pesassiez", "pesassent"] {
      T.testConjugation(infinitif: "peser", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "peser", tense: .participePassé, expected: "pesé")
    T.testConjugation(infinitif: "peser", tense: .participePrésent, expected: "pesant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["pÈse", "pesons", "pesez"] {
      T.testConjugation(infinitif: "peser", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPlaindre() {
    // ID: 5-12
    var personNumbersIndex = 0

    for conjugation in ["plaiNs", "plaiNs", "plaiNt", "plaiGNons", "plaiGNez", "plaiGNent"] {
      T.testConjugation(infinitif: "plaindre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaiGNais", "plaiGNais", "plaiGNait", "plaiGNions", "plaiGNiez", "plaiGNaient"] {
      T.testConjugation(infinitif: "plaindre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaindrai", "plaindras", "plaindra", "plaindrons", "plaindrez", "plaindront"] {
      T.testConjugation(infinitif: "plaindre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaindrais", "plaindrais", "plaindrait", "plaindrions", "plaindriez", "plaindraient"] {
      T.testConjugation(infinitif: "plaindre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaiGNis", "plaiGNis", "plaiGNit", "plaiGNîmes", "plaiGNîtes", "plaiGNirent"] {
      T.testConjugation(infinitif: "plaindre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaiGNe", "plaiGNes", "plaiGNe", "plaiGNions", "plaiGNiez", "plaiGNent"] {
      T.testConjugation(infinitif: "plaindre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plaiGNisse", "plaiGNisses", "plaiGNît", "plaiGNissions", "plaiGNissiez", "plaiGNissent"] {
      T.testConjugation(infinitif: "plaindre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "plaindre", tense: .participePassé, expected: "plaiNT")
    T.testConjugation(infinitif: "plaindre", tense: .participePrésent, expected: "plaiGNant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["plaiNs", "plaiGNons", "plaiGNez"] {
      T.testConjugation(infinitif: "plaindre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPleuvoir() {
    // ID: 4-4
    var personNumbersIndex = 0

    for conjugation in ["pleUs", "pleUs", "pleUt", "pleuvons", "pleuvez", "pleuvent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pleuvais", "pleuvais", "pleuvait", "pleuvions", "pleuviez", "pleuvaient"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pleuvRai", "pleuvRas", "pleuvRa", "pleuvRons", "pleuvRez", "pleuvRont"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pleuvRais", "pleuvRais", "pleuvRait", "pleuvRions", "pleuvRiez", "pleuvRaient"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pLus", "pLus", "pLut", "pLûmes", "pLûtes", "pLurent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pleuve", "pleuves", "pleuve", "pleuvions", "pleuviez", "pleuvent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pLusse", "pLusses", "pLût", "pLussions", "pLussiez", "pLussent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "pleuvoir", tense: .participePassé, expected: "pLU")
    T.testConjugation(infinitif: "pleuvoir", tense: .participePrésent, expected: "pleuvant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["pleUs", "pleuvons", "pleuvez"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPourvoir() {
    // ID: 4-1C
    var personNumbersIndex = 0

    for conjugation in ["pourvOIs", "pourvOIs", "pourvOIt", "pourvOYons", "pourvOYez", "pourvOIent"] {
      T.testConjugation(infinitif: "pourvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvOYais", "pourvOYais", "pourvOYait", "pourvOYions", "pourvOYiez", "pourvOYaient"] {
      T.testConjugation(infinitif: "pourvoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvoirai", "pourvoiras", "pourvoira", "pourvoirons", "pourvoirez", "pourvoiront"] {
      T.testConjugation(infinitif: "pourvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvoirais", "pourvoirais", "pourvoirait", "pourvoirions", "pourvoiriez", "pourvoiraient"] {
      T.testConjugation(infinitif: "pourvoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvus", "pourvus", "pourvut", "pourvûmes", "pourvûtes", "pourvurent"] {
      T.testConjugation(infinitif: "pourvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvOIe", "pourvOIes", "pourvOIe", "pourvOYions", "pourvOYiez", "pourvOIent"] {
      T.testConjugation(infinitif: "pourvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvusse", "pourvusses", "pourvût", "pourvussions", "pourvussiez", "pourvussent"] {
      T.testConjugation(infinitif: "pourvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "pourvoir", tense: .participePassé, expected: "pourvU")
    T.testConjugation(infinitif: "pourvoir", tense: .participePrésent, expected: "pourvOYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["pourvOIs", "pourvOYons", "pourvOYez"] {
      T.testConjugation(infinitif: "pourvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPouvoir() {
    // ID: 4-6
    var personNumbersIndex = 0

    for conjugation in ["pEUX/pUIs", "pEUX", "pEUt", "pouvons", "pouvez", "pouvent"] {
      T.testConjugation(infinitif: "pouvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pouvais", "pouvais", "pouvait", "pouvions", "pouviez", "pouvaient"] {
      T.testConjugation(infinitif: "pouvoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pouRrai", "pouRras", "pouRra", "pouRrons", "pouRrez", "pouRront"] {
      T.testConjugation(infinitif: "pouvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pouRrais", "pouRrais", "pouRrait", "pouRrions", "pouRriez", "pouRraient"] {
      T.testConjugation(infinitif: "pouvoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Pus", "Pus", "Put", "Pûmes", "Pûtes", "Purent"] {
      T.testConjugation(infinitif: "pouvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pUISSe", "pUISSes", "pUISSe", "pUISSions", "pUISSiez", "pUISSent"] {
      T.testConjugation(infinitif: "pouvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Pusse", "Pusses", "Pût", "Pussions", "Pussiez", "Pussent"] {
      T.testConjugation(infinitif: "pouvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "pouvoir", tense: .participePassé, expected: "PU")
    T.testConjugation(infinitif: "pouvoir", tense: .participePrésent, expected: "pouvant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["pEUX", "pouvons", "pouvez"] {
      T.testConjugation(infinitif: "pouvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPrendre() {
    // ID: 5-2
    var personNumbersIndex = 0

    for conjugation in ["prends", "prends", "prenD", "preNons", "preNez", "prenNent"] {
      T.testConjugation(infinitif: "prendre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["preNais", "preNais", "preNait", "preNions", "preNiez", "preNaient"] {
      T.testConjugation(infinitif: "prendre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prendrai", "prendras", "prendra", "prendrons", "prendrez", "prendront"] {
      T.testConjugation(infinitif: "prendre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prendrais", "prendrais", "prendrait", "prendrions", "prendriez", "prendraient"] {
      T.testConjugation(infinitif: "prendre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pris", "pris", "prit", "prîmes", "prîtes", "prirent"] {
      T.testConjugation(infinitif: "prendre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prenNe", "prenNes", "prenNe", "preNions", "preNiez", "prenNent"] {
      T.testConjugation(infinitif: "prendre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prisse", "prisses", "prît", "prissions", "prissiez", "prissent"] {
      T.testConjugation(infinitif: "prendre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "prendre", tense: .participePassé, expected: "prIS")
    T.testConjugation(infinitif: "prendre", tense: .participePrésent, expected: "preNant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["prends", "preNons", "preNez"] {
      T.testConjugation(infinitif: "prendre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPrédire() {
    // ID: 5-8B
    var personNumbersIndex = 0

    for conjugation in ["prédis", "prédis", "prédit", "prédiSons", "prédiSez", "prédiSent"] {
      T.testConjugation(infinitif: "prédire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédiSais", "prédiSais", "prédiSait", "prédiSions", "prédiSiez", "prédiSaient"] {
      T.testConjugation(infinitif: "prédire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédirai", "prédiras", "prédira", "prédirons", "prédirez", "prédiront"] {
      T.testConjugation(infinitif: "prédire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédirais", "prédirais", "prédirait", "prédirions", "prédiriez", "prédiraient"] {
      T.testConjugation(infinitif: "prédire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédis", "prédis", "prédit", "prédîmes", "prédîtes", "prédirent"] {
      T.testConjugation(infinitif: "prédire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédiSe", "prédiSes", "prédiSe", "prédiSions", "prédiSiez", "prédiSent"] {
      T.testConjugation(infinitif: "prédire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prédisse", "prédisses", "prédît", "prédissions", "prédissiez", "prédissent"] {
      T.testConjugation(infinitif: "prédire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "prédire", tense: .participePassé, expected: "prédiT")
    T.testConjugation(infinitif: "prédire", tense: .participePrésent, expected: "prédiSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["prédis", "prédiSons", "prédiSez"] {
      T.testConjugation(infinitif: "prédire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPrévaloir() {
    // ID: 4-5B
    var personNumbersIndex = 0

    for conjugation in ["prévaUX", "prévaUX", "prévaUt", "prévalons", "prévalez", "prévalent"] {
      T.testConjugation(infinitif: "prévaloir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévalais", "prévalais", "prévalait", "prévalions", "prévaliez", "prévalaient"] {
      T.testConjugation(infinitif: "prévaloir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévaUDrai", "prévaUDras", "prévaUDra", "prévaUDrons", "prévaUDrez", "prévaUDront"] {
      T.testConjugation(infinitif: "prévaloir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévaUDrais", "prévaUDrais", "prévaUDrait", "prévaUDrions", "prévaUDriez", "prévaUDraient"] {
      T.testConjugation(infinitif: "prévaloir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévalus", "prévalus", "prévalut", "prévalûmes", "prévalûtes", "prévalurent"] {
      T.testConjugation(infinitif: "prévaloir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévaLe", "prévaLes", "prévaLe", "prévalions", "prévaliez", "prévaLent"] {
      T.testConjugation(infinitif: "prévaloir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévalusse", "prévalusses", "prévalût", "prévalussions", "prévalussiez", "prévalussent"] {
      T.testConjugation(infinitif: "prévaloir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "prévaloir", tense: .participePassé, expected: "prévalU")
    T.testConjugation(infinitif: "prévaloir", tense: .participePrésent, expected: "prévalant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["prévaUX", "prévalons", "prévalez"] {
      T.testConjugation(infinitif: "prévaloir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPrévoir() {
    // ID: 4-1B
    var personNumbersIndex = 0

    for conjugation in ["prévOIs", "prévOIs", "prévOIt", "prévOYons", "prévOYez", "prévOIent"] {
      T.testConjugation(infinitif: "prévoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévOYais", "prévOYais", "prévOYait", "prévOYions", "prévOYiez", "prévOYaient"] {
      T.testConjugation(infinitif: "prévoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévoirai", "prévoiras", "prévoira", "prévoirons", "prévoirez", "prévoiront"] {
      T.testConjugation(infinitif: "prévoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévoirais", "prévoirais", "prévoirait", "prévoirions", "prévoiriez", "prévoiraient"] {
      T.testConjugation(infinitif: "prévoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévis", "prévis", "prévit", "prévîmes", "prévîtes", "prévirent"] {
      T.testConjugation(infinitif: "prévoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévOIe", "prévOIes", "prévOIe", "prévOYions", "prévOYiez", "prévOIent"] {
      T.testConjugation(infinitif: "prévoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévisse", "prévisses", "prévît", "prévissions", "prévissiez", "prévissent"] {
      T.testConjugation(infinitif: "prévoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "prévoir", tense: .participePassé, expected: "prévU")
    T.testConjugation(infinitif: "prévoir", tense: .participePrésent, expected: "prévOYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["prévOIs", "prévOYons", "prévOYez"] {
      T.testConjugation(infinitif: "prévoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPromouvoir() {
    // ID: 4-3B
    var personNumbersIndex = 0

    for conjugation in ["promEUs", "promEUs", "promEUt", "promouvons", "promouvez", "promEuvent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promouvais", "promouvais", "promouvait", "promouvions", "promouviez", "promouvaient"] {
      T.testConjugation(infinitif: "promouvoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promouvRai", "promouvRas", "promouvRa", "promouvRons", "promouvRez", "promouvRont"] {
      T.testConjugation(infinitif: "promouvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promouvRais", "promouvRais", "promouvRait", "promouvRions", "promouvRiez", "promouvRaient"] {
      T.testConjugation(infinitif: "promouvoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["proMus", "proMus", "proMut", "proMûmes", "proMûtes", "proMurent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promEuve", "promEuves", "promEuve", "promouvions", "promouviez", "promEuvent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["proMusse", "proMusses", "proMût", "proMussions", "proMussiez", "proMussent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "promouvoir", tense: .participePassé, expected: "proMU")
    T.testConjugation(infinitif: "promouvoir", tense: .participePrésent, expected: "promouvant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["promEUs", "promouvons", "promouvez"] {
      T.testConjugation(infinitif: "promouvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testProtéger() {
    // ID: 1-6C
    var personNumbersIndex = 0

    for conjugation in ["protÈge", "protÈges", "protÈge", "protégEons", "protégez", "protÈgent"] {
      T.testConjugation(infinitif: "protéger", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protégEais", "protégEais", "protégEait", "protégions", "protégiez", "protégEaient"] {
      T.testConjugation(infinitif: "protéger", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protégerai", "protégeras", "protégera", "protégerons", "protégerez", "protégeront"] {
      T.testConjugation(infinitif: "protéger", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protégerais", "protégerais", "protégerait", "protégerions", "protégeriez", "protégeraient"] {
      T.testConjugation(infinitif: "protéger", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protégEai", "protégEas", "protégEa", "protégEâmes", "protégEâtes", "protégèrent"] {
      T.testConjugation(infinitif: "protéger", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protÈge", "protÈges", "protÈge", "protégions", "protégiez", "protÈgent"] {
      T.testConjugation(infinitif: "protéger", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["protégEasse", "protégEasses", "protégEât", "protégEassions", "protégEassiez", "protégEassent"] {
      T.testConjugation(infinitif: "protéger", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "protéger", tense: .participePassé, expected: "protégé")
    T.testConjugation(infinitif: "protéger", tense: .participePrésent, expected: "protégEant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["protÈge", "protégEons", "protégez"] {
      T.testConjugation(infinitif: "protéger", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRapiécer() {
    // ID: 1-6B
    var personNumbersIndex = 0

    for conjugation in ["rapiÈce", "rapiÈces", "rapiÈce", "rapiéÇons", "rapiécez", "rapiÈcent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiéÇais", "rapiéÇais", "rapiéÇait", "rapiéCions", "rapiéCiez", "rapiéÇaient"] {
      T.testConjugation(infinitif: "rapiécer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiécerai", "rapiéceras", "rapiécera", "rapiécerons", "rapiécerez", "rapiéceront"] {
      T.testConjugation(infinitif: "rapiécer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiécerais", "rapiécerais", "rapiécerait", "rapiécerions", "rapiéceriez", "rapiéceraient"] {
      T.testConjugation(infinitif: "rapiécer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiéÇai", "rapiéÇas", "rapiéÇa", "rapiéÇâmes", "rapiéÇâtes", "rapiécèrent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiÈce", "rapiÈces", "rapiÈce", "rapiéCions", "rapiéCiez", "rapiÈcent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rapiéÇasse", "rapiéÇasses", "rapiéÇât", "rapiéÇassions", "rapiéÇassiez", "rapiéÇassent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "rapiécer", tense: .participePassé, expected: "rapiécé")
    T.testConjugation(infinitif: "rapiécer", tense: .participePrésent, expected: "rapiéÇant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["rapiÈce", "rapiéÇons", "rapiécez"] {
      T.testConjugation(infinitif: "rapiécer", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRecevoir() {
    // ID: 4-2B
    var personNumbersIndex = 0

    for conjugation in ["reÇOIs", "reÇOIs", "reÇOIt", "recevons", "recevez", "reÇOIvent"] {
      T.testConjugation(infinitif: "recevoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["recevais", "recevais", "recevait", "recevions", "receviez", "recevaient"] {
      T.testConjugation(infinitif: "recevoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["recevRai", "recevRas", "recevRa", "recevRons", "recevRez", "recevRont"] {
      T.testConjugation(infinitif: "recevoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["recevRais", "recevRais", "recevRait", "recevRions", "recevRiez", "recevRaient"] {
      T.testConjugation(infinitif: "recevoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["reÇus", "reÇus", "reÇut", "reÇûmes", "reÇûtes", "reÇurent"] {
      T.testConjugation(infinitif: "recevoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["reÇOIve", "reÇOIves", "reÇOIve", "recevions", "receviez", "reÇOIvent"] {
      T.testConjugation(infinitif: "recevoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["reÇusse", "reÇusses", "reÇût", "reÇussions", "reÇussiez", "reÇussent"] {
      T.testConjugation(infinitif: "recevoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "recevoir", tense: .participePassé, expected: "reÇU")
    T.testConjugation(infinitif: "recevoir", tense: .participePrésent, expected: "recevant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["reÇOIs", "recevons", "recevez"] {
      T.testConjugation(infinitif: "recevoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRendre() {
    // ID: 5-1A
    var personNumbersIndex = 0

    for conjugation in ["rends", "rends", "renD", "rendons", "rendez", "rendent"] {
      T.testConjugation(infinitif: "rendre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rendais", "rendais", "rendait", "rendions", "rendiez", "rendaient"] {
      T.testConjugation(infinitif: "rendre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rendrai", "rendras", "rendra", "rendrons", "rendrez", "rendront"] {
      T.testConjugation(infinitif: "rendre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rendrais", "rendrais", "rendrait", "rendrions", "rendriez", "rendraient"] {
      T.testConjugation(infinitif: "rendre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rendis", "rendis", "rendit", "rendîmes", "rendîtes", "rendirent"] {
      T.testConjugation(infinitif: "rendre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rende", "rendes", "rende", "rendions", "rendiez", "rendent"] {
      T.testConjugation(infinitif: "rendre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rendisse", "rendisses", "rendît", "rendissions", "rendissiez", "rendissent"] {
      T.testConjugation(infinitif: "rendre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "rendre", tense: .participePassé, expected: "rendu")
    T.testConjugation(infinitif: "rendre", tense: .participePrésent, expected: "rendant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["rends", "rendons", "rendez"] {
      T.testConjugation(infinitif: "rendre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRésoudre() {
    // ID: 5-13B
    var personNumbersIndex = 0

    for conjugation in ["résoUs", "résoUs", "résoUt", "résoLVons", "résoLVez", "résoLVent"] {
      T.testConjugation(infinitif: "résoudre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["résoLVais", "résoLVais", "résoLVait", "résoLVions", "résoLViez", "résoLVaient"] {
      T.testConjugation(infinitif: "résoudre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["résoudrai", "résoudras", "résoudra", "résoudrons", "résoudrez", "résoudront"] {
      T.testConjugation(infinitif: "résoudre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["résoudrais", "résoudrais", "résoudrait", "résoudrions", "résoudriez", "résoudraient"] {
      T.testConjugation(infinitif: "résoudre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["résoLus", "résoLus", "résoLut", "résoLûmes", "résoLûtes", "résoLurent"] {
      T.testConjugation(infinitif: "résoudre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["résoLVe", "résoLVes", "résoLVe", "résoLVions", "résoLViez", "résoLVent"] {
      T.testConjugation(infinitif: "résoudre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["résoLusse", "résoLusses", "résoLût", "résoLussions", "résoLussiez", "résoLussent"] {
      T.testConjugation(infinitif: "résoudre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "résoudre", tense: .participePassé, expected: "résouS/résoLu")
    T.testConjugation(infinitif: "résoudre", tense: .participePrésent, expected: "résoLVant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["résoUs", "résoLVons", "résoLVez"] {
      T.testConjugation(infinitif: "résoudre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRire() {
    // ID: 5-11
    var personNumbersIndex = 0

    for conjugation in ["ris", "ris", "rit", "rions", "riez", "rient"] {
      T.testConjugation(infinitif: "rire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["riais", "riais", "riait", "riions", "riiez", "riaient"] {
      T.testConjugation(infinitif: "rire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rirai", "riras", "rira", "rirons", "rirez", "riront"] {
      T.testConjugation(infinitif: "rire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rirais", "rirais", "rirait", "ririons", "ririez", "riraient"] {
      T.testConjugation(infinitif: "rire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["ris", "ris", "rit", "rîmes", "rîtes", "rirent"] {
      T.testConjugation(infinitif: "rire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rie", "ries", "rie", "riions", "riiez", "rient"] {
      T.testConjugation(infinitif: "rire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["risse", "risses", "rît", "rissions", "rissiez", "rissent"] {
      T.testConjugation(infinitif: "rire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "rire", tense: .participePassé, expected: "rI")
    T.testConjugation(infinitif: "rire", tense: .participePrésent, expected: "riant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["ris", "rions", "riez"] {
      T.testConjugation(infinitif: "rire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testRompre() {
    // ID: 5-1B
    var personNumbersIndex = 0

    for conjugation in ["romps", "romps", "rompT", "rompons", "rompez", "rompent"] {
      T.testConjugation(infinitif: "rompre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rompais", "rompais", "rompait", "rompions", "rompiez", "rompaient"] {
      T.testConjugation(infinitif: "rompre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["romprai", "rompras", "rompra", "romprons", "romprez", "rompront"] {
      T.testConjugation(infinitif: "rompre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["romprais", "romprais", "romprait", "romprions", "rompriez", "rompraient"] {
      T.testConjugation(infinitif: "rompre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rompis", "rompis", "rompit", "rompîmes", "rompîtes", "rompirent"] {
      T.testConjugation(infinitif: "rompre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rompe", "rompes", "rompe", "rompions", "rompiez", "rompent"] {
      T.testConjugation(infinitif: "rompre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["rompisse", "rompisses", "rompît", "rompissions", "rompissiez", "rompissent"] {
      T.testConjugation(infinitif: "rompre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "rompre", tense: .participePassé, expected: "rompu")
    T.testConjugation(infinitif: "rompre", tense: .participePrésent, expected: "rompant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["romps", "rompons", "rompez"] {
      T.testConjugation(infinitif: "rompre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testSavoir() {
    // ID: 4-7
    var personNumbersIndex = 0

    for conjugation in ["saIs", "saIs", "saIt", "savons", "savez", "savent"] {
      T.testConjugation(infinitif: "savoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["savais", "savais", "savait", "savions", "saviez", "savaient"] {
      T.testConjugation(infinitif: "savoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["saUrai", "saUras", "saUra", "saUrons", "saUrez", "saUront"] {
      T.testConjugation(infinitif: "savoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["saUrais", "saUrais", "saUrait", "saUrions", "saUriez", "saUraient"] {
      T.testConjugation(infinitif: "savoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Sus", "Sus", "Sut", "Sûmes", "Sûtes", "Surent"] {
      T.testConjugation(infinitif: "savoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["saCHe", "saCHes", "saCHe", "saCHions", "saCHiez", "saCHent"] {
      T.testConjugation(infinitif: "savoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Susse", "Susses", "Sût", "Sussions", "Sussiez", "Sussent"] {
      T.testConjugation(infinitif: "savoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "savoir", tense: .participePassé, expected: "SU")
    T.testConjugation(infinitif: "savoir", tense: .participePrésent, expected: "saCHant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["saCHe", "saCHons", "saCHez"] {
      T.testConjugation(infinitif: "savoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testSuffire() {
    // ID: 5-8C
    var personNumbersIndex = 0

    for conjugation in ["suffis", "suffis", "suffit", "suffiSons", "suffiSez", "suffiSent"] {
      T.testConjugation(infinitif: "suffire", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffiSais", "suffiSais", "suffiSait", "suffiSions", "suffiSiez", "suffiSaient"] {
      T.testConjugation(infinitif: "suffire", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffirai", "suffiras", "suffira", "suffirons", "suffirez", "suffiront"] {
      T.testConjugation(infinitif: "suffire", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffirais", "suffirais", "suffirait", "suffirions", "suffiriez", "suffiraient"] {
      T.testConjugation(infinitif: "suffire", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffis", "suffis", "suffit", "suffîmes", "suffîtes", "suffirent"] {
      T.testConjugation(infinitif: "suffire", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffiSe", "suffiSes", "suffiSe", "suffiSions", "suffiSiez", "suffiSent"] {
      T.testConjugation(infinitif: "suffire", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suffisse", "suffisses", "suffît", "suffissions", "suffissiez", "suffissent"] {
      T.testConjugation(infinitif: "suffire", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "suffire", tense: .participePassé, expected: "suffI")
    T.testConjugation(infinitif: "suffire", tense: .participePrésent, expected: "suffiSant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["suffis", "suffiSons", "suffiSez"] {
      T.testConjugation(infinitif: "suffire", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testSuivre() {
    // ID: 5-5
    var personNumbersIndex = 0

    for conjugation in ["suIs", "suIs", "suIt", "suivons", "suivez", "suivent"] {
      T.testConjugation(infinitif: "suivre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suivais", "suivais", "suivait", "suivions", "suiviez", "suivaient"] {
      T.testConjugation(infinitif: "suivre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suivrai", "suivras", "suivra", "suivrons", "suivrez", "suivront"] {
      T.testConjugation(infinitif: "suivre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suivrais", "suivrais", "suivrait", "suivrions", "suivriez", "suivraient"] {
      T.testConjugation(infinitif: "suivre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suivis", "suivis", "suivit", "suivîmes", "suivîtes", "suivirent"] {
      T.testConjugation(infinitif: "suivre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suive", "suives", "suive", "suivions", "suiviez", "suivent"] {
      T.testConjugation(infinitif: "suivre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["suivisse", "suivisses", "suivît", "suivissions", "suivissiez", "suivissent"] {
      T.testConjugation(infinitif: "suivre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "suivre", tense: .participePassé, expected: "suivIS")
    T.testConjugation(infinitif: "suivre", tense: .participePrésent, expected: "suivant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["suIs", "suivons", "suivez"] {
      T.testConjugation(infinitif: "suivre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testSurseoir() {
    // ID: 4-9C
    var personNumbersIndex = 0

    for conjugation in ["sursOIs", "sursOIs", "sursOIt", "sursOYons", "sursOYez", "sursOIent"] {
      T.testConjugation(infinitif: "surseoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["sursOYais", "sursOYais", "sursOYait", "sursOYions", "sursOYiez", "sursOYaient"] {
      T.testConjugation(infinitif: "surseoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["surseoirai", "surseoiras", "surseoira", "surseoirons", "surseoirez", "surseoiront"] {
      T.testConjugation(infinitif: "surseoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["surseoirais", "surseoirais", "surseoirait", "surseoirions", "surseoiriez", "surseoiraient"] {
      T.testConjugation(infinitif: "surseoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["surSis", "surSis", "surSit", "surSîmes", "surSîtes", "surSirent"] {
      T.testConjugation(infinitif: "surseoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["sursOIe", "sursOIes", "sursOIe", "sursOYions", "sursOYiez", "sursOIent"] {
      T.testConjugation(infinitif: "surseoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["surSisse", "surSisses", "surSît", "surSissions", "surSissiez", "surSissent"] {
      T.testConjugation(infinitif: "surseoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "surseoir", tense: .participePassé, expected: "surSIS")
    T.testConjugation(infinitif: "surseoir", tense: .participePrésent, expected: "sursOYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["sursOIs", "sursOYons", "sursOYez"] {
      T.testConjugation(infinitif: "surseoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testValoir() {
    // ID: 4-5A
    var personNumbersIndex = 0

    for conjugation in ["vaUX", "vaUX", "vaUt", "valons", "valez", "valent"] {
      T.testConjugation(infinitif: "valoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["valais", "valais", "valait", "valions", "valiez", "valaient"] {
      T.testConjugation(infinitif: "valoir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vaUDrai", "vaUDras", "vaUDra", "vaUDrons", "vaUDrez", "vaUDront"] {
      T.testConjugation(infinitif: "valoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vaUDrais", "vaUDrais", "vaUDrait", "vaUDrions", "vaUDriez", "vaUDraient"] {
      T.testConjugation(infinitif: "valoir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["valus", "valus", "valut", "valûmes", "valûtes", "valurent"] {
      T.testConjugation(infinitif: "valoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vaILle", "vaILles", "vaILle", "valions", "valiez", "vaILlent"] {
      T.testConjugation(infinitif: "valoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["valusse", "valusses", "valût", "valussions", "valussiez", "valussent"] {
      T.testConjugation(infinitif: "valoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "valoir", tense: .participePassé, expected: "valU")
    T.testConjugation(infinitif: "valoir", tense: .participePrésent, expected: "valant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vaUX", "valons", "valez"] {
      T.testConjugation(infinitif: "valoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testVivre() {
    // ID: 5-6
    var personNumbersIndex = 0

    for conjugation in ["vIs", "vIs", "vIt", "vivons", "vivez", "vivent"] {
      T.testConjugation(infinitif: "vivre", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vivais", "vivais", "vivait", "vivions", "viviez", "vivaient"] {
      T.testConjugation(infinitif: "vivre", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vivrai", "vivras", "vivra", "vivrons", "vivrez", "vivront"] {
      T.testConjugation(infinitif: "vivre", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vivrais", "vivrais", "vivrait", "vivrions", "vivriez", "vivraient"] {
      T.testConjugation(infinitif: "vivre", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vivis", "vivis", "vivit", "vivîmes", "vivîtes", "vivirent"] {
      T.testConjugation(infinitif: "vivre", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vive", "vives", "vive", "vivions", "viviez", "vivent"] {
      T.testConjugation(infinitif: "vivre", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vivisse", "vivisses", "vivît", "vivissions", "vivissiez", "vivissent"] {
      T.testConjugation(infinitif: "vivre", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "vivre", tense: .participePassé, expected: "vÉCu")
    T.testConjugation(infinitif: "vivre", tense: .participePrésent, expected: "vivant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vIs", "vivons", "vivez"] {
      T.testConjugation(infinitif: "vivre", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testVoir() {
    // ID: 4-1A
    var personNumbersIndex = 0

    for conjugation in ["vOIs", "vOIs", "vOIt", "vOYons", "vOYez", "vOIent"] {
      T.testConjugation(infinitif: "voir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vOYais", "vOYais", "vOYait", "vOYions", "vOYiez", "vOYaient"] {
      T.testConjugation(infinitif: "voir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vERrai", "vERras", "vERra", "vERrons", "vERrez", "vERront"] {
      T.testConjugation(infinitif: "voir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vERrais", "vERrais", "vERrait", "vERrions", "vERriez", "vERraient"] {
      T.testConjugation(infinitif: "voir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vis", "vis", "vit", "vîmes", "vîtes", "virent"] {
      T.testConjugation(infinitif: "voir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vOIe", "vOIes", "vOIe", "vOYions", "vOYiez", "vOIent"] {
      T.testConjugation(infinitif: "voir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["visse", "visses", "vît", "vissions", "vissiez", "vissent"] {
      T.testConjugation(infinitif: "voir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "voir", tense: .participePassé, expected: "vU")
    T.testConjugation(infinitif: "voir", tense: .participePrésent, expected: "vOYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vOIs", "vOYons", "vOYez"] {
      T.testConjugation(infinitif: "voir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testVouloir() {
    // ID: 4-8
    var personNumbersIndex = 0

    for conjugation in ["vEUX", "vEUX", "vEUt", "voulons", "voulez", "vEUlent"] {
      T.testConjugation(infinitif: "vouloir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["voulais", "voulais", "voulait", "voulions", "vouliez", "voulaient"] {
      T.testConjugation(infinitif: "vouloir", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vouDrai", "vouDras", "vouDra", "vouDrons", "vouDrez", "vouDront"] {
      T.testConjugation(infinitif: "vouloir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vouDrais", "vouDrais", "vouDrait", "vouDrions", "vouDriez", "vouDraient"] {
      T.testConjugation(infinitif: "vouloir", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["voulus", "voulus", "voulut", "voulûmes", "voulûtes", "voulurent"] {
      T.testConjugation(infinitif: "vouloir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vEUILle", "vEUILles", "vEUILle", "voulions", "vouliez", "vEUILlent"] {
      T.testConjugation(infinitif: "vouloir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["voulusse", "voulusses", "voulût", "voulussions", "voulussiez", "voulussent"] {
      T.testConjugation(infinitif: "vouloir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "vouloir", tense: .participePassé, expected: "voulU")
    T.testConjugation(infinitif: "vouloir", tense: .participePrésent, expected: "voulant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vEUX/vEUILLE", "voulons", "voulez/vEUILlez"] {
      T.testConjugation(infinitif: "vouloir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }
}
