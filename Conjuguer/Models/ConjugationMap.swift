//
//  ConjugationMap.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// Every one-word conjugation of every verb, mapped to the verbs it belongs to, so that search
/// can start from a conjugation: vais finds aller, and suis finds both être and suivre.
///
/// ConjugationMapTool builds the map at build time and writes it into the app bundle, and the
/// app reads that copy. The tool compiles this file and the conjugation core from the app's own
/// sources, so the two cannot disagree; see docs/feature_architecture.md § Conjugation Map.
///
/// What a verb contributes: its infinitive; every simple tense and both participles, each
/// alternate on its own ("paie" and "paye"); and the participe passé's agreed forms (allée,
/// allés, allées) for every verb, because a text agrees an avoir verb's participle with a
/// preceding object too. Left out: the radical du futur, a stem that no text writes; any cell
/// the verb's defect group lacks; and the compound tenses, whose words the map already holds,
/// since "est allée" resolves through allée. Entries for avoir and être would otherwise attach
/// to every verb.
nonisolated struct ConjugationMap: Equatable, Sendable {
  static let resourceName = "ConjugationMap"
  static let resourceExtension = "lzfse"

  /// Keys are lowercase and NFC, because the Conjugator marks irregular letters in uppercase
  /// (mORt), and that casing is highlighting rather than spelling. Values are keys of
  /// `Verb.verbs` ("sortir exit"), in UTF-8 byte order, since a doubled infinitive's entries
  /// conjugate differently.
  let verbsByConjugation: [String: [String]]

  func verbs(for conjugation: String) -> [String] {
    verbsByConjugation[Self.key(conjugation)] ?? []
  }

  static func key(_ conjugation: some StringProtocol) -> String {
    conjugation.lowercased().precomposedStringWithCanonicalMapping
  }

  /// The copy in the app bundle, loaded on first use. Loading takes a moment, so a caller on
  /// the main actor may want to touch it first from a background task. Empty if the file is
  /// missing, which `ConjugationMapTests` would catch.
  static let bundled: ConjugationMap = {
    guard
      let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension),
      let data = try? Data(contentsOf: url),
      let map = try? ConjugationMap(compressed: data)
    else {
      return ConjugationMap(verbsByConjugation: [:])
    }
    return map
  }()
}

nonisolated extension ConjugationMap {
  /// One line per conjugation, in sorted order: the conjugation, then a tab before each verb.
  ///
  ///     suis	suivre	être
  ///
  /// Sorted by UTF-8 bytes rather than by `<`: on 2026-11-22, `sorted()` left 155 of the
  /// 242,923 keys out of order (anathématiserai after anathématiserait), apparently because
  /// `precomposedStringWithCanonicalMapping` returns bridged strings, which made two builds of
  /// the same data write different bytes.
  var text: String {
    let lines = verbsByConjugation.keys.sorted(by: Self.precedes).map { conjugation in
      ([conjugation] + (verbsByConjugation[conjugation] ?? [])).joined(separator: "\t")
    }
    return lines.joined(separator: "\n")
  }

  init(text: String) {
    var verbsByConjugation: [String: [String]] = [:]
    for line in text.split(separator: "\n") {
      let fields = line.split(separator: "\t")
      guard let conjugation = fields.first else {
        continue
      }
      verbsByConjugation[String(conjugation)] = fields.dropFirst().map(String.init)
    }
    self.init(verbsByConjugation: verbsByConjugation)
  }

  static func precedes(_ lhs: String, _ rhs: String) -> Bool {
    lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
  }

  func compressed() throws -> Data {
    try (Data(text.utf8) as NSData).compressed(using: .lzfse) as Data
  }

  init(compressed data: Data) throws {
    let decompressed = try (data as NSData).decompressed(using: .lzfse) as Data
    self.init(text: String(decoding: decompressed, as: UTF8.self))
  }

  /// The participe passé as a text agrees it: feminine, masculine plural, feminine plural. A
  /// final circumflex marks only the masculine singular (dû, due, dus), a participle in -s does
  /// not add another (pris, prise, pris), and the -soudre participles change their ending
  /// (dissous, dissoute).
  static func agreedForms(ofParticiple participle: String) -> [String] {
    let base = participle.hasSuffix("û") ? String(participle.dropLast()) + "u" : participle
    let feminine = base.hasSuffix("ous") ? String(base.dropLast()) + "te" : base + "e"
    let masculinePlural = base.hasSuffix("s") ? base : base + "s"
    return [feminine, masculinePlural, feminine + "s"]
  }
}

extension ConjugationMap {
  /// Builds the map from `Verb.verbs`, `VerbModel.models`, and `DefectGroup.defectGroups`,
  /// which must be loaded.
  static func build() -> ConjugationMap {
    var verbsByConjugation: [String: Set<String>] = [:]
    for (verbKey, verb) in Verb.verbs {
      for conjugation in conjugations(of: verb) {
        verbsByConjugation[key(conjugation), default: []].insert(verbKey)
      }
    }
    return ConjugationMap(verbsByConjugation: verbsByConjugation.mapValues { $0.sorted(by: precedes) })
  }

  private static func conjugations(of verb: Verb) -> [String] {
    let defectGroup = verb.defectGroupId.flatMap { DefectGroup.defectGroups[$0] }
    var conjugations = [verb.infinitif]
    for tense in Tense.allConcreteCases where !tense.isCompound && tense != .radicalFutur {
      guard
        defectGroup?.isDefectiveForTense(tense) != true,
        let conjugation = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: .masculine)
      else {
        continue
      }
      for alternate in conjugation.components(separatedBy: Tense.alternateConjugationSeparator) {
        conjugations.append(alternate)
        if tense == .participePassé {
          conjugations += agreedForms(ofParticiple: alternate.lowercased())
        }
      }
    }
    return conjugations.filter { !$0.isEmpty }
  }
}
