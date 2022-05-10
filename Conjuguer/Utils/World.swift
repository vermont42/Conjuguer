//
//  World.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/15/19.
//  Enhanced by Stephen Celis on 1/16/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import SwiftUI

var Current = World.chooseWorld()

class World: ObservableObject {
  @Published var settings: Settings
  @Published var gameCenter: GameCenterable
  @Published var quiz: Quiz
  @Published var analytics: AnalyticsService
  @Published var reviewPrompter: ReviewPromptable
  @Published var verb: Verb?
  @Published var verbModel: VerbModel?
  @Published var info: Info?
  @Published var session: URLSession

  private static let fakeRatingsCount = 1
  private static let fakeSession = URLSession.stubSession(ratingsCount: fakeRatingsCount)

  init(
    settings: Settings,
    gameCenter: GameCenterable,
    quiz: Quiz,
    analytics: AnalyticsService,
    reviewPrompter: ReviewPromptable,
    session: URLSession
  ) {
    self.settings = settings
    self.gameCenter = gameCenter
    self.quiz = quiz
    self.analytics = analytics
    self.reviewPrompter = reviewPrompter
    self.session = session
  }

  static func chooseWorld() -> World {
#if targetEnvironment(simulator)
    let isRunningUnitTests = NSClassFromString("XCTest") != nil
    if isRunningUnitTests {
      return World.unitTest
    } else {
      return World.simulator
    }
#else
    return World.device
#endif
  }

  static let device: World = {
    let settings = Settings(getterSetter: UserDefaultsGetterSetter())
    let gameCenter = GameCenter.shared
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AWSAnalyticsService()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompter(),
      session: URLSession.shared
    )
  }()

  static let simulator: World = {
    let settings = Settings(getterSetter: UserDefaultsGetterSetter())
    let gameCenter = TestGameCenter()
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = TestAnalyticsService()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompter(),
      session: fakeSession
    )
  }()

  static let unitTest: World = {
    let settings = Settings(getterSetter: DictionaryGetterSetter())
    let gameCenter = TestGameCenter()
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = TestAnalyticsService()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: TestReviewPrompter(),
      session: fakeSession
    )
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
