//
//  VerbParser.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/31/20.
//

import Foundation

nonisolated class VerbParser: XMLDataParser {
  // Every verb is built with this placeholder rank, which `ranked(_:)` overwrites before
  // `parse(models:)` returns; no verb escapes the parser carrying it.
  private static let unranked = 0

  private let verbTag = "verb"
  private var verbs: [String: Verb] = [:]
  private var models: [String: VerbModel] = [:]
  private var currentVerb = ""
  private var currentTranslation = ""
  private var currentModel = ""
  private var currentAuxiliary: String?
  private var currentIsReflexive = false
  private var currentHasAspiratedH = false
  private var currentHits: Int?
  private var currentNewspaperHits: Int?
  private var currentLiteratureHits: Int?
  private var currentSubtitleFrequency: Int?
  private var currentHitsAreProvisional = false
  private var currentExtraLetters: String?
  private var currentDefectGroupId: String?

  init() {
    super.init(resource: "verbs")
  }

  init(xmlString: String) {
    super.init(data: Data(xmlString.utf8))
  }

  func parse(models: [String: VerbModel]) -> (verbs: [String: Verb], models: [String: VerbModel], rankCount: Int) {
    self.models = models
    parser?.parse()
    let (ranked, rankCount) = Self.ranked(verbs)
    return (ranked, self.models, rankCount)
  }

  /// Assigns each verb its frequency rank, 1 being the most common, and returns the number
  /// of distinct infinitives that rank runs to.
  ///
  /// `verbs.xml` stores raw corpus hit counts rather than ranks because a rank is a property
  /// of the corpus, not of the verb: were ranks stored, adding one verb would renumber every
  /// verb below it, turning a one-line change into a 6,000-line diff. Deriving them here
  /// costs one sort per launch and keeps the file additive.
  ///
  /// The sort descends through the four counts in order of corpus size — FrWaC web hits,
  /// then Le Monde, then Frantext, then Lexique 4's subtitle frequency — because a smaller
  /// corpus can only separate verbs a larger one saw equally often. A missing count sorts
  /// below a measured zero: zero is a corpus that could have seen the verb and did not,
  /// whereas absence is a corpus that never had the chance. The infinitive settles what is
  /// left, in French collation, which is load-bearing rather than defensive — 116 verbs share
  /// a hit count of zero, and without it their order would depend on dictionary iteration.
  ///
  /// The four doubled infinitives (haïr, ouïr, saillir, sortir — one entry per model) share
  /// one rank, since the counts belong to the verb rather than to the entry.
  private static func ranked(_ verbs: [String: Verb]) -> (verbs: [String: Verb], rankCount: Int) {
    func counts(_ key: String) -> [Int?] {
      guard let verb = verbs[key] else {
        return []
      }
      return [verb.hits, verb.newspaperHits, verb.literatureHits, verb.subtitleFrequency]
    }

    // Grouped by key rather than by value, because a verb's dictionary key carries its
    // `ex` extra letters and cannot be recomputed from the verb alone.
    let ordered = Dictionary(grouping: verbs.keys, by: { verbs[$0]?.infinitif ?? $0 })
      .sorted { lhs, rhs in
        guard let left = lhs.value.first, let right = rhs.value.first else {
          return lhs.key.compare(rhs.key, locale: Util.french) == .orderedAscending
        }
        for (leftCount, rightCount) in zip(counts(left), counts(right)) where leftCount != rightCount {
          return (leftCount ?? -1) > (rightCount ?? -1)
        }
        return lhs.key.compare(rhs.key, locale: Util.french) == .orderedAscending
      }

    var ranked: [String: Verb] = [:]
    ranked.reserveCapacity(verbs.count)
    for (index, group) in ordered.enumerated() {
      for key in group.value {
        ranked[key] = verbs[key]?.withFrequency(index + 1)
      }
    }
    return (ranked, ordered.count)
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    if elementName == verbTag {
      currentElementIsValid = true

      guard
        let infinitif = require("in", from: attributeDict, element: verbTag),
        let translation = require("tn", from: attributeDict, element: verbTag),
        let model = require("mo", from: attributeDict, element: verbTag)
      else {
        return
      }
      currentVerb = infinitif
      currentTranslation = translation
      currentModel = model

      if let auxiliary = attributeDict["ay"] {
        currentAuxiliary = auxiliary
      }

      if
        let isReflexive = attributeDict["re"],
        isReflexive == "t"
      {
        currentIsReflexive = true
      }

      if
        let hasAspiratedH = attributeDict["ah"],
        hasAspiratedH == "t"
      {
        currentHasAspiratedH = true
      }

      currentHits = attributeDict["hi"].flatMap { Int($0) }
      currentNewspaperHits = attributeDict["hn"].flatMap { Int($0) }
      currentLiteratureHits = attributeDict["hl"].flatMap { Int($0) }
      currentSubtitleFrequency = attributeDict["hs"].flatMap { Int($0) }
      currentHitsAreProvisional = attributeDict["hp"] == "y"

      if let extraLetters = attributeDict["ex"] {
        currentExtraLetters = extraLetters
      }

      if let defectGroupId = attributeDict["dg"] {
        currentDefectGroupId = defectGroupId
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == verbTag {
      defer {
        resetCurrent()
      }

      guard currentElementIsValid else {
        return
      }

      let auxiliary: Auxiliary

      if currentIsReflexive {
        auxiliary = .être
      } else if let currentAuxiliary = currentAuxiliary {
        auxiliary = Auxiliary(rawValue: currentAuxiliary) ?? .avoir
      } else {
        auxiliary = .avoir
      }

      let currentVerbWithPossibleExtraLetters: String
      if let currentExtraLetters = currentExtraLetters {
        currentVerbWithPossibleExtraLetters = currentVerb + " " + currentExtraLetters // haïr Canada
      } else {
        currentVerbWithPossibleExtraLetters = currentVerb
      }

      verbs[currentVerbWithPossibleExtraLetters] = Verb(
        infinitif: currentVerb,
        translation: currentTranslation,
        model: currentModel,
        auxiliary: auxiliary,
        isReflexive: currentIsReflexive,
        hasAspiratedH: currentHasAspiratedH,
        frequency: Self.unranked,
        hits: currentHits,
        newspaperHits: currentNewspaperHits,
        literatureHits: currentLiteratureHits,
        subtitleFrequency: currentSubtitleFrequency,
        hitsAreProvisional: currentHitsAreProvisional,
        extraLetters: currentExtraLetters,
        defectGroupId: currentDefectGroupId
      )

      if let model = models[currentModel] {
        var verbs = model.verbs
        verbs.append(currentVerbWithPossibleExtraLetters)
        models[currentModel]?.verbs = verbs
      }
    }
  }

  private func resetCurrent() {
    currentVerb = ""
    currentTranslation = ""
    currentModel = ""
    currentAuxiliary = nil
    currentIsReflexive = false
    currentHasAspiratedH = false
    currentHits = nil
    currentNewspaperHits = nil
    currentLiteratureHits = nil
    currentSubtitleFrequency = nil
    currentHitsAreProvisional = false
    currentExtraLetters = nil
    currentDefectGroupId = nil
  }
}
