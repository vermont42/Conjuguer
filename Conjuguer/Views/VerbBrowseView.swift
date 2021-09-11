//
//  VerbBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/15/21.
//

import SwiftUI

struct VerbBrowseView: View {
  @EnvironmentObject var current: World
  @ObservedObject var store: VerbStore

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
                ForEach(store.verbs, id: \.self) { verb in
                  NavigationLink(destination: VerbView(verb: verb), label: {
                    ZStack {
                      Color.customBackground

                      Text(verb.infinitifWithPossibleExtraLetters)
                        .tableText()
                    }
                  })
                    .buttonStyle(PlainButtonStyle())
                }
              }
                .navigationBarTitle(L.Navigation.verbs)
            }
          }
        }
      }
        .navigationViewStyle(StackNavigationViewStyle()) // https://stackoverflow.com/a/66024249
        .padding()
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
      .filter { $0.frequency != nil }
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
    case .alphabetic:
      verbs = alphabeticVerbs
    }
  }

  var verbSort: VerbSort {
    didSet {
      current.settings.verbSort = verbSort

      switch verbSort {
      case .frequency:
        verbs = frequencyVerbs
      case .alphabetic:
        verbs = alphabeticVerbs
      }
    }
  }
}
