//
//  StandardVariantsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct StandardVariantsTests {
  private func variants(_ infinitif: String, _ tense: Tense) throws -> [String] {
    let verb = try #require(Verb.verbs[infinitif])
    let conjugations = try #require(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: .feminine))
    return conjugations
      .components(separatedBy: Tense.alternateConjugationSeparator)
      .flatMap { StandardVariants.variants(of: $0.lowercased(), verb: verb, tense: tense) }
  }

  @Test(arguments: [
    ("connaître", Tense.indicatifPrésent(.thirdSingular), "connait"),
    ("connaître", .futurSimple(.firstSingular), "connaitrai"),
    ("plaire", .indicatifPrésent(.thirdSingular), "plait"),
    ("gésir", .indicatifPrésent(.thirdSingular), "git"),
    ("accroître", .indicatifPrésent(.thirdSingular), "accroit"),
    ("mouvoir", .participePassé, "mu"),
    ("mouvoir", .passéComposé(.firstSingular), "ai mu"),
    ("redevoir", .participePassé, "redu"),
    ("traîner", .indicatifPrésent(.firstSingular), "traine"),
    ("traîner", .passéSimple(.firstPlural), "trainâmes"),
    ("étiqueter", .indicatifPrésent(.firstSingular), "étiquète"),
    ("étiqueter", .futurSimple(.thirdSingular), "étiquètera"),
    ("amonceler", .indicatifPrésent(.firstSingular), "amoncèle"),
    ("ruisseler", .conditionnelPrésent(.thirdPlural), "ruisselleraient"),
    ("ensorceler", .indicatifPrésent(.firstSingular), "ensorcelle"),
    ("cacheter", .futurSimple(.firstSingular), "cachetterai"),
    ("pelleter", .indicatifPrésent(.thirdSingular), "pellète"),
    ("céder", .futurSimple(.firstSingular), "cèderai"),
    ("préférer", .conditionnelPrésent(.firstSingular), "préfèrerais"),
    ("régler", .conditionnelPrésent(.thirdPlural), "règleraient"),
    ("abréger", .futurSimple(.firstSingular), "abrègerai"),
    ("surseoir", .futurSimple(.firstSingular), "sursoirai"),
    ("absoudre", .participePassé, "absout"),
    ("dissoudre", .passéComposé(.thirdSingular), "a dissout"),
    ("interpeller", .indicatifPrésent(.firstPlural), "interpelons"),
    ("interpeller", .participePassé, "interpelé"),
    ("arguer", .indicatifPrésent(.firstSingular), "argüe"),
    ("caqueter", .indicatifPrésent(.thirdSingular), "caquette"),
    ("vouloir", .impératif(.firstPlural), "veuillons"),
    ("vouloir", .subjonctifPrésent(.secondPlural), "veuilliez"),
    ("éclore", .indicatifPrésent(.thirdSingular), "éclôt"),
    ("enclore", .indicatifPrésent(.thirdSingular), "enclôt")
  ])
  func acceptsVariant(infinitif: String, tense: Tense, variant: String) throws {
    #expect(try variants(infinitif, tense).contains(variant))
  }

  @Test(arguments: [
    ("venir", Tense.passéSimple(.firstPlural), "vinmes"),
    ("venir", .subjonctifImparfait(.thirdSingular), "vint"),
    ("être", .subjonctifImparfait(.thirdSingular), "fut"),
    ("dire", .passéSimple(.secondPlural), "dites"),
    ("avoir", .subjonctifPlusQueParfait(.thirdSingular), "eut parlé"),
    ("devoir", .participePassé, "du"),
    ("devoir", .passéComposé(.firstSingular), "ai du"),
    ("croître", .indicatifPrésent(.thirdSingular), "croit"),
    ("croître", .participePassé, "cru"),
    ("jeûner", .indicatifPrésent(.firstSingular), "jeune"),
    ("être", .indicatifPrésent(.secondPlural), "etes"),
    ("clore", .indicatifPrésent(.thirdSingular), "clot"),
    ("appeler", .indicatifPrésent(.firstSingular), "appèle"),
    ("rappeler", .futurSimple(.firstSingular), "rappèlerai"),
    ("jeter", .indicatifPrésent(.firstSingular), "jète"),
    ("projeter", .indicatifPrésent(.firstSingular), "projète"),
    ("interpeller", .indicatifPrésent(.firstSingular), "interpele"),
    ("interpeller", .futurSimple(.firstSingular), "interpelerai"),
    ("créer", .futurSimple(.firstSingular), "crèerai"),
    ("réserver", .futurSimple(.firstSingular), "rèserverai"),
    ("céder", .indicatifPrésent(.firstPlural), "cèdons"),
    ("harceler", .indicatifPrésent(.firstSingular), "harcelle"),
    ("acheter", .indicatifPrésent(.firstSingular), "achette"),
    ("geler", .futurSimple(.firstSingular), "gellerai"),
    ("vouloir", .indicatifPrésent(.firstPlural), "veuillons")
  ])
  func rejectsNonVariant(infinitif: String, tense: Tense, nonVariant: String) throws {
    #expect(try !variants(infinitif, tense).contains(nonVariant))
  }
}
