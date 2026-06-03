//
//  VerbView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/28/21.
//

import SwiftUI

struct VerbView: View {
  @Environment(World.self) private var world
  let verb: Verb
  let shouldShowVerbHeading: Bool
  private let conjugations: VerbConjugations
  @State private var shouldShowCompoundTenses = false

  init(verb: Verb, shouldShowVerbHeading: Bool = false) {
    self.verb = verb
    self.shouldShowVerbHeading = shouldShowVerbHeading
    conjugations = VerbConjugations(verb: verb)
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        Text(verb.infinitifWithPossibleExtraLetters)
          .headingLabel()
          .frenchPronunciation()

        Text(L.VerbView.overview)
          .subheadingLabel()
          .leftAligned()
          .padding(.top, Layout.defaultSpacing)

        Text(verb.translation)
          .bodyLabel()
          .englishPronunciation()

        if let model = VerbModel.models[verb.model] {
          HStack {
            Text(L.VerbView.modelWithColon + " ")
              .bodyLabel()
            Text(model.exemplar + " ")
              .bodyLabel()
              .frenchPronunciation()
            Text("(\(model.id))")
              .bodyLabel()
            Spacer()
          }
        }

        if verb.isReflexive {
          Text(L.VerbView.reflexive)
            .bodyLabel()
        }

        if verb.hasAspiratedH {
          Text(L.VerbView.aspiratedH)
            .bodyLabel()
        }

        HStack {
          Text(L.VerbView.auxiliaryWithColon + " ")
            .bodyLabel()
          Text(verb.auxiliary.verb)
            .bodyLabel()
            .frenchPronunciation()
          Spacer()
        }

        if let frequency = verb.frequency {
          Text("\(L.VerbView.frequencyWithColon) \(frequency) / \(FrequencyParser.maxFrequency)")
            .bodyLabel()
        }

        if
          let defectGroupId = verb.defectGroupId,
          let defectGroup = DefectGroup.defectGroups[defectGroupId]
        {
          Text("\(L.VerbView.defective) " + defectGroup.description())
              .bodyLabel()
        }

        if let example = verb.example {
          Text(L.VerbView.exampleUse)
            .subheadingLabel()
            .leftAligned()
            .padding(.top, Layout.defaultSpacing)

          Text(example)
            .bodyLabel()
            .frenchPronunciation()

          if let source = verb.source {
            Text(source)
              .smallLabel()
              .rightAligned()
              .frenchPronunciation()
          }
        }

        Text(L.VerbView.personlessConjugations)
          .subheadingLabel()
          .frenchPronunciation()
          .padding(.top, Layout.defaultSpacing)

        // One element carries both the colored display and the spoken (lowercased, French)
        // value, replacing the invisible-Color + accessibilityHidden-Text pair (#26).
        Text(conjugations.personlessDisplay)
          .font(bodyFont)
          .accessibilityLabel(conjugations.personlessAccessibility)
          .frenchPronunciation()
          .leftAligned()

        ForEach(conjugations.simpleSections) { section in
          TenseSectionView(section: section)
        }

        Toggle(isOn: $shouldShowCompoundTenses) {
          Text(L.VerbView.showCompoundTenses)
            .subheadingLabel()
        }
        .toggleStyle(.switch)
        .tint(.customRed)
        .padding(.top, Layout.defaultSpacing)

        if shouldShowCompoundTenses {
          CompoundTensesView(verb: verb)
        }
      }
      .onAppear {
        world.analytics.recordViewAppeared("\(VerbView.self)")
      }
      .padding(.leading, Layout.doubleDefaultSpacing)
      .padding(.trailing, Layout.doubleDefaultSpacing)
    }
    .screenBackground()
  }
}

private struct CompoundTensesView: View {
  let sections: [VerbConjugations.Section]

  init(verb: Verb) {
    sections = VerbConjugations.sections(verb: verb, specs: VerbConjugations.compoundSpecs)
  }

  var body: some View {
    ForEach(sections) { section in
      TenseSectionView(section: section)
    }
  }
}

private struct TenseSectionView: View {
  let section: VerbConjugations.Section

  var body: some View {
    Text(section.title)
      .subheadingLabel()
      .frenchPronunciation()
      .padding(.top, Layout.defaultSpacing)

    ForEach(section.cells) { cell in
      Text(cell.display)
        .font(bodyFont)
        .accessibilityLabel(cell.accessibility)
        .frenchPronunciation()
        .leftAligned()
    }
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return VerbView(verb: PreviewSupport.sampleVerb, shouldShowVerbHeading: true)
    .environment(Current)
}
#endif
