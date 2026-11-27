//
//  Verb.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/2/21.
//

import Foundation

struct Verb: Identifiable, Hashable {
  static var verbs: [String: Verb] = [:]
  static let minVerbLength = 4
  // The number of distinct infinitives, and so the largest rank `frequency` can take —
  // the denominator VerbView shows. `VerbData.publish` sets it from the parse, because the
  // count is a property of the data file rather than a constant.
  static var rankCount = 0

  var id: String { infinitifWithPossibleExtraLetters }
  let infinitif: String
  let translation: String
  let model: String
  let auxiliary: Auxiliary
  let isReflexive: Bool
  let hasAspiratedH: Bool
  var frequency: Int
  let hits: Int?
  let newspaperHits: Int?
  let literatureHits: Int?
  let subtitleFrequency: Int?
  let hitsAreProvisional: Bool
  let extraLetters: String?
  let defectGroupId: String?
  let searchKeys: VerbSearchKeys

  nonisolated init(
    infinitif: String,
    translation: String,
    model: String,
    auxiliary: Auxiliary,
    isReflexive: Bool,
    hasAspiratedH: Bool,
    frequency: Int,
    hits: Int?,
    newspaperHits: Int?,
    literatureHits: Int?,
    subtitleFrequency: Int?,
    hitsAreProvisional: Bool,
    extraLetters: String?,
    defectGroupId: String?
  ) {
    self.infinitif = infinitif
    self.translation = translation
    self.model = model
    self.auxiliary = auxiliary
    self.isReflexive = isReflexive
    self.hasAspiratedH = hasAspiratedH
    self.frequency = frequency
    self.hits = hits
    self.newspaperHits = newspaperHits
    self.literatureHits = literatureHits
    self.subtitleFrequency = subtitleFrequency
    self.hitsAreProvisional = hitsAreProvisional
    self.extraLetters = extraLetters
    self.defectGroupId = defectGroupId
    searchKeys = VerbSearchKeys(infinitif: infinitif, translation: translation)
  }

  nonisolated func withFrequency(_ frequency: Int) -> Verb {
    var verb = self
    verb.frequency = frequency
    return verb
  }

  var infinitifStem: String {
    let endingLength: Int
    if infinitif.hasSuffix("oir") {
      endingLength = 3
    } else if infinitif != "fiche" {
      endingLength = 2
    } else {
      endingLength = 1
    }
    let index = infinitif.index(infinitif.endIndex, offsetBy: -1 * endingLength)
    return String(infinitif[..<index])
  }

  nonisolated var dictionaryKey: String {
    if let extraLetters = extraLetters {
      return infinitif + " " + extraLetters
    } else {
      return infinitif
    }
  }

  /// Whether the verb's third-person singular is impersonal, so that its subject is il whatever
  /// the pronoun-gender setting: il faut, il pleut, il neige, il appert. The defect groups that
  /// keep only the third-person singular for the weather verbs, falloir, apparoir, and chaloir
  /// say so; pleuvoir shares its group with poindre, which takes a real subject (l'aube point), so
  /// pleuvoir is named. Pleuvoir's figurative plural (les coups pleuvent) follows il too.
  nonisolated var isImpersonal: Bool {
    defectGroupId.map(Self.impersonalDefectGroupIDs.contains) == true || Self.impersonalInfinitifs.contains(infinitif)
  }

  nonisolated static let impersonalDefectGroupIDs: Set<String> = ["2", "22", "23"]
  nonisolated static let impersonalInfinitifs: Set<String> = ["pleuvoir", "repleuvoir"]

  /// The pronoun gender the verb is asked and shown in: the learner's setting, or masculine for an
  /// impersonal verb.
  nonisolated func pronounGender(for setting: PronounGender) -> PronounGender {
    isImpersonal ? .masculine : setting
  }

  nonisolated var infinitifWithPossibleExtraLetters: String {
    if let extraLetters = extraLetters {
      return infinitif + " (" + extraLetters + ")"
    } else {
      return infinitif
    }
  }

  /// The most frequent first. The two entries of a doubled infinitive share a rank, so the id
  /// breaks the tie, and a list keeps one order whatever order the dictionary gives its values,
  /// which changes with each launch's hash seed.
  static func byFrequency(_ lhs: Verb, _ rhs: Verb) -> Bool {
    (lhs.frequency, lhs.id) < (rhs.frequency, rhs.id)
  }

  /// In French alphabetical order (écouter among the e's, where a plain comparison puts it after
  /// the z's), the id breaking the tie between the two entries of a doubled infinitive.
  static func alphabetically(_ lhs: Verb, _ rhs: Verb) -> Bool {
    switch lhs.infinitif.compare(rhs.infinitif, locale: Util.french) {
    case .orderedAscending:
      return true
    case .orderedDescending:
      return false
    case .orderedSame:
      return lhs.id < rhs.id
    }
  }

  static func endingIsValid(infinitif: String) -> Bool {
    let frenchVerbEndingLength = 2
    let validFrenchVerbEndings = ["er", "ir", "re", "ïr"]
    let index = infinitif.index(infinitif.endIndex, offsetBy: -1 * frenchVerbEndingLength)
    let ending = String(infinitif[index...])
    return validFrenchVerbEndings.contains(ending) || infinitif == "fiche"
  }

  static func verbForInfinitif(_ infinitif: String) -> Verb {
    if let verb = verbs[infinitif] {
      return verb
    }
    // Unreachable with today's data (callers pass known infinitifs); a future data typo
    // degrades to a placeholder regular -er verb rather than crashing the user.
    assertionFailure("Could not retrieve verb for \(infinitif).")
    return Verb(
      infinitif: infinitif,
      translation: "",
      model: "1-1",
      auxiliary: .avoir,
      isReflexive: false,
      hasAspiratedH: false,
      frequency: rankCount,
      hits: nil,
      newspaperHits: nil,
      literatureHits: nil,
      subtitleFrequency: nil,
      hitsAreProvisional: false,
      extraLetters: nil,
      defectGroupId: nil
    )
  }
}
