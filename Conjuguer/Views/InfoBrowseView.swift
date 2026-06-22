//
//  InfoBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/3/21.
//

import SwiftUI

struct InfoBrowseView: View {
  @Environment(World.self) private var world
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    @Bindable var world = world

    NavigationStack {
      ZStack {
        Color.customBackground

        infoCollection
      }
      .navigationTitle(L.Navigation.info)
      .navigationDestination(for: Info.self) { info in
        InfoView(info: info)
      }
    }
    .screenBackground()
    .sheet(item: $world.info) { info in
      InfoView(info: info, shouldShowInfoHeading: true)
        .sheetDismissable()
    }
    .sheet(item: $world.verb) { verb in
      VerbView(verb: verb)
        .sheetDismissable()
    }
    .recordsAppearance(as: "\(InfoBrowseView.self)")
  }

  @ViewBuilder
  private var infoCollection: some View {
    if horizontalSizeClass == .regular {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: Layout.tripleDefaultSpacing) {
          ForEach(Info.sections, id: \.category) { section in
            VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
              Text(section.category.title)
                .subheadingLabel()

              LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
                ForEach(section.infos) { info in
                  NavigationLink(value: info) {
                    infoCell(info)
                      .card()
                  }
                  .buttonStyle(.plain)
                }
              }
            }
          }
        }
        .padding()
      }
      .scrollContentBackground(.hidden)
    } else {
      List {
        ForEach(Info.sections, id: \.category) { section in
          Section {
            ForEach(section.infos) { info in
              NavigationLink(value: info) {
                infoCell(info)
              }
              .listRowBackground(Color.customBackground)
            }
          } header: {
            Text(section.category.title)
              .subheadingLabel()
          }
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
    }
  }

  private func infoCell(_ info: Info) -> some View {
    Text(info.heading)
      .tableText()
      .frenchPronunciation(forReal: info.alwaysUsesFrenchPronunciation)
  }
}
