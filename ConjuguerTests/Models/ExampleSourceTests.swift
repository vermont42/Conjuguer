//
//  ExampleSourceTests.swift
//  ConjuguerTests
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct ExampleSourceTests {
  @Test(arguments: [
    ("wiktionnaire|Honoré de Balzac|Le Père Goriot|1835", ExampleSource.wiktionnaire(author: "Honoré de Balzac", title: "Le Père Goriot", year: "1835")),
    ("wiktionnaire|Voltaire||", ExampleSource.wiktionnaire(author: "Voltaire", title: nil, year: nil)),
    ("wiktionnaire|Stendhal|Le Rouge et le Noir|", ExampleSource.wiktionnaire(author: "Stendhal", title: "Le Rouge et le Noir", year: nil)),
    ("wiktionary|Victor Hugo|Les Misérables|1862", ExampleSource.wiktionaryQuotation(author: "Victor Hugo", title: "Les Misérables", year: "1862")),
    ("wiktionary", ExampleSource.wiktionaryExample),
    ("Claude (Sonnet 5)", ExampleSource.claude(model: "Claude (Sonnet 5)")),
    ("zola-lassommoir-1877.txt", ExampleSource.zola)
  ])
  func testRawSourceParses(raw: String, expected: ExampleSource) {
    #expect(ExampleSource(rawSource: raw) == expected)
  }

  @Test func testWiktionnaireAttributionCarriesTheCitation() {
    let attribution = ExampleSource(rawSource: "wiktionnaire|Honoré de Balzac|Le Père Goriot|1835").attribution
    #expect(attribution.contains("Honoré de Balzac, « Le Père Goriot » (1835)"))
  }

  @Test func testTitleWithItsOwnGuillemetsIsNotWrappedAgain() {
    let attribution = ExampleSource(rawSource: "wiktionnaire|Charles Baudelaire|« Le Serpent qui danse » dans Les Fleurs du mal|").attribution
    #expect(attribution.contains("Charles Baudelaire, « Le Serpent qui danse » dans Les Fleurs du mal"))
    #expect(!attribution.contains("« «"))
  }

  @Test func testEveryShippedExampleHasAKnownSource() throws {
    let url = try #require(Bundle.main.url(forResource: "literature_examples", withExtension: "json"))
    let examples = try JSONDecoder().decode([String: Example].self, from: Data(contentsOf: url))
    #expect(examples.count > 5_000)
    let unknown = examples.filter {
      if case .other = $0.value.provenance {
        return true
      }
      return false
    }
    #expect(unknown.isEmpty, "Unrecognized sources: \(unknown.map(\.value.source).sorted().prefix(5))")
  }
}
