//
//  KeyConjugationsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct KeyConjugationsTests {
  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  @Test(arguments: [
    ("aller", ["va", "est allé", "ira"]),
    ("venir", ["vient", "est venu", "viendra"]),
    ("parler", ["parle", "a parlé", "parlera"]),
    ("avoir", ["a", "a eu", "aura"]),
    ("être", ["est", "a été", "sera"]),
    ("naître", ["naît", "est né", "naîtra"]),
    ("prendre", ["prend", "a pris", "prendra"]),
    ("sortir exit", ["sort", "est sorti", "sortira"]),
    ("souvenir", ["se souvient", "s'est souvenu", "se souviendra"]),
    ("évanouir", ["s'évanouit", "s'est évanoui", "s'évanouira"]),
    ("falloir", ["faut", "a fallu", "faudra"]),
    ("gésir", ["gît"]),
    ("accroire", [])
  ])
  func testKeyConjugations(key: String, expected: [String]) throws {
    let actual = try verb(key).keyConjugations().map { $0.lowercased() }

    #expect(actual == expected)
  }

  @Test func testKeyConjugationsMarkRedLetters() throws {
    let conjugations = try verb("aller").keyConjugations()

    #expect(conjugations.count == 3)
    #expect(conjugations.allSatisfy { $0.contains(where: \.isUppercase) })
    #expect(try verb("parler").keyConjugations().first == "parle")
  }

  @Test func testThePastParticipleAgreesWithIlWhateverThePronounGenderSetting() throws {
    #expect(Current.settings.pronounGender != .masculine)
    #expect(try verb("venir").keyConjugations()[1].lowercased() == "est venu")
  }

  @Test(arguments: [
    ("souvenir", "se souvenir"),
    ("évanouir", "s'évanouir"),
    ("aller", "aller"),
    ("haïr France", "haïr")
  ])
  func testCitationInfinitif(key: String, expected: String) throws {
    #expect(try verb(key).citationInfinitif == expected)
  }

  @Test func testShareTextNamesTheVerbItsGlossItsConjugationsAndTheAppStore() throws {
    let aller = try verb("aller")
    let text = aller.shareText()

    #expect(text.hasPrefix("aller"))
    #expect(text.contains(aller.translation))
    #expect(text.contains("va · est allé · ira"))
    #expect(text.hasSuffix("https://apps.apple.com/app/conjuguer/id1588624373"))
    #expect(!text.contains("conjuguer://"))
  }

  @Test func testShareTextCitesAReflexiveVerbWithItsPronoun() throws {
    let text = try verb("souvenir").shareText()

    #expect(text.hasPrefix("se souvenir"))
    #expect(text.contains("se souvient · s'est souvenu · se souviendra"))
  }

  @Test func testShareTextOfAVerbWithNoUsedFormsHasNoConjugationLine() throws {
    let lines = try verb("accroire").shareText().components(separatedBy: "\n")

    #expect(lines.count == 4)
    #expect(lines[1].isEmpty)
  }

  @Test func testCopyTextIsTheFormInLowercase() throws {
    let aller = try verb("aller")
    let cell = VerbConjugations.cell(verb: aller, tense: .indicatifPrésent(.firstSingular), id: 0, pronounGender: .feminine)

    #expect(cell.copyText == "vais")
    #expect(VerbConjugations.cell(verb: aller, tense: .passéComposé(.firstSingular), id: 0, pronounGender: .feminine).copyText?.hasPrefix("suis all") == true)
  }

  @Test func testAppStoreURLHasNoStorefront() {
    #expect(URL.appStore.absoluteString == "https://apps.apple.com/app/conjuguer/id1588624373")
  }
}
