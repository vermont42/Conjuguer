//
//  VerbView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/28/21.
//

import SwiftUI
import TipKit

struct VerbView: View {
  @Environment(World.self) private var world
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.tenseArticleOpener) private var tenseArticleOpener
  @Environment(\.verbPagePush) private var verbPagePush
  @Environment(\.isBeneathQuiz) private var isBeneathQuiz
  @AppStorage("hasSeenConjugationColorKey") private var hasSeenColorKey = false
  @AppStorage("showsCompoundTenses") private var showsCompoundTenses = true
  let verb: Verb
  let source: AnalyticsSource
  let marks: MarkedConjugations?
  private let conjugations: VerbConjugations
  /// A search that matched a compound tense shows the compound block on this page even when the
  /// learner has hidden it, without changing the stored choice.
  @State private var compoundTensesAreForcedOn: Bool
  @State private var detailSheet: DetailSheet?
  @State private var chansonExamples: [ChansonExample]
  @State private var chansonIndex: Int
  @State private var visit: VerbVisit?
  @State private var visibleSections: Set<VerbPageSection> = []
  @State private var isOnScreen = false
  @State private var hasAppeared = false
  private let scrollToBottomTip = ScrollToBottomTip()

  init(verb: Verb, source: AnalyticsSource, marks: MarkedConjugations? = nil) {
    self.verb = verb
    self.source = source
    self.marks = marks
    conjugations = VerbConjugations.memoized(for: verb)
    _compoundTensesAreForcedOn = State(initialValue: marks?.includesCompoundTense ?? false)
    let examples = ChansonData.examples(for: verb)
    _chansonExamples = State(initialValue: examples)
    // Start on a random occurrence so each launch still varies; the sword button cycles from here.
    _chansonIndex = State(initialValue: examples.indices.randomElement() ?? 0)
  }

  private var chansonExample: ChansonExample? {
    chansonExamples.indices.contains(chansonIndex) ? chansonExamples[chansonIndex] : nil
  }

  var body: some View {
    ScrollViewReader { proxy in
      page
        .onAppear {
          scrollToFirstMark(proxy)
          isOnScreen = true
          beginVisit(source: hasAppeared ? .resume : source)
          hasAppeared = true
          unlockScrollTipIfDue()
        }
    }
  }

  private var page: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        Text(verb.infinitifWithPossibleExtraLetters)
          .headingLabel()
          .frenchPronunciation()
          .copyOnLongPress(verb.infinitif)
          .scrollFade()

        overviewCard
          .scrollFade()

        if shouldShowColorKey {
          colorKey
            .scrollFade()
        } else {
          TipView(scrollToBottomTip)
            .tipBackground(Color.customBackground)
        }

        ForEach(conjugations.simpleSections) { section in
          TenseSectionView(section: section, marks: marks, openArticle: articleOpener(for:))
            .card()
            .scrollFade()
            .id(section.scrollID)
            .reportsReaching(section.id == conjugations.simpleSections.first?.id ? .simple : nil, to: sectionVisibilityChanged)
        }

        personlessCard
          .scrollFade()
          .id(TenseTable.personless.scrollID)

        Toggle(isOn: compoundTensesAreShown) {
          Text(L.VerbView.showCompoundTenses)
            .subheadingLabel()
        }
        .toggleStyle(.switch)
        .tint(.customRed)
        .scrollFade()

        if compoundTensesAreShown.wrappedValue {
          CompoundTensesView(verb: verb, marks: marks, openArticle: articleOpener(for:), sectionVisibilityChanged: sectionVisibilityChanged)
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

        if !verb.related.isEmpty {
          RelatedVerbsView(related: verb.related, open: open)
            .scrollFade()
        }
      }
      .padding(.horizontal, Layout.doubleDefaultSpacing)
    }
    .screenBackground()
    .toolbar {
      if verb.canBeQuizzed(at: world.settings.quizLevel), !isBeneathQuiz {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            detailSheet = .quiz
          } label: {
            Label(L.VerbView.testMe, systemImage: "pencil.and.list.clipboard")
          }
          .accessibilityIdentifier("verb_test_button")
        }
      }

      ToolbarItem(placement: .topBarTrailing) {
        starButton
      }

      ToolbarItem(placement: .topBarTrailing) {
        Button {
          world.analytics.signal(name: .tapShareVerb)
          ShareSheet.present(
            text: verb.shareText(),
            title: verb.citationInfinitif,
            icon: UIImage(named: world.settings.appIcon.previewAssetName),
            anchorLabel: L.VerbView.share
          )
        } label: {
          Label(L.VerbView.share, systemImage: "square.and.arrow.up")
        }
        .accessibilityIdentifier("verb_share_button")
      }
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
      case .model(let destination):
        ModelView(model: destination.model, verbOrder: destination.verbOrder)
          .sheetDismissable()
      case .article(let info):
        TenseArticleSheet(info: info)
      case .verb(let destination):
        VerbView(verb: destination.verb, source: destination.source)
          .sheetDismissable()
      case .relatedList(let destination):
        RelatedVerbListView(destination: destination)
          .sheetDismissable()
      case .quiz:
        QuizSheet(scope: .verbPage(verb))
      }
    }
  }

  private var starButton: some View {
    let isStarred = world.learnerVerbs.isStarred(verb)
    return Button {
      let isNowStarred = world.learnerVerbs.toggleStar(verb)
      world.analytics.signal(name: .tapStarVerb, parameters: [
        ParameterKey.starred.rawValue: "\(isNowStarred)"
      ])
    } label: {
      Label(isStarred ? L.VerbView.unstar : L.VerbView.star, systemImage: isStarred ? "star.fill" : "star")
    }
    .sensoryFeedback(.selection, trigger: isStarred)
    .accessibilityIdentifier("verb_star_button")
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
      open(ModelDestination(model: model))
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
    VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
      ForEach(conjugations.personlessCells) { cell in
        VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
          TenseHeading(tense: cell.tense, openArticle: articleOpener(for: cell.tense))

          MarkableConjugation(cell: cell, isMarked: marks?.contains(cell.tense) == true)
            .leftAligned()
        }
      }
    }
    .card()
  }

  private func open(_ value: any Hashable) {
    if let verbPagePush {
      verbPagePush(value)
      return
    }
    switch value {
    case let destination as VerbDestination:
      detailSheet = .verb(destination)
    case let destination as ModelDestination:
      detailSheet = .model(destination)
    case let destination as RelatedVerbListDestination:
      detailSheet = .relatedList(destination)
    default:
      break
    }
  }

  private var compoundTensesAreShown: Binding<Bool> {
    Binding {
      showsCompoundTenses || compoundTensesAreForcedOn
    } set: { isShown in
      showsCompoundTenses = isShown
      compoundTensesAreForcedOn = false
    }
  }

  private var shouldShowColorKey: Bool {
    !hasSeenColorKey && conjugations.hasIrregularLetters
  }

  private func articleOpener(for tense: Tense) -> (() -> Void)? {
    guard let info = tense.article else {
      return nil
    }
    return {
      world.analytics.signal(name: .tapTenseArticle)
      if let tenseArticleOpener {
        tenseArticleOpener(info)
      } else {
        detailSheet = .article(info)
      }
    }
  }

  // The scroll tip waits for a page visit after the color key was closed, rather than replacing
  // it in place the moment it closes. With tips switched off for screenshots and video, TipKit
  // is never configured, so this leaves its datastore alone.
  private func unlockScrollTipIfDue() {
    guard TipDisplay.tipsEnabled, hasSeenColorKey else {
      return
    }
    ScrollToBottomTip.isUnlocked = true
  }

  /// A page opened from a search scrolls to the first cell the search matched. The scroll
  /// waits a turn of the run loop, because on appearance the cards have no frames yet.
  private func scrollToFirstMark(_ proxy: ScrollViewProxy) {
    guard !hasAppeared, let firstTense = marks?.tenses.first else {
      return
    }
    Task {
      proxy.scrollTo(VerbConjugations.scrollID(for: firstTense), anchor: .top)
    }
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
    // A page that returns after a tab switch, the background, or its own sheet is not a new open.
    if source != .resume {
      world.learnerVerbs.recordOpen(verb)
      world.practice.recordLookup(verb, source: source)
    }
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
      // A learner who already scrolls to the bottom does not need the advice.
      if section >= .etymology, TipDisplay.tipsEnabled {
        scrollToBottomTip.invalidate(reason: .actionPerformed)
      }
    } else {
      visibleSections.remove(section)
    }
  }

  private enum DetailSheet: Identifiable, Equatable {
    case model(ModelDestination)
    case article(Info)
    case verb(VerbDestination)
    case relatedList(RelatedVerbListDestination)
    case quiz

    var id: String {
      switch self {
      case .model(let destination):
        return "model-\(destination.model.id)"
      case .article(let info):
        return "article-\(info.stableKey)"
      case .verb(let destination):
        return "verb-\(destination.verb.id)"
      case .relatedList(let destination):
        return "related-\(destination.root)"
      case .quiz:
        return "quiz"
      }
    }
  }
}

