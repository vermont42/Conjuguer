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

        List(Info.infos) { info in
          NavigationLink(value: info) {
            Text(info.heading)
              .tableText()
          }
          .frenchPronunciation(forReal: info.alwaysUsesFrenchPronunciation)
          .listRowBackground(Color.customBackground)
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
    // Two .sheet(item:) modifiers (rather than one Identifiable enum) intentionally preserve
    // sheet stacking: a verb link tapped inside a presented InfoView (routed in place via
    // TextViewDelegate.handleInAppURL, which sets Current.verb without clearing Current.info)
    // presents VerbView on top of the info article. Collapsing to one enum would dismiss the
    // article instead.
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
