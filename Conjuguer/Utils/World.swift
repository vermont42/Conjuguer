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
  var analytics: Analytics
  var reviewPrompter: ReviewPrompter
  var getterSetter: GetterSetter
  var languageModelService: LanguageModelService
  var soundPlayer: SoundPlayer
  var verb: Verb?
  var verbModel: VerbModel?
  var info: Info?
  var selectedTab: MainTab = .verbs
  var shouldNavigateToTutor = false
  var session: URLSession
  // A deeplink that arrived before VerbData finished loading (the cold-launch race — see
  // handleURL). ConjuguerApp replays it via drainPendingDeeplink() once the data is ready.
  @ObservationIgnored var pendingDeeplink: URL?

  private static let fakeRatingsCount = 1
  private static let fakeSession = URLSession.stubSession(ratingsCount: fakeRatingsCount)

  init(
    settings: Settings,
    gameCenter: GameCenter,
    quiz: Quiz,
    analytics: Analytics,
    reviewPrompter: ReviewPrompter,
    getterSetter: GetterSetter,
    languageModelService: LanguageModelService,
    soundPlayer: SoundPlayer,
    session: URLSession
  ) {
    self.settings = settings
    self.gameCenter = gameCenter
    self.quiz = quiz
    self.analytics = analytics
    self.reviewPrompter = reviewPrompter
    self.getterSetter = getterSetter
    self.languageModelService = languageModelService
    self.soundPlayer = soundPlayer
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
    let getterSetter = GetterSetterReal()
    let settings = Settings(getterSetter: getterSetter)
    let gameCenter = GameCenterReal.shared
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AnalyticsReal()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterReal(settings: settings),
      getterSetter: getterSetter,
      languageModelService: LanguageModelServiceReal(),
      soundPlayer: SoundPlayerReal(),
      session: URLSession.shared
    )
  }()

  static let simulator: World = {
    let getterSetter = GetterSetterReal()
    let settings = Settings(getterSetter: getterSetter)
    let gameCenter = GameCenterStub()
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AnalyticsSpy()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterReal(settings: settings),
      getterSetter: getterSetter,
      languageModelService: LanguageModelServiceReal(),
      soundPlayer: SoundPlayerReal(),
      session: fakeSession
    )
  }()

  static let unitTest: World = {
    let getterSetter = GetterSetterFake()
    let settings = Settings(getterSetter: getterSetter)
    let gameCenter = GameCenterStub()
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AnalyticsSpy()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterDummy(),
      getterSetter: getterSetter,
      languageModelService: LanguageModelServiceDummy(),
      soundPlayer: SoundPlayerDummy(),
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

    // On cold launch a widget's URL can arrive via onOpenURL before VerbData finishes its
    // off-main-actor parse, so entity lookups would silently fail (nil verb) while the tab
    // still switched — landing on VerbBrowseView instead of VerbView. Stash the URL and let
    // ConjuguerApp replay it via drainPendingDeeplink() once the data is loaded.
    guard !Verb.verbs.isEmpty else {
      pendingDeeplink = url
      return
    }

    verb = nil
    verbModel = nil
    info = nil

    if let tab = resolveDeeplinkEntity(from: url) {
      selectedTab = tab
    }
  }

  // Replays a deeplink deferred during cold-launch loading. A no-op when none is pending.
  func drainPendingDeeplink() {
    guard let url = pendingDeeplink else {
      return
    }
    pendingDeeplink = nil
    handleURL(url)
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
        Info.infos.indices.contains(infoIndex)
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
