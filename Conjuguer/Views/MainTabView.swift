//
//  MainTabView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/15/21.
//

import SwiftUI

struct MainTabView: View {
  var body: some View {
    TabView {
      VerbBrowseView()
        .environmentObject(Current)
        .tabItem({
          Image(systemName: "book.fill")
          Text(L.Navigation.verbs)
        })
        .tag(0)

      ModelBrowseView()
        .environmentObject(Current)
        .tabItem({
          Image(systemName: "key.fill")
          Text(L.Navigation.models)
        })
        .tag(1)

      QuizView()
        .environmentObject(Current)
        .tabItem({
          Image(systemName: "square.and.pencil")
          Text(L.Navigation.quiz)
        })
        .tag(2)

      InfoBrowseView()
        .environmentObject(Current)
        .tabItem({
          Image(systemName: "questionmark.diamond.fill")
          Text(L.Navigation.info)
        })
        .tag(3)

      SettingsView()
        .environmentObject(Current)
        .tabItem({
          Image(systemName: "gearshape.2.fill")
          Text(L.Navigation.settings)
        })
        .tag(4)
    }
  }
}

struct MainTabView_Previews: PreviewProvider {
  static var previews: some View {
    MainTabView()
  }
}
