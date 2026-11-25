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
    Current.practiceSet = nil
    Current.dailySessionRequest = nil
    Current.challengeRequest = nil
  }

  private func link(_ string: String) throws -> Deeplink {
    try #require(Deeplink(url: url(string)))
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

  @Test func testHandleInAppDoesNotSwitchTab() {
    resetCurrent()
    Current.selectedTab = .models
    Current.handleInApp(.verb(.key("parler")))
    #expect(Current.verb?.infinitif == "parler")
    #expect(Current.selectedTab == .models, "In-app verb link must not change the tab.")

    Current.selectedTab = .info
    Current.handleInApp(.info("3"))
    #expect(Current.info == Info.infos[3])
    #expect(Current.selectedTab == .info, "In-app info link must not change the tab.")
  }

  @Test func testHandleInAppPreservesSiblingEntity() {
    resetCurrent()
    let model = VerbModel.models["4-2B"]
    #expect(model != nil)
    Current.verbModel = model
    Current.selectedTab = .models

    Current.handleInApp(.verb(.key("parler")))

    #expect(Current.verb?.infinitif == "parler")
    #expect(Current.verbModel?.id == model?.id, "In-app link must not clear the sibling verbModel.")
    #expect(Current.selectedTab == .models)
  }

  @Test func testQuizDeeplinkStartsQuizAndSwitchesTab() {
    resetCurrent()
    Current.selectedTab = .settings
    let original = Current.analytics
    let spy = AnalyticsSpy()
    Current.analytics = spy
    defer {
      Current.analytics = original
    }

    Current.handleURL(url("conjuguer://quiz/start"))

    #expect(Current.selectedTab == .quiz)
    #expect(Current.quiz.quizState == .inProgress)
    #expect(Current.quiz.scope.isRanked)
    #expect(spy.signalNames == [.quizStart])
    #expect(spy.signalParameters.first?[ParameterKey.source.rawValue] == "deeplink")

    Current.quiz.quit()
    Current.handleURL(url("conjuguer://quiz/start?source=control"))
    #expect(spy.signalParameters.last?[ParameterKey.source.rawValue] == "control")
    Current.quiz.quit()
  }

  /// The reminder's link opens the Quiz tab with a request that names it, and starts nothing
  /// itself: the tab starts the session unless a quiz is under way.
  @Test func testDailySessionDeeplinkRequestsASession() throws {
    resetCurrent()
    let link = Deeplink.dailySession(source: .reminder).url
    #expect(link.absoluteString == "conjuguer://quiz/daily?source=reminder")
    Current.selectedTab = .verbs
    Current.handleURL(link)

    #expect(Current.selectedTab == .quiz)
    #expect(Current.dailySessionRequest?.source == .reminder)
    #expect(Current.practiceSet == nil)

    Current.handleURL(url("conjuguer://verb/parler"))
    #expect(Current.dailySessionRequest == nil)
  }

  /// A shared result's link asks for that day's challenge at that level, and the tab starts it
  /// unless a quiz is under way or the challenge was taken.
  @Test func testChallengeDeeplinkRequestsThatChallenge() throws {
    resetCurrent()
    let key = try #require(DailyChallenge.Key(day: "2026-11-24", level: .advanced))
    let link = Deeplink.challenge(day: key.day, level: key.level, source: .challengeLink).url
    #expect(link.absoluteString == "conjuguer://quiz/challenge?date=2026-11-24&level=advanced&source=challengeLink")
    Current.selectedTab = .verbs
    Current.handleURL(link)

    #expect(Current.selectedTab == .quiz)
    #expect(Current.challengeRequest?.key == key)
    #expect(Current.challengeRequest?.source == .challengeLink)

    Current.handleURL(url("conjuguer://verb/parler"))
    #expect(Current.challengeRequest == nil)
  }

  @Test func testChallengeWidgetLinkRequestsTodaysChallenge() {
    resetCurrent()
    Current.handleURL(url("conjuguer://quiz/challenge?source=challengeWidget"))
    #expect(Current.challengeRequest?.key == nil)
    #expect(Current.challengeRequest?.source == .challengeWidget)
    #expect(Current.selectedTab == .quiz)
  }

  /// A link with no valid date asks for today's, and one with no known level asks at the
  /// learner's.
  @Test func testChallengeDeeplinkFallsBackOnABadDateOrLevel() {
    let level = Current.settings.quizLevel
    defer {
      Current.settings.quizLevel = level
    }
    Current.settings.quizLevel = .elementary
    resetCurrent()
    Current.handleURL(url("conjuguer://quiz/challenge?date=2026-02-30&level=advanced&source=challengeLink"))
    #expect(Current.challengeRequest != nil)
    #expect(Current.challengeRequest?.key == nil)

    Current.handleURL(url("conjuguer://quiz/challenge?date=2026-11-24&level=expert&source=challengeLink"))
    #expect(Current.challengeRequest?.key == DailyChallenge.Key(day: "2026-11-24", level: .elementary))
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
    Current.pendingDeeplink = .verb(.key("parler"))

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

  /// A link that names nothing must not close what is showing or drop what is pending (B4 of
  /// docs/verb_browse_review.md), so each starts with a verb page, a model page, a search, and a
  /// daily session waiting.
  @Test(arguments: [
    "conjuguer://verb/nonsense",
    "conjuguer://model/nonsense",
    "conjuguer://list/nonsense",
    "conjuguer://info/nonsense",
    "conjuguer://info/9999",
    "conjuguer://bogus/thing",
    "conjuguer://verb",
    "https://verb/parler"
  ])
  func testALinkThatNamesNothingChangesNothing(link: String) throws {
    resetCurrent()
    Current.handleURL(url("conjuguer://verb/lire?match=lis&source=lookup"))
    let marks = try #require(Current.verbMarks)
    let model = try #require(VerbModel.models["4-2B"])
    Current.verbModel = model
    let search = SearchRequest(text: "suis", source: .lookup)
    Current.searchRequest = search
    let session = DailySessionRequest(source: .reminder)
    Current.dailySessionRequest = session
    Current.selectedTab = .settings

    Current.handleURL(url(link))

    #expect(Current.verb?.infinitif == "lire")
    #expect(Current.verbSource == .lookup)
    #expect(Current.verbMarks == marks)
    #expect(Current.verbModel == model)
    #expect(Current.searchRequest == search)
    #expect(Current.dailySessionRequest == session)
    #expect(Current.selectedTab == .settings)
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

  @Test func testQueryItemsDoNotCountAsPathComponents() throws {
    #expect(try link("conjuguer://quiz/start?source=widget") == .startQuiz(source: .widget))
    #expect(Deeplink(url: url("conjuguer://verb?source=widget")) == nil)
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

  @Test func testInfoArticleVerbLinkNamesItself() throws {
    resetCurrent()
    Current.handleInApp(try link("conjuguer://verb/parler?source=infoLink"))
    #expect(Current.verb?.infinitif == "parler")
    #expect(Current.verbSource == .infoLink)
  }

  @Test func testASearchLinkRequestsItsTextFromItsSource() {
    resetCurrent()
    Current.handleURL(url("conjuguer://verb/parler"))
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
      Current.handleURL(Deeplink.info(info.stableKey).url)
      #expect(Current.info == info)
    }
  }

  @Test(arguments: [
    ("aller", "vais", Tense.indicatifPrésent(.firstSingular)),
    ("haïr France", "haïssait", .imparfait(.thirdSingular)),
    ("sortir exit", "sortait", .imparfait(.thirdSingular)),
    ("entre-déchirer", "entre-déchiraient", .imparfait(.thirdPlural)),
    ("arc-bouter", "arc-boutera", .futurSimple(.thirdSingular))
  ])
  func testVerbBuilderRoundTrips(key: String, match: String, marked: Tense) throws {
    try #require(Verb.verbs[key] != nil)
    resetCurrent()
    Current.handleURL(Deeplink.verb(.key(key), source: .widget, match: match).url)
    #expect(Current.verb?.dictionaryKey == key)
    #expect(Current.verbSource == .widget)
    #expect(Current.verbMarks?.tenses == [marked])
  }

  @Test(arguments: ["suis", "j'ai mangé", "to go", "a&b=c#d/e?f", "", "œuvrer"])
  func testSearchBuilderRoundTrips(text: String) throws {
    resetCurrent()
    Current.handleURL(Deeplink.search(text: text, source: .lookup).url)
    #expect(Current.searchRequest == SearchRequest(text: text, source: .lookup))
  }

  @Test func testModelBuilderRoundTrips() throws {
    resetCurrent()
    let model = try #require(VerbModel.models["4-2B"])
    Current.handleURL(Deeplink.model(model.id).url)
    #expect(Current.verbModel == model)
  }

  // The control's link is a literal, which Shared/ writes because it cannot reach the builders.
  @Test func testFindAVerbOpensAnEmptySearch() throws {
    let links = [
      (url(OpenVerbSearchIntent.pendingDeeplink), AnalyticsSource.control),
      (QuickAction.findVerb.deeplink.url, .quickAction)
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
    Current.handleURL(Deeplink.verb(.key(key), source: .spotlight).url)
    #expect(Current.verb?.dictionaryKey == "haïr France")
    #expect(Current.verbSource == .spotlight)
  }

  @Test func testAPendingSearchLinkIsReplayed() {
    resetCurrent()
    Current.pendingDeeplink = .search(text: "vais", source: .lookup)
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
      guard case .verb(.key(let key), .deeplink, nil) = Deeplink(url: link) else {
        Issue.record("Not a verb link: \(link)")
        continue
      }
      #expect(Verb.verbs[key] != nil)
    }
  }

  @Test func testEveryRouteRoundTrips() {
    let links: [Deeplink] = [
      .verb(.key("aller")),
      .verb(.key("haïr France"), source: .widget, match: "j'ai haï"),
      .verb(.random, source: .shortcut),
      .search(text: nil, source: .control),
      .search(text: "", source: .quickAction),
      .search(text: "a&b=c#d/e?f", source: .lookup),
      .model("1-9"),
      .model("6-7", source: .sharedLink),
      .list("top100", source: .sharedLink),
      .info("futur_simple"),
      .info("0"),
      .practiceSet(CustomQuiz(tenses: [.imparfait, .futurSimple], verbSet: .collection(.être)), level: nil, source: .sharedLink),
      .practiceSet(CustomQuiz(verbSet: .list(["parler", "haïr France"])), level: .beginner, source: .qrCode),
      .practiceSet(CustomQuiz(), level: nil),
      .dailySession(source: .reminder),
      .challenge(day: "2026-11-24", level: .advanced, source: .challengeLink),
      .challenge(day: nil, level: nil, source: .challengeWidget),
      .startQuiz(source: .control),
      .startQuiz()
    ]
    for link in links {
      #expect(Deeplink(url: link.url) == link, "\(link.url)")
    }
    #expect(Set(links.map(route)) == ["verb", "search", "model", "list", "info", "practiceSet", "dailySession", "challenge", "startQuiz"])
  }

  /// A new route fails to compile here until it is named, and then fails the round trip above
  /// until it has an example there.
  private func route(_ link: Deeplink) -> String {
    switch link {
    case .verb:
      return "verb"
    case .search:
      return "search"
    case .model:
      return "model"
    case .list:
      return "list"
    case .info:
      return "info"
    case .practiceSet:
      return "practiceSet"
    case .dailySession:
      return "dailySession"
    case .challenge:
      return "challenge"
    case .startQuiz:
      return "startQuiz"
    }
  }

  @Test func testALinkWithoutASourceCountsAsADeeplinkAndBuildsWithoutOne() throws {
    #expect(try link("conjuguer://model/1-9") == .model("1-9", source: .deeplink))
    #expect(Deeplink.model("1-9").url.absoluteString == "conjuguer://model/1-9")
    #expect(Deeplink.verb(.key("aller"), source: .lookup, match: "vais").url.absoluteString == "conjuguer://verb/aller?source=lookup&match=vais")
  }
}
