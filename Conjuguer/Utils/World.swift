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
      reviewPrompter: ReviewPrompterReal(settings: settings),
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
      reviewPrompter: ReviewPrompterReal(settings: settings),
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

    if let tab = resolveDeeplinkEntity(from: url) {
      selectedTab = tab
    }
  }

  func handleInAppURL(_ url: URL) {
    guard
      url.isDeeplink,
      url.hasExpectedNumberOfDeeplinkComponents
    else {
      return
    }

    resolveDeeplinkEntity(from: url)
  }

  @discardableResult
  private func resolveDeeplinkEntity(from url: URL) -> MainTab? {
    switch url.host {
    case URL.verbHost:
      if url.pathComponents[1] == URL.randomVerbPath {
        verb = Verb.verbs.values.randomElement()
      } else {
        verb = Verb.verbs[url.pathComponents[1]]
      }
      return .verbs
    case URL.quizHost:
      if quiz.quizState != .inProgress {
        quiz.start()
      }
      return .quiz
    case URL.verbModelHost:
      verbModel = VerbModel.models[url.pathComponents[1]]
      return .models
    case URL.infoHost:
      guard
        let infoIndex = Int(url.pathComponents[1]),
        infoIndex < Info.infos.count
      else {
        return nil
      }
      info = Info.infos[infoIndex]
      return .info
    default:
      return nil
    }
  }
}
