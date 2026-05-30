//
//  MainTabView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/15/21.
//

import SwiftUI

struct MainTabView: View {
  @State private var quiz = Current.quiz

  var body: some View {
    @Bindable var current = Current

    TabView(selection: $current.selectedTab) {
      Tab(L.Navigation.verbs, systemImage: "book.fill", value: MainTab.verbs) {
        VerbBrowseView()
      }

      Tab(L.Navigation.models, systemImage: "key.fill", value: MainTab.models) {
        ModelBrowseView()
      }

      Tab(L.Navigation.quiz, systemImage: "pencil.circle.fill", value: MainTab.quiz) {
        QuizView()
          .environment(quiz)
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
      Current.analytics.recordViewAppeared("\(MainTabView.self)")
    }
  }
}

struct MainTabView_Previews: PreviewProvider {
  static var previews: some View {
    MainTabView()
  }
}
