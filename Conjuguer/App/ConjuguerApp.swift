//
//  ConjuguerApp.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/1/21.
//

import SwiftUI

@main
struct ConjuguerApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }

  init() {
    Verb.verbs = VerbParser().parse()
    VerbModel.models = VerbModelParser().parse()

    print("verb count: \(Verb.verbs.count)  model count: \(VerbModel.models.count)")
  }
}
