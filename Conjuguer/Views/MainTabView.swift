//
//  MainTabView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/15/21.
//

import SwiftUI

struct MainTabView: View {
  @Environment(World.self) private var world

  var body: some View {
    @Bindable var world = world

    TabView(selection: $world.selectedTab) {
      Tab(L.Navigation.verbs, systemImage: "book.fill", value: MainTab.verbs) {
        VerbBrowseView()
      }

      Tab(L.Navigation.models, systemImage: "key.fill", value: MainTab.models) {
        ModelBrowseView()
      }

      Tab(L.Navigation.quiz, systemImage: "pencil.circle.fill", value: MainTab.quiz) {
        QuizView()
          .environment(world.quiz)
      }

      Tab(L.Navigation.info, systemImage: "questionmark.diamond.fill", value: MainTab.info) {
        InfoBrowseView()
      }

      Tab(L.Navigation.settings, systemImage: "gearshape.2.fill", value: MainTab.settings) {
        SettingsView()
      }
    }
    .tabViewStyle(.sidebarAdaptable)
    .onAppear {
      world.analytics.recordViewAppeared("\(MainTabView.self)")
    }
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return MainTabView()
    .environment(Current)
}
#endif
