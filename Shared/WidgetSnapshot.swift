//
//  WidgetSnapshot.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import Foundation

/// The file the app writes to the shared container and the widget reads: a snapshot for each
/// coming day, today first.
struct WidgetSnapshotBundle: Codable, Equatable {
  let snapshots: [WidgetSnapshot]
  /// The last day each verb of My Verbs was given, by `Verb.dictionaryKey`, so that the app's next
  /// write takes them in turn. The widget does not read it.
  let myVerbsLastShown: [String: Date]

  /// A file written before the bundle holds the bare list of snapshots, which decodes with no
  /// days given to My Verbs, so that the widget and today's verb survive the app's upgrade.
  static func decoded(from data: Data) -> WidgetSnapshotBundle? {
    let decoder = JSONDecoder()
    if let bundle = try? decoder.decode(WidgetSnapshotBundle.self, from: data) {
      return bundle
    }
    return (try? decoder.decode([WidgetSnapshot].self, from: data)).map { WidgetSnapshotBundle(snapshots: $0, myVerbsLastShown: [:]) }
  }

  /// Sorted keys, so that the same bundle always encodes to the same bytes, and the app can skip
  /// a write, and the widget's reload, when nothing moved.
  var encoded: Data? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    return try? encoder.encode(self)
  }
}

// The verb-of-the-day payload the app precomputes and writes to the shared container.
// The widget extension only decodes and renders this — it never loads the verb data or
// runs the conjugation engine itself.
struct WidgetSnapshot: Codable, Equatable {
  let infinitif: String
  // Optional so a snapshot written before this field existed still decodes after an
  // update, rather than blanking the widget until the app next launches.
  let verbKey: String?
  let translation: String
  let auxiliary: String
  let frequency: Int
  let présentParadigm: [WidgetConjugation]
  let participePassé: String
  let etymologySnippet: String?
  let exampleFrench: String?
  let exampleEnglish: String?
  let exampleSource: String?
  let quizQuestion: WidgetQuizQuestion
  let dateString: String
}

struct WidgetConjugation: Codable, Equatable {
  let pronoun: String
  let form: String
}

struct WidgetQuizQuestion: Codable, Equatable {
  let infinitif: String
  let tenseDisplay: String
  let pronoun: String?
  let correctAnswer: String
  let wrongAnswers: [String]
  let questionID: String

  // FNV-1a over the UTF-8 bytes: a seed that is the same in every process and on every device.
  // Swift's `Hasher` is seeded randomly per launch, and WidgetKit recycles the extension process
  // between reloads, so a Hasher-derived seed would let a question's buttons reorder between
  // renders, inviting a mid-aim mis-tap, and would give each device its own daily challenge.
  nonisolated static func stableSeed(for string: String) -> UInt64 {
    var hash: UInt64 = 0xcbf2_9ce4_8422_2325
    for byte in string.utf8 {
      hash ^= UInt64(byte)
      hash = hash &* 0x0000_0100_0000_01b3
    }
    return hash
  }
}
