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
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var store: BrowseStore<ModelAndDecorator, ModelSort>?
  @State private var searchText = ""
  @State private var searchResults: [ModelAndDecorator] = []

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
      store = ModelBrowse.makeStore(world: world)
    }
  }

  @ViewBuilder
  private func content(store: BrowseStore<ModelAndDecorator, ModelSort>) -> some View {
    @Bindable var store = store
    @Bindable var world = world

    NavigationStack {
      ZStack {
        Color.customBackground

        VStack {
          Picker("", selection: $store.sort) {
            ForEach(ModelSort.allCases, id: \.self) { type in
              Text(type.displayName).tag(type)
            }
          }
          .pickerStyle(.segmented)
          .accessibilityLabel(Text(L.BrowseView.sortOrder))

          modelCollection
        }
        .padding()
      }
      .navigationTitle(L.Navigation.models)
      .navigationDestination(for: VerbModel.self) { model in
        ModelView(model: model)
      }
      .searchable(text: $searchText, prompt: L.ModelBrowseView.searchPrompt)
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

  @ViewBuilder
  private var modelCollection: some View {
    if horizontalSizeClass == .regular {
      ScrollView {
        LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
          ForEach(searchResults) { modelAndDecorator in
            NavigationLink(value: modelAndDecorator.model) {
              modelRow(modelAndDecorator)
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
      List(searchResults) { modelAndDecorator in
        NavigationLink(value: modelAndDecorator.model) {
          modelRow(modelAndDecorator)
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

  private func modelRow(_ modelAndDecorator: ModelAndDecorator) -> some View {
    HStack {
      Text(modelAndDecorator.model.exemplarWithPossibleExtraLetters + modelAndDecorator.decorator)
        .tableText()
      if let irregularity = modelAndDecorator.irregularityBadge {
        Spacer()
        IrregularityBadge(percent: irregularity)
      }
    }
    .frenchPronunciation()
  }

  private func updateSearchResults(playSoundIfEmpty: Bool) {
    guard let store else {
      return
    }
    searchResults = BrowseSearch.results(in: store.items, query: searchText, playSoundIfEmpty: playSoundIfEmpty) {
      $0.model.exemplarWithPossibleExtraLetters.localizedStandardContains($1)
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
