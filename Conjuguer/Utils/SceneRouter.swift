//
//  SceneRouter.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/25/26.
//

import Observation
import SwiftUI
import UIKit

enum MainTab: Hashable {
  case verbs
  case models
  case quiz
  case info
  case settings
}

/// What one window shows: its tab, the page a link opened over the tabs, and the requests that a
/// tab takes up when it appears. Each window owns one, so that a link, a tab switch, or Command-F
/// in one window leaves the others as they were. The services, settings, and stores stay in
/// `World`, which every window shares.
@MainActor
@Observable
final class SceneRouter {
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
  // A link that arrived before VerbData finished loading (the cold-launch race; see handle(_:)).
  // SceneRoot replays it, in this window, via drainPendingDeeplink() once the data is ready.
  @ObservationIgnored var pendingDeeplink: Deeplink?
  /// The window this router serves, once SceneRoot has seen it. VerbSearchArrowKeys installs
  /// there, and a link that names a scene finds its router by it.
  @ObservationIgnored private(set) weak var window: UIWindow?

  @ObservationIgnored private let world: World

  init(world: World = Current) {
    self.world = world
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
    // off-main-actor parse, so every lookup would fail. Stash the link and let SceneRoot replay
    // it via drainPendingDeeplink() once the data is loaded. Every entry point (an intent, the
    // quick action, Spotlight) arrives here, so each inherits this.
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

  /// Replays a link deferred during cold-launch loading. A no-op when none is pending.
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
        found = VerbDraw.randomVerb(myVerbs: world.learnerVerbs.myVerbs)
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
      let key = day.flatMap { DailyChallenge.Key(day: $0, level: level ?? world.settings.quizLevel) }
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
      // The quiz is one for the whole app, so a second window's link finds it under way.
      if world.quiz.quizState != .inProgress {
        world.quiz.start(scope: .allVerbs(source: source))
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

/// A quick action names its scene, a notification's response usually does, and an App Intent
/// names none. These find the router of the window they belong to, or wait for it.
extension SceneRouter {
  private static var routers: [WeakRouter] = []
  // A quick action that launched the app arrives before its window's router exists.
  private static var linksAwaitingScene: [(scene: WeakScene, link: Deeplink)] = []
  // A link for no window in particular, which arrived while no window was active.
  private static var unaddressedLink: Deeplink?

  private struct WeakRouter {
    weak var router: SceneRouter?
  }

  private struct WeakScene {
    weak var scene: UIScene?
  }

  /// Records the window this router serves and hands it any link that was waiting for its
  /// scene.
  func attach(to window: UIWindow) {
    guard self.window !== window else {
      return
    }
    self.window = window
    Self.routers.removeAll { $0.router == nil || $0.router === self }
    Self.routers.append(WeakRouter(router: self))
    guard let scene = window.windowScene else {
      return
    }
    let waiting = Self.linksAwaitingScene.filter { $0.scene.scene === scene }.map(\.link)
    Self.linksAwaitingScene.removeAll { $0.scene.scene == nil || $0.scene.scene === scene }
    waiting.forEach(handle)
  }

  /// Takes the link that arrived for no window while none was active. SceneRoot calls this when
  /// its window becomes active.
  func claimUnaddressedLink() {
    guard let link = Self.unaddressedLink else {
      return
    }
    Self.unaddressedLink = nil
    handle(link)
  }

  /// Sends a link to the router of `scene`, or, with no scene, to the active window's: the key
  /// window's when several are active. A link for a scene whose router does not exist yet waits
  /// for `attach(to:)`, and a link for no scene that finds no active window waits for
  /// `claimUnaddressedLink()`.
  static func deliver(_ link: Deeplink, to scene: UIScene? = nil) {
    let live = routers.compactMap(\.router)
    if let scene {
      if let router = live.first(where: { $0.window?.windowScene === scene }) {
        router.handle(link)
      } else {
        linksAwaitingScene.append((WeakScene(scene: scene), link))
      }
      return
    }
    let active = live.filter { $0.window?.windowScene?.activationState == .foregroundActive }
    if let router = active.first(where: { $0.window?.isKeyWindow == true }) ?? active.first {
      router.handle(link)
    } else {
      unaddressedLink = link
    }
  }

  static func deliver(_ url: URL, to scene: UIScene? = nil) {
    if let link = Deeplink(url: url) {
      deliver(link, to: scene)
    }
  }
}

extension FocusedValues {
  /// The focused window's router, which Command-F asks to show the search field.
  @Entry var sceneRouter: SceneRouter?
}

/// A request, from a link or a command, that the verb list show its search field.
struct SearchRequest: Equatable {
  let text: String?
  let source: AnalyticsSource
}
