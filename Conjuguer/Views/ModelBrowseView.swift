//
//  ModelBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/17/21.
//

import Observation
import SwiftUI
import TipKit

struct ModelBrowseView: View {
  @Environment(World.self) private var world
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var store: BrowseStore<ModelAndDecorator, ModelSort>?
  @State private var searchText = ""
  @State private var searchResults: [ModelAndDecorator] = []
  @State private var selectedModel: VerbModel?
  private let exploreModelsTip = ExploreModelsTip()

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

  private func content(store: BrowseStore<ModelAndDecorator, ModelSort>) -> some View {
    @Bindable var store = store
    @Bindable var world = world

    let sortPicker = Picker("", selection: $store.sort) {
      ForEach(ModelSort.allCases, id: \.self) { type in
        Text(type.displayName).tag(type)
      }
    }
    .pickerStyle(.segmented)
    .accessibilityLabel(Text(L.BrowseView.sortOrder))

    return NavigationStack {
      ZStack {
        Color.customBackground

        VStack {
          if horizontalSizeClass == .regular {
            sortPicker
          }

          TipView(exploreModelsTip)

          modelCollection

          if horizontalSizeClass != .regular {
            sortPicker
          }
        }
        .padding()
      }
      .navigationTitle(L.Navigation.models)
      .navigationDestination(item: $selectedModel) { model in
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
            Button {
              selectedModel = modelAndDecorator.model
            } label: {
              modelRow(modelAndDecorator)
                .card()
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(Self.rowIdentifier(modelAndDecorator))
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
        Button {
          selectedModel = modelAndDecorator.model
        } label: {
          modelRow(modelAndDecorator)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(Self.rowIdentifier(modelAndDecorator))
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
    BrowseRow(
      title: modelAndDecorator.model.exemplarWithPossibleExtraLetters + modelAndDecorator.decorator,
      badge: modelAndDecorator.irregularityBadge.map { irregularityBadge(percent: $0) }
    )
  }

  private static func rowIdentifier(_ modelAndDecorator: ModelAndDecorator) -> String {
    "model_row_\(modelAndDecorator.model.exemplar)"
  }

  private func irregularityBadge(percent: Int) -> BrowseRow.Badge {
    BrowseRow.Badge(
      text: "\(percent)%",
      tint: percent == 0 ? .customBlue : .customRed,
      accessibilityLabel: Text("\(percent)% \(L.ModelView.irregular)")
    )
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
