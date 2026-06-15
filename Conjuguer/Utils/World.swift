//
//  World.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/15/19.
//  Enhanced by Stephen Celis on 1/16/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import Observation
import SwiftUI

@MainActor var Current = World.chooseWorld()

enum MainTab: Hashable {
  case verbs
  case models
  case quiz
  case info
  case settings
}

@MainActor
@Observable
class World {
  var settings: Settings
  var gameCenter: GameCenter
  var quiz: Quiz
  var analytics: AnalyticsService
  var reviewPrompter: ReviewPrompter
  var verb: Verb?
  var verbModel: VerbModel?
  var info: Info?
  var selectedTab: MainTab = .verbs
  var session: URLSession

  private static let fakeRatingsCount = 1
  private static let fakeSession = URLSession.stubSession(ratingsCount: fakeRatingsCount)

  init(
    settings: Settings,
    gameCenter: GameCenter,
    quiz: Quiz,
    analytics: AnalyticsService,
    reviewPrompter: ReviewPrompter,
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
    let settings = Settings(getterSetter: GetterSetterReal())
    let gameCenter = GameCenterReal.shared
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AnalyticsServiceReal()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterReal(),
      session: URLSession.shared
    )
  }()

  static let simulator: World = {
    let settings = Settings(getterSetter: GetterSetterReal())
    let gameCenter = GameCenterStub()
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AnalyticsServiceSpy()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterReal(),
      session: fakeSession
    )
  }()

  static let unitTest: World = {
    let settings = Settings(getterSetter: GetterSetterFake())
    let gameCenter = GameCenterStub()
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AnalyticsServiceSpy()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterDummy(),
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
      selectedTab = .verbs
    case URL.verbModelHost:
      verbModel = VerbModel.models[url.pathComponents[1]]
      selectedTab = .models
    case URL.infoHost:
      if
        let infoIndex = Int(url.pathComponents[1]),
        infoIndex < Info.infos.count
      {
        info = Info.infos[infoIndex]
        selectedTab = .info
      }
    default:
      return
    }
  }

  // Handles a deep link tapped from within an already-presented detail view (e.g. the
  // "Verbs Using This Model" links in ModelView or the verb/info links in InfoView's text).
  // Unlike handleURL, it neither switches selectedTab nor clears the sibling entities, so
  // the target is presented in place as a sheet by the current context and the user stays
  // on the same tab. Clearing siblings here would blank out the underlying sheet (e.g.
  // ModelView is driven by verbModel), so only the tapped entity is set.
  func handleInAppURL(_ url: URL) {
    guard
      url.isDeeplink,
      url.hasExpectedNumberOfDeeplinkComponents
    else {
      return
    }

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
