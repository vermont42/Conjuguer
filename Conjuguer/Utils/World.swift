//
//  World.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/15/19.
//  Enhanced by Stephen Celis on 1/16/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import Foundation
import SwiftUI

#if targetEnvironment(simulator)
var Current = World.simulator
#else
var Current = World.device
#endif

class World: ObservableObject {
  @Published var settings: Settings

  init(settings: Settings) {
    self.settings = settings
  }

  static let device: World = {
    let settings = Settings(getterSetter: UserDefaultsGetterSetter())

    return World(settings: settings)
  }()

  static let simulator: World = {
    let settings = Settings(getterSetter: UserDefaultsGetterSetter())

    return World(settings: settings)
  }()

  static let unitTest: World = {
    let settings = Settings(getterSetter: DictionaryGetterSetter())

    return World(settings: settings)
  }()
}
