//
//  World.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/15/19.
//  Enhanced by Stephen Celis on 1/16/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import SwiftUI

#if targetEnvironment(simulator)
var Current = World.simulator
#else
var Current = World.device
#endif

class World: ObservableObject {
  @Published var settings: Settings
  @Published var gameCenter: GameCenterable
  @Published var quiz: Quiz
  @Published var verb: Verb?
  @Published var verbModel: VerbModel?
  @Published var info: Info?

  init(settings: Settings, gameCenter: GameCenterable, quiz: Quiz) {
    self.settings = settings
    self.gameCenter = gameCenter
    self.quiz = quiz
  }

  static let device: World = {
    let settings = Settings(getterSetter: UserDefaultsGetterSetter())
    let gameCenter = GameCenter.shared
    let quiz = Quiz(gameCenter: gameCenter)
    return World(settings: settings, gameCenter: gameCenter, quiz: quiz)
  }()

  static let simulator: World = {
    let settings = Settings(getterSetter: UserDefaultsGetterSetter())
    let gameCenter = GameCenter.shared
    let quiz = Quiz(gameCenter: gameCenter)
    return World(settings: settings, gameCenter: gameCenter, quiz: quiz)
  }()

  static let unitTest: World = {
    let settings = Settings(getterSetter: DictionaryGetterSetter())
    let gameCenter = TestGameCenter()
    let quiz = Quiz(gameCenter: gameCenter)
    return World(settings: settings, gameCenter: gameCenter, quiz: quiz)
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
