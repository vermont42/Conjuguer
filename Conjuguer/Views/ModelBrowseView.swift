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
  @State private var failedSearchSound = FailedSearchSound()
  @State private var engagement = SearchEngagement()
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

    let sortBinding = Binding<ModelSort>(
      get: { store.sort },
      set: { sort in
        withAnimation(.snappy) {
          store.sort = sort
        }
      }
    )

    let sortPicker = Picker("", selection: sortBinding) {
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

          modelCollection(store: store)

          if horizontalSizeClass != .regular {
            sortPickerOrKeyRow(sortPicker)
          }
        }
        .padding()
      }
      .navigationTitle(L.Navigation.models)
      .verbPageNavigation(path: $path)
      .browseSearchable(text: $searchText, prompt: L.ModelBrowseView.searchPrompt, isFocused: $searchIsFocused, engagement: engagement)
    }
    .screenBackground()
    .onChange(of: trimmedSearchText) {
      updateSearchResults(store: store)
      if failedSearchSound.searchChanged(hasFailed: isSearching && searchResults.isEmpty, isStillTyping: false) {
        world.soundPlayer.play(.randomSadTrombone)
      }
    }
    // A model's row carries its decorator, " (1-9)" under Identifier, so the results are the
    // sort's own items.
    .onChange(of: store.sort) {
      updateSearchResults(store: store)
    }
    .sensoryFeedback(.selection, trigger: store.sort)
    .recordsAppearance(as: "\(ModelBrowseView.self)")
  }

  private var trimmedSearchText: String {
    searchText.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var isSearching: Bool {
    !trimmedSearchText.isEmpty
  }

  private func modelCollection(store: BrowseStore<ModelAndDecorator, ModelSort>) -> some View {
    modelsAndCollections(store: store)
      .scrollContentBackground(.hidden)
      .overlay {
        if isSearching && searchResults.isEmpty {
          ContentUnavailableView.search(text: trimmedSearchText)
        }
      }
  }

  @ViewBuilder
  private func modelsAndCollections(store: BrowseStore<ModelAndDecorator, ModelSort>) -> some View {
    let showsCollections = !isSearching
    let models = isSearching ? searchResults : store.items
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
            ForEach(models) { modelAndDecorator in
              modelButton(modelAndDecorator, isCard: true)
            }
          }
        }
        .padding(.vertical, Layout.defaultSpacing)
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
          ForEach(models) { modelAndDecorator in
            modelButton(modelAndDecorator, isCard: false)
          }
        } header: {
          if showsCollections {
            sectionHeading(L.Navigation.models)
          }
        }
      }
      .listStyle(.plain)
    }
  }

  private static let collectionPairs = stride(from: 0, to: VerbCollection.featured.count, by: 2).map {
    Array(VerbCollection.featured[$0 ..< min($0 + 2, VerbCollection.featured.count)])
  }

  @ViewBuilder
  private func collectionButton(_ collection: VerbCollection, isCard: Bool) -> some View {
    Button {
      push(.collection(VerbCollectionDestination(collection: collection, source: .tab)))
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

  private func modelButton(_ modelAndDecorator: ModelAndDecorator, isCard: Bool) -> some View {
    Button {
      push(.model(modelAndDecorator.model))
    } label: {
      if isCard {
        modelRow(modelAndDecorator)
          .card()
      } else {
        modelRow(modelAndDecorator)
      }
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(Self.rowIdentifier(modelAndDecorator))
    .listRowBackground(Color.customBackground)
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

  private func push(_ route: VerbPageRoute) {
    engagement.push(fieldIsEmpty: !isSearching) {
      path.append(route)
    }
  }

  private func sortPickerOrKeyRow(_ sortPicker: some View) -> some View {
    SortPickerOrKeyRow(engagement: engagement, isSearching: isSearching) { letter in
      engagement.insert(letter) { letters in
        searchText.append(letters)
      } focus: {
        searchIsFocused = true
      }
    } sortPicker: {
      sortPicker
    }
  }

  private func updateSearchResults(store: BrowseStore<ModelAndDecorator, ModelSort>) {
    guard isSearching else {
      searchResults = []
      return
    }
    let itemsById = Dictionary(store.items.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    searchResults = ModelSearch.matches(for: trimmedSearchText, in: store.items.map(\.model), verbs: Array(Verb.verbs.values)).compactMap { match in
      var item = itemsById[match.model.id]
      item?.matchedVerb = match.verb?.infinitifWithPossibleExtraLetters
      return item
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
