//
//  FuturStemsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import XCTest

@MainActor
class FuturStemsTests: XCTestCase {
  func testRegularReFuturStemTrimsTrailingE() {
    let model = VerbModel.model(id: Verb.verbs["vendre"]!.model)
    XCTAssertEqual(model.futurStemsRecursive(infinitif: "vendre"), ["vendr"])
  }

  func testPayerHasTwoFuturStems() {
    let model = VerbModel.model(id: Verb.verbs["payer"]!.model)
    XCTAssertEqual(model.futurStemsRecursive(infinitif: "payer"), ["payer", "paIer"])
  }
}
