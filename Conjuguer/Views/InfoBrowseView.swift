//
//  InfoBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/3/21.
//

import SwiftUI

struct InfoBrowseView: View {
  @Environment(World.self) private var world

  var body: some View {
    @Bindable var world = world

    NavigationStack {
      ZStack {
        Color.customBackground

        List {
          ForEach(Info.sections, id: \.category) { section in
            Section {
              ForEach(section.infos) { info in
                NavigationLink(value: info) {
                  Text(info.heading)
                    .tableText()
                }
                .frenchPronunciation(forReal: info.alwaysUsesFrenchPronunciation)
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
      VerbView(verb: verb, shouldShowVerbHeading: true)
        .sheetDismissable()
    }
    .onAppear {
      world.analytics.recordViewAppeared("\(InfoBrowseView.self)")
    }
  }
}
