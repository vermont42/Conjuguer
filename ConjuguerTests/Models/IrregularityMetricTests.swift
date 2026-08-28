//
//  IrregularityMetricTests.swift
//  ConjuguerTests
//
//  Created by Claude on 8/28/26.
//

@testable import Conjuguer
import Testing

// Keeps `VerbModel.irregularity` and the app's prose telling the same story. `VerbModel
// .description` prints "regular -er/-ir/-re" for exactly three model ids and "N% irregular"
// for every other, and `Info.irregularitiesText` names those same three as the regular
// models. So a fourth model scoring 0 is a contradiction the user can see: model 3-2A (the
// assaillir family, -ir verbs taking -er présent endings) read "0% irregular" on its own
// screen, and counted four irregular verbs into the regular column of the Info text.
@MainActor
struct IrregularityMetricTests {
  // The three ids VerbModel.description labels regular rather than scoring.
  private static let regularModelIds: Set<String> = ["1-1", "2-1", "5-1A"]

  @Test func testOnlyTheThreeRegularModelsScoreZero() {
    let zeros = Set(VerbModel.models.values.filter { $0.irregularity == 0 }.map(\.id))
    #expect(zeros == Self.regularModelIds, "Models scoring 0% irregular: \(zeros.sorted())")
  }

  @Test func testAssaillirFamilyIsScoredIrregular() {
    // Its irregularity is entirely in the endings group — no stem alteration, no uppercase
    // participe ending — which is the case the metric used to miss.
    let assaillir = VerbModel.models["3-2A"]
    #expect(assaillir?.stemAlterationsRecursive == nil)
    #expect((assaillir?.irregularity ?? 0) > 0)
  }

  @Test func testNoModelExceedsTheScale() {
    for model in VerbModel.models.values {
      #expect((0 ... 100).contains(model.irregularity), "\(model.id) scores \(model.irregularity)%.")
    }
    // The ceiling constant is meant to be the highest count any model reaches, so something
    // has to touch 100 or the scale has drifted from the data.
    #expect(VerbModel.models.values.contains { $0.irregularity == 100 })
  }

  // The figures in Info.irregularitiesText and Info.valuePropositionText, in both languages.
  // A verb added, removed, or re-modeled changes these, and the prose has silently gone stale
  // twice; failing here is the reminder to update it.
  @Test func testShippingSplitMatchesTheInfoText() {
    var modelsByInfinitif: [String: [String]] = [:]
    for verb in Verb.verbs.values {
      modelsByInfinitif[verb.infinitif, default: []].append(verb.model)
    }
    // saillir and sortir each carry one regular and one irregular pattern; a verb is
    // "completely regular", in the Info text's words, only if every pattern it has is.
    let regular = modelsByInfinitif.values.count { $0.allSatisfy { Self.regularModelIds.contains($0) } }
    let irregular = modelsByInfinitif.count - regular

    #expect(regular == 5223, "Info text says 5,223 regular verbs; the data says \(regular).")
    #expect(irregular == 1103, "Info text says 1,103 irregular verbs; the data says \(irregular).")
    #expect(regular + irregular == Verb.rankCount)
  }
}
