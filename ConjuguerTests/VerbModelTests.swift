//
//  VerbModelTests.swift
//  ConjuguerTests
//
//  Created by Joshua Adams on 1/13/21.
//

@testable import Conjuguer
import XCTest

class GenerateVerbModelTests: XCTestCase {
  func testGenerateVerbModelTests() {
    T.generateVerbModelTests()
  }
}

class VerbModelTests: XCTestCase {
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

  func testManger() {
    var personNumbersIndex = 0

    for conjugation in ["mange", "manges", "mange", "mangEons", "mangez", "mangent"] {
      T.testConjugation(infinitif: "manger", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["mangEais", "mangEais", "mangEait", "mangions", "mangiez", "mangEaient"] {
      T.testConjugation(infinitif: "manger", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["mangerai", "mangeras", "mangera", "mangerons", "mangerez", "mangeront"] {
      T.testConjugation(infinitif: "manger", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["mangerais", "mangerais", "mangerait", "mangerions", "mangeriez", "mangeraient"] {
      T.testConjugation(infinitif: "manger", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["mangEai", "mangEas", "mangEa", "mangEâmes", "mangEâtes", "mangèrent"] {
      T.testConjugation(infinitif: "manger", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["mange", "manges", "mange", "mangions", "mangiez", "mangent"] {
      T.testConjugation(infinitif: "manger", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["mangEasse", "mangEasses", "mangEât", "mangEassions", "mangEassiez", "mangEassent"] {
      T.testConjugation(infinitif: "manger", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "manger", tense: .participePassé, expected: "mangé")
    T.testConjugation(infinitif: "manger", tense: .participePrésent, expected: "mangEant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["mange", "mangEons", "mangez"] {
      T.testConjugation(infinitif: "manger", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
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

  func testJeter() {
    var personNumbersIndex = 0

    for conjugation in ["jetTe", "jetTes", "jetTe", "jetons", "jetez", "jetTent"] {
      T.testConjugation(infinitif: "jeter", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["jetais", "jetais", "jetait", "jetions", "jetiez", "jetaient"] {
      T.testConjugation(infinitif: "jeter", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["jetTerai", "jetTeras", "jetTera", "jetTerons", "jetTerez", "jetTeront"] {
      T.testConjugation(infinitif: "jeter", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["jetTerais", "jetTerais", "jetTerait", "jetTerions", "jetTeriez", "jetTeraient"] {
      T.testConjugation(infinitif: "jeter", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["jetai", "jetas", "jeta", "jetâmes", "jetâtes", "jetèrent"] {
      T.testConjugation(infinitif: "jeter", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["jetTe", "jetTes", "jetTe", "jetions", "jetiez", "jetTent"] {
      T.testConjugation(infinitif: "jeter", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["jetasse", "jetasses", "jetât", "jetassions", "jetassiez", "jetassent"] {
      T.testConjugation(infinitif: "jeter", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "jeter", tense: .participePassé, expected: "jeté")
    T.testConjugation(infinitif: "jeter", tense: .participePrésent, expected: "jetant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["jetTe", "jetons", "jetez"] {
      T.testConjugation(infinitif: "jeter", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testPeser() {
    var personNumbersIndex = 0

    for conjugation in ["pÈse", "pÈses", "pÈse", "pesons", "pesez", "pÈsent"] {
      T.testConjugation(infinitif: "peser", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["pesais", "pesais", "pesait", "pesions", "pesiez", "pesaient"] {
      T.testConjugation(infinitif: "peser", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["pÈserai", "pÈseras", "pÈsera", "pÈserons", "pÈserez", "pÈseront"] {
      T.testConjugation(infinitif: "peser", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["pÈserais", "pÈserais", "pÈserait", "pÈserions", "pÈseriez", "pÈseraient"] {
      T.testConjugation(infinitif: "peser", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["pesai", "pesas", "pesa", "pesâmes", "pesâtes", "pesèrent"] {
      T.testConjugation(infinitif: "peser", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["pÈse", "pÈses", "pÈse", "pesions", "pesiez", "pÈsent"] {
      T.testConjugation(infinitif: "peser", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["pesasse", "pesasses", "pesât", "pesassions", "pesassiez", "pesassent"] {
      T.testConjugation(infinitif: "peser", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "peser", tense: .participePassé, expected: "pesé")
    T.testConjugation(infinitif: "peser", tense: .participePrésent, expected: "pesant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["pÈse", "pesons", "pesez"] {
      T.testConjugation(infinitif: "peser", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testCéder() {
    var personNumbersIndex = 0

    for conjugation in ["cÈde", "cÈdes", "cÈde", "cédons", "cédez", "cÈdent"] {
      T.testConjugation(infinitif: "céder", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["cédais", "cédais", "cédait", "cédions", "cédiez", "cédaient"] {
      T.testConjugation(infinitif: "céder", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["céderai", "céderas", "cédera", "céderons", "céderez", "céderont"] {
      T.testConjugation(infinitif: "céder", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["céderais", "céderais", "céderait", "céderions", "céderiez", "céderaient"] {
      T.testConjugation(infinitif: "céder", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["cédai", "cédas", "céda", "cédâmes", "cédâtes", "cédèrent"] {
      T.testConjugation(infinitif: "céder", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["cÈde", "cÈdes", "cÈde", "cédions", "cédiez", "cÈdent"] {
      T.testConjugation(infinitif: "céder", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["cédasse", "cédasses", "cédât", "cédassions", "cédassiez", "cédassent"] {
      T.testConjugation(infinitif: "céder", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "céder", tense: .participePassé, expected: "cédé")
    T.testConjugation(infinitif: "céder", tense: .participePrésent, expected: "cédant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["cÈde", "cédons", "cédez"] {
      T.testConjugation(infinitif: "céder", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testDépecer() {
    var personNumbersIndex = 0

    for conjugation in ["dépÈce", "dépÈces", "dépÈce", "dépeÇons", "dépecez", "dépÈcent"] {
      T.testConjugation(infinitif: "dépecer", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["dépeÇais", "dépeÇais", "dépeÇait", "dépeCions", "dépeCiez", "dépeÇaient"] {
      T.testConjugation(infinitif: "dépecer", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["dépÈcerai", "dépÈceras", "dépÈcera", "dépÈcerons", "dépÈcerez", "dépÈceront"] {
      T.testConjugation(infinitif: "dépecer", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["dépÈcerais", "dépÈcerais", "dépÈcerait", "dépÈcerions", "dépÈceriez", "dépÈceraient"] {
      T.testConjugation(infinitif: "dépecer", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["dépeÇai", "dépeÇas", "dépeÇa", "dépeÇâmes", "dépeÇâtes", "dépecèrent"] {
      T.testConjugation(infinitif: "dépecer", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["dépÈce", "dépÈces", "dépÈce", "dépeCions", "dépeCiez", "dépÈcent"] {
      T.testConjugation(infinitif: "dépecer", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["dépeÇasse", "dépeÇasses", "dépeÇât", "dépeÇassions", "dépeÇassiez", "dépeÇassent"] {
      T.testConjugation(infinitif: "dépecer", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "dépecer", tense: .participePassé, expected: "dépecé")
    T.testConjugation(infinitif: "dépecer", tense: .participePrésent, expected: "dépeÇant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["dépÈce", "dépeÇons", "dépecez"] {
      T.testConjugation(infinitif: "dépecer", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testRapiécer() {
    var personNumbersIndex = 0

    for conjugation in ["rapiÈce", "rapiÈces", "rapiÈce", "rapiéÇons", "rapiécez", "rapiÈcent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["rapiéÇais", "rapiéÇais", "rapiéÇait", "rapiéCions", "rapiéCiez", "rapiéÇaient"] {
      T.testConjugation(infinitif: "rapiécer", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["rapiécerai", "rapiéceras", "rapiécera", "rapiécerons", "rapiécerez", "rapiéceront"] {
      T.testConjugation(infinitif: "rapiécer", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["rapiécerais", "rapiécerais", "rapiécerait", "rapiécerions", "rapiéceriez", "rapiéceraient"] {
      T.testConjugation(infinitif: "rapiécer", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["rapiéÇai", "rapiéÇas", "rapiéÇa", "rapiéÇâmes", "rapiéÇâtes", "rapiécèrent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["rapiÈce", "rapiÈces", "rapiÈce", "rapiéCions", "rapiéCiez", "rapiÈcent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["rapiéÇasse", "rapiéÇasses", "rapiéÇât", "rapiéÇassions", "rapiéÇassiez", "rapiéÇassent"] {
      T.testConjugation(infinitif: "rapiécer", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "rapiécer", tense: .participePassé, expected: "rapiécé")
    T.testConjugation(infinitif: "rapiécer", tense: .participePrésent, expected: "rapiéÇant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["rapiÈce", "rapiéÇons", "rapiécez"] {
      T.testConjugation(infinitif: "rapiécer", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testProtéger() {
    var personNumbersIndex = 0

    for conjugation in ["protÈge", "protÈges", "protÈge", "protégEons", "protégez", "protÈgent"] {
      T.testConjugation(infinitif: "protéger", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["protégEais", "protégEais", "protégEait", "protégions", "protégiez", "protégEaient"] {
      T.testConjugation(infinitif: "protéger", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["protégerai", "protégeras", "protégera", "protégerons", "protégerez", "protégeront"] {
      T.testConjugation(infinitif: "protéger", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["protégerais", "protégerais", "protégerait", "protégerions", "protégeriez", "protégeraient"] {
      T.testConjugation(infinitif: "protéger", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["protégEai", "protégEas", "protégEa", "protégEâmes", "protégEâtes", "protégèrent"] {
      T.testConjugation(infinitif: "protéger", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["protÈge", "protÈges", "protÈge", "protégions", "protégiez", "protÈgent"] {
      T.testConjugation(infinitif: "protéger", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["protégEasse", "protégEasses", "protégEât", "protégEassions", "protégEassiez", "protégEassent"] {
      T.testConjugation(infinitif: "protéger", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "protéger", tense: .participePassé, expected: "protégé")
    T.testConjugation(infinitif: "protéger", tense: .participePrésent, expected: "protégEant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["protÈge", "protégEons", "protégez"] {
      T.testConjugation(infinitif: "protéger", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
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

  func testAssaillir() {
    var personNumbersIndex = 0

    for conjugation in ["assaillE", "assaillES", "assaillE", "assaillONS", "assaillEZ", "assaillENT"] {
      T.testConjugation(infinitif: "assaillir", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["assaillais", "assaillais", "assaillait", "assaillions", "assailliez", "assaillaient"] {
      T.testConjugation(infinitif: "assaillir", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["assaillirai", "assailliras", "assaillira", "assaillirons", "assaillirez", "assailliront"] {
      T.testConjugation(infinitif: "assaillir", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["assaillirais", "assaillirais", "assaillirait", "assaillirions", "assailliriez", "assailliraient"] {
      T.testConjugation(infinitif: "assaillir", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["assaillis", "assaillis", "assaillit", "assaillîmes", "assaillîtes", "assaillirent"] {
      T.testConjugation(infinitif: "assaillir", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["assaille", "assailles", "assaille", "assaillions", "assailliez", "assaillent"] {
      T.testConjugation(infinitif: "assaillir", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["assaillisse", "assaillisses", "assaillît", "assaillissions", "assaillissiez", "assaillissent"] {
      T.testConjugation(infinitif: "assaillir", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "assaillir", tense: .participePassé, expected: "assailli")
    T.testConjugation(infinitif: "assaillir", tense: .participePrésent, expected: "assaillant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["assaillE", "assaillONS", "assaillEZ"] {
      T.testConjugation(infinitif: "assaillir", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testCueillir() {
    var personNumbersIndex = 0

    for conjugation in ["cueillE", "cueillES", "cueillE", "cueillONS", "cueillEZ", "cueillENT"] {
      T.testConjugation(infinitif: "cueillir", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["cueillais", "cueillais", "cueillait", "cueillions", "cueilliez", "cueillaient"] {
      T.testConjugation(infinitif: "cueillir", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["cueillErai", "cueillEras", "cueillEra", "cueillErons", "cueillErez", "cueillEront"] {
      T.testConjugation(infinitif: "cueillir", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["cueillErais", "cueillErais", "cueillErait", "cueillErions", "cueillEriez", "cueillEraient"] {
      T.testConjugation(infinitif: "cueillir", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["cueillis", "cueillis", "cueillit", "cueillîmes", "cueillîtes", "cueillirent"] {
      T.testConjugation(infinitif: "cueillir", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["cueille", "cueilles", "cueille", "cueillions", "cueilliez", "cueillent"] {
      T.testConjugation(infinitif: "cueillir", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["cueillisse", "cueillisses", "cueillît", "cueillissions", "cueillissiez", "cueillissent"] {
      T.testConjugation(infinitif: "cueillir", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "cueillir", tense: .participePassé, expected: "cueilli")
    T.testConjugation(infinitif: "cueillir", tense: .participePrésent, expected: "cueillant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["cueillE", "cueillONS", "cueillEZ"] {
      T.testConjugation(infinitif: "cueillir", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count
    }
  }

  func testBouillir() {
    var personNumbersIndex = 0

    for conjugation in ["bouS", "bouS", "bouT", "bouillONS", "bouillEZ", "bouillENT"] {
      T.testConjugation(infinitif: "bouillir", tense: .indicatifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["bouillais", "bouillais", "bouillait", "bouillions", "bouilliez", "bouillaient"] {
      T.testConjugation(infinitif: "bouillir", tense: .imparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["bouillirai", "bouilliras", "bouillira", "bouillirons", "bouillirez", "bouilliront"] {
      T.testConjugation(infinitif: "bouillir", tense: .futurSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["bouillirais", "bouillirais", "bouillirait", "bouillirions", "bouilliriez", "bouilliraient"] {
      T.testConjugation(infinitif: "bouillir", tense: .conditionnelPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["bouillis", "bouillis", "bouillit", "bouillîmes", "bouillîtes", "bouillirent"] {
      T.testConjugation(infinitif: "bouillir", tense: .passéSimple(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["bouille", "bouilles", "bouille", "bouillions", "bouilliez", "bouillent"] {
      T.testConjugation(infinitif: "bouillir", tense: .subjonctifPrésent(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    for conjugation in ["bouillisse", "bouillisses", "bouillît", "bouillissions", "bouillissiez", "bouillissent"] {
      T.testConjugation(infinitif: "bouillir", tense: .subjonctifImparfait(T.personNumbers[personNumbersIndex]), expected: conjugation)
      personNumbersIndex += 1
      personNumbersIndex %= T.personNumbers.count
    }

    T.testConjugation(infinitif: "bouillir", tense: .participePassé, expected: "bouilli")
    T.testConjugation(infinitif: "bouillir", tense: .participePrésent, expected: "bouillant")

    var impératifPersonNumbersIndex = 0

    for conjugation in ["bouillE", "bouillONS", "bouillEZ"] {
      T.testConjugation(infinitif: "bouillir", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)
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