private struct CompoundTensesView: View {
  let sections: [VerbConjugations.Section]
  let marks: MarkedConjugations?
  let openArticle: (Tense) -> (() -> Void)?
  let sectionVisibilityChanged: (VerbPageSection, Bool) -> Void

  init(
    verb: Verb,
    marks: MarkedConjugations?,
    openArticle: @escaping (Tense) -> (() -> Void)?,
    sectionVisibilityChanged: @escaping (VerbPageSection, Bool) -> Void
  ) {
    sections = VerbConjugations.sections(verb: verb, tables: TenseTable.compound)
    self.marks = marks
    self.openArticle = openArticle
    self.sectionVisibilityChanged = sectionVisibilityChanged
  }

  var body: some View {
    ForEach(sections) { section in
      TenseSectionView(section: section, marks: marks, openArticle: openArticle)
        .card()
        .scrollFade()
        .id(section.scrollID)
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
  let marks: MarkedConjugations?
  let openArticle: (Tense) -> (() -> Void)?

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      TenseHeading(tense: section.table.representative, openArticle: openArticle(section.table.representative))

      Grid(alignment: .leading, horizontalSpacing: Layout.doubleDefaultSpacing, verticalSpacing: 8) {
        ForEach(section.cells) { cell in
          GridRow(alignment: .firstTextBaseline) {
            Text(cell.pronoun)
              .smallLabel()
              .frenchPronunciation()
              .gridColumnAlignment(.leading)
              .accessibilityHidden(true)

            MarkableConjugation(cell: cell, isMarked: isMarked(cell))
              .gridColumnAlignment(.leading)
          }
        }
      }
    }
  }

