//
//  FuturStemsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct FuturStemsTests {
  @Test func testRegularReFuturStemTrimsTrailingE() {
    let model = VerbModel.model(id: Verb.verbs["vendre"]!.model)
    #expect(model.futurStemsRecursive(infinitif: "vendre") == ["vendr"])
  }

  @Test func testPayerHasTwoFuturStems() {
    let model = VerbModel.model(id: Verb.verbs["payer"]!.model)
    #expect(model.futurStemsRecursive(infinitif: "payer") == ["payer", "paIer"])
  }
}
