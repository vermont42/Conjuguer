//
//  MainTabView.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/15/21.
//

import SwiftUI

struct MainTabView: View {
  var body: some View {
    TabView {

      VerbBrowseView()
        .environmentObject(Current)
        .tabItem({
          Image(systemName: "sun.max")
          Text("Verbs")
        })
        .tag(0)

      ModelBrowseView()
        .environmentObject(Current)
        .tabItem({
          Image(systemName: "moon.stars")
          Text("Models")
        })
        .tag(1)

      InputView()
        .tabItem({
          Image(systemName: "keyboard")
          Text("Input")
        })
        .tag(2)
    }
  }
}

struct MainTabView_Previews: PreviewProvider {
  static var previews: some View {
    MainTabView()
  }
}
