//
//  TestUtils.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 1/13/21.
//

@testable import Conjuguer
import XCTest

enum T {
  static func conjugate(infinitif: String, tense: Tense, extraLetters: String?) -> String {
    let result = Conjugator.conjugate(infinitif: infinitif, tense: tense, extraLetters: extraLetters)
    switch result {
    case .success(let value):
      return value
    case .failure:
      fatalError("Conjugation failed.")
    }
  }

  static func testConjugation(infinitif: String, tense: Tense, expected: String, extraLetters: String?) {
    let result = Conjugator.conjugate(infinitif: infinitif, tense: tense, extraLetters: extraLetters)
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
"""
    print(firstPart)

    var completedTestCount = 0

    let models = Array(VerbModel.models.values).sorted(by: { lhs, rhs in
        lhs.exemplar.caseInsensitiveCompare(rhs.exemplar) == .orderedAscending
      }
    )

    for model in models {
      var output = "  func test" + model.exemplar.capitalizingFirstLetter() + (model.extraLetters?.replacingOccurrences(of: ".", with: "").capitalizingFirstLetter() ?? "") + "() {\n    // ID: \(model.id)\n    var personNumbersIndex = 0\n\n"
      let extraLettersComponent: String
      if let extraLetters = model.extraLetters {
        extraLettersComponent = "\"\(extraLetters)\""
      } else {
        extraLettersComponent = "nil"
      }
      let extraLettersArg = ", extraLetters: " + extraLettersComponent
      for tense in ["indicatifPrésent", "imparfait", "futurSimple", "conditionnelPrésent", "passéSimple", "subjonctifPrésent", "subjonctifImparfait"] {
        output += "    for conjugation in ["
        for personNumber in PersonNumber.allCases {
          let conjugation = T.conjugate(infinitif: model.exemplar, tense: Tense.fromString(tense, personNumber: personNumber), extraLetters: model.extraLetters)
          output += "\"" + conjugation + "\""
          if personNumber == .thirdPlural {
            output += "] {\n"
          } else {
            output += ", "
          }
        }

        output += "      T.testConjugation(infinitif: \"" + model.exemplar + "\", tense: ." + tense + "(PersonNumber.allCases[personNumbersIndex]), expected: conjugation\(extraLettersArg))\n"
        output += "      personNumbersIndex += 1\n"
        output += "      personNumbersIndex %= PersonNumber.allCases.count\n"
        output += "    }\n\n"
      }

      for tense in ["participePassé", "participePrésent"] {
        let conjugation = T.conjugate(infinitif: model.exemplar, tense: Tense.fromString(tense, personNumber: .firstSingular), extraLetters: model.extraLetters)
        output += "    T.testConjugation(infinitif: \"" + model.exemplar + "\", tense: ." + tense + ", expected: \"\(conjugation)\"\(extraLettersArg))\n"
      }

      output += "\n    var impératifPersonNumbersIndex = 0\n\n"
      output += "    for conjugation in ["
      for personNumber in PersonNumber.impératifPersonNumbers {
        let conjugation = T.conjugate(infinitif: model.exemplar, tense: .impératif(personNumber), extraLetters: model.extraLetters)
        output += "\"" + conjugation + "\""
        if personNumber == .secondPlural {
          output += "] {\n"
        } else {
          output += ", "
        }
      }

      output += "      T.testConjugation(infinitif: \"" + model.exemplar + "\", tense: .impératif(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation\(extraLettersArg))\n"
      output += "      impératifPersonNumbersIndex += 1\n"
      output += "      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count\n"
      output += "    }\n"

      output += "  }"
      completedTestCount += 1
      if completedTestCount < VerbModel.models.count {
        output += "\n"
      }
      print(output)
    }
    print("}")
  }
}

extension String {
    func capitalizingFirstLetter() -> String {
      prefix(1).capitalized + dropFirst()
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
