//
//  VerbView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/28/21.
//

import SwiftUI

struct VerbView: View {
  @Environment(World.self) private var world
  @AppStorage("hasSeenConjugationColorKey") private var hasSeenColorKey = false
  let verb: Verb
  private let conjugations: VerbConjugations
  @State private var shouldShowCompoundTenses = false
  @State private var detailSheet: DetailSheet?
  @State private var chansonExample: ChansonExample?

  init(verb: Verb) {
    self.verb = verb
    conjugations = VerbConjugations.memoized(for: verb)
    _chansonExample = State(initialValue: ChansonData.example(for: verb))
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        Text(verb.infinitifWithPossibleExtraLetters)
          .headingLabel()
          .frenchPronunciation()
          .scrollFade()

        overviewCard
          .scrollFade()

        if !hasSeenColorKey {
          colorKey
            .scrollFade()
        }

        personlessCard
          .scrollFade()

        ForEach(conjugations.simpleSections) { section in
          TenseSectionView(section: section)
            .card()
            .scrollFade()
        }

        Toggle(isOn: $shouldShowCompoundTenses) {
          Text(L.VerbView.showCompoundTenses)
            .subheadingLabel()
        }
        .toggleStyle(.switch)
        .tint(.customRed)
        .scrollFade()

        if shouldShowCompoundTenses {
          CompoundTensesView(verb: verb)
        }

        if let etymologyText = Etymology.text(for: verb.infinitif) {
          etymologyCard(etymologyText)
            .scrollFade()
        }

        if let example = ExampleData.example(for: verb) {
          exampleCard(example)
            .scrollFade()
        }
      }
      .recordsAppearance(as: "\(VerbView.self)")
      .padding(.horizontal, Layout.doubleDefaultSpacing)
    }
    .screenBackground()
    .sheet(item: $detailSheet) { sheet in
      switch sheet {
      case .model(let model):
        ModelView(model: model)
          .sheetDismissable()
      }
    }
  }

  private var overviewCard: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.VerbView.overview)
        .subheadingLabel()

      Text(verb.translation)
        .bodyLabel()
        .englishPronunciation()

      if let model = VerbModel.models[verb.model] {
        modelRow(model)
      }

      if verb.isReflexive {
        Text(L.VerbView.reflexive)
          .bodyLabel()
      }

      if verb.hasAspiratedH {
        Text(L.VerbView.aspiratedH)
          .bodyLabel()
      }

      metaRow(L.VerbView.auxiliaryWithColon, verb.auxiliary.verb)
        .font(bodyFont)
        .frenchPronunciation()
        .frame(maxWidth: .infinity, alignment: .leading)

      if let frequency = verb.frequency {
        metaRow(L.VerbView.frequencyWithColon, "\(frequency) / \(Verb.maxFrequency)")
          .font(bodyFont)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      if
        let defectGroupId = verb.defectGroupId,
        let defectGroup = DefectGroup.defectGroups[defectGroupId]
      {
        Text("\(L.VerbView.defective) " + defectGroup.description())
          .bodyLabel()
      }
    }
    .card()
  }

  private func modelRow(_ model: VerbModel) -> some View {
    Button {
      detailSheet = .model(model)
    } label: {
      modelReferenceText(model)
        .frenchPronunciation()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .buttonStyle(.plain)
    .accessibilityHint(Text(L.VerbView.modelButtonHint))
  }

  private func modelReferenceText(_ model: VerbModel) -> Text {
    // Gray, demoted "Model:" prefix vs. the blue, link-colored value, per #29.
    var label = AttributedString(L.VerbView.modelWithColon + " ")
    label.foregroundColor = Color.customGray

    var value = AttributedString("\(model.exemplar) (\(model.id)) ")
    value.foregroundColor = Color.customBlue

    let reference = Text(label + value)
      .font(bodyFont)
    let chevron = Text(Image(systemName: "chevron.right"))
      .font(.footnote)
      .foregroundStyle(Color.customBlue)

    return Text("\(reference)\(chevron)")
  }

  private func metaRow(_ prefix: String, _ value: String) -> Text {
    var label = AttributedString(prefix + " ")
    label.foregroundColor = Color.customGray

    var valuePart = AttributedString(value)
    valuePart.foregroundColor = Color.customForeground

    return Text(label + valuePart)
  }

  private func exampleCard(_ example: Example) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(chansonExample == nil ? L.VerbView.exampleUse : L.VerbView.exampleUses)
        .subheadingLabel()
        .accessibilityAddTraits(.isHeader)

      Text(example.fr)
        .bodyLabel()
        .frenchPronunciation()

      Text(example.en)
        .translationLabel()
        .englishPronunciation()

      Text(example.provenance.attribution)
        .smallLabel()
        .rightAligned()

      if let chanson = chansonExample {
        chansonSection(chanson)
      }
    }
    .card()
    .accessibilityIdentifier("verb_example")
  }

  private func chansonSection(_ chanson: ChansonExample) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Divider()
        .padding(.vertical, 4)

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
    }
  }

  private func etymologyCard(_ text: String) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.VerbView.etymologyHeading)
        .subheadingLabel()
        .accessibilityAddTraits(.isHeader)

      Text(text.etymologyAttributedString)
        .lineSpacing(4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .card()
  }

  private var personlessCard: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.VerbView.personlessConjugations)
        .subheadingLabel()
        .frenchPronunciation()

      Text(conjugations.personlessDisplay)
        .font(bodyFont)
        .accessibilityLabel(conjugations.personlessAccessibility)
        .frenchPronunciation()
        .leftAligned()
    }
    .card()
  }

  private var colorKey: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack {
        Text(L.VerbView.colorKeyTitle)
          .subheadingLabel()
        Spacer()
        Button {
          withAnimation { hasSeenColorKey = true }
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(Color.customGray)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(Text(L.VerbView.dismissColorKey))
      }

      Text(L.VerbView.colorKeyExplanation)
        .smallLabel()

      HStack(spacing: Layout.doubleDefaultSpacing) {
        colorKeySwatch(color: .customBlue, label: L.VerbView.colorKeyRegular)
        colorKeySwatch(color: .customRed, label: L.VerbView.colorKeyIrregular)
        Spacer()
      }
    }
    .card(accent: .customBlue)
  }

  private func colorKeySwatch(color: Color, label: String) -> some View {
    HStack(spacing: 6) {
      Circle()
        .fill(color)
        .frame(width: 12, height: 12)
      Text(label)
        .bodyLabel()
        .foregroundStyle(color)
    }
    .accessibilityElement(children: .combine)
  }

  private enum DetailSheet: Identifiable {
    case model(VerbModel)

    var id: String {
      switch self {
      case .model(let model):
        return "model-\(model.id)"
      }
    }
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
        .card()
        .scrollFade()
    }
  }
}

private struct TenseSectionView: View {
  let section: VerbConjugations.Section

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(section.title)
        .subheadingLabel()
        .frenchPronunciation()

      Grid(alignment: .leading, horizontalSpacing: Layout.doubleDefaultSpacing, verticalSpacing: 8) {
        ForEach(section.cells) { cell in
          GridRow(alignment: .firstTextBaseline) {
            Text(cell.pronoun)
              .smallLabel()
              .frenchPronunciation()
              .gridColumnAlignment(.leading)
              .accessibilityHidden(true)

            Text(cell.display)
              .font(bodyFont)
              .frenchPronunciation()
              .gridColumnAlignment(.leading)
              .accessibilityLabel(cell.accessibility)
          }
        }
      }
    }
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return VerbView(verb: PreviewSupport.sampleVerb)
    .environment(Current)
}
#endif
