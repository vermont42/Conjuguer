//
//  ConjugationMapTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite("ConjugationMap")
enum ConjugationMapTests {
  @MainActor
  @Suite("The bundled map")
  struct Bundled {
    // The build phase regenerates the map when an XML file or the tool's executable is newer
    // than it. This catches what that dependency analysis misses: a source the Conjugator
    // depends on that the tool does not compile, so that the app and the map disagree.
    @Test func matchesAFreshBuild() {
      let bundled = ConjugationMap.bundled
      let fresh = ConjugationMap.build()
      let keys = Set(bundled.verbsByConjugation.keys).union(fresh.verbsByConjugation.keys)
      let differing = keys.filter { bundled.verbsByConjugation[$0] != fresh.verbsByConjugation[$0] }.sorted()
      #expect(bundled.verbsByConjugation.count > 240_000)
      #expect(differing.isEmpty, "Stale entries, first few: \(differing.prefix(5))")
    }

    // The measure: a sentence counts as found when one of its words maps to the sentence's
    // verb. A word is a maximal run of letters and hyphens, lowercased, so that arc-boutait
    // stays whole; when a word holds a hyphen, its hyphen-separated parts count too, so that
    // souviens-toi yields souviens. An apostrophe ends a word, so that m'abasourdissez yields
    // abasourdissez. A sentence filed under a doubled infinitive's bare form (sortir) counts
    // for either entry. On 2026-11-22 this found 6,322 of 6,328 (99.91%). The six misses are
    // spellings the Conjugator does not produce: étiquètes and markete (the 1990 spellings),
    // emmaillottent, presurer, redîmé, and s'entrenuisaient.
    @Test func findsTheVerbOfNearlyEveryExampleSentence() throws {
      let url = try #require(Bundle.main.url(forResource: "literature_examples", withExtension: "json"))
      let examples = try JSONDecoder().decode([String: Example].self, from: Data(contentsOf: url))
      let infinitifByKey = Verb.verbs.mapValues(\.infinitif)
      let map = ConjugationMap.bundled

      var misses: [String] = []
      for (verbID, example) in examples {
        let words = example.fr.lowercased().split { !$0.isLetter && $0 != "-" }
        let candidates = words.flatMap { word in
          word.contains("-") ? [word] + word.split(separator: "-") : [word]
        }
        let wantedInfinitif = verbID.split(separator: " (").first.map(String.init) ?? verbID
        let found = candidates.contains { word in
          map.verbs(for: String(word)).contains { infinitifByKey[$0] == wantedInfinitif }
        }
        if !found {
          misses.append(verbID)
        }
      }
      let foundCount = examples.count - misses.count
      #expect(examples.count > 6_000)
      #expect(Double(foundCount) / Double(examples.count) >= 0.99, "Found \(foundCount) of \(examples.count); missed \(misses.sorted().prefix(20))")
    }
  }

  @MainActor
  @Suite("Entries")
  struct Entries {
    @Test(arguments: [
      ("suis", ["suivre", "être"]),
      ("Suis", ["suivre", "être"]),
      ("vis", ["vivre", "voir"]),
      ("fus", ["être"]),
      ("lis", ["lire"]),
      ("tu", ["taire"]),
      ("été", ["être"]),
      ("vais", ["aller"]),
      ("vins", ["venir"]),
      ("a", ["avoir"]),
      ("manger", ["manger"]),
      ("allée", ["aller"]),
      ("allés", ["aller"]),
      ("allées", ["aller"]),
      ("paie", ["payer"]),
      ("paye", ["payer"]),
      ("due", ["devoir"]),
      ("dissoute", ["dissoudre"]),
      ("manœuvre", ["manœuvrer"]),
      ("arc-boutait", ["arc-bouter"]),
      ("sortissait", ["sortir obtain"])
    ])
    func maps(conjugation: String, verbs: [String]) {
      #expect(ConjugationMap.bundled.verbs(for: conjugation) == verbs)
    }

    @Test func keepsBothEntriesOfADoubledInfinitive() {
      #expect(ConjugationMap.bundled.verbs(for: "sortir") == ["sortir exit", "sortir obtain"])
      #expect(ConjugationMap.bundled.verbs(for: "sors") == ["sortir exit"])
    }

    @Test(arguments: ["est allée", "ai mangé", "viendr", "ir", "xyzzy", ""])
    func hasNoEntriesFor(text: String) {
      #expect(ConjugationMap.bundled.verbs(for: text).isEmpty)
    }

    // choir uses only its participe passé, and clore has no imparfait.
    @Test func leavesOutDefectiveCells() {
      #expect(ConjugationMap.bundled.verbs(for: "chu").contains("choir"))
      #expect(!ConjugationMap.bundled.verbs(for: "choit").contains("choir"))
      #expect(ConjugationMap.bundled.verbs(for: "clos").contains("clore"))
      #expect(!ConjugationMap.bundled.verbs(for: "closait").contains("clore"))
    }
  }

  @Suite("Format")
  struct Format {
    let map = ConjugationMap(verbsByConjugation: [
      "suis": ["suivre", "être"],
      "vais": ["aller"]
    ])

    @Test func writesOneLinePerConjugation() {
      #expect(map.text == "suis\tsuivre\têtre\nvais\taller")
    }

    @Test func readsWhatItWrites() throws {
      #expect(ConjugationMap(text: map.text) == map)
      #expect(try ConjugationMap(compressed: map.compressed()) == map)
    }

    @Test func refusesTextThatIsNotUTF8() throws {
      let compressed = try (Data([0x76, 0x61, 0xFF, 0x09, 0x61]) as NSData).compressed(using: .lzfse) as Data
      #expect(throws: ConjugationMap.ReadError.notUTF8) {
        try ConjugationMap(compressed: compressed)
      }
    }

    @Test(arguments: [
      ("allé", ["allée", "allés", "allées"]),
      ("pris", ["prise", "pris", "prises"]),
      ("dû", ["due", "dus", "dues"]),
      ("dissous", ["dissoute", "dissous", "dissoutes"])
    ])
    func agrees(participle: String, forms: [String]) {
      #expect(ConjugationMap.agreedForms(ofParticiple: participle) == forms)
    }
  }
}
