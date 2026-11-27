//
//  VerbOrderTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/27/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct VerbOrderTests {
  private func haïr() throws -> (france: Verb, québec: Verb) {
    (try #require(Verb.verbs["haïr France"]), try #require(Verb.verbs["haïr Québec"]))
  }

  private func haïrModels() throws -> (france: VerbModel, québec: VerbModel) {
    (try #require(VerbModel.models["2-3A"]), try #require(VerbModel.models["2-3B"]))
  }

  // Verb.verbs.values comes in an order that changes with each launch's hash seed, so a sort
  // that compared the infinitive alone kept the doubled entries in whatever order it was given.
  @Test(arguments: VerbSort.allCases)
  func aDoubledInfinitiveKeepsItsOrderWhateverTheInput(order: VerbSort) throws {
    let (france, québec) = try haïr()
    #expect([france, québec].sorted(by: order.areInIncreasingOrder).map(\.id) == ["haïr (France)", "haïr (Québec)"])
    #expect([québec, france].sorted(by: order.areInIncreasingOrder).map(\.id) == ["haïr (France)", "haïr (Québec)"])
  }

  @Test func haïrsModelsKeepTheirOrderWhateverTheInput() throws {
    let (france, québec) = try haïrModels()
    for comparator in [VerbModel.alphabetically, VerbModel.byIrregularity] {
      #expect([france, québec].sorted(by: comparator).map(\.id) == ["2-3A", "2-3B"])
      #expect([québec, france].sorted(by: comparator).map(\.id) == ["2-3A", "2-3B"])
    }
  }

  @Test func theAlphabeticalOrderIsFrench() throws {
    let verbs = try ["zozoter", "écouter", "effacer", "ébaucher"].map { try #require(Verb.verbs[$0]) }
    #expect(verbs.sorted(by: Verb.alphabetically).map(\.infinitif) == ["ébaucher", "écouter", "effacer", "zozoter"])
  }

  @Test func everyListOfAllVerbsAgrees() {
    let alphabetical = Verb.verbs.values.sorted(by: Verb.alphabetically)
    #expect(Verb.verbs.values.shuffled().sorted(by: Verb.alphabetically) == alphabetical)
    #expect(Verb.verbs.values.shuffled().sorted(by: Verb.byFrequency) == Verb.verbsByFrequency)
  }

  // The two haïr rows of the verb list and of the Models tab were each verb_row_haïr and
  // model_row_haïr, so a script could reach only the first.
  @Test func aDoubledInfinitivesRowsHaveTheirOwnIdentifiers() throws {
    let (france, québec) = try haïr()
    #expect(VerbBrowseView.rowIdentifier(france) != VerbBrowseView.rowIdentifier(québec))
    let (franceModel, québecModel) = try haïrModels()
    #expect(ModelBrowseView.rowIdentifier(franceModel) != ModelBrowseView.rowIdentifier(québecModel))
  }
}
