//
//  ConjuguerTests.swift
//  ConjuguerTests
//
//  Created by Joshua Adams on 1/1/21.
//

@testable import Conjuguer
import XCTest

class ConjuguerTests: XCTestCase {
  func testConjugations() {
    
  }

  private func conjugate(infinitif: String, tense: Tense, expected: String) {
    let result = Conjugator.conjugate(infinitif: infinitif, tense: tense)
    switch result {
    case .success(let value):
      XCTAssertEqual(expected, value)
    case .failure(_):
      XCTFail("Conjugation failed.")
    }
  }
}
