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
  @State private var selectedVerb: VerbDestination?
  @State private var searchTracker = SearchTracker()
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

    let sortPicker = Picker("", selection: $store.sort) {
      ForEach(VerbSort.allCases, id: \.self) { type in
        Text(type.displayName).tag(type)
      }
    }
    .pickerStyle(.segmented)
    .accessibilityIdentifier("verb_browse_sort")
    .accessibilityLabel(Text(L.BrowseView.sortOrder))

    return NavigationStack {
      ZStack {
        Color.customBackground

        VStack {
          if horizontalSizeClass == .regular {
            sortPickerOrKeyRow(sortPicker)
          }

          TipView(tryQuizTip)

          verbCollection

          if horizontalSizeClass != .regular {
            sortPickerOrKeyRow(sortPicker)
          }
        }
        .padding()
      }
      .navigationTitle(L.Navigation.verbs)
      .navigationDestination(item: $selectedVerb) { destination in
        VerbView(verb: destination.verb, source: destination.source, marks: destination.marks)
      }
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
      if let query = searchTracker.textChanged(to: searchText) {
        signalEndedSearch(query: query)
      }
    }
    .onChange(of: scenePhase) {
      if scenePhase == .background, let query = searchTracker.finish() {
        signalEndedSearch(query: query)
      }
    }
    .onChange(of: searchIsFocused) {
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
    .onChange(of: world.verbSearchIsRequested) {
      focusSearchIfRequested()
    }
    .onChange(of: store.sort) { _, _ in
      withAnimation(.snappy) {
        updateSearchResults(playSoundIfEmpty: false)
      }
    }
    .sensoryFeedback(.selection, trigger: store.sort)
    .sheet(item: $world.verb) { verb in
      VerbView(verb: verb, source: world.verbSource)
        .sheetDismissable()
    }
    .recordsAppearance(as: "\(VerbBrowseView.self)")
    .onAppear {
      world.reviewPrompter.promptableActionHappened()
      focusSearchIfRequested()
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
          verbCount
            .padding(.top, Layout.defaultSpacing)

          LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
            ForEach(Array(searchResults.enumerated()), id: \.element.id) { index, verb in
              Button {
                openResult(verb, at: index)
              } label: {
                verbRow(verb, at: index)
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
          verbCount
            .listRowBackground(Color.customBackground)
            .listRowSeparator(.hidden)

          ForEach(Array(searchResults.enumerated()), id: \.element.id) { index, verb in
            Button {
              openResult(verb, at: index)
            } label: {
              verbRow(verb, at: index)
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
  private var verbCount: some View {
    if !searchResults.isEmpty {
      // Rows outnumber verbs: haïr, ouïr, saillir and sortir each carry two entries, and every
      // other count the app quotes is the 6,326 distinct infinitives.
      Text(L.VerbBrowseView.verbCount(count: Set(searchResults.map(\.infinitif)).count))
        .subheadingLabel()
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("verb_browse_count")
    }
  }

  private func verbRow(_ verb: Verb, at index: Int) -> some View {
    BrowseRow(
      title: verb.infinitifWithPossibleExtraLetters,
      subtitle: verb.translation,
      detail: conjugation(at: index)?.line(pronounGender: world.settings.pronounGender),
      badge: BrowseRow.Badge(text: "#\(verb.frequency)", tint: .customBlue)
    )
  }

  private func conjugation(at index: Int) -> MatchedConjugation? {
    guard isSearching, searchMatches.indices.contains(index) else {
      return nil
    }
    return searchMatches[index].conjugation
  }

  private static func rowIdentifier(_ verb: Verb) -> String {
    "verb_row_\(verb.infinitif)"
  }

  // A keyboard toolbar never appears for the navigation bar's search field (iOS 26.3), so the
  // accent row takes the sort picker's place while the field is focused. Search ranks its
  // results whatever the sort order, so the picker has nothing to do then.
  @ViewBuilder
  private func sortPickerOrKeyRow(_ sortPicker: some View) -> some View {
    if searchIsFocused {
      FrenchLetterKeyRow { letter in
        searchText.append(letter)
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
  /// search found nothing. None while the field is blank, since the whole list is no search.
  private var keyboardTargets: [Verb] {
    guard isSearching else {
      return []
    }
    if searchResults.isEmpty, let guess {
      return [guess.verb]
    }
    return searchResults
  }

  private func moveKeyboardSelection(by offset: Int) {
    guard selectedVerb == nil else {
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
    if searchResults.isEmpty, let guess {
      openGuess(guess)
    } else {
      openResult(targets[index], at: index)
    }
  }

  /// A row opened while the field holds a query is a search result, and opening it ends the
  /// search. Opening another row after returning to the same results ends nothing more.
  private func openResult(_ verb: Verb, at index: Int) {
    guard isSearching, searchMatches.indices.contains(index) else {
      selectedVerb = VerbDestination(verb: verb, source: .browse)
      return
    }
    if let query = searchTracker.finish() {
      signal(.opened(query: query, resultCount: searchMatches.count, kind: searchMatches[index].kind, position: index))
    }
    selectedVerb = VerbDestination(verb: verb, source: .search, marks: searchMatches[index].conjugation?.marks)
  }

  private func openGuess(_ guess: VerbSearch.Guess) {
    if let query = searchTracker.finish() {
      signal(.openedGuess(query: query))
    }
    selectedVerb = VerbDestination(verb: guess.verb, source: .searchGuess, marks: guess.conjugation?.marks)
  }

  private func signalEndedSearch(query: String) {
    guard let store else {
      return
    }
    signal(.ended(query: query, matches: VerbSearch.matches(for: query, in: store.items, includeGlosses: true)))
  }

  private func signal(_ report: SearchReport) {
    world.analytics.signal(name: .finishSearch, parameters: report.parameters)
  }

  private func scrollToKeyboardSelection(_ proxy: ScrollViewProxy) {
    guard let keyboardSelection, searchResults.indices.contains(keyboardSelection) else {
      return
    }
    withAnimation {
      proxy.scrollTo(searchResults[keyboardSelection].id)
    }
  }

  private func focusSearchIfRequested() {
    guard world.verbSearchIsRequested else {
      return
    }
    world.verbSearchIsRequested = false
    Task {
      if selectedVerb != nil {
        selectedVerb = nil
        // Hack: focus requested while the pop animates sets the focus state without making the
        // field first responder, so typing goes nowhere (Konjugieren). Wait out the animation.
        try? await Task.sleep(for: .milliseconds(500))
      }
      searchIsFocused = true
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
