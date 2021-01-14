//
//  VerbModelTests.swift
//  ConjuguerTests
//
//  Created by Joshua Adams on 1/13/21.
//

@testable import Conjuguer
import XCTest

class VerbModelTests: XCTestCase {
//  func testGenerateVerbModelTests() {
//    T.generateVerbModelTests()
//  }

  func testParler() {
    var personNumbersIndex = 0

    for conjugation in ["parle", "parles", "parle", "parlons", "parlez", "parlent"] {
      T.testConjugation(infinitif: "parler", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["parlais", "parlais", "parlait", "parlions", "parliez", "parlaient"] {
      T.testConjugation(infinitif: "parler", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["parlerai", "parleras", "parlera", "parlerons", "parlerez", "parleront"] {
      T.testConjugation(infinitif: "parler", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["parlerais", "parlerais", "parlerait", "parlerions", "parleriez", "parleraient"] {
      T.testConjugation(infinitif: "parler", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["parlai", "parlas", "parla", "parlâmes", "parlâtes", "parlèrent"] {
      T.testConjugation(infinitif: "parler", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["parle", "parles", "parle", "parlions", "parliez", "parlent"] {
      T.testConjugation(infinitif: "parler", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["parlasse", "parlasses", "parlât", "parlassions", "parlassiez", "parlassent"] {
      T.testConjugation(infinitif: "parler", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "parler", tense: .participePassé, expected: "parlé")
    T.testConjugation(infinitif: "parler", tense: .participePrésent, expected: "parlant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["parle", "parlons", "parlez"] {
      T.testConjugation(infinitif: "parler", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testLancer() {
    var personNumbersIndex = 0

    for conjugation in ["lance", "lances", "lance", "lanÇons", "lancez", "lancent"] {
      T.testConjugation(infinitif: "lancer", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["lanÇais", "lanÇais", "lanÇait", "lanCions", "lanCiez", "lanÇaient"] {
      T.testConjugation(infinitif: "lancer", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["lancerai", "lanceras", "lancera", "lancerons", "lancerez", "lanceront"] {
      T.testConjugation(infinitif: "lancer", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["lancerais", "lancerais", "lancerait", "lancerions", "lanceriez", "lanceraient"] {
      T.testConjugation(infinitif: "lancer", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["lanÇai", "lanÇas", "lanÇa", "lanÇâmes", "lanÇâtes", "lancèrent"] {
      T.testConjugation(infinitif: "lancer", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["lance", "lances", "lance", "lanCions", "lanCiez", "lancent"] {
      T.testConjugation(infinitif: "lancer", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["lanÇasse", "lanÇasses", "lanÇât", "lanÇassions", "lanÇassiez", "lanÇassent"] {
      T.testConjugation(infinitif: "lancer", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "lancer", tense: .participePassé, expected: "lancé")
    T.testConjugation(infinitif: "lancer", tense: .participePrésent, expected: "lanÇant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["lance", "lanÇons", "lancez"] {
      T.testConjugation(infinitif: "lancer", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testAppeler() {
    var personNumbersIndex = 0

    for conjugation in ["appelLe", "appelLes", "appelLe", "appelons", "appelez", "appelLent"] {
      T.testConjugation(infinitif: "appeler", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["appelais", "appelais", "appelait", "appelions", "appeliez", "appelaient"] {
      T.testConjugation(infinitif: "appeler", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["appelLerai", "appelLeras", "appelLera", "appelLerons", "appelLerez", "appelLeront"] {
      T.testConjugation(infinitif: "appeler", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["appelLerais", "appelLerais", "appelLerait", "appelLerions", "appelLeriez", "appelLeraient"] {
      T.testConjugation(infinitif: "appeler", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["appelai", "appelas", "appela", "appelâmes", "appelâtes", "appelèrent"] {
      T.testConjugation(infinitif: "appeler", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["appelLe", "appelLes", "appelLe", "appelions", "appeliez", "appelLent"] {
      T.testConjugation(infinitif: "appeler", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["appelasse", "appelasses", "appelât", "appelassions", "appelassiez", "appelassent"] {
      T.testConjugation(infinitif: "appeler", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "appeler", tense: .participePassé, expected: "appelé")
    T.testConjugation(infinitif: "appeler", tense: .participePrésent, expected: "appelant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["appelLe", "appelons", "appelez"] {
      T.testConjugation(infinitif: "appeler", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testFinir() {
    var personNumbersIndex = 0

    for conjugation in ["finis", "finis", "finit", "finissons", "finissez", "finissent"] {
      T.testConjugation(infinitif: "finir", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["finissais", "finissais", "finissait", "finissions", "finissiez", "finissaient"] {
      T.testConjugation(infinitif: "finir", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["finirai", "finiras", "finira", "finirons", "finirez", "finiront"] {
      T.testConjugation(infinitif: "finir", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["finirais", "finirais", "finirait", "finirions", "finiriez", "finiraient"] {
      T.testConjugation(infinitif: "finir", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["finis", "finis", "finit", "finîmes", "finîtes", "finirent"] {
      T.testConjugation(infinitif: "finir", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["finisse", "finisses", "finisse", "finissions", "finissiez", "finissent"] {
      T.testConjugation(infinitif: "finir", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["finisse", "finisses", "finît", "finissions", "finissiez", "finissent"] {
      T.testConjugation(infinitif: "finir", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "finir", tense: .participePassé, expected: "fini")
    T.testConjugation(infinitif: "finir", tense: .participePrésent, expected: "finissant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["finis", "finissons", "finissez"] {
      T.testConjugation(infinitif: "finir", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testCouvrir() {
    var personNumbersIndex = 0

    for conjugation in ["couvrE", "couvrES", "couvrE", "couvrONS", "couvrEZ", "couvrENT"] {
      T.testConjugation(infinitif: "couvrir", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["couvrais", "couvrais", "couvrait", "couvrions", "couvriez", "couvraient"] {
      T.testConjugation(infinitif: "couvrir", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["couvrirai", "couvriras", "couvrira", "couvrirons", "couvrirez", "couvriront"] {
      T.testConjugation(infinitif: "couvrir", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["couvrirais", "couvrirais", "couvrirait", "couvririons", "couvririez", "couvriraient"] {
      T.testConjugation(infinitif: "couvrir", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["couvris", "couvris", "couvrit", "couvrîmes", "couvrîtes", "couvrirent"] {
      T.testConjugation(infinitif: "couvrir", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["couvre", "couvres", "couvre", "couvrions", "couvriez", "couvrent"] {
      T.testConjugation(infinitif: "couvrir", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["couvrisse", "couvrisses", "couvrît", "couvrissions", "couvrissiez", "couvrissent"] {
      T.testConjugation(infinitif: "couvrir", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "couvrir", tense: .participePassé, expected: "couverT")
    T.testConjugation(infinitif: "couvrir", tense: .participePrésent, expected: "couvrant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["couvrE", "couvrONS", "couvrEZ"] {
      T.testConjugation(infinitif: "couvrir", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testÊtre() {
    var personNumbersIndex = 0

    for conjugation in ["SUIS", "Es", "EST", "SOMMEs", "êteS", "SOnt"] {
      T.testConjugation(infinitif: "être", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["Étais", "Étais", "Était", "Étions", "Étiez", "Étaient"] {
      T.testConjugation(infinitif: "être", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["SErai", "SEras", "SEra", "SErons", "SErez", "SEront"] {
      T.testConjugation(infinitif: "être", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["SErais", "SErais", "SErait", "SErions", "SEriez", "SEraient"] {
      T.testConjugation(infinitif: "être", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["FUs", "FUs", "FUt", "FÛmes", "FÛtes", "FUrent"] {
      T.testConjugation(infinitif: "être", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["SOIS", "SOIs", "SOIT", "SOYons", "SOYez", "SOIent"] {
      T.testConjugation(infinitif: "être", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["FUsse", "FUsses", "FÛt", "FUssions", "FUssiez", "FUssent"] {
      T.testConjugation(infinitif: "être", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "être", tense: .participePassé, expected: "ÉTÉ")
    T.testConjugation(infinitif: "être", tense: .participePrésent, expected: "Étant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["SOIs", "SOYons", "SOYez"] {
      T.testConjugation(infinitif: "être", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testAvoir() {
    var personNumbersIndex = 0

    for conjugation in ["AI", "As", "A", "aVons", "aVez", "Ont"] {
      T.testConjugation(infinitif: "avoir", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["aVais", "aVais", "aVait", "aVions", "aViez", "aVaient"] {
      T.testConjugation(infinitif: "avoir", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["aUrai", "aUras", "aUra", "aUrons", "aUrez", "aUront"] {
      T.testConjugation(infinitif: "avoir", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["aUrais", "aUrais", "aUrait", "aUrions", "aUriez", "aUraient"] {
      T.testConjugation(infinitif: "avoir", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["Eus", "Eus", "Eut", "Eûmes", "Eûtes", "Eurent"] {
      T.testConjugation(infinitif: "avoir", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["aIe", "aIes", "aIT", "aYons", "aYez", "aIent"] {
      T.testConjugation(infinitif: "avoir", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["Eusse", "Eusses", "Eût", "Eussions", "Eussiez", "Eussent"] {
      T.testConjugation(infinitif: "avoir", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "avoir", tense: .participePassé, expected: "EU")
    T.testConjugation(infinitif: "avoir", tense: .participePrésent, expected: "aYant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["AIe", "AYons", "AYez"] {
      T.testConjugation(infinitif: "avoir", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testAller() {
    var personNumbersIndex = 0

    for conjugation in ["VAIS", "VAs", "VA", "allons", "allez", "VOnt"] {
      T.testConjugation(infinitif: "aller", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["allais", "allais", "allait", "allions", "alliez", "allaient"] {
      T.testConjugation(infinitif: "aller", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["IRai", "IRas", "IRa", "IRons", "IRez", "IRont"] {
      T.testConjugation(infinitif: "aller", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["IRais", "IRais", "IRait", "IRions", "IRiez", "IRaient"] {
      T.testConjugation(infinitif: "aller", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["allai", "allas", "alla", "allâmes", "allâtes", "allèrent"] {
      T.testConjugation(infinitif: "aller", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["aIlle", "aIlles", "aIlle", "aLlions", "aLliez", "aIllent"] {
      T.testConjugation(infinitif: "aller", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["allasse", "allasses", "allât", "allassions", "allassiez", "allassent"] {
      T.testConjugation(infinitif: "aller", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "aller", tense: .participePassé, expected: "allé")
    T.testConjugation(infinitif: "aller", tense: .participePrésent, expected: "allant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["VA", "allons", "allez"] {
      T.testConjugation(infinitif: "aller", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }
}
