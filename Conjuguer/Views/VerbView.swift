//
//  VerbView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/28/21.
//

import SwiftUI

struct VerbView: View {
  @Environment(World.self) private var world
  @Environment(\.scenePhase) private var scenePhase
  @AppStorage("hasSeenConjugationColorKey") private var hasSeenColorKey = false
  let verb: Verb
  let source: AnalyticsSource
  private let conjugations: VerbConjugations
  @State private var shouldShowCompoundTenses = false
  @State private var detailSheet: DetailSheet?
  @State private var chansonExamples: [ChansonExample]
  @State private var chansonIndex: Int
  @State private var visit: VerbVisit?
  @State private var visibleSections: Set<VerbPageSection> = []
  @State private var isOnScreen = false
  @State private var hasAppeared = false

  init(verb: Verb, source: AnalyticsSource) {
    self.verb = verb
    self.source = source
    conjugations = VerbConjugations.memoized(for: verb)
    let examples = ChansonData.examples(for: verb)
    _chansonExamples = State(initialValue: examples)
    // Start on a random occurrence so each launch still varies; the sword button cycles from here.
    _chansonIndex = State(initialValue: examples.indices.randomElement() ?? 0)
  }

  private var chansonExample: ChansonExample? {
    chansonExamples.indices.contains(chansonIndex) ? chansonExamples[chansonIndex] : nil
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
            .reportsReaching(section.id == conjugations.simpleSections.first?.id ? .simple : nil, to: sectionVisibilityChanged)
        }

        Toggle(isOn: $shouldShowCompoundTenses) {
          Text(L.VerbView.showCompoundTenses)
            .subheadingLabel()
        }
        .toggleStyle(.switch)
        .tint(.customRed)
        .scrollFade()

        if shouldShowCompoundTenses {
          CompoundTensesView(verb: verb, sectionVisibilityChanged: sectionVisibilityChanged)
        }

        if let etymologyText = Etymology.text(for: verb.infinitif) {
          etymologyCard(etymologyText)
            .scrollFade()
            .reportsReaching(.etymology, to: sectionVisibilityChanged)
        }

        if ExampleData.example(for: verb) != nil || chansonExample != nil {
          exampleCard(ExampleData.example(for: verb))
            .scrollFade()
            .reportsReaching(.example, to: sectionVisibilityChanged)
        }
      }
      .padding(.horizontal, Layout.doubleDefaultSpacing)
    }
    .screenBackground()
    .onAppear {
      isOnScreen = true
      beginVisit(source: hasAppeared ? .resume : source)
      hasAppeared = true
    }
    .onDisappear {
      isOnScreen = false
      endVisit()
    }
    .onChange(of: scenePhase) {
      switch scenePhase {
      case .background:
        endVisit()
      case .active:
        resumeVisitIfUncovered()
      default:
        break
      }
    }
    .onChange(of: detailSheet) {
      if detailSheet == nil {
        resumeVisitIfUncovered()
      } else {
        endVisit()
      }
    }
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

      metaRow(L.VerbView.frequencyWithColon, "\(verb.frequency) / \(Verb.rankCount)")
        .font(bodyFont)
        .frame(maxWidth: .infinity, alignment: .leading)

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

  private func exampleCard(_ example: Example?) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(example != nil && chansonExample != nil ? L.VerbView.exampleUses : L.VerbView.exampleUse)
        .subheadingLabel()
        .accessibilityAddTraits(.isHeader)

      if let example {
        Text(example.fr)
          .bodyLabel()
          .frenchPronunciation()

        Text(example.en)
          .translationLabel()
          .englishPronunciation()

        Text(example.provenance.attribution)
          .smallLabel()
          .rightAligned()
      }

      if let chanson = chansonExample {
        chansonSection(chanson, showDivider: example != nil)
      }
    }
    .card()
    .accessibilityIdentifier("verb_example")
  }

  private func chansonSection(_ chanson: ChansonExample, showDivider: Bool) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      if showDivider {
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

      if chansonExamples.count > 1 {
        Button {
          withAnimation {
            chansonIndex = (chansonIndex + 1) % chansonExamples.count
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

  private func beginVisit(source: AnalyticsSource) {
    guard visit == nil else {
      return
    }
    let newVisit = VerbVisit(source: source, start: .now, visibleSections: visibleSections)
    visit = newVisit
    world.analytics.signal(name: .viewAppeared, parameters: newVisit.viewParameters)
  }

  private func endVisit() {
    guard let visit else {
      return
    }
    world.analytics.signal(name: .leaveVerbView, parameters: visit.leaveParameters(end: .now))
    self.visit = nil
  }

  // The model page, presented over this one, ends the visit, and closing it resumes the visit.
  private func resumeVisitIfUncovered() {
    guard isOnScreen, detailSheet == nil else {
      return
    }
    beginVisit(source: .resume)
  }

  private func sectionVisibilityChanged(_ section: VerbPageSection, isVisible: Bool) {
    if isVisible {
      visibleSections.insert(section)
      visit?.reach(section)
    } else {
      visibleSections.remove(section)
    }
  }

  private enum DetailSheet: Identifiable, Equatable {
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
  let sectionVisibilityChanged: (VerbPageSection, Bool) -> Void

  init(verb: Verb, sectionVisibilityChanged: @escaping (VerbPageSection, Bool) -> Void) {
    sections = VerbConjugations.sections(verb: verb, specs: VerbConjugations.compoundSpecs)
    self.sectionVisibilityChanged = sectionVisibilityChanged
  }

  var body: some View {
    ForEach(sections) { section in
      TenseSectionView(section: section)
        .card()
        .scrollFade()
        .reportsReaching(section.id == sections.first?.id ? .compound : nil, to: sectionVisibilityChanged)
    }
  }
}

private extension View {
  /// Reports when a third of this card comes on screen or leaves it, which counts as reaching
  /// `section`: a higher threshold could never be met by an etymology card taller than the
  /// screen. A nil section reports nothing, so that only the first card of a block counts.
  @ViewBuilder
  func reportsReaching(_ section: VerbPageSection?, to report: @escaping (VerbPageSection, Bool) -> Void) -> some View {
    if let section {
      onScrollVisibilityChange(threshold: 0.3) { isVisible in
        report(section, isVisible)
      }
    } else {
      self
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
  return VerbView(verb: PreviewSupport.sampleVerb, source: .browse)
    .environment(Current)
}
#endif
