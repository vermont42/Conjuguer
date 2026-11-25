//
//  SceneRouterTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/25/26.
//

@testable import Conjuguer
import Foundation
import Testing
import UIKit

/// Each window owns a router, so that what one window shows does not change what another does
/// ("Multiple windows" in docs/verb_browse_review.md).
@MainActor
@Suite(.serialized)
struct SceneRouterTests {
  private static func url(_ string: String) throws -> URL {
    try #require(URL(string: string))
  }

  private static func scene() throws -> UIWindowScene {
    try #require(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
  }

  private static func window(in scene: UIWindowScene) -> UIWindow {
    let window = UIWindow(windowScene: scene)
    window.rootViewController = UIViewController()
    return window
  }

  @Test func twoWindowsKeepTheirOwnTabSheetAndSearch() throws {
    let first = SceneRouter()
    let second = SceneRouter()
    second.selectedTab = .settings

    first.handleURL(try Self.url("conjuguer://verb/venir?source=widget"))
    #expect(first.routedVerb?.verb.infinitif == "venir")
    #expect(first.selectedTab == .verbs)
    #expect(second.routedSheet == nil)
    #expect(second.selectedTab == .settings)

    second.openSearch(text: nil, source: .tab)
    #expect(second.searchRequest == SearchRequest(text: nil, source: .tab))
    #expect(second.selectedTab == .verbs)
    #expect(first.searchRequest == nil)
    #expect(first.routedVerb?.verb.infinitif == "venir")

    second.handleURL(try Self.url("conjuguer://quiz/daily?source=reminder"))
    #expect(second.dailySessionRequest != nil)
    #expect(first.dailySessionRequest == nil)
    #expect(first.selectedTab == .verbs)
  }

  @Test func aLinkThatArrivesBeforeTheVerbsIsReplayedInItsOwnWindow() {
    let first = SceneRouter()
    let second = SceneRouter()
    first.pendingDeeplink = .verb(.key("aller"))

    second.drainPendingDeeplink()
    first.drainPendingDeeplink()

    #expect(first.routedVerb?.verb.infinitif == "aller")
    #expect(second.routedSheet == nil)
  }

  /// A quick action that launches the app names its scene before that scene's router exists.
  @Test func aLinkForASceneWaitsForItsRouter() throws {
    let scene = try Self.scene()
    let window = Self.window(in: scene)
    defer {
      window.isHidden = true
    }

    SceneRouter.deliver(.search(text: "", source: .quickAction), to: scene)
    let router = SceneRouter()
    #expect(router.searchRequest == nil)
    router.attach(to: window)

    #expect(router.searchRequest == SearchRequest(text: "", source: .quickAction))
    let other = SceneRouter()
    other.attach(to: Self.window(in: scene))
    #expect(other.searchRequest == nil, "A waiting link is taken once.")
  }

  /// An App Intent names no window, so its link goes to the active one, and to none other.
  @Test func aLinkForNoWindowGoesToTheActiveWindow() throws {
    let scene = try Self.scene()
    try #require(scene.activationState == .foregroundActive)
    let window = Self.window(in: scene)
    defer {
      window.isHidden = true
    }
    let attached = SceneRouter()
    attached.attach(to: window)
    let detached = SceneRouter()

    SceneRouter.deliver(try Self.url("conjuguer://verb/lire?source=lookup"))

    #expect(attached.routedVerb?.verb.infinitif == "lire")
    #expect(detached.routedSheet == nil)
  }

  /// With no window active, as when an intent opens the app on a cold launch, the link waits
  /// for the first window that becomes active.
  @Test func aLinkForNoWindowWaitsForOneToBecomeActive() throws {
    SceneRouter.deliver(try Self.url("conjuguer://model/1-9"))
    let router = SceneRouter()
    router.claimUnaddressedLink()
    #expect(router.routedModel?.id == "1-9")

    let later = SceneRouter()
    later.claimUnaddressedLink()
    #expect(later.routedSheet == nil, "The link is claimed once.")
  }

  /// Before Phase 3, one closure and one host served every window: the second window's field
  /// took the first's arrow keys, and either window's uninstall took them from both.
  @Test func eachWindowKeepsItsOwnArrowKeys() throws {
    let scene = try Self.scene()
    let first = Self.window(in: scene)
    let second = Self.window(in: scene)
    defer {
      VerbSearchArrowKeys.uninstall(from: first)
      VerbSearchArrowKeys.uninstall(from: second)
    }
    var firstMoves: [Int] = []
    var secondMoves: [Int] = []

    VerbSearchArrowKeys.install(in: first) { firstMoves.append($0) }
    VerbSearchArrowKeys.install(in: second) { secondMoves.append($0) }
    #expect(first.rootViewController?.keyCommands?.count == 2)
    #expect(second.rootViewController?.keyCommands?.count == 2)

    VerbSearchArrowKeys.move(by: 1, in: first)
    VerbSearchArrowKeys.move(by: -1, in: second)
    #expect(firstMoves == [1])
    #expect(secondMoves == [-1])

    VerbSearchArrowKeys.uninstall(from: first)
    #expect(first.rootViewController?.keyCommands?.isEmpty ?? true)
    #expect(second.rootViewController?.keyCommands?.count == 2)
    VerbSearchArrowKeys.move(by: 1, in: first)
    VerbSearchArrowKeys.move(by: 1, in: second)
    #expect(firstMoves == [1])
    #expect(secondMoves == [-1, 1])
  }
}
