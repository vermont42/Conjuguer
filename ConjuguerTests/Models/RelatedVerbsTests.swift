//
//  RelatedVerbsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct RelatedVerbsTests {
  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  @Test(arguments: [
    ("apprendre", "prendre"),
    ("comprendre", "prendre"),
    ("surprendre", "prendre"),
    ("devenir", "venir"),
    ("convenir", "venir"),
    ("souvenir", "venir"),
    ("obtenir", "tenir"),
    ("maintenir", "tenir"),
    ("soumettre", "mettre"),
    ("rappeler", "appeler"),
    ("ressortir", "sortir"),
    ("dessécher", "sécher"),
    ("réunir", "unir"),
    ("décrire", "écrire"),
    ("satisfaire", "faire"),
    ("redécouvrir", "découvrir"),
    ("allier", "lier"),
    ("advenir", "venir")
  ])
  func testKnownPairsFindTheirBase(verb: String, base: String) {
    #expect(VerbBase.base(of: verb) == base)
  }

  @Test(arguments: [
    "oublier",
    "avoir", "devoir", "répondre", "ajouter", "connaître", "atteindre", "accorder", "souligner",
    "arriver", "considérer", "supplier", "délibérer", "épisser", "encastrer", "asservir",
    "prendre", "parler"
  ])
  func testFalsePairsAndPlainVerbsFindNoBase(verb: String) {
    #expect(VerbBase.base(of: verb) == nil)
  }

  /// The base rule reads the etymology in the interface's language, so a reworded etymology in one
  /// language could change a verb's relatives, and the widget's draw, on that language's devices.
  @Test func testTheBaseRuleGivesTheSameAnswerInEnglishAndFrench() throws {
    let english = try #require(Etymology.texts(in: "en"))
    let french = try #require(Etymology.texts(in: "fr"))
    var differences: [String] = []
    for infinitif in Set(Verb.verbs.values.map(\.infinitif)) {
      let englishBase = VerbBase.base(of: infinitif) { english[$0] }
      let frenchBase = VerbBase.base(of: infinitif) { french[$0] }
      if englishBase != frenchBase {
        differences.append("\(infinitif): \(englishBase ?? "none") in English, \(frenchBase ?? "none") in French")
      }
    }
    #expect(differences.isEmpty, "\(differences.sorted().joined(separator: "; "))")
  }

  @Test func testEveryFalsePairWouldOtherwisePass() {
    for pair in VerbBase.falsePairs {
      #expect(Etymology.text(for: pair.verb)?.contains("~\(pair.base)~") == true, "\(pair.verb) no longer names \(pair.base); drop the pair")
    }
  }

  @Test func testEveryKnownPairIsAPrefixAndABase() {
    for pair in VerbBase.knownPairs {
      #expect(VerbBase.base(of: pair.verb) == pair.base)
    }
  }

  @Test func testRootsFollowNestedBases() {
    #expect(VerbBase.root(of: "redécouvrir") == "couvrir")
    #expect(VerbBase.root(of: "compromettre") == "mettre")
    #expect(VerbBase.root(of: "réapprendre") == "prendre")
    #expect(VerbBase.root(of: "venir") == "venir")
  }

  @Test func testADerivativeListsItsRootFirstThenByFrequency() throws {
    let related = try verb("apprendre").related
    let infinitives = related.builtOnRoot.map(\.infinitif)
    #expect(related.root == "prendre")
    #expect(infinitives.first == "prendre")
    #expect(infinitives.contains("comprendre"))
    #expect(infinitives.contains("réapprendre"))
    #expect(!infinitives.contains("apprendre"))
    let frequencies = related.builtOnRoot.dropFirst().map(\.frequency)
    #expect(frequencies == frequencies.sorted())
  }

  @Test func testARootListsItsDerivativesWithoutItself() throws {
    let infinitives = try verb("venir").related.builtOnRoot.map(\.infinitif)
    #expect(infinitives.prefix(3) == ["devenir", "revenir", "intervenir"])
    #expect(!infinitives.contains("venir"))
    #expect(Set(infinitives).isSuperset(of: ["convenir", "souvenir", "prévenir", "redevenir"]))
  }

  @Test func testModelRelativesShowOneVerbForEachOtherRoot() throws {
    let venir = try verb("venir").related
    let relatives = venir.modelRelatives.map(\.infinitif)
    #expect(relatives.first == "tenir")
    #expect(!relatives.contains { $0.hasSuffix("venir") })
    #expect(!relatives.contains("obtenir"))

    let parler = try verb("parler").related
    #expect(parler.modelRelatives.count == RelatedVerbs.shortListLength)
    #expect(Set(parler.modelRelatives.map(\.root)).count == parler.modelRelatives.count)
  }

  @Test func testAModelHoldingOnlyOneFamilyShowsNoModelRelatives() throws {
    #expect(try verb("apprendre").related.modelRelatives.isEmpty)
  }

  @Test func testADoubledRootShowsTheEntryThatSharesTheModel() throws {
    let ressortir = try verb("ressortir").related.builtOnRoot
    #expect(ressortir.first?.id == "sortir (exit)")
    #expect(ressortir.filter { $0.infinitif == "sortir" }.count == 1)

    let assortir = try verb("assortir").related.builtOnRoot
    #expect(assortir.first?.id == "sortir (obtain)")
  }

  @Test func testModelVerbListSortsBothWays() throws {
    let model = try #require(VerbModel.models["1-1"])
    let alphabetical = String(model.verbsWithDeepLinks(order: .alphabetical).characters)
    let frequency = String(model.verbsWithDeepLinks(order: .frequency).characters)
    #expect(alphabetical.hasPrefix("abaisser, abandonner"))
    let écouter = try #require(alphabetical.range(of: "écouter"))
    let zozoter = try #require(alphabetical.range(of: "zozoter"))
    #expect(écouter.lowerBound < zozoter.lowerBound)
    #expect(frequency.hasPrefix("donner, trouver, passer"))
  }
}
