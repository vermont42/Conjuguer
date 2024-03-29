//
//  VerbBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/15/21.
//

import SwiftUI

struct VerbBrowseView: View {
  @ObservedObject private var store: VerbStore
  @State private var isPresentingVerb = false
  @State private var searchText = ""

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      NavigationView {
        ZStack {
          Color.customBackground

          VStack {
            Picker("", selection: $store.verbSort) {
              ForEach(VerbSort.allCases, id: \.self) { type in
                Text(L.displayNameForVerbSort(type)).tag(type)
              }
            }
            .pickerStyle(SegmentedPickerStyle())

            ScrollView {
              LazyVStack {
                ForEach(searchResults, id: \.self) { verb in
                  NavigationLink(destination: VerbView(verb: verb)) {
                    ZStack {
                      Color.customBackground
                      Text(verb.infinitifWithPossibleExtraLetters)
                    }
                  }
                  .buttonStyle(PlainButtonStyle())
                  .frenchPronunciation()
                }
              }
              .navigationBarTitle(L.Navigation.verbs)
            }
          }
        }
      }
      .navigationViewStyle(.stack) // https://stackoverflow.com/a/66024249
      .padding()
      .searchable(text: $searchText, prompt: "", suggestions: {
        ForEach(searchResults, id: \.self) { result in
          Text(result.infinitifWithPossibleExtraLetters)
            .searchCompletion(result.infinitifWithPossibleExtraLetters)
        }
      })
    }
    .onChange(of: Current.verb) { _, newVerb in
      if newVerb != nil {
        isPresentingVerb = true
      }
    }
    .sheet(
      isPresented: $isPresentingVerb,
      onDismiss: {
        Current.verb = nil
        isPresentingVerb = false
      },
      content: {
        Current.verb.map {
          VerbView(verb: $0, shouldShowVerbHeading: true)
        }
      }
    )
    .onAppear {
      Current.analytics.recordViewAppeared("\(VerbBrowseView.self)")
      Current.reviewPrompter.promptableActionHappened()
    }
  }

  var searchResults: [Verb] {
    if searchText.isEmpty {
      return store.verbs
    } else {
      let matchingVerbs = store.verbs.filter { $0.infinitifWithPossibleExtraLetters.contains(searchText.localizedLowercase) }
      if matchingVerbs.isEmpty {
        SoundPlayer.play(.randomSadTrombone)
      }
      return matchingVerbs
    }
  }

  init() {
    store = VerbStore(world: Current)
  }
}

final class VerbStore: ObservableObject {
  @Published var verbs: [Verb]
  private let current: World
  private let frequencyVerbs: [Verb]
  private let alphabeticVerbs: [Verb]

  init(world: World) {
    self.current = world
    verbSort = current.settings.verbSort

    frequencyVerbs = Verb.verbs.values
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

    alphabeticVerbs = Verb.verbs.values.sorted { lhs, rhs in
      lhs.infinitif.compare(rhs.infinitif, locale: Util.french) == .orderedAscending
    }

    switch verbSort {
    case .frequency:
      verbs = frequencyVerbs
    case .alphabetical:
      verbs = alphabeticVerbs
    }
  }

  var verbSort: VerbSort {
    didSet {
      current.settings.verbSort = verbSort

      switch verbSort {
      case .frequency:
        verbs = frequencyVerbs
      case .alphabetical:
        verbs = alphabeticVerbs
      }
    }
  }
}
