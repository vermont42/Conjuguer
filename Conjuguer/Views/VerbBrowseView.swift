//
//  VerbBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/15/21.
//

import Observation
import SwiftUI

struct VerbBrowseView: View {
  @Environment(World.self) private var world
  @State private var store = VerbBrowse.makeStore(world: Current)
  @State private var searchText = ""
  @State private var searchResults: [Verb] = []

  var body: some View {
    @Bindable var store = store
    @Bindable var world = world

    NavigationStack {
      ZStack {
        Color.customBackground

        VStack {
          Picker("", selection: $store.sort) {
            ForEach(VerbSort.allCases, id: \.self) { type in
              Text(L.displayNameForVerbSort(type)).tag(type)
            }
          }
          .pickerStyle(.segmented)
          .accessibilityIdentifier("verb_browse_sort")
          .accessibilityLabel(Text(L.VerbBrowseView.sortOrder))

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
        .padding()
      }
      .navigationTitle(L.Navigation.verbs)
      .navigationDestination(for: Verb.self) { verb in
        VerbView(verb: verb)
      }
      .searchable(text: $searchText, prompt: L.VerbBrowseView.searchPrompt, suggestions: {
        ForEach(searchResults) { result in
          Text(result.infinitifWithPossibleExtraLetters)
            .searchCompletion(result.infinitifWithPossibleExtraLetters)
        }
      })
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
    .onAppear {
      world.analytics.recordViewAppeared("\(VerbBrowseView.self)")
      world.reviewPrompter.promptableActionHappened()
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
  }

  private func updateSearchResults(playSoundIfEmpty: Bool) {
    if searchText.isEmpty {
      searchResults = store.items
    } else {
      let matchingVerbs = store.items.filter { $0.infinitifWithPossibleExtraLetters.localizedStandardContains(searchText) }
      if matchingVerbs.isEmpty && playSoundIfEmpty {
        SoundPlayer.play(.randomSadTrombone)
      }
      searchResults = matchingVerbs
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
