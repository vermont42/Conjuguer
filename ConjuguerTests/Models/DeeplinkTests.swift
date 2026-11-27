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

  private func link(_ string: String) throws -> Deeplink {
    try #require(Deeplink(url: url(string)))
  }

  @Test func testHandleURLSwitchesTab() {
    let router = SceneRouter()
    router.selectedTab = .settings
    router.handleURL(url("conjuguer://verb/parler"))
    #expect(router.routedVerb?.verb.infinitif == "parler")
    #expect(router.selectedTab == .verbs)

    router.selectedTab = .settings
    router.handleURL(url("conjuguer://info/2"))
    #expect(router.routedArticle == Info.infos[2])
    #expect(router.selectedTab == .info)
  }

  /// An article's links are its rich text's URLs: a heading, percent-encoded, names another
  /// article, and a verb's name names its page.
  @Test func anArticlesLinkNamesAnArticleOrAVerb() throws {
    let article = try #require(Info.infos.first { $0.heading.contains(" ") })
    let encoded = try #require(article.heading.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
    #expect(InfoView.LinkTarget(url: url(encoded)) == .article(article))
    #expect(InfoView.LinkTarget(url: url("%C3%AAtre")) == .verb(try #require(Verb.verbs["être"])))
    #expect(InfoView.LinkTarget(url: url("https://fr.wiktionary.org")) == nil)
  }

  @Test func testQuizDeeplinkStartsQuizAndSwitchesTab() {
    let router = SceneRouter()
    router.selectedTab = .settings
    let original = Current.analytics
    let spy = AnalyticsSpy()
    Current.analytics = spy
    defer {
      Current.analytics = original
    }

    router.handleURL(url("conjuguer://quiz/start"))

    #expect(router.selectedTab == .quiz)
    #expect(Current.quiz.quizState == .inProgress)
    #expect(Current.quiz.scope.isRanked)
    #expect(spy.signalNames == [.quizStart])
    #expect(spy.signalParameters.first?[ParameterKey.source.rawValue] == "deeplink")

    Current.quiz.quit()
    router.handleURL(url("conjuguer://quiz/start?source=control"))
    #expect(spy.signalParameters.last?[ParameterKey.source.rawValue] == "control")
    Current.quiz.quit()
  }

  /// The reminder's link opens the Quiz tab with a request that names it, and starts nothing
  /// itself: the tab starts the session unless a quiz is under way.
  @Test func testDailySessionDeeplinkRequestsASession() throws {
    let router = SceneRouter()
    let link = Deeplink.dailySession(source: .reminder).url
    #expect(link.absoluteString == "conjuguer://quiz/daily?source=reminder")
    router.selectedTab = .verbs
    router.handleURL(link)

    #expect(router.selectedTab == .quiz)
    #expect(router.dailySessionRequest?.source == .reminder)
    #expect(router.routedPracticeSet == nil)

    router.handleURL(url("conjuguer://verb/parler"))
    #expect(router.dailySessionRequest == nil)
  }

  /// A shared result's link asks for that day's challenge at that level, and the tab starts it
  /// unless a quiz is under way or the challenge was taken.
  @Test func testChallengeDeeplinkRequestsThatChallenge() throws {
    let router = SceneRouter()
    let key = try #require(DailyChallenge.Key(day: "2026-11-24", level: .advanced))
    let link = Deeplink.challenge(day: key.day, level: key.level, source: .challengeLink).url
    #expect(link.absoluteString == "conjuguer://quiz/challenge?date=2026-11-24&level=advanced&source=challengeLink")
    router.selectedTab = .verbs
    router.handleURL(link)

    #expect(router.selectedTab == .quiz)
    #expect(router.challengeRequest?.key == key)
    #expect(router.challengeRequest?.source == .challengeLink)

    router.handleURL(url("conjuguer://verb/parler"))
    #expect(router.challengeRequest == nil)
  }

  @Test func testChallengeWidgetLinkRequestsTodaysChallenge() {
    let router = SceneRouter()
    router.handleURL(url("conjuguer://quiz/challenge?source=challengeWidget"))
    #expect(router.challengeRequest?.key == nil)
    #expect(router.challengeRequest?.source == .challengeWidget)
    #expect(router.selectedTab == .quiz)
  }

  /// A link with no valid date asks for today's, and one with no known level asks at the
  /// learner's.
  @Test func testChallengeDeeplinkFallsBackOnABadDateOrLevel() {
    let level = Current.settings.quizLevel
    defer {
      Current.settings.quizLevel = level
    }
    Current.settings.quizLevel = .elementary
    let router = SceneRouter()
    router.handleURL(url("conjuguer://quiz/challenge?date=2026-02-30&level=advanced&source=challengeLink"))
    #expect(router.challengeRequest != nil)
    #expect(router.challengeRequest?.key == nil)

    router.handleURL(url("conjuguer://quiz/challenge?date=2026-11-24&level=expert&source=challengeLink"))
    #expect(router.challengeRequest?.key == DailyChallenge.Key(day: "2026-11-24", level: .elementary))
  }

  @Test func testModelDeeplinkSelectsModel() {
    let router = SceneRouter()
    router.selectedTab = .verbs

    router.handleURL(url("conjuguer://model/4-2B"))

    #expect(router.routedModel?.id == "4-2B")
    #expect(router.selectedTab == .models)
  }

  @Test func testRandomVerbDeeplinkSelectsSomeVerb() {
    let router = SceneRouter()
    router.selectedTab = .settings

    router.handleURL(url("conjuguer://verb/random"))

    #expect(router.routedVerb != nil, "The random-verb link must resolve to a verb.")
    #expect(router.selectedTab == .verbs)
  }

  @Test func testNegativeInfoIndexIsRejectedWithoutCrashing() {
    let router = SceneRouter()
    router.selectedTab = .settings

    // Finding 9: `-1` passes the upper-bound check but must be rejected by the
    // `indices.contains` guard rather than trapping on `Info.infos[-1]`.
    router.handleURL(url("conjuguer://info/-1"))

    #expect(router.routedArticle == nil)
    #expect(router.selectedTab == .settings, "An out-of-range info link must not switch the tab.")
  }

  @Test func testTooLargeInfoIndexIsRejected() {
    let router = SceneRouter()
    router.selectedTab = .settings

    router.handleURL(url("conjuguer://info/9999"))

    #expect(router.routedArticle == nil)
    #expect(router.selectedTab == .settings)
  }

  @Test func testNonNumericInfoIndexIsRejected() {
    let router = SceneRouter()
    router.selectedTab = .settings

    router.handleURL(url("conjuguer://info/abc"))

    #expect(router.routedArticle == nil)
    #expect(router.selectedTab == .settings)
  }

  @Test func testWrongSchemeIsIgnored() {
    let router = SceneRouter()
    router.selectedTab = .settings

    router.handleURL(url("https://verb/parler"))

    #expect(router.routedVerb == nil, "A non-conjuguer scheme must not resolve an entity.")
    #expect(router.selectedTab == .settings)
  }

  @Test func testWrongComponentCountIsIgnored() {
    let router = SceneRouter()
    router.selectedTab = .settings

    // `conjuguer://verb` has no path component, so it fails the component-count guard.
    router.handleURL(url("conjuguer://verb"))

    #expect(router.routedVerb == nil)
    #expect(router.selectedTab == .settings)
  }

  @Test func testDrainPendingDeeplinkReplaysDeferredLink() {
    let router = SceneRouter()
    router.selectedTab = .settings

    // Simulates the cold-launch case: handleURL deferred a widget link (stored it in
    // pendingDeeplink) because VerbData had not loaded yet.
    router.pendingDeeplink = .verb(.key("parler"))

    router.drainPendingDeeplink()

    #expect(router.routedVerb?.verb.infinitif == "parler", "Draining must resolve the deferred verb.")
    #expect(router.selectedTab == .verbs, "Draining must switch to the verb's tab.")
    #expect(router.pendingDeeplink == nil, "Draining must clear the pending deeplink.")
  }

  @Test func testDrainPendingDeeplinkIsNoOpWhenNonePending() {
    let router = SceneRouter()
    router.selectedTab = .settings

    router.drainPendingDeeplink()

    #expect(router.routedVerb == nil)
    #expect(router.selectedTab == .settings, "Draining with nothing pending must not change state.")
  }

  /// A link that names nothing must not close what is showing or drop what is pending (B4 of
  /// docs/verb_browse_review.md), so each starts with a verb page, a search, and a daily session
  /// waiting.
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
    let router = SceneRouter()
    router.handleURL(url("conjuguer://verb/lire?match=lis&source=lookup"))
    let sheet = try #require(router.routedSheet)
    let marks = try #require(router.routedVerb?.marks)
    let search = SearchRequest(text: "suis", source: .lookup)
    router.searchRequest = search
    let session = DailySessionRequest(source: .reminder)
    router.dailySessionRequest = session
    router.selectedTab = .settings

    router.handleURL(url(link))

    #expect(router.routedVerb?.verb.infinitif == "lire")
    #expect(router.routedVerb?.source == .lookup)
    #expect(router.routedVerb?.marks == marks)
    #expect(router.routedSheet?.id == sheet.id)
    #expect(router.searchRequest == search)
    #expect(router.dailySessionRequest == session)
    #expect(router.selectedTab == .settings)
  }

  @Test func testUnknownHostIsIgnored() {
    let router = SceneRouter()
    router.selectedTab = .settings

    router.handleURL(url("conjuguer://bogus/thing"))

    #expect(router.routedVerb == nil)
    #expect(router.routedModel == nil)
    #expect(router.routedArticle == nil)
    #expect(router.selectedTab == .settings, "An unknown host must not switch the tab.")
  }

  @Test func testOpenSearchClosesPagesAndRequestsTheField() {
    let router = SceneRouter()
    router.selectedTab = .quiz
    router.handleURL(url("conjuguer://verb/parler"))

    router.openSearch(text: nil, source: .tab)

    #expect(router.routedSheet == nil)
    #expect(router.selectedTab == .verbs)
    #expect(router.searchRequest == SearchRequest(text: nil, source: .tab))
    router.searchRequest = nil
  }

  @Test(arguments: [
    ("conjuguer://verb/aller?source=widget", AnalyticsSource.widget),
    ("conjuguer://verb/aller", .deeplink),
    ("conjuguer://verb/aller?source=bogus", .deeplink),
    ("conjuguer://verb/aller?source=", .deeplink),
    ("conjuguer://verb/aller?other=1&source=control", .control)
  ])
  func testVerbLinkCarriesItsSource(link: String, source: AnalyticsSource) {
    let router = SceneRouter()
    router.handleURL(url(link))
    #expect(router.routedVerb?.verb.infinitif == "aller")
    #expect(router.routedVerb?.source == source)
  }

  @Test func testSourceItemDoesNotBreakAPercentEncodedVerb() {
    let router = SceneRouter()
    router.handleURL(url("conjuguer://verb/ha%C3%AFr%20France?source=widget"))
    #expect(router.routedVerb?.verb.dictionaryKey == "haïr France")
    #expect(router.routedVerb?.source == .widget)
  }

  @Test func testQueryItemsDoNotCountAsPathComponents() throws {
    #expect(try link("conjuguer://quiz/start?source=widget") == .startQuiz(source: .widget))
    #expect(Deeplink(url: url("conjuguer://verb?source=widget")) == nil)
  }

  @Test(arguments: [
    (OpenRandomVerbIntent.pendingDeeplink, AnalyticsSource.shortcut),
    (OpenRandomVerbControlIntent.pendingDeeplink, .control)
  ])
  func testRandomVerbIntentsNameThemselves(link: WidgetDeeplink, source: AnalyticsSource) throws {
    let router = SceneRouter()
    router.handleURL(try #require(link.url))
    #expect(router.routedVerb != nil)
    #expect(router.routedVerb?.source == source)
  }

  // The widget extension and Shared/ cannot reach Deeplink, so they spell their links
  // themselves. Each must be the link Deeplink builds for the same place.
  @Test(arguments: [
    (WidgetDeeplink.challenge, Deeplink.challenge(day: nil, level: nil, source: .challengeWidget)),
    (.findVerb, .search(text: nil, source: .control)),
    (.quiz, .startQuiz()),
    (.randomVerbFromControl, .verb(.random, source: .control)),
    (.randomVerbFromShortcut, .verb(.random, source: .shortcut)),
    (.verb("aller"), .verb(.key("aller"), source: .widget))
  ])
  func testAWidgetLinkIsTheBuildersLink(widgetLink: WidgetDeeplink, link: Deeplink) throws {
    let url = try #require(widgetLink.url)
    #expect(url == link.url)
    #expect(Deeplink(url: url) == link)
  }

  @Test func testTheIntentsLeaveTheirOwnLinks() {
    let intents: [any PendingDeeplinkIntent.Type] = [
      OpenQuizIntent.self, OpenRandomVerbIntent.self, OpenRandomVerbControlIntent.self, OpenVerbSearchIntent.self
    ]
    #expect(Set(intents.map { $0.pendingDeeplink }) == [.quiz, .randomVerbFromShortcut, .randomVerbFromControl, .findVerb])
  }

  @Test func testAnIntentLeavesItsLinkForTheApp() async throws {
    let defaults = try #require(WidgetConstants.sharedDefaults)
    let earlier = defaults.string(forKey: WidgetConstants.pendingDeeplinkKey)
    defer {
      defaults.set(earlier, forKey: WidgetConstants.pendingDeeplinkKey)
    }
    _ = try await OpenRandomVerbControlIntent().perform()
    #expect(defaults.string(forKey: WidgetConstants.pendingDeeplinkKey) == WidgetDeeplink.randomVerbFromControl.url?.absoluteString)
  }

  @Test func testEveryVerbsWidgetLinkIsTheBuildersLink() {
    for key in Verb.verbs.keys {
      let widgetURL = WidgetDeeplink.verb(key).url
      if widgetURL != Deeplink.verb(.key(key), source: .widget).url {
        Issue.record("\(key): the widget builds \(widgetURL?.absoluteString ?? "nothing")")
      }
    }
  }

  @Test func testASearchLinkRequestsItsTextFromItsSource() {
    let router = SceneRouter()
    router.handleURL(url("conjuguer://verb/parler"))
    router.selectedTab = .quiz
    router.handleURL(url("conjuguer://search?q=j%27ai%20mang%C3%A9&source=lookup"))
    #expect(router.searchRequest == SearchRequest(text: "j'ai mangé", source: .lookup))
    #expect(router.selectedTab == .verbs)
    #expect(router.routedVerb == nil)
  }

  @Test func testASearchLinkWithoutTextClearsTheFieldForTyping() {
    let router = SceneRouter()
    router.handleURL(url("conjuguer://search"))
    #expect(router.searchRequest == SearchRequest(text: "", source: .deeplink))
  }

  @Test func testTheSearchRouteTakesNoTarget() {
    let router = SceneRouter()
    router.selectedTab = .settings
    router.handleURL(url("conjuguer://search/venir"))
    #expect(router.searchRequest == nil)
    #expect(router.selectedTab == .settings)
  }

  @Test func testAVerbLinkClearsAPendingSearchRequest() {
    let router = SceneRouter()
    router.handleURL(url("conjuguer://search?q=suis"))
    router.handleURL(url("conjuguer://verb/aller"))
    #expect(router.searchRequest == nil)
    #expect(router.routedVerb?.verb.infinitif == "aller")
  }

  @Test func testAMatchMarksItsCells() throws {
    let router = SceneRouter()
    router.handleURL(url("conjuguer://verb/aller?match=vais&source=lookup"))
    let marks = try #require(router.routedVerb?.marks)
    #expect(marks.tenses == [.indicatifPrésent(.firstSingular)])
    #expect(router.routedVerb?.source == .lookup)
  }

  @Test func testACompoundMatchMarksTheCompoundTense() throws {
    let router = SceneRouter()
    router.handleURL(url("conjuguer://verb/manger?match=ai%20mang%C3%A9"))
    let marks = try #require(router.routedVerb?.marks)
    #expect(marks.includesCompoundTense)
    #expect(marks.contains(.passéComposé(.firstSingular)))
  }

  @Test func testAMatchThatFillsNoCellStillOpensThePage() {
    let router = SceneRouter()
    router.handleURL(url("conjuguer://verb/aller?match=xyzzyq"))
    #expect(router.routedVerb?.verb.infinitif == "aller")
    #expect(router.routedVerb?.marks == nil)
  }

  @Test func testAnInfoLinkNamesItsArticleByKeyOrPosition() {
    for (index, info) in Info.infos.enumerated() {
      let router = SceneRouter()
      router.handleURL(url("conjuguer://info/\(info.stableKey)"))
      #expect(router.routedArticle == info)
      router.handleURL(url("conjuguer://info/\(index)"))
      #expect(router.routedArticle == info)
    }
  }

  @Test func testInfoBuilderRoundTrips() throws {
    for info in Info.infos {
      let router = SceneRouter()
      router.handleURL(Deeplink.info(info.stableKey).url)
      #expect(router.routedArticle == info)
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
    let router = SceneRouter()
    router.handleURL(Deeplink.verb(.key(key), source: .widget, match: match).url)
    #expect(router.routedVerb?.verb.dictionaryKey == key)
    #expect(router.routedVerb?.source == .widget)
    #expect(router.routedVerb?.marks?.tenses == [marked])
  }

  @Test(arguments: ["suis", "j'ai mangé", "to go", "a&b=c#d/e?f", "", "œuvrer"])
  func testSearchBuilderRoundTrips(text: String) throws {
    let router = SceneRouter()
    router.handleURL(Deeplink.search(text: text, source: .lookup).url)
    #expect(router.searchRequest == SearchRequest(text: text, source: .lookup))
  }

  @Test func testModelBuilderRoundTrips() throws {
    let router = SceneRouter()
    let model = try #require(VerbModel.models["4-2B"])
    router.handleURL(Deeplink.model(model.id).url)
    #expect(router.routedModel == model)
  }

  @Test func testFindAVerbOpensAnEmptySearch() throws {
    let links = [
      (try #require(OpenVerbSearchIntent.pendingDeeplink.url), AnalyticsSource.control),
      (QuickAction.findVerb.deeplink.url, .quickAction)
    ]
    for (link, source) in links {
      let router = SceneRouter()
      router.selectedTab = .quiz
      router.handleURL(link)
      #expect(router.searchRequest == SearchRequest(text: "", source: source))
      #expect(router.selectedTab == .verbs)
    }
  }

  @Test func testASpotlightResultOpensItsVerb() throws {
    let router = SceneRouter()
    let key = VerbSpotlight.verbKey(fromSpotlightIdentifier: "VerbEntity/haïr France")
    router.handleURL(Deeplink.verb(.key(key), source: .spotlight).url)
    #expect(router.routedVerb?.verb.dictionaryKey == "haïr France")
    #expect(router.routedVerb?.source == .spotlight)
  }

  @Test func testAPendingSearchLinkIsReplayed() {
    let router = SceneRouter()
    router.pendingDeeplink = .search(text: "vais", source: .lookup)
    router.drainPendingDeeplink()
    #expect(router.searchRequest == SearchRequest(text: "vais", source: .lookup))
    #expect(router.pendingDeeplink == nil)
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
