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
  @Environment(\.pushesTenseArticles) private var pushesTenseArticles
  @Environment(\.verbPagePush) private var verbPagePush
  @Environment(\.isBeneathQuiz) private var isBeneathQuiz
  @AppStorage("hasSeenConjugationColorKey") private var hasSeenColorKey = false
  @AppStorage("showsCompoundTenses") private var showsCompoundTenses = true
  let verb: Verb
  let marks: MarkedConjugations?
  /// A search that matched a compound tense shows the compound block on this page even when the
  /// learner has hidden it, without changing the stored choice.
  @State private var compoundTensesAreForcedOn: Bool
  @State private var detailSheet: DetailSheet?
  @State private var visits: VerbVisitTracker
  @State private var hasAppeared = false
  private let scrollToBottomTip = ScrollToBottomTip()

  init(verb: Verb, source: AnalyticsSource, marks: MarkedConjugations? = nil) {
    self.verb = verb
    self.marks = marks
    _compoundTensesAreForcedOn = State(initialValue: marks?.includesCompoundTense ?? false)
    _visits = State(initialValue: VerbVisitTracker(source: source))
  }

  private var conjugations: VerbConjugations {
    VerbConjugations.memoized(for: verb, pronounGender: world.settings.pronounGender)
  }

  var body: some View {
    ScrollViewReader { proxy in
      page
        .onAppear {
          scrollToFirstMark(proxy)
          hasAppeared = true
          perform(visits.pageAppeared())
          unlockScrollTipIfDue()
        }
    }
  }

  private var page: some View {
    let conjugations = conjugations
    return ScrollView {
      VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        Text(verb.infinitifWithPossibleExtraLetters)
          .headingLabel()
          .frenchPronunciation()
          .copyOnLongPress(verb.infinitif)
          .scrollFade()

        overviewCard
          .scrollFade()

        if shouldShowColorKey(conjugations) {
          colorKey
            .scrollFade()
        } else {
          TipView(scrollToBottomTip)
            .tipBackground(Color.customBackground)
        }

        tenseCards(conjugations.simpleSections, reaching: .simple)

        PersonlessCard(cells: conjugations.personlessCells, marks: marks, openArticle: articleOpener(for:))
          .card()
          .scrollFade()
          .id(TenseTable.personless)
          .reportsReaching(.simple, to: sectionVisibilityChanged)

        Toggle(isOn: compoundTensesAreShown) {
          Text(L.VerbView.showCompoundTenses)
            .subheadingLabel()
        }
        .toggleStyle(.switch)
        .tint(.customRed)
        .scrollFade()

        if compoundTensesAreShown.wrappedValue {
          tenseCards(conjugations.compoundSections, reaching: .compound)
        }

        if let etymologyText = Etymology.text(for: verb.infinitif) {
          etymologyCard(etymologyText)
            .scrollFade()
            .reportsReaching(.etymology, to: sectionVisibilityChanged)
        }

        ExampleCard(verb: verb)
          .scrollFade()
          .reportsReaching(.example, to: sectionVisibilityChanged)

        if !verb.related.isEmpty {
          RelatedVerbsView(related: verb.related)
            .scrollFade()
            .reportsReaching(.related, to: sectionVisibilityChanged)
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
        VerbStarButton(verb: verb)
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
      perform(visits.pageDisappeared())
    }
    .onChange(of: scenePhase) {
      perform(visits.scenePhaseChanged(to: scenePhase))
    }
    .onChange(of: detailSheet) {
      perform(visits.coverChanged(isCovered: detailSheet != nil))
    }
    .sheet(item: $detailSheet) { sheet in
      switch sheet {
      case .article(let info):
        ArticleSheet(info: info)
      case .quiz:
        QuizSheet(scope: .verbPage(verb))
      }
    }
  }

  private var overviewCard: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.VerbView.overview)
        .subheadingLabel()
        .accessibilityAddTraits(.isHeader)

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
        let defectGroup = DefectGroup.defectGroups[defectGroupId] {
        Text("\(L.VerbView.defective) " + defectGroup.description())
          .bodyLabel()
      }
    }
    .card()
  }

  private func modelRow(_ model: VerbModel) -> some View {
    Button {
      verbPagePush(.model(model))
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

  private func tenseCards(_ sections: [VerbConjugations.Section], reaching block: VerbPageSection) -> some View {
    ForEach(sections) { section in
      TenseSectionView(section: section, marks: marks, openArticle: articleOpener(for:))
        .card()
        .scrollFade()
        .id(section.table)
        .reportsReaching(block, to: sectionVisibilityChanged)
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

  private func shouldShowColorKey(_ conjugations: VerbConjugations) -> Bool {
    TipDisplay.tipsEnabled && !hasSeenColorKey && conjugations.hasIrregularLetters
  }

  private func articleOpener(for tense: Tense) -> (() -> Void)? {
    guard let info = tense.article else {
      return nil
    }
    return {
      world.analytics.signal(name: .tapTenseArticle)
      if pushesTenseArticles {
        verbPagePush(.article(info))
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
      proxy.scrollTo(firstTense.table, anchor: .top)
    }
  }

  private var colorKey: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack {
        Text(L.VerbView.colorKeyTitle)
          .subheadingLabel()
          .accessibilityAddTraits(.isHeader)
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

  private func perform(_ effects: [VerbVisitTracker.Effect]) {
    for effect in effects {
      switch effect {
      case let .signal(name, parameters):
        world.analytics.signal(name: name, parameters: parameters)
      case let .recordOpen(source):
        world.learnerVerbs.recordOpen(verb)
        world.practice.recordLookup(verb, source: source)
      }
    }
  }

  private func sectionVisibilityChanged(_ section: VerbPageSection, isVisible: Bool) {
    visits.sectionVisibilityChanged(section, isVisible: isVisible)
    // A learner who already scrolls to the bottom does not need the advice.
    if isVisible, section >= .etymology, TipDisplay.tipsEnabled {
      scrollToBottomTip.invalidate(reason: .actionPerformed)
    }
  }

  private enum DetailSheet: Identifiable, Equatable {
    case article(Info)
    case quiz

    var id: String {
      switch self {
      case .article(let info):
        return "article-\(info.stableKey)"
      case .quiz:
        return "quiz"
      }
    }
  }
}

private struct VerbStarButton: View {
  @Environment(World.self) private var world
  let verb: Verb

  var body: some View {
    let isStarred = world.learnerVerbs.isStarred(verb)
    Button {
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
}

private extension View {
  /// Reports when a third of this card comes on screen or leaves it, which counts as reaching
  /// `section`: a higher threshold could never be met by an etymology card taller than the
  /// screen.
  func reportsReaching(_ section: VerbPageSection, to report: @escaping (VerbPageSection, Bool) -> Void) -> some View {
    onScrollVisibilityChange(threshold: 0.3) { isVisible in
      report(section, isVisible)
    }
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return PreviewStack {
    VerbView(verb: PreviewSupport.sampleVerb, source: .browse)
  }
}
#endif