  private func isMarked(_ cell: VerbConjugations.Cell) -> Bool {
    marks?.contains(cell.tense) == true
  }
}

/// A tense's name, the name a textbook also uses, and a button that opens the tense's article.
private struct TenseHeading: View {
  let tense: Tense
  let openArticle: (() -> Void)?

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack(alignment: .firstTextBaseline, spacing: 6) {
        Text(tense.titleCaseName)
          .subheadingLabel()
          .frenchPronunciation()
          .accessibilityAddTraits(.isHeader)

        if let openArticle {
          Button(action: openArticle) {
            Image(systemName: "questionmark.diamond.fill")
          }
          .buttonStyle(.borderless)
          .tint(.customRed)
          .accessibilityLabel(Text(L.Navigation.info))
          .accessibilityHint(Text(L.VerbView.articleButtonHint))
        }

        Spacer(minLength: 0)
      }

      if let secondName = tense.secondName {
        Text(L.VerbView.secondName(secondName))
          .smallLabel()
      }
    }
  }
}

private struct MarkableConjugation: View {
  let cell: VerbConjugations.Cell
  let isMarked: Bool

  var body: some View {
    Text(cell.display)
      .font(bodyFont)
      .frenchPronunciation()
      .accessibilityLabel(cell.accessibility)
      .accessibilityValue(Text(isMarked ? L.VerbView.matchesSearch : ""))
      .background {
        if isMarked {
          RoundedRectangle(cornerRadius: 6)
            .fill(Color.markedConjugation)
            .padding(-4)
        }
      }
      .copyOnLongPress(cell.copyText)
  }
}

/// A tense's Info article, opened from its heading on the verb page. A link to another article or
/// to a verb opens it inside the sheet, so that the learner can follow the thread and still close
/// the sheet onto the same verb page. A verb page inside the sheet opens its own articles here
/// too, rather than stacking a sheet on the sheet.
private struct TenseArticleSheet: View {
  let info: Info
  @Environment(\.dismiss) private var dismiss
  @State private var path = NavigationPath()

  var body: some View {
    NavigationStack(path: $path) {
      page(InfoView(info: info, openLink: open))
        .navigationDestination(for: Info.self) { info in
          page(InfoView(info: info, openLink: open))
        }
        .verbPageNavigation(path: $path) {
          dismiss()
        }
    }
    .environment(\.tenseArticleOpener) { info in
      path.append(info)
    }
  }

  private func page(_ content: some View) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(L.Navigation.done) {
            dismiss()
          }
        }
      }
  }

  private func open(_ url: URL) {
    guard url.isDeeplink, url.hasExpectedNumberOfDeeplinkComponents else {
      return
    }
    let target = url.pathComponents[1]
    switch url.host {
    case URL.infoHost:
      if let info = Info.info(deeplinkTarget: target) {
        path.append(info)
      }
    case URL.verbHost:
      if let verb = Verb.verbs[target] {
        path.append(VerbDestination(verb: verb, source: .infoLink))
      }
    default:
      break
    }
  }
}

extension EnvironmentValues {
  /// Set inside a tense article's sheet, so that a verb page there pushes an article instead of
  /// presenting one.
  @Entry var tenseArticleOpener: ((Info) -> Void)?
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return VerbView(verb: PreviewSupport.sampleVerb, source: .browse)
    .environment(Current)
}
#endif
