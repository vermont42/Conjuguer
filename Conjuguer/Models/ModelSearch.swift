//
//  ModelSearch.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// Finds a model by its exemplar or by any of its verbs, through `VerbSearch`'s matching, so
/// that devenir finds venir's model. Glosses are left out: the Models tab names models, and
/// "go" listing a model for every verb that means it would bury the one sought.
enum ModelSearch {
  struct Match: Equatable {
    let model: VerbModel

    /// The verb that matched, when it was not the exemplar.
    let verb: Verb?
  }

  /// Every model whose exemplar matches, ranked as `VerbSearch` ranks the exemplars, and then
  /// every other model with a verb that matches, ranked by its best such verb.
  static func matches(for query: String, in models: [VerbModel], verbs: [Verb]) -> [Match] {
    let modelsById = Dictionary(models.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    var exemplarMatches: [Match] = []
    var verbMatches: [Match] = []
    var seenExemplars: Set<String> = []
    var seenVerbs: Set<String> = []

    for match in VerbSearch.matches(for: query, in: verbs, includeGlosses: false) {
      guard let model = modelsById[match.verb.model] else {
        continue
      }
      if match.verb.infinitif == model.exemplar {
        if seenExemplars.insert(model.id).inserted {
          exemplarMatches.append(Match(model: model, verb: nil))
        }
      } else if seenVerbs.insert(model.id).inserted {
        verbMatches.append(Match(model: model, verb: match.verb))
      }
    }

    return exemplarMatches + verbMatches.filter { !seenExemplars.contains($0.model.id) }
  }
}
