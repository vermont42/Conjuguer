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

    for conjugation in ["pourvOIrai", "pourvOIras", "pourvOIra", "pourvOIrons", "pourvOIrez", "pourvOIront"] {
      T.testConjugation(infinitif: "pourvoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvOIrais", "pourvOIrais", "pourvOIrait", "pourvOIrions", "pourvOIriez", "pourvOIraient"] {
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

    for conjugation in ["prévOIrai", "prévOIras", "prévOIra", "prévOIrons", "prévOIrez", "prévOIront"] {
      T.testConjugation(infinitif: "prévoir", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévOIrais", "prévOIrais", "prévOIrait", "prévOIrions", "prévOIriez", "prévOIraient"] {
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
