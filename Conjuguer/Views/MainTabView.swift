//
//  MainTabView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/15/21.
//

import SwiftUI

struct MainTabView: View {
  @StateObject var current = Current

  var body: some View {
    TabView {
      VerbBrowseView()
        .tabItem({
            Image(systemName: "book.fill")
            Text(L.Navigation.verbs)
          }
        )
        .tag(0)

      ModelBrowseView()
        .tabItem({
            Image(systemName: "key.fill")
            Text(L.Navigation.models)
          }
        )
        .tag(1)

      QuizView()
        .environmentObject(current)
        .tabItem({
            Image(systemName: "square.and.pencil")
            Text(L.Navigation.quiz)
          }
        )
        .tag(2)

      InfoBrowseView()
        .tabItem({
            Image(systemName: "questionmark.diamond.fill")
            Text(L.Navigation.info)
          }
        )
        .tag(3)

      SettingsView()
        .tabItem({
            Image(systemName: "gearshape.2.fill")
            Text(L.Navigation.settings)
          }
        )
        .tag(4)
    }
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
