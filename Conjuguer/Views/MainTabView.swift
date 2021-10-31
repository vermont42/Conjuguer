//
//  MainTabView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/15/21.
//

import SwiftUI

struct MainTabView: View {
  @StateObject var current = Current
  @StateObject var quiz = Quiz(gameCenter: TestGameCenter())

  var body: some View {
    TabView {
      VerbBrowseView()
        .environmentObject(current)
        .tabItem({
            Image(systemName: "book.fill")
            Text(L.Navigation.verbs)
          }
        )
        .tag(0)

      ModelBrowseView()
        .environmentObject(current)
        .tabItem({
            Image(systemName: "key.fill")
            Text(L.Navigation.models)
          }
        )
        .tag(1)

      QuizView()
        .environmentObject(quiz)
        .tabItem({
            Image(systemName: "square.and.pencil")
            Text(L.Navigation.quiz)
          }
        )
        .tag(2)

      InfoBrowseView()
        .environmentObject(current)
        .tabItem({
            Image(systemName: "questionmark.diamond.fill")
            Text(L.Navigation.info)
          }
        )
        .tag(3)

      SettingsView()
        .environmentObject(current)
        .tabItem({
            Image(systemName: "gearshape.2.fill")
            Text(L.Navigation.settings)
          }
        )
        .tag(4)
    }
  }
}

struct MainTabView_Previews: PreviewProvider {
  static var previews: some View {
    MainTabView()
  }
}
