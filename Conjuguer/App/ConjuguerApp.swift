//
//  ConjuguerApp.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/1/21.
//

import SwiftUI

struct ConjuguerApp: App {
  var body: some Scene {
    WindowGroup {
      MainTabView()
        .onOpenURL(perform: Current.handleURL(_:))
    }
  }

  static var compoundPersonNumbersIndex = 0
  static var compoundImpératifPersonNumbersIndex = 0

  init() {
    Current.analytics.recordBecameActive()

    Modifiers.modifyAppearances()

    SoundPlayer.setup()
    Utterer.setup()
  }
}
