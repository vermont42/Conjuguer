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

//struct MainTabView: View {
//  @State var activeTab = TabIdentifier.verbs
//
//  var body: some View {
//    TabView(selection: $activeTab) {
//      VerbBrowseView()
//        .environmentObject(Current)
//        .tabItem({
//          Image(systemName: "tortoise.fill")
//          Text(L.Navigation.verbs)
//        })
//        .tag(TabIdentifier.verbs)
//
//      ModelBrowseView()
//        .environmentObject(Current)
//        .tabItem({
//          Image(systemName: "hare.fill")
//          Text(L.Navigation.models)
//        })
//        .tag(TabIdentifier.models)
//
//      InfoBrowseView()
//        .environmentObject(Current)
//        .tabItem({
//          Image(systemName: "ladybug.fill")
//          Text(L.Navigation.info)
//        })
//        .tag(TabIdentifier.info)
//    }
//    .onOpenURL { url in
//      guard let tabIdentifier = url.tabIdentifier else {
//        return
//      }
//
//      activeTab = tabIdentifier
//    }
//  }
//}
//
//struct MainTabView_Previews: PreviewProvider {
//  static var previews: some View {
//    MainTabView()
//  }
//}
//
//enum TabIdentifier: Hashable {
//  case verbs
//  case models
//  case info
//}
