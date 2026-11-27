//
//  ExampleCard.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import SwiftUI

/// The verb page's example sentence and, for a verb the *Chanson de Roland* uses, a line from it.
/// Shows nothing for a verb with neither.
struct ExampleCard: View {
  let verb: Verb
  /// Starts the chanson's lines at a random one, so each visit still varies; the sword button
  /// steps on from there.
  @State private var chansonOffset = Int.random(in: 0..<1_000)

  var body: some View {
    let example = ExampleData.example(for: verb)
    let chansonExamples = ChansonData.examples(for: verb)
    let chanson = chansonExamples.isEmpty ? nil : chansonExamples[chansonOffset % chansonExamples.count]

    if example != nil || chanson != nil {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        Text(example != nil && chanson != nil ? L.VerbView.exampleUses : L.VerbView.exampleUse)
          .subheadingLabel()
          .accessibilityAddTraits(.isHeader)

        if let example {
          Text(example.styledFrench)
            .bodyLabel()
            .frenchPronunciation()

          Text(example.en)
            .translationLabel()
            .englishPronunciation()

          Text(example.provenance.attribution)
            .smallLabel()
            .rightAligned()
        }

        if let chanson {
          chansonSection(chanson, showsDivider: example != nil, hasMore: chansonExamples.count > 1)
        }
      }
      .card()
      .accessibilityIdentifier("verb_example")
    }
  }

  private func chansonSection(_ chanson: ChansonExample, showsDivider: Bool, hasMore: Bool) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      if showsDivider {
        Divider()
          .padding(.vertical, 4)
      }

      Text(L.VerbView.chansonHeading)
        .smallLabel()
        .accessibilityAddTraits(.isHeader)

      Text(L.VerbView.chansonReference(laisse: chanson.laisse, line: chanson.line))
        .smallLabel()

      Text(chanson.of)
        .bodyLabel()
        .frenchPronunciation()

      Text(chanson.tr)
        .translationLabel()
        .englishPronunciation()

      if hasMore {
        Button {
          withAnimation {
            chansonOffset += 1
          }
        } label: {
          Image(systemName: "flag.2.crossed")
            .foregroundStyle(Color.customRed)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(L.VerbView.chansonNextExample))
      }
    }
  }
}
