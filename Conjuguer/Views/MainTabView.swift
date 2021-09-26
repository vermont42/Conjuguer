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
          Image(systemName: "tortoise.fill")
          Text(L.Navigation.verbs)
        })
        .tag(0)

      ModelBrowseView()
        .environmentObject(Current)
        .tabItem({
          Image(systemName: "hare.fill")
          Text(L.Navigation.models)
        })
        .tag(1)

      InfoBrowseView()
        .environmentObject(Current)
        .tabItem({
          Image(systemName: "ladybug.fill")
          Text(L.Navigation.info)
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
