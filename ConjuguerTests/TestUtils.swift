//
//  TestUtils.swift
//  ConjuguerTests
//
//  Created by Joshua Adams on 1/13/21.
//

@testable import Conjuguer
import XCTest

enum T {
  static let personNumbers: [PersonNumber] = [.firstSingular, .secondSingular, .thirdSingular, .firstPlural, .secondPlural, .thirdPlural]
  static let impératifPersonNumbers: [PersonNumber] = [.secondSingular, .firstPlural, .secondPlural]

  static func conjugate(infinitif: String, tense: Tense) -> String {
    let result = Conjugator.conjugate(infinitif: infinitif, tense: tense)
    switch result {
    case .success(let value):
      return value
    case .failure:
      fatalError("Conjugation failed.")
    }
  }

  static func testConjugation(infinitif: String, tense: Tense, expected: String) {
    let result = Conjugator.conjugate(infinitif: infinitif, tense: tense)
    switch result {
    case .success(let value):
      XCTAssertEqual(expected, value)
    case .failure:
      XCTFail("Conjugation failed. Expected: \(expected)")
    }
  }

  static func generateVerbModelTests() {
    let firstPart = """
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
"""
    print(firstPart)

    let models = ["parler", "lancer", "manger", "appeler", "jeter", "peser", "céder", "dépecer", "rapiécer", "finir", "couvrir", "assaillir", "cueillir", "bouillir", "être", "avoir", "aller"]

    for model in models {
      var output = "  func test" + model.capitalizingFirstLetter() + "() {\n    var personNumbersIndex = 0\n\n"
      for tense in ["indicatifPrésent", "imparfait", "futurSimple", "conditionnelPrésent", "passéSimple", "subjonctifPrésent", "subjonctifImparfait"] {
        output += "    for conjugation in ["
        for personNumber in personNumbers {
          let conjugation = T.conjugate(infinitif: model, tense: Tense.fromString(tense, personNumber: personNumber))
          output += "\"" + conjugation + "\""
          if personNumber == .thirdPlural {
            output += "] {\n"
          } else {
            output += ", "
          }
        }

        output += "      T.testConjugation(infinitif: \"" + model + "\", tense: ." + tense + "(T.personNumbers[personNumbersIndex]), expected: conjugation)\n"
        output += "      personNumbersIndex += 1\n"
        output += "      personNumbersIndex %= T.personNumbers.count\n"
        output += "    }\n\n"
      }

      for tense in ["participePassé", "participePrésent"] {
        let conjugation = T.conjugate(infinitif: model, tense: Tense.fromString(tense, personNumber: .firstSingular))
        output += "    T.testConjugation(infinitif: \"" + model + "\", tense: ." + tense + ", expected: \"\(conjugation)\")\n"
      }

      output += "\n    var impératifPersonNumbersIndex = 0\n\n"
      output += "    for conjugation in ["
      for personNumber in impératifPersonNumbers {
        let conjugation = T.conjugate(infinitif: model, tense: .impératif(personNumber))
        output += "\"" + conjugation + "\""
        if personNumber == .secondPlural {
          output += "] {\n"
        } else {
          output += ", "
        }
      }

      output += "      T.testConjugation(infinitif: \"" + model + "\", tense: .impératif(T.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation)\n"
      output += "      impératifPersonNumbersIndex += 1\n"
      output += "      impératifPersonNumbersIndex %= T.impératifPersonNumbers.count\n"
      output += "    }\n"

      output += "  }"
      if model != models[models.count - 1] {
        output += "\n"
      }
      print(output)
    }
    print("}")
  }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}

extension Tense {
  static func fromString(_ string: String, personNumber: PersonNumber) -> Tense {
    switch string {
    case "indicatifPrésent":
      return .indicatifPrésent(personNumber)
    case "passéSimple":
      return .passéSimple(personNumber)
    case "imparfait":
      return .imparfait(personNumber)
    case "futurSimple":
      return .futurSimple(personNumber)
    case "conditionnelPrésent":
      return .conditionnelPrésent(personNumber)
    case "subjonctifPrésent":
      return .subjonctifPrésent(personNumber)
    case "subjonctifImparfait":
      return .subjonctifImparfait(personNumber)
    case "participePassé":
      return .participePassé
    case "participePrésent":
      return .participePrésent
    default:
      fatalError("Invalid fromString \(string).")
    }
  }
}
