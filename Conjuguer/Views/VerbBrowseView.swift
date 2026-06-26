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
  @State private var store: BrowseStore<Verb, VerbSort>?
  @State private var searchText = ""
  @State private var searchResults: [Verb] = []
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

  @ViewBuilder
  private func content(store: BrowseStore<Verb, VerbSort>) -> some View {
    @Bindable var store = store
    @Bindable var world = world

    NavigationStack {
      ZStack {
        Color.customBackground

        VStack {
          Picker("", selection: $store.sort) {
            ForEach(VerbSort.allCases, id: \.self) { type in
              Text(type.displayName).tag(type)
            }
          }
          .pickerStyle(.segmented)
          .accessibilityIdentifier("verb_browse_sort")
          .accessibilityLabel(Text(L.BrowseView.sortOrder))

          TipView(tryQuizTip)

          verbCollection
        }
        .padding()
      }
      .navigationTitle(L.Navigation.verbs)
      .navigationDestination(for: Verb.self) { verb in
        VerbView(verb: verb)
      }
      .searchable(text: $searchText, prompt: L.VerbBrowseView.searchPrompt)
    }
    .screenBackground()
    .onChange(of: searchText, initial: true) { _, _ in
      updateSearchResults(playSoundIfEmpty: true)
    }
    .onChange(of: store.sort) { _, _ in
      withAnimation(.snappy) {
        updateSearchResults(playSoundIfEmpty: false)
      }
    }
    .sensoryFeedback(.selection, trigger: store.sort)
    .sheet(item: $world.verb) { verb in
      VerbView(verb: verb)
        .sheetDismissable()
    }
    .recordsAppearance(as: "\(VerbBrowseView.self)")
    .onAppear {
      world.reviewPrompter.promptableActionHappened()
    }
  }

  @ViewBuilder
  private var verbCollection: some View {
    if horizontalSizeClass == .regular {
      ScrollView {
        LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
          ForEach(searchResults) { verb in
            NavigationLink(value: verb) {
              verbRow(verb)
                .card()
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.vertical, Layout.defaultSpacing)
      }
      .scrollContentBackground(.hidden)
      .overlay {
        if searchResults.isEmpty && !searchText.isEmpty {
          ContentUnavailableView.search(text: searchText)
        }
      }
    } else {
      List(searchResults) { verb in
        NavigationLink(value: verb) {
          verbRow(verb)
        }
        .listRowBackground(Color.customBackground)
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
      .overlay {
        if searchResults.isEmpty && !searchText.isEmpty {
          ContentUnavailableView.search(text: searchText)
        }
      }
    }
  }

  private func verbRow(_ verb: Verb) -> some View {
    HStack(alignment: .firstTextBaseline) {
      VStack(alignment: .leading, spacing: 2) {
        Text(verb.infinitifWithPossibleExtraLetters)
          .tableText()
          .frenchPronunciation()

        Text(verb.translation)
          .smallLabel()
          .englishPronunciation()
      }

      if let frequency = verb.frequency {
        Spacer()
        Text("#\(frequency)")
          .smallLabel()
          .accessibilityHidden(true)
      }
    }
    .accessibilityIdentifier("verb_row_\(verb.infinitif)")
  }

  private func updateSearchResults(playSoundIfEmpty: Bool) {
    guard let store else {
      return
    }
    searchResults = BrowseSearch.results(in: store.items, query: searchText, playSoundIfEmpty: playSoundIfEmpty) {
      $0.infinitifWithPossibleExtraLetters.localizedStandardContains($1)
    }
  }
}

enum VerbBrowse {
  static func makeStore(world: World) -> BrowseStore<Verb, VerbSort> {
    let frequencyVerbs = Verb.verbs.values
      .sorted { lhs, rhs in
        if lhs.frequency == nil && rhs.frequency == nil {
          return lhs.infinitif.compare(rhs.infinitif, locale: Util.french) == .orderedAscending
        } else if lhs.frequency == nil && rhs.frequency != nil {
          return false
        } else if lhs.frequency != nil && rhs.frequency == nil {
          return true
        } else {
          return (lhs.frequency ?? 0) < (rhs.frequency ?? 0)
        }
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
