//
//  ConjuguerApp.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/1/21.
//

import SwiftUI

@main
struct ConjuguerApp: App {
  var body: some Scene {
    WindowGroup {
      MainTabView()
        .environmentObject(Current)
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

    VerbModel.models = VerbModelParser().parse()
    Verb.verbs = VerbParser().parse()
    VerbModel.computeIrregularities()
    VerbModel.sortVerbs()
    DefectGroup.defectGroups = DefectGroupParser().parse()

//    Conjugator.printConjugations(infinitif: "alunir")
  }
}
