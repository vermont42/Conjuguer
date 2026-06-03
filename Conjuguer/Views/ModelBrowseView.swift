//
//  ModelBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/17/21.
//

import Observation
import SwiftUI

struct ModelBrowseView: View {
  @Environment(World.self) private var world
  @State private var store = ModelStore(world: Current)
  @State private var searchText = ""
  @State private var searchResults: [ModelAndDecorator] = []

  var body: some View {
    @Bindable var store = store
    @Bindable var world = world

    NavigationStack {
      ZStack {
        Color.customBackground

        VStack {
          Picker("", selection: $store.modelSort) {
            ForEach(ModelSort.allCases, id: \.self) { type in
              Text(L.displayNameForModelSort(type)).tag(type)
            }
          }
          .pickerStyle(.segmented)
          .accessibilityLabel(Text(L.ModelBrowseView.sortOrder))

          List(searchResults) { modelAndDecorator in
            NavigationLink(value: modelAndDecorator.model) {
              Text(modelAndDecorator.model.exemplarWithPossibleExtraLetters + modelAndDecorator.decorator)
                .tableText()
            }
            .frenchPronunciation()
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
      .navigationTitle(L.Navigation.models)
      .navigationDestination(for: VerbModel.self) { model in
        ModelView(model: model)
      }
      .searchable(text: $searchText, prompt: L.ModelBrowseView.searchPrompt, suggestions: {
        ForEach(searchResults) { modelAndDecorator in
          Text("\(modelAndDecorator.model.exemplarWithPossibleExtraLetters)\(modelAndDecorator.decorator)")
            .tableText()
            .frenchPronunciation()
            .searchCompletion(modelAndDecorator.model.exemplarWithPossibleExtraLetters)
        }
      })
    }
    .screenBackground()
    .onChange(of: searchText, initial: true) { _, _ in
      updateSearchResults(playSoundIfEmpty: true)
    }
    .onChange(of: store.modelSort) { _, _ in
      updateSearchResults(playSoundIfEmpty: false)
    }
    .sheet(item: $world.verbModel) { model in
      ModelView(model: model)
        .sheetDismissable()
    }
    .onAppear {
      world.analytics.recordViewAppeared("\(ModelBrowseView.self)")
    }
  }

  private func updateSearchResults(playSoundIfEmpty: Bool) {
    if searchText.isEmpty {
      searchResults = store.modelsAndDecorators
    } else {
      let matchingModels = store.modelsAndDecorators.filter { $0.model.exemplar.contains(searchText.localizedLowercase) }
      if matchingModels.isEmpty && playSoundIfEmpty {
        SoundPlayer.play(.randomSadTrombone)
      }
      searchResults = matchingModels
    }
  }
}

struct ModelAndDecorator: Identifiable, Hashable {
  let model: VerbModel
  let decorator: String
  var id: String { model.id }
}

@Observable
final class ModelStore {
  var modelsAndDecorators: [ModelAndDecorator]
  private let current: World
  private let irregularityModelsAndDecorators: [ModelAndDecorator]
  private let alphabeticModelsAndDecorators: [ModelAndDecorator]
  private let identifierModelsAndDecorators: [ModelAndDecorator]

  init(world: World) {
    self.current = world

    irregularityModelsAndDecorators = VerbModel.models.values.sorted { lhs, rhs in
      lhs.irregularity >= rhs.irregularity
    }
    .map { ModelAndDecorator(model: $0, decorator: " • \($0.irregularity)%") }

    alphabeticModelsAndDecorators = VerbModel.models.values.sorted { lhs, rhs in
      lhs.exemplar.compare(rhs.exemplar, locale: Util.french) == .orderedAscending
    }
    .map { ModelAndDecorator(model: $0, decorator: "") }

    identifierModelsAndDecorators = VerbModel.models.values.sorted { lhs, rhs in
      lhs.position < rhs.position
    }
    .map { ModelAndDecorator(model: $0, decorator: " (\($0.id))") }

    let initialSort = current.settings.modelSort
    switch initialSort {
    case .irregularity:
      modelsAndDecorators = irregularityModelsAndDecorators
    case .alphabetical:
      modelsAndDecorators = alphabeticModelsAndDecorators
    case .identifier:
      modelsAndDecorators = identifierModelsAndDecorators
    }
    modelSort = initialSort
  }

  var modelSort: ModelSort {
    didSet {
      current.settings.modelSort = modelSort

      switch modelSort {
      case .irregularity:
        modelsAndDecorators = irregularityModelsAndDecorators
      case .alphabetical:
        modelsAndDecorators = alphabeticModelsAndDecorators
      case .identifier:
        modelsAndDecorators = identifierModelsAndDecorators
      }
    }
  }
}
