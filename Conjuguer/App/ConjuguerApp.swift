//
//  ConjuguerApp.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/1/21.
//

import SwiftUI

struct ConjuguerApp: App {
  @State private var verbData = VerbData()

  var body: some Scene {
    WindowGroup {
      Group {
        switch verbData.state {
        case .loading:
          LoadingView()
        case .loaded:
          MainTabView()
            .environment(Current)
        }
      }
      .task {
        await verbData.load()
      }
      .onOpenURL(perform: Current.handleURL(_:))
    }
  }

  init() {
    Current.analytics.recordBecameActive()

    Modifiers.modifyAppearances()

    SoundPlayer.setup()
    Utterer.setup()
  }
}
