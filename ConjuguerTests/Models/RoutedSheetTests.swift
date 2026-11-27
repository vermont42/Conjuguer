//
//  RoutedSheetTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/25/26.
//

@testable import Conjuguer
import Foundation
import SwiftUI
import Testing

extension SceneRouter {
  var routedVerb: VerbDestination? {
    if case .verb(let destination) = routedSheet?.page {
      return destination
    }
    return nil
  }

  var routedModel: VerbModel? {
    if case .model(let model) = routedSheet?.page {
      return model
    }
    return nil
  }

  var routedCollection: VerbCollectionDestination? {
    if case .collection(let destination) = routedSheet?.page {
      return destination
    }
    return nil
  }

  var routedArticle: Info? {
    if case .article(let info) = routedSheet?.page {
      return info
    }
    return nil
  }

  var routedPracticeSet: PracticeSetRequest? {
    if case .practiceSet(let request) = routedSheet?.page {
      return request
    }
    return nil
  }
}

@MainActor
@Suite(.serialized)
struct RoutedSheetTests {
  /// A world of its own, so that the suites that change `Current` cannot reach the window.
  private static func world(analytics: AnalyticsSpy) -> World {
    let getterSetter = GetterSetterFake()
    let gameCenter = GameCenterSpy()
    return World(
      settings: Settings(getterSetter: getterSetter),
      gameCenter: gameCenter,
      quiz: Quiz(gameCenter: gameCenter),
      analytics: analytics,
      reviewPrompter: ReviewPrompterDummy(),
      getterSetter: getterSetter,
      languageModelService: LanguageModelServiceDummy(),
      soundPlayer: SoundPlayerDummy(),
      learnerVerbs: LearnerVerbStore(getterSetter: GetterSetterFake()),
      practice: PracticeStore(getterSetter: GetterSetterFake()),
      liveActivities: LiveActivitiesSpy(),
      reminderScheduler: ReminderSchedulerSpy(),
      session: URLSession.stubSession(ratingsCount: 1)
    )
  }

  private static func url(_ string: String) throws -> URL {
    try #require(URL(string: string))
  }

  /// Lets the window run until `condition` holds or `seconds` pass. A sheet that replaces another
  /// takes about two seconds on the simulator, its dismissal and then its presentation.
  @discardableResult
  private static func waitUntil(seconds: Double = 6, _ condition: () -> Bool) async throws -> Bool {
    let deadline = Date.now.addingTimeInterval(seconds)
    while !condition(), Date.now < deadline {
      try await Task.sleep(for: .milliseconds(100))
    }
    return condition()
  }

  /// Long enough for a stray second presentation to show itself. With B1 restored, the second
  /// page appeared in the same 100 ms poll as the first, so this leaves room for a slower one.
  private static func settle() async throws {
    try await Task.sleep(for: .milliseconds(300))
  }

  /// B8 of docs/verb_browse_review.md: a second link to the verb already showing is a new sheet,
  /// which SwiftUI presents afresh, rather than new marks on the old one.
  @Test func eachLinkToAVerbIsASheetOfItsOwn() throws {
    let router = SceneRouter(world: Self.world(analytics: AnalyticsSpy()))
    router.handleURL(try Self.url("conjuguer://verb/aller?match=vais"))
    let first = try #require(router.routedSheet)
    router.handleURL(try Self.url("conjuguer://verb/aller?match=suis%20all%C3%A9"))
    let second = try #require(router.routedSheet)
    #expect(first.id != second.id)
    #expect(router.routedVerb?.marks?.includesCompoundTense == true)
  }

  @Test func everyPageALinkOpensIsTheOneSheet() throws {
    let router = SceneRouter(world: Self.world(analytics: AnalyticsSpy()))
    let links = [
      "conjuguer://verb/boire",
      "conjuguer://model/1-9",
      "conjuguer://list/top100",
      "conjuguer://info/passe_compose",
      "conjuguer://quiz/set?tenses=imparfait"
    ]
    for link in links {
      router.handleURL(try Self.url(link))
      #expect(router.routedSheet != nil, "\(link)")
    }
    #expect(router.routedPracticeSet != nil)
    router.handleURL(try Self.url("conjuguer://search?q=suis"))
    #expect(router.routedSheet == nil)
  }

  /// B1 of docs/verb_browse_review.md: once the Info tab had been visited, two tabs presented a
  /// linked verb's page, so its open was counted twice. Each link must present one page, which
  /// begins one visit and records one open, and a second link to the same verb begins another.
  @Test func aLinkedVerbIsPresentedOnce() async throws {
    let scene = try #require(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
    let analytics = AnalyticsSpy()
    let world = Self.world(analytics: analytics)
    let router = SceneRouter(world: world)
    let window = UIWindow(windowScene: scene)
    window.rootViewController = UIHostingController(rootView: MainTabView().environment(world).environment(router))
    window.makeKeyAndVisible()
    defer {
      window.rootViewController?.dismiss(animated: false)
      window.isHidden = true
    }

    router.selectedTab = .info
    #expect(try await Self.waitUntil { appearances(of: "\(InfoBrowseView.self)", analytics) > 0 }, "The Info tab must load, since B1 needs its view.")
    let verbBrowseAppearances = appearances(of: "\(VerbBrowseView.self)", analytics)
    router.selectedTab = .verbs
    #expect(try await Self.waitUntil { appearances(of: "\(VerbBrowseView.self)", analytics) > verbBrowseAppearances })

    router.handleURL(try Self.url("conjuguer://verb/boire?source=widget"))
    try await Self.waitUntil { !verbPageAppearances(analytics).isEmpty }
    try await Self.settle()
    #expect(verbPageAppearances(analytics) == ["widget"])
    #expect(world.learnerVerbs.record.entries["boire"]?.openCount == 1)

    router.handleURL(try Self.url("conjuguer://verb/boire?source=lookup&match=bu"))
    try await Self.waitUntil { verbPageAppearances(analytics).count > 1 }
    try await Self.settle()
    #expect(verbPageAppearances(analytics) == ["widget", "lookup"])
    #expect(world.learnerVerbs.record.entries["boire"]?.openCount == 2)
  }

  private func appearances(of viewName: String, _ analytics: AnalyticsSpy) -> Int {
    zip(analytics.signalNames, analytics.signalParameters).filter { name, parameters in
      name == .viewAppeared && parameters[ParameterKey.viewName.rawValue] == viewName
    }.count
  }

  private func verbPageAppearances(_ analytics: AnalyticsSpy) -> [String] {
    zip(analytics.signalNames, analytics.signalParameters).compactMap { name, parameters in
      guard name == .viewAppeared, parameters[ParameterKey.viewName.rawValue] == VerbVisit.viewName else {
        return nil
      }
      return parameters[ParameterKey.source.rawValue]
    }
  }
}
