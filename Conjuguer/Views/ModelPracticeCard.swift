//
//  ModelPracticeCard.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import SwiftUI

/// A model's practice: the model alone, and mixed with the models the learner knows. A model
/// without a practice of its own says why.
struct ModelPracticeCard: View {
  let modelID: String
  /// False where the model's row already says so.
  var showsKnown = true
  @Environment(World.self) private var world
  @Environment(\.isBeneathQuiz) private var isBeneathQuiz
  @State private var session: ModelPracticeSession?

  private static let partnerPreviewCount = 4

  var body: some View {
    // Opened from a quiz's held correction, a model starts no second quiz over the first.
    if !isBeneathQuiz {
      if let practice = ModelPractice.practice(modelID), practice.offersPracticeAlone {
        practiceContent(practice)
          .card()
          .sheet(item: $session) { session in
            QuizSheet(scope: .modelPractice(session))
          }
      } else if let absence = ModelPractice.absence(of: modelID) {
        absenceNote(absence)
          .card()
      }
    }
  }

  private func practiceContent(_ practice: ModelPractice) -> some View {
    let record = world.practice.record
    let partners = practice.mixPartners(in: record)

    return VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack {
        Text(L.ModelPractice.heading)
          .subheadingLabel()
          .accessibilityAddTraits(.isHeader)

        Spacer()

        if showsKnown, practice.isKnown(in: record) {
          knownSeal
        }
      }

      Text(description(of: practice))
        .bodyLabel()
        .fixedSize(horizontal: false, vertical: true)

      HStack(spacing: Layout.defaultSpacing) {
        Button {
          session = ModelPracticeSession(modelID: modelID, mode: .alone)
        } label: {
          Label(L.ModelPractice.alone, systemImage: "square.3.layers.3d")
        }
        .accessibilityHint(practice.kind == .verbEssentials ? L.ModelPractice.aloneEssentialsHint : L.ModelPractice.aloneCellsHint)
        .accessibilityIdentifier("model_practice_alone_button")

        Button {
          session = ModelPracticeSession(modelID: modelID, mode: .mixed)
        } label: {
          Label(L.ModelPractice.mixed, systemImage: "shuffle")
        }
        .disabled(partners.isEmpty)
        .accessibilityHint(L.ModelPractice.mixedHint)
        .accessibilityIdentifier("model_practice_mixed_button")
      }
      .buttonStyle(.bordered)
      .tint(.customRed)

      Text(partners.isEmpty ? L.ModelPractice.mixedLocked : L.ModelPractice.mixedWith(Self.preview(of: partners)))
        .smallLabel()
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("model_practice_mixed_note")
    }
  }

  private func absenceNote(_ absence: ModelPractice.Absence) -> some View {
    let isKnown = showsKnown && absence == .singleVerb && ModelPractice.practice(modelID)?.isKnown(in: world.practice.record) == true

    return VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack {
        Text(L.ModelPractice.heading)
          .subheadingLabel()
          .accessibilityAddTraits(.isHeader)

        Spacer()

        if isKnown {
          knownSeal
        }
      }

      Text(note(for: absence))
        .smallLabel()
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("model_practice_absence_note")
    }
  }

  private var knownSeal: some View {
    Label(L.ModelPractice.known, systemImage: "checkmark.seal.fill")
      .font(captionFont)
      .foregroundStyle(Color.customRed)
      .accessibilityIdentifier("model_practice_known")
  }

  private func description(of practice: ModelPractice) -> String {
    switch practice.kind {
    case .verbEssentials:
      return practice.verbs.count < ModelPractice.verbLimit ? L.ModelPractice.descriptionEssentialsAll : L.ModelPractice.descriptionEssentialsFrequent
    case .markedCells:
      return L.ModelPractice.descriptionCells(ModelPractice.baseExemplar(of: modelID) ?? "")
    }
  }

  private func note(for absence: ModelPractice.Absence) -> String {
    switch absence {
    case .base:
      return L.ModelPractice.base
    case .fewMarkedCells:
      return L.ModelPractice.fewMarkedCells(ModelPractice.baseExemplar(of: modelID) ?? "")
    case .singleVerb:
      return L.ModelPractice.singleVerb
    }
  }

  /// "venir, prendre, mettre, faire …": the first known models, by their exemplars.
  private static func preview(of partners: [ModelPractice]) -> String {
    let shown = partners.prefix(partnerPreviewCount).map(\.exemplar)
    return shown.joined(separator: ", ") + (partners.count > shown.count ? " …" : "")
  }
}
