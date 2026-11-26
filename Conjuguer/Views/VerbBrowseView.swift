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
  @State private var verbToUnstar: Verb?
  @State private var reviewCard: ReviewCardState?
  @State private var reviewCardIsChosen = false
  @State private var appWasInBackground = false
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
    @Bindable var store = store
    @Bindable var search = search

    let listModeBinding = Binding<VerbListMode>(
      get: { listMode },
      set: { mode in
        if let sort = mode.sort {
          myVerbsIsChosen = false
          withAnimation(.snappy) {
            store.sort = sort
          }
        } else {
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

          if let reviewCard, showsReviewCard {
            ReviewCardView(
              verb: reviewCard.offer.verb,
              caption: L.ReviewCard.caption(daysAgo: reviewCard.offer.daysSinceActivity, wasLookedUp: reviewCard.offer.wasLookedUp),
              isRevealed: reviewCard.isRevealed,
              reveal: revealReviewCard,
              open: openReviewCard,
              dismiss: dismissReviewCard
            )
            .frame(maxWidth: horizontalSizeClass == .regular ? Self.reviewCardMaxWidth : .infinity)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.opacity)
            .onAppear {
              signalReviewCardShown()
            }
          }

          // My Verbs is a List of its own, because only a List's rows can be swiped to delete.
          if showsMyVerbs {
            myVerbsList
          } else {
            verbCollection(store: store)
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
      switch scenePhase {
      case .background:
        appWasInBackground = true
        search.appLeftForeground()
      case .active where appWasInBackground:
        appWasInBackground = false
        chooseReviewCard()
      default:
        break
      }
    }
    .onChange(of: world.settings.reviewCardSuppression) {
      if world.settings.reviewCardSuppression == .off, reviewCard == nil {
        chooseReviewCard()
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
      if !reviewCardIsChosen {
        chooseReviewCard()
      }
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
  private func verbCollection(store: BrowseStore<Verb, VerbSort>) -> some View {
    let recents = shownRecents
    let highlighted = search.highlightedVerbID(recents: recents)
    if search.hasFailed {
      FailedVerbSearchView(
        query: search.query,
        guess: search.guess,
        pronounGender: world.settings.pronounGender,
        guessIsSelected: highlighted != nil
      ) { _ in
        if let destination = search.openGuess() {
          push(destination)
        }
      }
    } else if horizontalSizeClass == .regular {
      ScrollViewReader { proxy in
        ScrollView {
          listHeading
            .padding(.top, Layout.defaultSpacing)

          LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
            verbRows(store: store, recents: recents, highlighted: highlighted, isCard: true)
          }
          .padding(.vertical, Layout.defaultSpacing)
        }
        .scrollContentBackground(.hidden)
        .onChange(of: search.selectedVerbID) {
          scrollToSelection(proxy)
        }
      }
    } else {
      ScrollViewReader { proxy in
        List {
          listHeading
            .listRowBackground(Color.customBackground)
            .listRowSeparator(.hidden)

          verbRows(store: store, recents: recents, highlighted: highlighted, isCard: false)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .onChange(of: search.selectedVerbID) {
          scrollToSelection(proxy)
        }
      }
    }
  }

  /// A search's results with the cells each matched, or with the field empty the recent verbs or
  /// every verb. A row's source is settled as it is drawn, because a tap can take the focus from
  /// the field, and with it the recents, before the row's action runs.
  @ViewBuilder
  private func verbRows(store: BrowseStore<Verb, VerbSort>, recents: [Verb], highlighted: String?, isCard: Bool) -> some View {
    if search.isSearching {
      ForEach(search.results) { result in
        verbButton(result.match.verb, detail: matchLine(result.match), isHighlighted: result.id == highlighted, isCard: isCard) {
          push(search.open(result))
        }
      }
    } else {
      let source: AnalyticsSource = showsRecents ? .recent : .browse
      ForEach(showsRecents ? recents : store.items) { verb in
        verbButton(verb, detail: nil, isHighlighted: verb.id == highlighted, isCard: isCard) {
          push(VerbDestination(verb: verb, source: source))
        }
      }
    }
  }

  private func verbButton(_ verb: Verb, detail: String?, isHighlighted: Bool, isCard: Bool, open: @escaping () -> Void) -> some View {
    Button(action: open) {
      if isCard {
        verbRow(verb, detail: detail)
          .card(accent: isHighlighted ? .customRed : nil)
      } else {
        verbRow(verb, detail: detail)
      }
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(Self.rowIdentifier(verb))
    .accessibilityAddTraits(isHighlighted ? .isSelected : [])
    .listRowBackground(isHighlighted ? Color.customRed.opacity(0.2) : Color.customBackground)
  }

  @ViewBuilder
  private var listHeading: some View {
    if showsRecents {
      Text(L.MyVerbs.recent)
        .subheadingLabel()
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("recent_verbs_heading")
    } else {
      Text(L.VerbBrowseView.verbCount(count: search.isSearching ? search.verbCount : Verb.rankCount))
        .subheadingLabel()
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("verb_browse_count")
    }
  }

  private func verbRow(_ verb: Verb, detail: String? = nil) -> some View {
    BrowseRow(
      title: verb.infinitifWithPossibleExtraLetters,
      subtitle: verb.translation,
      detail: detail,
      badge: BrowseRow.Badge(text: "#\(verb.frequency)", tint: .customBlue)
    )
  }

  private func matchLine(_ match: VerbSearch.Match) -> String? {
    match.conjugation?.line(pronounGender: match.verb.pronounGender(for: world.settings.pronounGender))
  }

  private var listMode: VerbListMode {
    myVerbsIsChosen ? .myVerbs : VerbListMode(store?.sort ?? Settings.verbSortDefault)
  }

  private var showsRecents: Bool {
    engagement.isEngaged && !search.isSearching && !world.learnerVerbs.recentVerbs.isEmpty
  }

  /// The recents while the list shows them, which is when Return and the arrow keys reach them.
  private var shownRecents: [Verb] {
    showsRecents ? world.learnerVerbs.recentVerbs : []
  }

  private var showsMyVerbs: Bool {
    myVerbsIsChosen && !search.isSearching && !showsRecents
  }

  private var showsReviewCard: Bool {
    world.settings.reviewCardSuppression == .off && !search.isSearching && !showsRecents && !myVerbsIsChosen
  }

  private static let reviewCardMaxWidth: CGFloat = 560

  /// Each launch, and each return from the background, offers the irregular verb whose key
  /// conjugation is longest overdue in the practice record, if any.
  /// The choice is made once per opening, so revealing a card does not swap it for the next one.
  private func chooseReviewCard() {
    reviewCardIsChosen = true
    guard world.settings.reviewCardSuppression == .off else {
      reviewCard = nil
      return
    }
    reviewCard = world.practice.cardOffer().map { ReviewCardState(offer: $0) }
  }

  private func signalReviewCardShown() {
    guard reviewCard?.wasSignaled == false else {
      return
    }
    reviewCard?.wasSignaled = true
    world.analytics.signal(name: .viewReviewCard)
  }

  private func revealReviewCard() {
    guard let reviewCard, !reviewCard.isRevealed else {
      return
    }
    world.practice.recordReview(reviewCard.offer)
    world.gameCenter.reportAchievements(in: world.practice.record)
    world.analytics.signal(name: .tapRevealReviewCard)
    withAnimation {
      self.reviewCard?.isRevealed = true
    }
  }

  private func openReviewCard() {
    guard let reviewCard else {
      return
    }
    path.append(VerbPageRoute.verb(VerbDestination(verb: reviewCard.offer.verb, source: .reviewCard)))
  }

  /// A card dismissed before its conjugations were seen was no review, so its verb's due key
  /// conjugations return tomorrow in the same box.
  private func dismissReviewCard() {
    guard let reviewCard else {
      return
    }
    if !reviewCard.isRevealed {
      world.practice.snooze(reviewCard.offer)
    }
    withAnimation {
      self.reviewCard = nil
    }
  }

  private func push(_ destination: VerbDestination) {
    engagement.push(fieldIsEmpty: !search.isSearching) {
      path.append(VerbPageRoute.verb(destination))
    }
  }

  /// The starred verbs, then the recent ones not starred. Search ignores this choice, as it
  /// ignores the sort order. A swipe deletes a verb, star and opens alike, so it leaves the list;
  /// a starred verb asks first, since its star was put there on purpose.
  @ViewBuilder
  private var myVerbsList: some View {
    let starred = world.learnerVerbs.starredVerbs
    let recent = world.learnerVerbs.recentUnstarredVerbs
    if starred.isEmpty, recent.isEmpty {
      ContentUnavailableView(L.MyVerbs.emptyTitle, systemImage: "star", description: Text(L.MyVerbs.emptyDescription))
        .frame(maxHeight: .infinity)
        .accessibilityIdentifier("my_verbs_empty")
    } else {
      List {
        if !starred.isEmpty {
          Section {
            ForEach(starred) { verb in
              myVerbRow(verb)
                .swipeActions(edge: .trailing) {
                  // Not .destructive: that role removes the row at once, before the learner answers.
                  Button {
                    verbToUnstar = verb
                  } label: {
                    Label(L.MyVerbs.delete, systemImage: "star.slash")
                  }
                  .tint(.customRed)
                }
            }
          } header: {
            myVerbsHeading(L.MyVerbs.starred)
              .accessibilityIdentifier("my_verbs_starred_heading")
          }
        }

        if !recent.isEmpty {
          Section {
            ForEach(recent) { verb in
              myVerbRow(verb)
                .swipeActions(edge: .trailing) {
                  Button(role: .destructive) {
                    withAnimation {
                      world.learnerVerbs.remove(verb)
                    }
                  } label: {
                    Label(L.MyVerbs.delete, systemImage: "trash")
                  }
                }
            }
          } header: {
            HStack(alignment: .firstTextBaseline) {
              myVerbsHeading(L.MyVerbs.recent)
                .accessibilityIdentifier("my_verbs_recent_heading")

              Spacer()

              Button(L.MyVerbs.clearRecent) {
                withAnimation {
                  world.learnerVerbs.clearRecents()
                }
              }
              .buttonStyle(.borderless)
              .tint(.customRed)
              .accessibilityIdentifier("my_verbs_clear_recent")
            }
          }
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
      .accessibilityIdentifier("my_verbs_list")
      .alert(
        L.MyVerbs.unstarTitle(verbToUnstar?.infinitifWithPossibleExtraLetters ?? ""),
        isPresented: Binding(
          get: { verbToUnstar != nil },
          set: { isPresented in
            if !isPresented {
              verbToUnstar = nil
            }
          }
        ),
        presenting: verbToUnstar
      ) { verb in
        Button(L.MyVerbs.unstarConfirm, role: .destructive) {
          withAnimation {
            world.learnerVerbs.remove(verb)
          }
        }
        Button(role: .cancel) {}
      } message: { _ in
        Text(L.MyVerbs.unstarMessage)
      }
    }
  }

  private func myVerbsHeading(_ text: String) -> some View {
    Text(text)
      .subheadingLabel()
      .accessibilityAddTraits(.isHeader)
  }

  private func myVerbRow(_ verb: Verb) -> some View {
    Button {
      path.append(VerbPageRoute.verb(VerbDestination(verb: verb, source: .myVerbs)))
    } label: {
      verbRow(verb)
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(Self.rowIdentifier(verb))
    .listRowBackground(Color.customBackground)
  }

  private static func rowIdentifier(_ verb: Verb) -> String {
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

private struct ReviewCardState {
  let offer: PracticeStore.CardOffer
  var isRevealed = false
  var wasSignaled = false
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
