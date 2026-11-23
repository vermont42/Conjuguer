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
  @State private var path = NavigationPath()
  @FocusState private var searchIsFocused: Bool
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

    return NavigationStack(path: $path) {
      ZStack {
        Color.customBackground

        VStack {
          if horizontalSizeClass == .regular {
            sortPickerOrKeyRow(sortPicker)
          }

          TipView(exploreModelsTip)

          modelCollection

          if horizontalSizeClass != .regular {
            sortPickerOrKeyRow(sortPicker)
          }
        }
        .padding()
      }
      .navigationTitle(L.Navigation.models)
      .verbPageNavigation(path: $path)
      .searchable(text: $searchText, placement: BrowseLayout.searchPlacement, prompt: L.ModelBrowseView.searchPrompt)
      .searchFocused($searchIsFocused)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
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
    .sheet(item: $world.collection) { destination in
      VerbCollectionView(destination: destination)
        .sheetDismissable()
    }
    .recordsAppearance(as: "\(ModelBrowseView.self)")
  }

  // The collections lead the tab while it lists every model, and give way to a search's results.
  private var showsCollections: Bool {
    searchText.isEmpty
  }

  @ViewBuilder
  private var modelCollection: some View {
    if horizontalSizeClass == .regular {
      ScrollView {
        VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
          if showsCollections {
            sectionHeading(L.VerbCollection.heading)

            // Two by two: at the models' narrower width the titles wrapped and the cards ran
            // to uneven heights.
            Grid(horizontalSpacing: Layout.doubleDefaultSpacing, verticalSpacing: Layout.doubleDefaultSpacing) {
              ForEach(Self.collectionPairs, id: \.first) { pair in
                GridRow {
                  ForEach(pair) { collection in
                    collectionButton(collection, isCard: true)
                  }
                }
              }
            }

            sectionHeading(L.Navigation.models)
          }

          LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
            ForEach(searchResults) { modelAndDecorator in
              Button {
                path.append(ModelDestination(model: modelAndDecorator.model))
              } label: {
                modelRow(modelAndDecorator)
                  .card()
              }
              .buttonStyle(.plain)
              .accessibilityIdentifier(Self.rowIdentifier(modelAndDecorator))
            }
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
      List {
        if showsCollections {
          Section {
            ForEach(VerbCollection.featured) { collection in
              collectionButton(collection, isCard: false)
                .listRowBackground(Color.customBackground)
            }
          } header: {
            sectionHeading(L.VerbCollection.heading)
          }
        }

        Section {
          ForEach(searchResults) { modelAndDecorator in
            Button {
              path.append(ModelDestination(model: modelAndDecorator.model))
            } label: {
              modelRow(modelAndDecorator)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(Self.rowIdentifier(modelAndDecorator))
            .listRowBackground(Color.customBackground)
          }
        } header: {
          if showsCollections {
            sectionHeading(L.Navigation.models)
          }
        }
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

  private static let collectionPairs = stride(from: 0, to: VerbCollection.featured.count, by: 2).map {
    Array(VerbCollection.featured[$0 ..< min($0 + 2, VerbCollection.featured.count)])
  }

  @ViewBuilder
  private func collectionButton(_ collection: VerbCollection, isCard: Bool) -> some View {
    Button {
      path.append(VerbCollectionDestination(collection: collection, source: .tab))
    } label: {
      if isCard {
        VerbCollectionRow(collection: collection)
          .frame(maxHeight: .infinity, alignment: .top)
          .card()
      } else {
        VerbCollectionRow(collection: collection)
      }
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("collection_row_\(collection.key)")
  }

  private func sectionHeading(_ text: String) -> some View {
    Text(text)
      .subheadingLabel()
      .accessibilityAddTraits(.isHeader)
  }

  private func modelRow(_ modelAndDecorator: ModelAndDecorator) -> some View {
    BrowseRow(
      title: modelAndDecorator.model.exemplarWithPossibleExtraLetters + modelAndDecorator.decorator,
      subtitle: modelAndDecorator.matchedVerb,
      subtitleIsFrench: true,
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

  private func updateSearchResults(playSoundIfEmpty: Bool) {
    guard let store else {
      return
    }
    let itemsById = Dictionary(store.items.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    searchResults = BrowseSearch.results(in: store.items, query: searchText, playSoundIfEmpty: playSoundIfEmpty) { query in
      ModelSearch.matches(for: query, in: store.items.map(\.model), verbs: Array(Verb.verbs.values)).compactMap { match in
        var item = itemsById[match.model.id]
        item?.matchedVerb = match.verb?.infinitifWithPossibleExtraLetters
        return item
      }
    }
  }
}

struct ModelAndDecorator: Identifiable, Hashable {
  let model: VerbModel
  let decorator: String
  var irregularityBadge: Int?
  var matchedVerb: String?
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
