//
//  VerbData.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/3/26.
//

import Observation
import SwiftUI

// The four parsed data sets, bundled so a background parse can hand its results to the
// main actor in one Sendable transfer. The element types are value types whose inits are
// `nonisolated`, so building them off the main actor is safe.
nonisolated struct ParsedVerbData: Sendable {
  let models: [String: VerbModel]
  let verbs: [String: Verb]
  let defectGroups: [String: DefectGroup]
}

// Owns app-launch data loading. The heavy parse runs off the main actor and only the
// lightweight publish hops back, with a loading state gating the UI so it never renders
// against an empty store.
@MainActor
@Observable
final class VerbData {
  enum LoadState {
    case loading
    case loaded
  }

  private(set) var state: LoadState = .loading

  // Parses all three data files. Safe to run off the main actor: every type it constructs
  // has a `nonisolated` init and it touches no main-actor state. It returns its results
  // for the main actor to publish. VerbParser threads the models dict through locally,
  // rather than the main-actor `VerbModel.models` store, so verb→model association happens
  // here without touching shared state.
  nonisolated static func parse() -> ParsedVerbData {
    let models = VerbModelParser().parse()
    let (verbs, populatedModels) = VerbParser().parse(models: models)
    let defectGroups = DefectGroupParser().parse()
    return ParsedVerbData(models: populatedModels, verbs: verbs, defectGroups: defectGroups)
  }

  // Publishes parsed data into the static stores, then runs the derived-data passes that
  // read those stores. computeIrregularities / sortVerbs resolve model parents through
  // VerbModel.models, so they must run on the main actor after the stores are assigned.
  static func publish(_ parsed: ParsedVerbData) {
    VerbModel.models = parsed.models
    Verb.verbs = parsed.verbs
    DefectGroup.defectGroups = parsed.defectGroups
    VerbModel.computeIrregularities()
    VerbModel.sortVerbs()
  }

  // Synchronous load for non-UI launch paths (unit tests, previews) that need the data
  // ready before anything runs. Launch-time cost is irrelevant there.
  static func loadSynchronously() {
    publish(parse())
  }

  // Async load for the app: the heavy XML parse runs off the main actor (Task.detached),
  // and only the cheap publish runs back on the main actor before the UI is revealed.
  func load() async {
    if Verb.verbs.isEmpty {
      let parsed = await Task.detached(priority: .userInitiated) {
        VerbData.parse()
      }.value
      VerbData.publish(parsed)
    }
    state = .loaded
  }
}
