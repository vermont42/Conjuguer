//
//  MainTabView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/15/21.
//

import SwiftUI

struct MainTabView: View {
  @Environment(World.self) private var world
  @Environment(SceneRouter.self) private var router

  var body: some View {
    @Bindable var router = router

    TabView(selection: $router.selectedTab) {
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
    .sheet(item: $router.routedSheet) { sheet in
      routedPage(sheet.page)
    }
    .recordsAppearance(as: "\(MainTabView.self)")
  }

  @ViewBuilder
  private func routedPage(_ page: RoutedSheet.Page) -> some View {
    switch page {
    case .verb(let destination):
      VerbView(verb: destination.verb, source: destination.source, marks: destination.marks)
        .sheetDismissable()
    case .model(let model):
      ModelView(model: model)
        .sheetDismissable()
    case .collection(let destination):
      VerbCollectionView(destination: destination)
        .sheetDismissable()
    case .article(let info):
      ArticleSheet(info: info)
    case .practiceSet(let request):
      PracticeSetView(request: request)
        .sheetDismissable()
        .presentationSizing(.page)
    }
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return MainTabView()
    .environment(Current)
    .environment(SceneRouter())
}
#endif
