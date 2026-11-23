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
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.scenePhase) private var scenePhase
  @State private var store: BrowseStore<Verb, VerbSort>?
  @State private var searchText = ""
  @State private var searchResults: [Verb] = []
  @State private var searchMatches: [VerbSearch.Match] = []
  @State private var guess: VerbSearch.Guess?
  @State private var keyboardSelection: Int?
  @State private var path = NavigationPath()
  @State private var searchTracker = SearchTracker()
  @State private var myVerbsIsChosen = false
  @State private var searchIsEngaged = false
  @State private var searchFocusLostAt: Date?
  @State private var verbToUnstar: Verb?
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
    @Bindable var world = world

    let listModeBinding = Binding<VerbListMode>(
      get: { listMode },
      set: { mode in
        if let sort = mode.sort {
          myVerbsIsChosen = false
          store.sort = sort
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

          // My Verbs is a List of its own, because only a List's rows can be swiped to delete.
          if showsMyVerbs {
            myVerbsList
          } else {
            verbCollection
          }

          if horizontalSizeClass != .regular {
            sortPickerOrKeyRow(sortPicker)
          }
        }
        .padding()
      }
      .navigationTitle(L.Navigation.verbs)
      .verbPageNavigation(path: $path)
      .searchable(text: $searchText, placement: BrowseLayout.searchPlacement, prompt: L.VerbBrowseView.searchPrompt)
      .searchFocused($searchIsFocused)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
      .onSubmit(of: .search) {
        // On iPhone, the keyboard's Search key keeps its usual meaning: it only hides the keyboard.
        if BrowseLayout.isPadOrMac {
          openKeyboardSelection()
        }
      }
    }
    .screenBackground()
    .onChange(of: searchText, initial: true) { _, _ in
      keyboardSelection = nil
      updateSearchResults(playSoundIfEmpty: true)
      if let search = searchTracker.textChanged(to: searchText) {
        signalEndedSearch(search)
      }
    }
    .onChange(of: scenePhase) {
      if scenePhase == .background, let search = searchTracker.finish() {
        signalEndedSearch(search)
      }
    }
    .onChange(of: searchIsFocused) {
      searchFocusChanged()
      if !searchIsFocused {
        searchTracker.fieldClosed()
      }
      guard BrowseLayout.isPadOrMac else {
        return
      }
      if searchIsFocused {
        VerbSearchArrowKeys.install { offset in
          moveKeyboardSelection(by: offset)
        }
      } else {
        VerbSearchArrowKeys.uninstall()
      }
    }
    .onChange(of: world.searchRequest) {
      openRequestedSearch()
    }
    .onChange(of: store.sort) { _, _ in
      withAnimation(.snappy) {
        updateSearchResults(playSoundIfEmpty: false)
      }
    }
    .sensoryFeedback(.selection, trigger: listMode)
    .sheet(item: $world.verb) { verb in
      VerbView(verb: verb, source: world.verbSource, marks: world.verbMarks)
        .sheetDismissable()
    }
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
  private var verbCollection: some View {
    let verbs = displayedVerbs
    let browseSource = self.browseSource
    if searchResults.isEmpty && isSearching {
      FailedVerbSearchView(
        query: trimmedSearchText,
        guess: guess,
        pronounGender: world.settings.pronounGender,
        guessIsSelected: keyboardSelection == 0
      ) { guess in
        openGuess(guess)
      }
    } else if horizontalSizeClass == .regular {
      ScrollViewReader { proxy in
        ScrollView {
          listHeading
            .padding(.top, Layout.defaultSpacing)

          LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
            ForEach(Array(verbs.enumerated()), id: \.element.id) { index, verb in
              Button {
                openResult(verb, at: index, browseSource: browseSource)
              } label: {
                verbRow(verb, detail: matchLine(at: index))
                  .card(accent: index == keyboardSelection ? .customRed : nil)
              }
              .buttonStyle(.plain)
              .accessibilityIdentifier(Self.rowIdentifier(verb))
            }
          }
          .padding(.vertical, Layout.defaultSpacing)
        }
        .scrollContentBackground(.hidden)
        .onChange(of: keyboardSelection) {
          scrollToKeyboardSelection(proxy)
        }
      }
    } else {
      ScrollViewReader { proxy in
        List {
          listHeading
            .listRowBackground(Color.customBackground)
            .listRowSeparator(.hidden)

          ForEach(Array(verbs.enumerated()), id: \.element.id) { index, verb in
            Button {
              openResult(verb, at: index, browseSource: browseSource)
            } label: {
              verbRow(verb, detail: matchLine(at: index))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(Self.rowIdentifier(verb))
            .listRowBackground(index == keyboardSelection ? Color.customRed.opacity(0.2) : Color.customBackground)
          }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .onChange(of: keyboardSelection) {
          scrollToKeyboardSelection(proxy)
        }
      }
    }
  }

  @ViewBuilder
  private var listHeading: some View {
    if showsRecents {
      Text(L.MyVerbs.recent)
        .subheadingLabel()
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("recent_verbs_heading")
    } else if !searchResults.isEmpty {
      // Rows outnumber verbs: haïr, ouïr, saillir and sortir each carry two entries, and every
      // other count the app quotes is the 6,326 distinct infinitives.
      Text(L.VerbBrowseView.verbCount(count: Set(searchResults.map(\.infinitif)).count))
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

  private func matchLine(at index: Int) -> String? {
    guard isSearching, searchMatches.indices.contains(index) else {
      return nil
    }
    return searchMatches[index].conjugation?.line(pronounGender: world.settings.pronounGender)
  }

  private var listMode: VerbListMode {
    myVerbsIsChosen ? .myVerbs : VerbListMode(store?.sort ?? Settings.verbSortDefault)
  }

  /// The verbs last opened, shown while the field is focused and empty, before anything is typed.
  private var showsRecents: Bool {
    searchIsEngaged && !isSearching && !world.learnerVerbs.recentVerbs.isEmpty
  }

  private var showsMyVerbs: Bool {
    myVerbsIsChosen && !isSearching && !showsRecents
  }

  private var displayedVerbs: [Verb] {
    showsRecents ? world.learnerVerbs.recentVerbs : searchResults
  }

  /// The source of a row opened with the field empty. Settled as the row is drawn, because a tap
  /// can take the focus from the field, and with it the recents, before the row's action runs.
  private var browseSource: AnalyticsSource {
    showsRecents ? .recent : .browse
  }

  // Hack: on iPad, a tap outside an empty search field ends the search at touch-down, before the
  // tap completes. Views that followed the focus (the recent verbs, the letter row) vanished
  // under the finger, so tapping a recent verb or é did nothing (Konjugieren, iPadOS 26.3). They
  // follow searchIsEngaged instead, which lets go of the focus a moment later. See also
  // pushFromSearch.
  private func searchFocusChanged() {
    guard !searchIsFocused else {
      searchIsEngaged = true
      searchFocusLostAt = nil
      return
    }
    searchFocusLostAt = .now
    Task {
      try? await Task.sleep(for: Self.searchLingering)
      if !searchIsFocused {
        searchIsEngaged = false
      }
    }
  }

  private static let searchLingering = Duration.milliseconds(700)

  // A tap that ends an empty search on iPad would push while the search is still animating away,
  // and UIKit drops such a push; see ViewControllerTransitions. A typed search does not end on
  // that tap, and on iPhone nothing is animating, so both push at once.
  private func pushFromSearch(_ destination: VerbDestination) {
    guard !isSearching, searchFocusLostAt != nil else {
      path.append(destination)
      return
    }
    Task {
      await ViewControllerTransitions.waitUntilIdle()
      path.append(destination)
    }
  }

  // On iPad a key's tap ends an empty search, and the search clears its text as it goes, so a
  // letter set meanwhile is lost or shows in the results but not the field. The letter waits for
  // the search to be gone, then reopens it, as a search request from outside the app does.
  private func insertLetter(_ letter: String) {
    guard !searchIsFocused else {
      searchText.append(letter)
      return
    }
    Task {
      await ViewControllerTransitions.waitUntilIdle()
      searchText.append(letter)
      searchIsFocused = true
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
      path.append(VerbDestination(verb: verb, source: .myVerbs))
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

  // A keyboard toolbar never appears for the navigation bar's search field (iOS 26.3), so the
  // accent row takes the sort picker's place while the field is focused. Search ranks its
  // results whatever the sort order, so the picker has nothing to do then.
  @ViewBuilder
  private func sortPickerOrKeyRow(_ sortPicker: some View) -> some View {
    if searchIsEngaged {
      FrenchLetterKeyRow { letter in
        insertLetter(letter)
      }
    } else {
      sortPicker
    }
  }

  private var trimmedSearchText: String {
    searchText.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var isSearching: Bool {
    !trimmedSearchText.isEmpty
  }

  private func updateSearchResults(playSoundIfEmpty: Bool) {
    guard let store else {
      return
    }
    searchMatches = isSearching ? VerbSearch.matches(for: searchText, in: store.items, includeGlosses: true) : []
    // "j'" and "nous" are a conjugation still being typed, and the trombone would sound mid-word.
    let isStillTyping = ConjugationQuery(searchText).isOnlyPronouns
    searchResults = BrowseSearch.results(in: store.items, query: searchText, playSoundIfEmpty: playSoundIfEmpty && !isStillTyping) { _ in
      searchMatches.map(\.verb)
    }
    guess = searchResults.isEmpty && isSearching ? VerbSearch.guess(for: searchText, in: store.items) : nil
  }

  /// The rows that Return and the arrow keys move through: the results, or the guess when a
  /// search found nothing, or the recent verbs in the empty field. None while the field shows
  /// the whole list, which is no search.
  private var keyboardTargets: [Verb] {
    guard isSearching else {
      return showsRecents ? world.learnerVerbs.recentVerbs : []
    }
    if searchResults.isEmpty, let guess {
      return [guess.verb]
    }
    return searchResults
  }

  private func moveKeyboardSelection(by offset: Int) {
    guard path.isEmpty else {
      return
    }
    keyboardSelection = Self.keyboardSelection(after: keyboardSelection, moving: offset, count: keyboardTargets.count)
  }

  /// The first arrow press lands on the first result, and the selection stops at either end
  /// rather than wrapping.
  nonisolated static func keyboardSelection(after current: Int?, moving offset: Int, count: Int) -> Int? {
    let lastIndex = count - 1
    guard lastIndex >= 0 else {
      return nil
    }
    guard let current else {
      return offset > 0 ? 0 : nil
    }
    return min(max(current + offset, 0), lastIndex)
  }

  /// Return opens the highlighted row, else the first result, else the guess.
  private func openKeyboardSelection() {
    let targets = keyboardTargets
    let index = keyboardSelection ?? 0
    guard targets.indices.contains(index) else {
      return
    }
    if isSearching, searchResults.isEmpty, let guess {
      openGuess(guess)
    } else {
      openResult(targets[index], at: index, browseSource: browseSource)
    }
  }

  /// A row opened while the field holds a query is a search result, and opening it ends the
  /// search. Opening another row after returning to the same results ends nothing more.
  private func openResult(_ verb: Verb, at index: Int, browseSource: AnalyticsSource) {
    guard isSearching, searchMatches.indices.contains(index) else {
      pushFromSearch(VerbDestination(verb: verb, source: browseSource))
      return
    }
    if let search = searchTracker.finish() {
      signal(.opened(query: search.query, resultCount: searchMatches.count, kind: searchMatches[index].kind, position: index, source: search.source))
    }
    path.append(VerbDestination(verb: verb, source: .search, marks: searchMatches[index].conjugation?.marks))
  }

  private func openGuess(_ guess: VerbSearch.Guess) {
    if let search = searchTracker.finish() {
      signal(.openedGuess(query: search.query, source: search.source))
    }
    path.append(VerbDestination(verb: guess.verb, source: .searchGuess, marks: guess.conjugation?.marks))
  }

  private func signalEndedSearch(_ search: SearchTracker.Search) {
    guard let store else {
      return
    }
    signal(.ended(query: search.query, matches: VerbSearch.matches(for: search.query, in: store.items, includeGlosses: true), source: search.source))
  }

  private func signal(_ report: SearchReport) {
    world.analytics.signal(name: .finishSearch, parameters: report.parameters)
  }

  private func scrollToKeyboardSelection(_ proxy: ScrollViewProxy) {
    let verbs = displayedVerbs
    guard let keyboardSelection, verbs.indices.contains(keyboardSelection) else {
      return
    }
    withAnimation {
      proxy.scrollTo(verbs[keyboardSelection].id)
    }
  }

  /// Text that arrives with the request shows as results, with the keyboard down so that they
  /// are visible. A request with no text, or with empty text, is for typing, so it focuses the
  /// field. A nil text, Command-F's, keeps what the field holds.
  private func openRequestedSearch() {
    guard let request = world.searchRequest, store != nil else {
      return
    }
    world.searchRequest = nil
    if let text = request.text {
      if let ended = searchTracker.fieldOpened(from: request.source) {
        signalEndedSearch(ended)
      }
      searchText = text
      // onChange(of: searchText) does not fire when the text is unchanged, and the request
      // still begins a search.
      _ = searchTracker.textChanged(to: text)
    }
    let wantsKeyboard = request.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    Task {
      if !path.isEmpty {
        path = NavigationPath()
        // Hack: focus requested while the pop animates sets the focus state without making the
        // field first responder, so typing goes nowhere (Konjugieren). Wait out the animation.
        try? await Task.sleep(for: .milliseconds(500))
      }
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
