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
  @State private var store = ModelBrowse.makeStore(world: Current)
  @State private var searchText = ""
  @State private var searchResults: [ModelAndDecorator] = []

  var body: some View {
    @Bindable var store = store
    @Bindable var world = world

    NavigationStack {
      ZStack {
        Color.customBackground

        VStack {
          Picker("", selection: $store.sort) {
            ForEach(ModelSort.allCases, id: \.self) { type in
              Text(L.displayNameForModelSort(type)).tag(type)
            }
          }
          .pickerStyle(.segmented)
          .accessibilityLabel(Text(L.ModelBrowseView.sortOrder))

          List(searchResults) { modelAndDecorator in
            NavigationLink(value: modelAndDecorator.model) {
              HStack {
                Text(modelAndDecorator.model.exemplarWithPossibleExtraLetters + modelAndDecorator.decorator)
                  .tableText()
                if let irregularity = modelAndDecorator.irregularityBadge {
                  Spacer()
                  IrregularityBadge(percent: irregularity)
                }
              }
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
    .onChange(of: store.sort) { _, _ in
      withAnimation(.snappy) {
        updateSearchResults(playSoundIfEmpty: false)
      }
    }
    .sensoryFeedback(.selection, trigger: store.sort)
    .sheet(item: $world.verbModel) { model in
      ModelView(model: model)
        .sheetDismissable()
    }
    .recordsAppearance(as: "\(ModelBrowseView.self)")
  }

  private func updateSearchResults(playSoundIfEmpty: Bool) {
    if searchText.isEmpty {
      searchResults = store.items
    } else {
      let matchingModels = store.items.filter { $0.model.exemplar.localizedStandardContains(searchText) }
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
  var irregularityBadge: Int?
  var id: String { model.id }
}

enum ModelBrowse {
  static func makeStore(world: World) -> BrowseStore<ModelAndDecorator, ModelSort> {
    let irregularityModelsAndDecorators = VerbModel.models.values.sorted { lhs, rhs in
      if lhs.irregularity != rhs.irregularity {
        return lhs.irregularity > rhs.irregularity
      }
      return lhs.exemplar.compare(rhs.exemplar, locale: Util.french) == .orderedAscending
    }
    .map { ModelAndDecorator(model: $0, decorator: "", irregularityBadge: $0.irregularity) }

    let alphabeticModelsAndDecorators = VerbModel.models.values.sorted { lhs, rhs in
      lhs.exemplar.compare(rhs.exemplar, locale: Util.french) == .orderedAscending
    }
    .map { ModelAndDecorator(model: $0, decorator: "") }

    let identifierModelsAndDecorators = VerbModel.models.values.sorted { lhs, rhs in
      lhs.position < rhs.position
    }
    .map { ModelAndDecorator(model: $0, decorator: " (\($0.id))") }

    return BrowseStore(
      itemsBySort: [
        .irregularity: irregularityModelsAndDecorators,
        .alphabetical: alphabeticModelsAndDecorators,
        .identifier: identifierModelsAndDecorators
      ],
      initialSort: world.settings.modelSort,
      persistSort: { world.settings.modelSort = $0 }
    )
  }
}
