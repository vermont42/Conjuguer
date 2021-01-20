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

  func testAvoir() {
    // ID: 8
    var personNumbersIndex = 0

    for conjugation in ["AI", "As", "A", "aVons", "aVez", "Ont"] {
      T.testConjugation(infinitif: "avoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aVais", "aVais", "aVait", "aVions", "aViez", "aVaient"] {
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

    for conjugation in ["AIe", "AYons", "AYez"] {
      T.testConjugation(infinitif: "avoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
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

    for conjugation in ["dOis", "dOis", "dOit", "deVons", "deVez", "dOIvent"] {
      T.testConjugation(infinitif: "devoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["deVais", "deVais", "deVait", "deVions", "deViez", "deVaient"] {
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

    for conjugation in ["dus", "dus", "dut", "dûmes", "dûtes", "durent"] {
      T.testConjugation(infinitif: "devoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dOIve", "dOIves", "dOIve", "deVions", "deViez", "dOIvent"] {
      T.testConjugation(infinitif: "devoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["dusse", "dusses", "dût", "dussions", "dussiez", "dussent"] {
      T.testConjugation(infinitif: "devoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "devoir", tense: .participePassé, expected: "dÛ")
    T.testConjugation(infinitif: "devoir", tense: .participePrésent, expected: "deVant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["dOis", "deVons", "deVez"] {
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

  func testMouvoir() {
    // ID: 4-3A
    var personNumbersIndex = 0

    for conjugation in ["mEUs", "mEUs", "mEUt", "mouVons", "mouVez", "mEUvent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mouVais", "mouVais", "mouVait", "mouVions", "mouViez", "mouVaient"] {
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

    for conjugation in ["mus", "mus", "mut", "mûmes", "mûtes", "murent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["mEUve", "mEUves", "mEUve", "mouVions", "mouViez", "mEUvent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["musse", "musses", "mût", "mussions", "mussiez", "mussent"] {
      T.testConjugation(infinitif: "mouvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "mouvoir", tense: .participePassé, expected: "mÛ")
    T.testConjugation(infinitif: "mouvoir", tense: .participePrésent, expected: "mouVant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["mEUs", "mouVons", "mouVez"] {
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

    for conjugation in ["paIe", "paIes", "paIe", "payons", "payez", "paIent"] {
      T.testConjugation(infinitif: "payer", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payais", "payais", "payait", "payions", "payiez", "payaient"] {
      T.testConjugation(infinitif: "payer", tense: .imparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["paIerai/payerai", "paIeras/payeras", "paIera/payera", "paIerons/payerons", "paIerez/payerez", "paIeront/payeront"] {
      T.testConjugation(infinitif: "payer", tense: .futurSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["paIerais/payerais", "paIerais/payerais", "paIerait/payerait", "paIerions/payerions", "paIeriez/payeriez", "paIeraient/payeraient"] {
      T.testConjugation(infinitif: "payer", tense: .conditionnelPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["payai", "payas", "paya", "payâmes", "payâtes", "payèrent"] {
      T.testConjugation(infinitif: "payer", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["paIe/paye", "paIes/payes", "paIe/paye", "payions", "payiez", "paIent/payent"] {
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

    for conjugation in ["paIe", "payons", "payez"] {
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

    for conjugation in ["plEUs", "plEUs", "plEUt", "pleuVons", "pleuVez", "plEUvent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pleuVais", "pleuVais", "pleuVait", "pleuVions", "pleuViez", "pleuVaient"] {
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

    for conjugation in ["plus", "plus", "plut", "plûmes", "plûtes", "plurent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plEUve", "plEUves", "plEUve", "pleuVions", "pleuViez", "plEUvent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["plusse", "plusses", "plût", "plussions", "plussiez", "plussent"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "pleuvoir", tense: .participePassé, expected: "plU")
    T.testConjugation(infinitif: "pleuvoir", tense: .participePrésent, expected: "pleuVant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["plEUs", "pleuVons", "pleuVez"] {
      T.testConjugation(infinitif: "pleuvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPourvoir() {
    // ID: 4-1C
    var personNumbersIndex = 0

    for conjugation in ["pourvois", "pourvois", "pourvoit", "pourvoYons", "pourvoYez", "pourvoient"] {
      T.testConjugation(infinitif: "pourvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["pourvoYais", "pourvoYais", "pourvoYait", "pourvoYions", "pourvoYiez", "pourvoYaient"] {
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

    for conjugation in ["pourvoie", "pourvoies", "pourvoie", "pourvoYions", "pourvoYiez", "pourvoient"] {
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
    T.testConjugation(infinitif: "pourvoir", tense: .participePrésent, expected: "pourvoYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["pourvois", "pourvoYons", "pourvoYez"] {
      T.testConjugation(infinitif: "pourvoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPrévoir() {
    // ID: 4-1B
    var personNumbersIndex = 0

    for conjugation in ["prévois", "prévois", "prévoit", "prévoYons", "prévoYez", "prévoient"] {
      T.testConjugation(infinitif: "prévoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["prévoYais", "prévoYais", "prévoYait", "prévoYions", "prévoYiez", "prévoYaient"] {
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

    for conjugation in ["prévoie", "prévoies", "prévoie", "prévoYions", "prévoYiez", "prévoient"] {
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
    T.testConjugation(infinitif: "prévoir", tense: .participePrésent, expected: "prévoYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["prévois", "prévoYons", "prévoYez"] {
      T.testConjugation(infinitif: "prévoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testPromouvoir() {
    // ID: 4-3B
    var personNumbersIndex = 0

    for conjugation in ["promEUs", "promEUs", "promEUt", "promouVons", "promouVez", "promEUvent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promouVais", "promouVais", "promouVait", "promouVions", "promouViez", "promouVaient"] {
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

    for conjugation in ["promus", "promus", "promut", "promûmes", "promûtes", "promurent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .passéSimple(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promEUve", "promEUves", "promEUve", "promouVions", "promouViez", "promEUvent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .subjonctifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["promusse", "promusses", "promût", "promussions", "promussiez", "promussent"] {
      T.testConjugation(infinitif: "promouvoir", tense: .subjonctifImparfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    T.testConjugation(infinitif: "promouvoir", tense: .participePassé, expected: "promU")
    T.testConjugation(infinitif: "promouvoir", tense: .participePrésent, expected: "promouVant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["promEUs", "promouVons", "promouVez"] {
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

    for conjugation in ["reÇOis", "reÇOis", "reÇOit", "receVons", "receVez", "reÇOIvent"] {
      T.testConjugation(infinitif: "recevoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["receVais", "receVais", "receVait", "receVions", "receViez", "receVaient"] {
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

    for conjugation in ["reÇOIve", "reÇOIves", "reÇOIve", "receVions", "receViez", "reÇOIvent"] {
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
    T.testConjugation(infinitif: "recevoir", tense: .participePrésent, expected: "receVant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["reÇOis", "receVons", "receVez"] {
      T.testConjugation(infinitif: "recevoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testValoir() {
    // ID: 4-5A
    var personNumbersIndex = 0

    for conjugation in ["vaUX", "vaUX", "vaUt", "vaLons", "vaLez", "vaLent"] {
      T.testConjugation(infinitif: "valoir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["vaLais", "vaLais", "vaLait", "vaLions", "vaLiez", "vaLaient"] {
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

    for conjugation in ["vaILle", "vaILles", "vaILle", "vaLions", "vaLiez", "vaILlent"] {
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
    T.testConjugation(infinitif: "valoir", tense: .participePrésent, expected: "vaLant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vaUX", "vaLons", "vaLez"] {
      T.testConjugation(infinitif: "valoir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }

  func testVoir() {
    // ID: 4-1A
    var personNumbersIndex = 0

    for conjugation in ["vois", "vois", "voit", "voYons", "voYez", "voient"] {
      T.testConjugation(infinitif: "voir", tense: .indicatifPrésent(PersonNumber.allCases[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["voYais", "voYais", "voYait", "voYions", "voYiez", "voYaient"] {
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

    for conjugation in ["voie", "voies", "voie", "voYions", "voYiez", "voient"] {
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
    T.testConjugation(infinitif: "voir", tense: .participePrésent, expected: "voYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["vois", "voYons", "voYez"] {
      T.testConjugation(infinitif: "voir", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }
}
