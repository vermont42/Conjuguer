//
//  VerbListPage.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/27/26.
//

import SwiftUI

/// A page of verbs, the most frequent first or in French alphabetical order, each row pushing its
/// verb's page, in a grid on iPad. A featured collection's page and the list of every verb built on
/// one root are both this page: the collection's puts its heading and bar above the picker, and
/// checks the verbs already looked up.
struct VerbListPage<Header: View>: View {
  let verbs: [Verb]
  let source: AnalyticsSource
  /// "collection" gives `collection_sort` and `collection_verb_<dictionaryKey>`.
  let identifierPrefix: String
  let checksOpenedVerbs: Bool
  let header: Header
  @Environment(World.self) private var world
  @Environment(\.verbPagePush) private var push
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var order = VerbSort.frequency

  init(
    verbs: [Verb],
    source: AnalyticsSource,
    identifierPrefix: String,
    checksOpenedVerbs: Bool = false,
    @ViewBuilder header: () -> Header
  ) {
    self.verbs = verbs
    self.source = source
    self.identifierPrefix = identifierPrefix
    self.checksOpenedVerbs = checksOpenedVerbs
    self.header = header()
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        header

        Picker(L.BrowseView.sortOrder, selection: $order) {
          ForEach(VerbSort.allCases, id: \.self) { order in
            Text(order.displayName)
              .tag(order)
          }
        }
        .pickerStyle(.segmented)
        .sensoryFeedback(.selection, trigger: order)
        .accessibilityIdentifier("\(identifierPrefix)_sort")

        if horizontalSizeClass == .regular {
          LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
            rows
          }
        } else {
          LazyVStack(alignment: .leading, spacing: Layout.defaultSpacing) {
            rows
          }
        }
      }
      .padding(.horizontal, Layout.doubleDefaultSpacing)
      .padding(.bottom, Layout.doubleDefaultSpacing)
    }
    .screenBackground()
    .navigationBarTitleDisplayMode(.inline)
  }

  private var rows: some View {
    ForEach(verbs.sorted(by: order.areInIncreasingOrder)) { verb in
      Button {
        push(.verb(VerbDestination(verb: verb, source: source)))
      } label: {
        BrowseRow(verb: verb, isChecked: checksOpenedVerbs && world.learnerVerbs.hasOpened(verb))
          .card()
      }
      .buttonStyle(.plain)
      .accessibilityIdentifier("\(identifierPrefix)_verb_\(verb.dictionaryKey)")
    }
  }
}

extension VerbListPage where Header == EmptyView {
  init(verbs: [Verb], source: AnalyticsSource, identifierPrefix: String) {
    self.init(verbs: verbs, source: source, identifierPrefix: identifierPrefix) {
      EmptyView()
    }
  }
}
