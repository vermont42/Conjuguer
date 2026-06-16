//
//  CorpusFormsDumpTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/16/26.
//

@testable import Conjuguer
import XCTest

// NOT a behavioral test — a build-time corpus tool that happens to ride the test target so it
// can reuse the app's authoritative `Conjugator` (and the already-bootstrapped verb data).
//
// It emits every single-word surface form of the ~981 usage-ranked verbs to
// `corpus/working/forms.json` as `{ "<form>": ["<verb id>", ...] }`. The Python index builder
// (`corpus/working/build_corpus_index.py`) then does exact whole-token matching against the
// corpus instead of fragile per-verb stem-grepping — irregulars (veux/voulons/voudrai) and
// false-substring hits (ancr- in "rancœur") both fall out for free.
//
// One form can map to several verbs (homographs: "suis" → être & suivre); the builder records
// the occurrence under each candidate and lets the LLM-selection step disambiguate from context.
//
// Run on demand (it writes a file; it asserts nothing about behavior):
//   run_tests.sh --only-testing ConjuguerTests/CorpusFormsDumpTests
@MainActor
class CorpusFormsDumpTests: XCTestCase {
  // Drop single-character tokens ("a", "y", "e"): ultra-noisy and the verbs that emit them
  // (avoir, aller, …) are covered many times over by their longer forms.
  private static let minFormLength = 2

  func testDumpUsageRankedVerbForms() throws {
    // Repo root from this file's compile-time path: …/ConjuguerTests/Models/<file> → up three.
    let outURL = URL(filePath: #filePath)
      .deletingLastPathComponent()  // Models/
      .deletingLastPathComponent()  // ConjuguerTests/
      .deletingLastPathComponent()  // repo root
      .appending(path: "corpus/working/forms.json")

    let ranked = Verb.verbs.values
      .filter { $0.frequency != nil }
      .sorted { ($0.frequency ?? 0) < ($1.frequency ?? 0) }
    XCTAssertFalse(ranked.isEmpty, "Verb data not loaded — expected the usage-ranked set.")

    // form → set of verb ids that produce it.
    var index: [String: Set<String>] = [:]
    var conjugationCount = 0

    for verb in ranked {
      let id = verb.infinitifWithPossibleExtraLetters
      for tense in Tense.allConcreteCases {
        // Both genders so être/reflexive participle agreement (mangé/mangée/…) is harvested;
        // simple tenses ignore the gender and the Set dedups the duplicate work.
        for gender in [PronounGender.feminine, .masculine] {
          guard let conjugation = Conjugator.conjugatedString(
            infinitif: verb.infinitif,
            tense: tense,
            extraLetters: verb.extraLetters,
            pronounGender: gender
          ) else {
            continue
          }
          conjugationCount += 1
          // Each "/"-separated alternate is its own form ("paie/paye"). For a compound tense the
          // form is "auxiliary … participle"; emit ONLY the participle (last word) — the auxiliary
          // ("ai", "suis", "aura") is a form of avoir/être, covered by their own simple tenses, and
          // mapping it to every avoir/être verb would make every "j'ai …" a false hit.
          for alternate in conjugation.split(separator: "/") {
            let words = alternate.split(separator: " ").map { Self.normalize(String($0)) }
            let forms = tense.isCompound ? Array(words.suffix(1)) : words
            for token in forms where token.count >= Self.minFormLength {
              index[token, default: []].insert(id)
            }
          }
        }
      }
    }

    // Serialize sorted for stable, reviewable diffs.
    let out = index.reduce(into: [String: [String]]()) { accumulator, pair in
      accumulator[pair.key] = pair.value.sorted()
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    try encoder.encode(out).write(to: outURL)

    print("CorpusFormsDump: \(ranked.count) verbs × \(Tense.allConcreteCases.count) tenses → "
      + "\(conjugationCount) conjugations → \(out.count) distinct forms")
    print("CorpusFormsDump: wrote \(outURL.path)")
  }

  // Lowercase + NFC so forms compare equal to NFC-normalized corpus tokens regardless of how
  // accents were encoded upstream.
  private static func normalize(_ string: String) -> String {
    string.lowercased().precomposedStringWithCanonicalMapping
  }
}
