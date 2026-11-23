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
  var learnerVerbs: LearnerVerbStore
  var verb: Verb?
  // How `verb` was reached, for its page's `viewAppeared`: a link's `source` item, else `deeplink`.
  var verbSource: AnalyticsSource = .deeplink
  // The cells a link's `match` item names on `verb`'s page.
  var verbMarks: MarkedConjugations?
  var verbModel: VerbModel?
  // A featured collection that a `list/` link opens over the Models tab.
  var collection: VerbCollectionDestination?
  var info: Info?
  var selectedTab: MainTab = .verbs
  var shouldNavigateToTutor = false
  // Set by a search link, Command-F, the control, or the quick action, and cleared by
  // VerbBrowseView once it has shown the field.
  var searchRequest: SearchRequest?
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
    learnerVerbs: LearnerVerbStore,
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
    self.learnerVerbs = learnerVerbs
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
      learnerVerbs: sharedLearnerVerbs(),
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
      learnerVerbs: sharedLearnerVerbs(),
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
      learnerVerbs: LearnerVerbStore(getterSetter: GetterSetterFake()),
      session: fakeSession
    )
  }()

  // The App Group's defaults, so that the widget can read the learner's verbs. Without the
  // group, as in a build lacking the entitlement, the record falls back to the app's own defaults.
  private static func sharedLearnerVerbs() -> LearnerVerbStore {
    LearnerVerbStore(getterSetter: GetterSetterReal(userDefaults: WidgetConstants.sharedDefaults ?? .standard))
  }

  /// The grammar is in docs/feature_architecture.md § Deeplinks.
  func handleURL(_ url: URL) {
    guard url.isDeeplink, url.hasDeeplinkTarget else {
      return
    }

    // On cold launch a widget's URL can arrive via onOpenURL before VerbData finishes its
    // off-main-actor parse, so entity lookups would silently fail (nil verb) while the tab
    // still switched — landing on VerbBrowseView instead of VerbView. Stash the URL and let
    // ConjuguerApp replay it via drainPendingDeeplink() once the data is loaded. Every entry
    // point (an intent, the quick action, Spotlight) arrives here, so each inherits this.
    guard !Verb.verbs.isEmpty else {
      pendingDeeplink = url
      return
    }

    clearDeeplinkTargets()

    if let tab = resolveDeeplinkEntity(from: url) {
      selectedTab = tab
    }
  }

  /// Shows the verb list, with any verb page closed, and its search field. Nil `text` keeps
  /// whatever the field holds, as Command-F does; empty text clears it for typing.
  func openSearch(text: String?, source: AnalyticsSource) {
    clearDeeplinkTargets()
    selectedTab = .verbs
    searchRequest = SearchRequest(text: text, source: source)
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
    guard url.isDeeplink, url.hasDeeplinkTarget else {
      return
    }

    resolveDeeplinkEntity(from: url)
  }

  private func clearDeeplinkTargets() {
    verb = nil
    verbMarks = nil
    verbModel = nil
    collection = nil
    info = nil
    searchRequest = nil
  }

  @discardableResult
  private func resolveDeeplinkEntity(from url: URL) -> MainTab? {
    if url.host == URL.searchHost {
      searchRequest = SearchRequest(text: url.deeplinkQueryValue(named: URL.searchTextQueryName) ?? "", source: url.analyticsSource ?? .deeplink)
      return .verbs
    }

    let target = url.pathComponents[1]
    switch url.host {
    case URL.verbHost:
      let found = target == URL.randomVerbPath ? VerbDraw.randomVerb(myVerbs: learnerVerbs.myVerbs) : Verb.verbs[target]
      verbSource = url.analyticsSource ?? .deeplink
      verbMarks = found.flatMap { verb in
        url.deeplinkQueryValue(named: URL.matchQueryName).flatMap { MarkedConjugations(text: $0, on: verb) }
      }
      verb = found
      return .verbs
    case URL.quizHost:
      if quiz.quizState != .inProgress {
        quiz.start()
      }
      return .quiz
    case URL.verbModelHost:
      verbModel = VerbModel.models[target]
      return .models
    case URL.listHost:
      guard let found = VerbCollection(featuredKey: target) else {
        return nil
      }
      collection = VerbCollectionDestination(collection: found, source: url.analyticsSource ?? .deeplink)
      return .models
    case URL.infoHost:
      guard let found = Info.info(deeplinkTarget: target) else {
        return nil
      }
      info = found
      return .info
    default:
      return nil
    }
  }
}

/// A request, from a link or a command, that the verb list show its search field.
struct SearchRequest: Equatable {
  /// Nil keeps what the field holds.
  let text: String?
  let source: AnalyticsSource
}
