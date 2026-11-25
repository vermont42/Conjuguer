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
  var practice: PracticeStore
  var liveActivities: LiveActivities
  var reminderScheduler: ReminderScheduler
  // The page a link shows over the tabs: a verb's, a model's, a collection's, an article, or a
  // practice set. MainTabView presents it, and nothing else presents what a link opens.
  var routedSheet: RoutedSheet?
  // A `quiz/daily` link's session, which the Quiz tab starts unless a quiz is under way.
  var dailySessionRequest: DailySessionRequest?
  // A `quiz/challenge` link's challenge, from a shared result or the quiz widget, which the Quiz
  // tab starts unless a quiz is under way or the challenge was taken.
  var challengeRequest: DailyChallengeRequest?
  var selectedTab: MainTab = .verbs
  var shouldNavigateToTutor = false
  // Set by a search link, Command-F, the control, or the quick action, and cleared by
  // VerbBrowseView once it has shown the field.
  var searchRequest: SearchRequest?
  var session: URLSession
  // A deeplink that arrived before VerbData finished loading (the cold-launch race; see
  // handle(_:)). ConjuguerApp replays it via drainPendingDeeplink() once the data is ready.
  @ObservationIgnored var pendingDeeplink: Deeplink?

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
    practice: PracticeStore,
    liveActivities: LiveActivities,
    reminderScheduler: ReminderScheduler,
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
    self.practice = practice
    self.liveActivities = liveActivities
    self.reminderScheduler = reminderScheduler
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
    let sharedGetterSetter = sharedDefaults()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterReal(settings: settings),
      getterSetter: getterSetter,
      languageModelService: LanguageModelServiceReal(),
      soundPlayer: SoundPlayerReal(),
      learnerVerbs: LearnerVerbStore(getterSetter: sharedGetterSetter),
      practice: PracticeStore(getterSetter: sharedGetterSetter),
      liveActivities: LiveActivitiesReal(),
      reminderScheduler: ReminderSchedulerReal(),
      session: URLSession.shared
    )
  }()

  static let simulator: World = {
    let getterSetter = GetterSetterReal()
    let settings = Settings(getterSetter: getterSetter)
    let gameCenter = GameCenterSpy()
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AnalyticsSpy()
    let sharedGetterSetter = sharedDefaults()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterReal(settings: settings),
      getterSetter: getterSetter,
      languageModelService: LanguageModelServiceReal(),
      soundPlayer: SoundPlayerReal(),
      learnerVerbs: LearnerVerbStore(getterSetter: sharedGetterSetter),
      practice: PracticeStore(getterSetter: sharedGetterSetter),
      liveActivities: LiveActivitiesReal(),
      reminderScheduler: ReminderSchedulerReal(),
      session: fakeSession
    )
  }()

  static let unitTest: World = {
    let getterSetter = GetterSetterFake()
    let settings = Settings(getterSetter: getterSetter)
    let gameCenter = GameCenterSpy()
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
      practice: PracticeStore(getterSetter: GetterSetterFake()),
      liveActivities: LiveActivitiesSpy(),
      reminderScheduler: ReminderSchedulerSpy(),
      session: fakeSession
    )
  }()

  // The App Group's defaults, so that the widget can read the learner's verbs and practice.
  // Without the group, as in a build lacking the entitlement, the records fall back to the app's
  // own defaults.
  private static func sharedDefaults() -> GetterSetter {
    GetterSetterReal(userDefaults: WidgetConstants.sharedDefaults ?? .standard)
  }

  /// The grammar is in docs/feature_architecture.md § Deeplinks. A URL that is not a link of the
  /// grammar does nothing.
  func handleURL(_ url: URL) {
    if let link = Deeplink(url: url) {
      handle(link)
    }
  }

  /// Shows what the link names, with every other routed page closed and every pending request
  /// dropped, and selects its tab. A link that names nothing that exists changes nothing.
  func handle(_ link: Deeplink) {
    // On cold launch a widget's URL can arrive via onOpenURL before VerbData finishes its
    // off-main-actor parse, so every lookup would fail. Stash the link and let ConjuguerApp
    // replay it via drainPendingDeeplink() once the data is loaded. Every entry point (an
    // intent, the quick action, Spotlight) arrives here, so each inherits this.
    guard !Verb.verbs.isEmpty else {
      pendingDeeplink = link
      return
    }
    guard let destination = resolve(link) else {
      return
    }
    show(destination)
  }

  /// Shows the verb list, with any verb page closed, and its search field. Nil `text` keeps
  /// whatever the field holds, as Command-F does; empty text clears it for typing.
  func openSearch(text: String?, source: AnalyticsSource) {
    show(.search(SearchRequest(text: text, source: source)))
  }

  // Replays a deeplink deferred during cold-launch loading. A no-op when none is pending.
  func drainPendingDeeplink() {
    guard let link = pendingDeeplink else {
      return
    }
    pendingDeeplink = nil
    handle(link)
  }

  /// What a link opens, looked up. Nil when it names nothing that exists.
  private enum Destination {
    case sheet(RoutedSheet.Page)
    case search(SearchRequest)
    case dailySession(DailySessionRequest)
    case challenge(DailyChallengeRequest)
    case startQuiz(source: AnalyticsSource)

    var tab: MainTab? {
      switch self {
      case .sheet(let page):
        return page.tab
      case .search:
        return .verbs
      case .dailySession, .challenge, .startQuiz:
        return .quiz
      }
    }
  }

  private func resolve(_ link: Deeplink) -> Destination? {
    switch link {
    case let .verb(target, source, match):
      let found: Verb?
      switch target {
      case .key(let key):
        found = Verb.verbs[key]
      case .random:
        found = VerbDraw.randomVerb(myVerbs: learnerVerbs.myVerbs)
      }
      return found.map { verb in
        .sheet(.verb(VerbDestination(verb: verb, source: source, marks: match.flatMap { MarkedConjugations(text: $0, on: verb) })))
      }
    case let .search(text, source):
      return .search(SearchRequest(text: text ?? "", source: source))
    case .model(let id, _):
      return VerbModel.models[id].map { .sheet(.model($0)) }
    case let .list(key, source):
      return VerbCollection(featuredKey: key).map { .sheet(.collection(VerbCollectionDestination(collection: $0, source: source))) }
    case .info(let target):
      return Info.info(deeplinkTarget: target).map { .sheet(.article($0)) }
    case let .practiceSet(custom, level, source):
      return .sheet(.practiceSet(PracticeSetRequest(practiceSet: PracticeSet(linked: custom, level: level), source: source)))
    case .dailySession(let source):
      return .dailySession(DailySessionRequest(source: source))
    case let .challenge(day, level, source):
      let key = day.flatMap { DailyChallenge.Key(day: $0, level: level ?? settings.quizLevel) }
      return .challenge(DailyChallengeRequest(key: key, source: source))
    case .startQuiz(let source):
      return .startQuiz(source: source)
    }
  }

  private func show(_ destination: Destination) {
    clearDeeplinkTargets()
    switch destination {
    case .sheet(let page):
      routedSheet = RoutedSheet(page: page)
    case .search(let request):
      searchRequest = request
    case .dailySession(let request):
      dailySessionRequest = request
    case .challenge(let request):
      challengeRequest = request
    case .startQuiz(let source):
      if quiz.quizState != .inProgress {
        quiz.start(scope: .allVerbs(source: source))
      }
    }
    if let tab = destination.tab {
      selectedTab = tab
    }
  }

  private func clearDeeplinkTargets() {
    routedSheet = nil
    searchRequest = nil
    dailySessionRequest = nil
    challengeRequest = nil
  }
}

/// A request, from a link or a command, that the verb list show its search field.
struct SearchRequest: Equatable {
  let text: String?
  let source: AnalyticsSource
}
