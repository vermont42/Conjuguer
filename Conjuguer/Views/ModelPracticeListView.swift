//
//  ModelPracticeListView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import SwiftUI

/// What the Quiz tab's hub pushes for its Conjugation Models row.
struct ModelPracticeDestination: Hashable {}

/// The models that can be practiced alone, the most used first, each opening onto its practice.
/// A model's page in the Models tab offers the same practice.
struct ModelPracticeListView: View {
  @Environment(World.self) private var world
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var expandedModels: Set<String> = []

  var body: some View {
    let record = world.practice.record

    ScrollView {
      LazyVStack(alignment: .leading, spacing: 0) {
        Text(L.ModelPractice.listIntro)
          .smallLabel()
          .fixedSize(horizontal: false, vertical: true)
          .padding(.bottom, Layout.defaultSpacing)

        ForEach(ModelPractice.practicedAloneByUse) { practice in
          let isExpanded = expandedModels.contains(practice.modelID)

          VStack(alignment: .leading, spacing: 0) {
            ModelPracticeRow(practice: practice, isKnown: practice.isKnown(in: record), isExpanded: isExpanded)
              .contentShape(.rect)
              .accessibilityAddTraits(.isButton)
              .accessibilityIdentifier("model_practice_\(practice.modelID)")
              .onTapGesture {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                  if isExpanded {
                    expandedModels.remove(practice.modelID)
                  } else {
                    expandedModels.insert(practice.modelID)
                  }
                }
              }

            if isExpanded {
              ModelPracticeCard(modelID: practice.modelID, showsKnown: false)
                .padding(.bottom, Layout.doubleDefaultSpacing)
            }

            Divider()
          }
        }
      }
      .frame(maxWidth: CustomQuizLayout.maxWidth)
      .padding(Layout.doubleDefaultSpacing)
      .frame(maxWidth: .infinity)
    }
    .screenBackground()
    .navigationTitle(L.ModelPractice.title)
    .navigationBarTitleDisplayMode(.inline)
    .recordsAppearance(as: "\(ModelPracticeListView.self)")
  }
}

private struct ModelPracticeRow: View {
  let practice: ModelPractice
  let isKnown: Bool
  let isExpanded: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(alignment: .firstTextBaseline) {
        Text(verbatim: practice.exemplar)
          .font(bodyEmphasisFont)
          .foregroundStyle(Color.customRed)
          .frenchPronunciation()

        Text(verbatim: "(\(practice.modelID))")
          .font(captionFont)
          .foregroundStyle(Color.customGray)

        if isKnown {
          Image(systemName: "checkmark.seal.fill")
            .font(captionFont)
            .foregroundStyle(Color.customRed)
            .accessibilityLabel(L.ModelPractice.known)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundStyle(Color.customGray)
          .rotationEffect(.degrees(isExpanded ? 90 : 0))
          .accessibilityHidden(true)
      }

      Text(practice.model?.description ?? "")
        .smallLabel()
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.vertical, 12)
    .accessibilityElement(children: .combine)
  }
}
