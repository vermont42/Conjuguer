//
//  Etymology.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/9/26.
//

import Foundation

// Supplies an etymology for a verb, keyed by infinitif, loaded from the bundled
// `Etymologies.json`. That file is keyed language → infinitif → text; the text uses
// `~bold~` markup (see String.etymologyAttributedString) and `\n\n` paragraph breaks.
// Entries are produced by the pipeline in etymology_pipeline.md.
enum Etymology {
  @MainActor private static var etymologies: [String: String]?

  @MainActor private static func loadIfNeeded() {
    guard etymologies == nil else {
      return
    }
    let file = decodedFile()
    let language = Locale.current.language.languageCode?.identifier ?? "en"
    etymologies = file?[language] ?? file?["en"] ?? [:]
  }

  @MainActor static func text(for infinitif: String) -> String? {
    loadIfNeeded()
    return etymologies?[infinitif]
  }

  /// Every etymology in one language, read afresh from the bundle and not kept, so that a test can
  /// compare the two languages. Nil for a language the file lacks.
  static func texts(in language: String) -> [String: String]? {
    decodedFile()?[language]
  }

  private static func decodedFile() -> [String: [String: String]]? {
    guard
      let url = Bundle.main.url(forResource: "Etymologies", withExtension: "json"),
      let data = try? Data(contentsOf: url)
    else {
      return nil
    }
    return try? JSONDecoder().decode([String: [String: String]].self, from: data)
  }
}
