//
//  AppLauncher.swift
//  Conjuguer
//
//  Created by Joshua Adams on 5/7/22.
//

import SwiftUI

@main
enum AppLauncher {
  static func main() throws {
    setupModels()

    if NSClassFromString("XCTestCase") == nil {
      ConjuguerApp.main()
    } else {
      TestApp.main()
    }
  }

  private static func setupModels() {
    VerbModel.models = VerbModelParser().parse()
    Verb.verbs = VerbParser().parse()
    VerbModel.computeIrregularities()
    VerbModel.sortVerbs()
    DefectGroup.defectGroups = DefectGroupParser().parse()

//    Conjugator.printConjugations(infinitif: "alunir")
  }
}
