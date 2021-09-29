//
//  World.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/15/19.
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
  @Published var verb: Verb?
  @Published var verbModel: VerbModel?
  @Published var info: Info?

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

  func handleURL(_ url: URL) {
    guard
      url.isDeeplink,
      url.hasExpectedNumberOfDeeplinkComponents
    else {
      return
    }

    verb = nil
    verbModel = nil
    info = nil

    switch url.host {
    case URL.verbHost:
      verb = Verb.verbs[url.pathComponents[1]]
    case URL.verbModelHost:
      verbModel = VerbModel.models[url.pathComponents[1]]
    case URL.infoHost:
      if
        let infoIndex = Int(url.pathComponents[1]),
        infoIndex < Info.infos.count
      {
        info = Info.infos[infoIndex]
      }
    default:
      return
    }
  }
}
