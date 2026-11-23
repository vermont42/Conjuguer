//
//  DeeplinkTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 5/31/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct DeeplinkTests {
  private func url(_ string: String) -> URL {
    guard let url = URL(string: string) else {
      fatalError("Invalid test URL: \(string)")
    }
    return url
  }

  // Swift Testing has no setUp; each serialized test clears the shared `Current` entities
  // first so a prior test's state can't leak in.
  private func resetCurrent() {
    Current.verb = nil
    Current.verbModel = nil
    Current.collection = nil
    Current.info = nil
    Current.pendingDeeplink = nil
    Current.verbSource = .deeplink
    Current.verbMarks = nil
    Current.searchRequest = nil
  }

  @Test func testHandleURLSwitchesTab() {
    resetCurrent()
    Current.selectedTab = .settings
    Current.handleURL(url("conjuguer://verb/parler"))
    #expect(Current.verb?.infinitif == "parler")
    #expect(Current.selectedTab == .verbs)

    Current.selectedTab = .settings
    Current.handleURL(url("conjuguer://info/2"))
    #expect(Current.info == Info.infos[2])
    #expect(Current.selectedTab == .info)
  }

  @Test func testHandleInAppURLDoesNotSwitchTab() {
    resetCurrent()
    Current.selectedTab = .models
    Current.handleInAppURL(url("conjuguer://verb/parler"))
    #expect(Current.verb?.infinitif == "parler")
    #expect(Current.selectedTab == .models, "In-app verb link must not change the tab.")

    Current.selectedTab = .info
    Current.handleInAppURL(url("conjuguer://info/3"))
    #expect(Current.info == Info.infos[3])
    #expect(Current.selectedTab == .info, "In-app info link must not change the tab.")
  }

  @Test func testHandleInAppURLPreservesSiblingEntity() {
    resetCurrent()
    let model = VerbModel.models["4-2B"]
    #expect(model != nil)
    Current.verbModel = model
    Current.selectedTab = .models

    Current.handleInAppURL(url("conjuguer://verb/parler"))

    #expect(Current.verb?.infinitif == "parler")
    #expect(Current.verbModel?.id == model?.id, "In-app link must not clear the sibling verbModel.")
    #expect(Current.selectedTab == .models)
  }

  @Test func testQuizDeeplinkStartsQuizAndSwitchesTab() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("conjuguer://quiz/start"))

    #expect(Current.selectedTab == .quiz)
    #expect(Current.quiz.quizState == .inProgress)
  }

  @Test func testModelDeeplinkSelectsModel() {
    resetCurrent()
    Current.selectedTab = .verbs

    Current.handleURL(url("conjuguer://model/4-2B"))

    #expect(Current.verbModel?.id == "4-2B")
    #expect(Current.selectedTab == .models)
  }

  @Test func testRandomVerbDeeplinkSelectsSomeVerb() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("conjuguer://verb/random"))

    #expect(Current.verb != nil, "The random-verb link must resolve to a verb.")
    #expect(Current.selectedTab == .verbs)
  }

  @Test func testNegativeInfoIndexIsRejectedWithoutCrashing() {
    resetCurrent()
    Current.selectedTab = .settings

    // Finding 9: `-1` passes the upper-bound check but must be rejected by the
    // `indices.contains` guard rather than trapping on `Info.infos[-1]`.
    Current.handleURL(url("conjuguer://info/-1"))

    #expect(Current.info == nil)
    #expect(Current.selectedTab == .settings, "An out-of-range info link must not switch the tab.")
  }

  @Test func testTooLargeInfoIndexIsRejected() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("conjuguer://info/9999"))

    #expect(Current.info == nil)
    #expect(Current.selectedTab == .settings)
  }

  @Test func testNonNumericInfoIndexIsRejected() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("conjuguer://info/abc"))

    #expect(Current.info == nil)
    #expect(Current.selectedTab == .settings)
  }

  @Test func testWrongSchemeIsIgnored() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("https://verb/parler"))

    #expect(Current.verb == nil, "A non-conjuguer scheme must not resolve an entity.")
    #expect(Current.selectedTab == .settings)
  }

  @Test func testWrongComponentCountIsIgnored() {
    resetCurrent()
    Current.selectedTab = .settings

    // `conjuguer://verb` has no path component, so it fails the component-count guard.
    Current.handleURL(url("conjuguer://verb"))

    #expect(Current.verb == nil)
    #expect(Current.selectedTab == .settings)
  }

  @Test func testDrainPendingDeeplinkReplaysDeferredLink() {
    resetCurrent()
    Current.selectedTab = .settings

    // Simulates the cold-launch case: handleURL deferred a widget link (stored it in
    // pendingDeeplink) because VerbData had not loaded yet.
    Current.pendingDeeplink = url("conjuguer://verb/parler")

    Current.drainPendingDeeplink()

    #expect(Current.verb?.infinitif == "parler", "Draining must resolve the deferred verb.")
    #expect(Current.selectedTab == .verbs, "Draining must switch to the verb's tab.")
    #expect(Current.pendingDeeplink == nil, "Draining must clear the pending deeplink.")
  }

  @Test func testDrainPendingDeeplinkIsNoOpWhenNonePending() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.drainPendingDeeplink()

    #expect(Current.verb == nil)
    #expect(Current.selectedTab == .settings, "Draining with nothing pending must not change state.")
  }

  @Test func testUnknownHostIsIgnored() {
    resetCurrent()
    Current.selectedTab = .settings

    Current.handleURL(url("conjuguer://bogus/thing"))

    #expect(Current.verb == nil)
    #expect(Current.verbModel == nil)
    #expect(Current.info == nil)
    #expect(Current.selectedTab == .settings, "An unknown host must not switch the tab.")
  }

  @Test func testOpenSearchClosesPagesAndRequestsTheField() {
    resetCurrent()
    Current.selectedTab = .quiz
    Current.handleURL(url("conjuguer://verb/parler"))
    Current.verbModel = VerbModel.models.values.first

    Current.openSearch(text: nil, source: .tab)

    #expect(Current.verb == nil)
    #expect(Current.verbModel == nil)
    #expect(Current.selectedTab == .verbs)
    #expect(Current.searchRequest == SearchRequest(text: nil, source: .tab))
    Current.searchRequest = nil
  }

  @Test(arguments: [
    ("conjuguer://verb/aller?source=widget", AnalyticsSource.widget),
    ("conjuguer://verb/aller", .deeplink),
    ("conjuguer://verb/aller?source=bogus", .deeplink),
    ("conjuguer://verb/aller?source=", .deeplink),
    ("conjuguer://verb/aller?other=1&source=control", .control)
  ])
  func testVerbLinkCarriesItsSource(link: String, source: AnalyticsSource) {
    resetCurrent()
    Current.verbSource = .resume
    Current.handleURL(url(link))
    #expect(Current.verb?.infinitif == "aller")
    #expect(Current.verbSource == source)
  }

  @Test func testSourceItemDoesNotBreakAPercentEncodedVerb() {
    resetCurrent()
    Current.handleURL(url("conjuguer://verb/ha%C3%AFr%20France?source=widget"))
    #expect(Current.verb?.dictionaryKey == "haïr France")
    #expect(Current.verbSource == .widget)
  }

  @Test func testQueryItemsDoNotCountAsPathComponents() {
    #expect(url("conjuguer://quiz/start?source=widget").hasExpectedNumberOfDeeplinkComponents)
    #expect(!url("conjuguer://verb?source=widget").hasExpectedNumberOfDeeplinkComponents)
  }

  @Test(arguments: [
    (OpenRandomVerbIntent.pendingDeeplink, AnalyticsSource.shortcut),
    (OpenRandomVerbControlIntent.pendingDeeplink, .control)
  ])
  func testRandomVerbIntentsNameThemselves(link: String, source: AnalyticsSource) {
    resetCurrent()
    Current.handleURL(url(link))
    #expect(Current.verb != nil)
    #expect(Current.verbSource == source)
  }

  @Test func testInfoArticleVerbLinkNamesItself() {
    resetCurrent()
    Current.handleInAppURL(url("conjuguer://verb/parler?source=infoLink"))
    #expect(Current.verb?.infinitif == "parler")
    #expect(Current.verbSource == .infoLink)
  }

  @Test func testASearchLinkRequestsItsTextFromItsSource() {
    resetCurrent()
    Current.selectedTab = .quiz
    Current.handleURL(url("conjuguer://search?q=j%27ai%20mang%C3%A9&source=lookup"))
    #expect(Current.searchRequest == SearchRequest(text: "j'ai mangé", source: .lookup))
    #expect(Current.selectedTab == .verbs)
    #expect(Current.verb == nil)
  }

  @Test func testASearchLinkWithoutTextClearsTheFieldForTyping() {
    resetCurrent()
    Current.handleURL(url("conjuguer://search"))
    #expect(Current.searchRequest == SearchRequest(text: "", source: .deeplink))
  }

  @Test func testTheSearchRouteTakesNoTarget() {
    resetCurrent()
    Current.selectedTab = .settings
    Current.handleURL(url("conjuguer://search/venir"))
    #expect(Current.searchRequest == nil)
    #expect(Current.selectedTab == .settings)
  }

  @Test func testAVerbLinkClearsAPendingSearchRequest() {
    resetCurrent()
    Current.handleURL(url("conjuguer://search?q=suis"))
    Current.handleURL(url("conjuguer://verb/aller"))
    #expect(Current.searchRequest == nil)
    #expect(Current.verb?.infinitif == "aller")
  }

  @Test func testAMatchMarksItsCells() throws {
    resetCurrent()
    Current.handleURL(url("conjuguer://verb/aller?match=vais&source=lookup"))
    let marks = try #require(Current.verbMarks)
    #expect(marks.tenses == [.indicatifPrésent(.firstSingular)])
    #expect(Current.verbSource == .lookup)
  }

  @Test func testACompoundMatchMarksTheCompoundTense() throws {
    resetCurrent()
    Current.handleURL(url("conjuguer://verb/manger?match=ai%20mang%C3%A9"))
    let marks = try #require(Current.verbMarks)
    #expect(marks.includesCompoundTense)
    #expect(marks.contains(.passéComposé(.firstSingular)))
  }

  @Test func testAMatchThatFillsNoCellStillOpensThePage() {
    resetCurrent()
    Current.handleURL(url("conjuguer://verb/aller?match=xyzzyq"))
    #expect(Current.verb?.infinitif == "aller")
    #expect(Current.verbMarks == nil)
  }

  @Test func testAnInfoLinkNamesItsArticleByKeyOrPosition() {
    for (index, info) in Info.infos.enumerated() {
      resetCurrent()
      Current.handleURL(url("conjuguer://info/\(info.stableKey)"))
      #expect(Current.info == info)
      resetCurrent()
      Current.handleURL(url("conjuguer://info/\(index)"))
      #expect(Current.info == info)
    }
  }

  @Test func testInfoBuilderRoundTrips() throws {
    for info in Info.infos {
      resetCurrent()
      Current.handleURL(try #require(URL.infoDeeplink(info)))
      #expect(Current.info == info)
    }
  }

  @Test(arguments: ["aller", "haïr France", "sortir exit", "s'entre-déchirer", "arc-bouter"])
  func testVerbBuilderRoundTrips(key: String) throws {
    guard Verb.verbs[key] != nil else {
      return
    }
    resetCurrent()
    Current.handleURL(try #require(URL.verbDeeplink(key, source: .widget, match: "j'ai")))
    #expect(Current.verb?.dictionaryKey == key)
    #expect(Current.verbSource == .widget)
  }

  @Test(arguments: ["suis", "j'ai mangé", "to go", "a&b=c#d/e?f", "", "œuvrer"])
  func testSearchBuilderRoundTrips(text: String) throws {
    resetCurrent()
    Current.handleURL(try #require(URL.searchDeeplink(text: text, source: .lookup)))
    #expect(Current.searchRequest == SearchRequest(text: text, source: .lookup))
  }

  @Test func testModelBuilderRoundTrips() throws {
    resetCurrent()
    let model = try #require(VerbModel.models["4-2B"])
    Current.handleURL(try #require(URL.modelDeeplink(model)))
    #expect(Current.verbModel == model)
  }

  // The control's link is a literal, which Shared/ writes because it cannot reach the builders.
  @Test func testFindAVerbOpensAnEmptySearch() throws {
    let links = [
      (url(OpenVerbSearchIntent.pendingDeeplink), AnalyticsSource.control),
      (try #require(QuickAction.findVerb.deeplink), .quickAction)
    ]
    for (link, source) in links {
      resetCurrent()
      Current.selectedTab = .quiz
      Current.handleURL(link)
      #expect(Current.searchRequest == SearchRequest(text: "", source: source))
      #expect(Current.selectedTab == .verbs)
    }
  }

  @Test func testASpotlightResultOpensItsVerb() throws {
    resetCurrent()
    let key = VerbSpotlight.verbKey(fromSpotlightIdentifier: "VerbEntity/haïr France")
    Current.handleURL(try #require(URL.verbDeeplink(key, source: .spotlight)))
    #expect(Current.verb?.dictionaryKey == "haïr France")
    #expect(Current.verbSource == .spotlight)
  }

  @Test func testAPendingSearchLinkIsReplayed() {
    resetCurrent()
    Current.pendingDeeplink = url("conjuguer://search?q=vais&source=lookup")
    Current.drainPendingDeeplink()
    #expect(Current.searchRequest == SearchRequest(text: "vais", source: .lookup))
    #expect(Current.pendingDeeplink == nil)
  }

  // A model page's verbs list is a run of these links, which ModelView reads back.
  @Test func testAModelsVerbLinksNameTheirVerbs() throws {
    let model = try #require(VerbModel.models["4-2B"])
    let links = model.verbsWithDeepLinks().runs.compactMap(\.link)
    #expect(links.count == model.verbs.count)
    for link in links {
      #expect(link.hasExpectedNumberOfDeeplinkComponents)
      #expect(Verb.verbs[link.pathComponents[1]] != nil)
    }
  }
}
