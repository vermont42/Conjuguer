//
//  VerbBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/15/21.
//

import Observation
import SwiftUI
import TipKit

struct VerbBrowseView: View {
  @Environment(World.self) private var world
  @Environment(SceneRouter.self) private var router
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.scenePhase) private var scenePhase
  @State private var store: BrowseStore<Verb, VerbSort>?
  @State private var search = VerbSearchModel()
  @State private var engagement = SearchEngagement()
  @State private var path = NavigationPath()
  @State private var myVerbsIsChosen = false
  @FocusState private var searchIsFocused: Bool
  private let tryQuizTip = TryQuizTip()

  var body: some View {
    Group {
      if let store {
        content(store: store)
      } else {
        Color.customBackground
          .screenBackground()
      }
    }
    .onAppear {
      guard store == nil else {
        return
      }
      store = VerbBrowse.makeStore(world: world)
    }
  }

  private func content(store: BrowseStore<Verb, VerbSort>) -> some View {
    @Bindable var search = search
    let listContent = self.listContent

    let listModeBinding = Binding<VerbListMode>(
      get: { listMode },
      set: { mode in
        switch mode {
        case .sorted(let sort):
          myVerbsIsChosen = false
          withAnimation(.snappy) {
            store.sort = sort
          }
        case .myVerbs:
          myVerbsIsChosen = true
        }
      }
    )

    let sortPicker = Picker("", selection: listModeBinding) {
      ForEach(VerbListMode.allCases, id: \.self) { mode in
        Text(mode.displayName).tag(mode)
      }
    }
    .pickerStyle(.segmented)
    .accessibilityIdentifier("verb_browse_sort")
    .accessibilityLabel(Text(L.BrowseView.sortOrder))

    return NavigationStack(path: $path) {
      ZStack {
        Color.customBackground

        VStack {
          if horizontalSizeClass == .regular {
            sortPickerOrKeyRow(sortPicker)
          }

          TipView(tryQuizTip)

          ReviewCardHost(isShown: listContent.showsReviewCard, open: push) {
            list(listContent, store: store)
          }

          if horizontalSizeClass != .regular {
            sortPickerOrKeyRow(sortPicker)
          }
        }
        .padding()
      }
      .navigationTitle(L.Navigation.verbs)
      .verbPageNavigation(path: $path)
      .browseSearchable(text: $search.text, prompt: L.VerbBrowseView.searchPrompt, isFocused: $searchIsFocused, engagement: engagement)
      .onSubmit(of: .search) {
        // On iPhone, the keyboard's Search key keeps its usual meaning: it only hides the keyboard.
        if BrowseLayout.isPadOrMac, let destination = search.openForReturn(recents: shownRecents) {
          push(destination)
        }
      }
    }
    .screenBackground()
    .onChange(of: scenePhase) {
      if scenePhase == .background {
        search.appLeftForeground()
      }
    }
    .onChange(of: engagement.isEngaged) {
      // Not at the loss of focus: on iPad an accent key's touch takes the focus, and the letter
      // it then sets still belongs to the search that the control or a link opened.
      if !engagement.isEngaged {
        search.fieldClosed()
      }
    }
    .onChange(of: searchIsFocused) {
      guard BrowseLayout.isPadOrMac, let window = router.window else {
        return
      }
      if searchIsFocused {
        VerbSearchArrowKeys.install(in: window) { offset in
          moveSelection(by: offset)
        }
      } else {
        VerbSearchArrowKeys.uninstall(from: window)
      }
    }
    .onChange(of: router.searchRequest) {
      openRequestedSearch()
    }
    .sensoryFeedback(.selection, trigger: listMode)
    .recordsAppearance(as: "\(VerbBrowseView.self)")
    .onAppear {
      world.reviewPrompter.promptableActionHappened()
      openRequestedSearch()
    }
    .task {
      // Loading the map and folding its 243,000 conjugations takes over a second in a Debug
      // build, which the first keystroke should not wait for.
      await Task.detached(priority: .utility) {
        _ = ConjugationIndex.bundled
      }.value
    }
  }

  @ViewBuilder
  private func list(_ listContent: VerbListContent, store: BrowseStore<Verb, VerbSort>) -> some View {
    switch listContent {
    case .noResults:
      FailedVerbSearchView(
        query: search.query,
        guess: search.guess,
        pronounGender: world.settings.pronounGender,
        guessIsSelected: search.highlightedVerbID(recents: []) != nil
      ) { _ in
        if let destination = search.openGuess() {
          push(destination)
        }
      }
    case .myVerbs:
      MyVerbsList(open: push)
    case .all, .results, .recents:
      verbCollection(listContent, store: store)
    }
  }

  private func verbCollection(_ listContent: VerbListContent, store: BrowseStore<Verb, VerbSort>) -> some View {
    let recents = shownRecents
    let highlighted = search.highlightedVerbID(recents: recents)
    return ScrollViewReader { proxy in
      Group {
        if horizontalSizeClass == .regular {
          ScrollView {
            listHeading(listContent)
              .padding(.top, Layout.defaultSpacing)

            LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
              verbRows(listContent, store: store, recents: recents, highlighted: highlighted, isCard: true)
            }
            .padding(.vertical, Layout.defaultSpacing)
          }
        } else {
          List {
            listHeading(listContent)
              .listRowBackground(Color.customBackground)
              .listRowSeparator(.hidden)

            verbRows(listContent, store: store, recents: recents, highlighted: highlighted, isCard: false)
          }
          .listStyle(.plain)
        }
      }
      .scrollContentBackground(.hidden)
      .onChange(of: search.selectedVerbID) {
        scrollToSelection(proxy)
      }
    }
  }

  /// A search's results with the cells each matched, the recent verbs, or every verb. A row's
  /// source is settled as it is drawn, because a tap can take the focus from the field, and with
  /// it the recents, before the row's action runs.
  @ViewBuilder
  private func verbRows(_ listContent: VerbListContent, store: BrowseStore<Verb, VerbSort>, recents: [Verb], highlighted: String?, isCard: Bool) -> some View {
    switch listContent {
    case .results:
      ForEach(search.results) { result in
        verbButton(result.match.verb, detail: matchLine(result.match), isHighlighted: result.id == highlighted, isCard: isCard) {
          push(search.open(result))
        }
      }
    case .recents:
      verbButtons(recents, source: .recent, highlighted: highlighted, isCard: isCard)
    case .all:
      verbButtons(store.items, source: .browse, highlighted: highlighted, isCard: isCard)
    case .noResults, .myVerbs:
      EmptyView()
    }
  }

  private func verbButtons(_ verbs: [Verb], source: AnalyticsSource, highlighted: String?, isCard: Bool) -> some View {
    ForEach(verbs) { verb in
      verbButton(verb, detail: nil, isHighlighted: verb.id == highlighted, isCard: isCard) {
        push(VerbDestination(verb: verb, source: source))
      }
    }
  }

  private func verbButton(_ verb: Verb, detail: String?, isHighlighted: Bool, isCard: Bool, open: @escaping () -> Void) -> some View {
    Button(action: open) {
      if isCard {
        BrowseRow(verb: verb, detail: detail)
          .card(accent: isHighlighted ? .customRed : nil)
      } else {
        BrowseRow(verb: verb, detail: detail)
      }
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(Self.rowIdentifier(verb))
    .accessibilityAddTraits(isHighlighted ? .isSelected : [])
    .listRowBackground(isHighlighted ? Color.customRed.opacity(0.2) : Color.customBackground)
  }

  @ViewBuilder
  private func listHeading(_ listContent: VerbListContent) -> some View {
    if listContent == .recents {
      Text(L.MyVerbs.recent)
        .subheadingLabel()
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("recent_verbs_heading")
    } else {
      Text(L.VerbBrowseView.verbCount(count: listContent == .results ? search.verbCount : Verb.rankCount))
        .subheadingLabel()
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("verb_browse_count")
    }
  }

  private func matchLine(_ match: VerbSearch.Match) -> String? {
    match.conjugation?.line(pronounGender: match.verb.pronounGender(for: world.settings.pronounGender))
  }

  private var listMode: VerbListMode {
    myVerbsIsChosen ? .myVerbs : .sorted(store?.sort ?? Settings.verbSortDefault)
  }

  private var listContent: VerbListContent {
    VerbListContent(
      isSearching: search.isSearching,
      hasFailed: search.hasFailed,
      isEngaged: engagement.isEngaged,
      hasRecents: !world.learnerVerbs.recentVerbs.isEmpty,
      mode: listMode
    )
  }

  /// The recents while the list shows them, which is when Return and the arrow keys reach them.
  private var shownRecents: [Verb] {
    listContent == .recents ? world.learnerVerbs.recentVerbs : []
  }

  /// Every push from the tab, the review card's and My Verbs' included, since each can be tapped
  /// while an empty search is being dismissed.
  private func push(_ destination: VerbDestination) {
    engagement.push(fieldIsEmpty: !search.isSearching) {
      path.append(VerbPageRoute.verb(destination))
    }
  }

  static func rowIdentifier(_ verb: Verb) -> String {
    "verb_row_\(verb.infinitif)"
  }

  private func sortPickerOrKeyRow(_ sortPicker: some View) -> some View {
    SortPickerOrKeyRow(engagement: engagement, isSearching: search.isSearching) { letter in
      engagement.insert(letter) { letters in
        search.text.append(letters)
      } focus: {
        searchIsFocused = true
      }
    } sortPicker: {
      sortPicker
    }
  }

  private func moveSelection(by offset: Int) {
    guard path.isEmpty else {
      return
    }
    search.moveSelection(by: offset, recents: shownRecents)
  }

  private func scrollToSelection(_ proxy: ScrollViewProxy) {
    guard let id = search.selectedVerbID else {
      return
    }
    withAnimation {
      proxy.scrollTo(id)
    }
  }

  /// Text that arrives with the request shows as results, with the keyboard down so that they
  /// are visible. A request with no text, or with empty text, is for typing, so it focuses the
  /// field. A nil text, Command-F's, keeps what the field holds.
  private func openRequestedSearch() {
    guard let request = router.searchRequest, store != nil else {
      return
    }
    router.searchRequest = nil
    if let text = request.text {
      search.request(text: text, source: request.source)
    }
    let wantsKeyboard = request.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    let didPop = !path.isEmpty
    if didPop {
      path = NavigationPath()
    }
    engagement.focus(afterPopping: didPop) {
      searchIsFocused = wantsKeyboard
    }
  }
}

enum VerbBrowse {
  static func makeStore(world: World) -> BrowseStore<Verb, VerbSort> {
    let frequencyVerbs = Verb.verbs.values
      .sorted { lhs, rhs in
        (lhs.frequency, lhs.id) < (rhs.frequency, rhs.id)
      }

    let alphabeticVerbs = Verb.verbs.values.sorted { lhs, rhs in
      lhs.infinitif.compare(rhs.infinitif, locale: Util.french) == .orderedAscending
    }

    return BrowseStore(
      itemsBySort: [.frequency: frequencyVerbs, .alphabetical: alphabeticVerbs],
      initialSort: world.settings.verbSort,
      persistSort: { world.settings.verbSort = $0 }
    )
  }
}
