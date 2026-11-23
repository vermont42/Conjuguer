//
//  PracticeSetTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import CoreImage
import Foundation
import Testing
import UIKit

@MainActor
struct PracticeSetTests {
  private static var retainedSettings: [Settings] = []

  private func url(_ string: String) throws -> URL {
    try #require(URL(string: string))
  }

  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  private func roundTripped(_ practiceSet: PracticeSet, source: AnalyticsSource = .sharedLink) throws -> PracticeSet? {
    PracticeSet(url: try #require(practiceSet.deeplink(source: source)))
  }

  // The link is permanent: a teacher's printed or projected code must keep opening its set.
  @Test func theLinkIsPinned() throws {
    let practiceSet = PracticeSet(custom: CustomQuiz(tenses: [.futurSimple, .imparfait], verbSet: .collection(.être)), level: nil)
    #expect(practiceSet.deeplink(source: .sharedLink)?.absoluteString == "conjuguer://quiz/set?tenses=imparfait,futur_simple&verbs=etre&source=sharedLink")
    let leveled = PracticeSet(custom: CustomQuiz(verbSet: .model("1-3A")), level: .elementary)
    #expect(leveled.deeplink(source: .qrCode)?.absoluteString == "conjuguer://quiz/set?verbs=model-1-3A&level=elementary&source=qrCode")
    let list = PracticeSet(custom: CustomQuiz(verbSet: .list(["parler", "haïr France"])), level: .beginner)
    #expect(list.deeplink(source: .sharedLink)?.absoluteString == "conjuguer://quiz/set?infinitives=parler,ha%C3%AFr%20France&level=beginner&source=sharedLink")
  }

  @Test func everyTenseRoundTrips() throws {
    for slot in QuizTenseSlot.allCases {
      let practiceSet = PracticeSet(custom: CustomQuiz(tenses: [slot]), level: .advanced)
      #expect(try roundTripped(practiceSet) == practiceSet)
    }
    let all = PracticeSet(custom: CustomQuiz(tenses: Set(QuizTenseSlot.allCases)), level: .beginner)
    #expect(try roundTripped(all) == all)
  }

  @Test func everyVerbSetButMyVerbsRoundTrips() throws {
    let sets = QuizVerbSet.editorChoices(showsMyVerbs: false) + VerbModel.models.keys.map(QuizVerbSet.model)
    for verbSet in sets {
      let practiceSet = PracticeSet(custom: CustomQuiz(tenses: [.passéComposé], verbSet: verbSet), level: nil)
      #expect(try roundTripped(practiceSet) == practiceSet, "\(verbSet.key)")
    }
  }

  @Test(arguments: QuizLevel.allCases)
  func everyLevelRoundTrips(level: QuizLevel) throws {
    let practiceSet = PracticeSet(custom: CustomQuiz(tenses: [.subjonctifPrésent]), level: level)
    #expect(try roundTripped(practiceSet)?.level == level)
  }

  @Test func aListRoundTripsInItsOrder() throws {
    let keys = ["venir", "haïr Québec", "aller", "asseoir"]
    let practiceSet = PracticeSet(custom: CustomQuiz(verbSet: .list(keys)), level: .intermediate)
    let opened = try roundTripped(practiceSet)
    #expect(opened == practiceSet)
    #expect(opened?.custom.verbSet?.listedVerbs(myVerbs: [])?.map(\.dictionaryKey) == keys)
  }

  // Settings load before the verbs are parsed, so a kept list cannot check its keys; a link,
  // which the app reads only once the verbs are loaded, can.
  @Test func aStoredListKeepsUnknownKeysAndALinkDropsThem() throws {
    let stored = try #require(CustomQuiz(rawValue: "infinitives=parler,nonverbe,parler"))
    #expect(stored.verbSet == .list(["parler", "nonverbe"]))
    #expect(stored.verbSet?.listedVerbs(myVerbs: [])?.map(\.infinitif) == ["parler"])

    let opened = try #require(PracticeSet(url: try url("conjuguer://quiz/set?infinitives=parler,nonverbe,venir")))
    #expect(opened.custom.verbSet == .list(["parler", "venir"]))
  }

  @Test func aListTakesPrecedenceOnlyWithoutVerbs() {
    #expect(CustomQuiz(rawValue: "verbs=etre&infinitives=parler")?.verbSet == .collection(.être))
    #expect(QuizVerbSet(key: QuizVerbSet.listKey) == nil)
  }

  @Test(arguments: [
    "conjuguer://quiz/start",
    "conjuguer://quiz/set",
    "conjuguer://quiz/set?source=qrCode",
    "conjuguer://quiz/set?tenses=aoriste&verbs=nonsense",
    "conjuguer://quiz/set?verbs=myVerbs",
    "conjuguer://quiz/set?infinitives=nonverbe,autre",
    "conjuguer://quiz/set?verbs=model-9-99",
    "conjuguer://quiz/set/extra?tenses=imparfait",
    "conjuguer://verb/set?tenses=imparfait",
    "konjugieren://quiz/set?tenses=imparfait"
  ])
  func aLinkThatNamesNothingOpensNothing(link: String) throws {
    #expect(PracticeSet(url: try url(link)) == nil)
  }

  @Test func aLinkKeepsWhatItCanRead() throws {
    let opened = try #require(PracticeSet(url: try url("conjuguer://quiz/set?tenses=imparfait,aoriste&verbs=myVerbs&level=expert&extra=1")))
    #expect(opened.custom == CustomQuiz(tenses: [.imparfait]))
    #expect(opened.level == nil)
  }

  @Test func sharedMyVerbsTravelAsACappedList() throws {
    let myVerbs = try [verb("parler"), verb("finir"), verb("haïr France")]
    let shared = PracticeSet(sharing: CustomQuiz(tenses: [.imparfait], verbSet: .myVerbs), level: .beginner, myVerbs: myVerbs)
    #expect(shared.custom.verbSet == .list(["parler", "finir", "haïr France"]))
    #expect(shared.level == nil)

    let many = Array(Verb.verbs.values.prefix(PracticeSet.maximumListCount + 20))
    let capped = PracticeSet(sharing: CustomQuiz(verbSet: .myVerbs), level: .advanced, myVerbs: many)
    guard case .list(let keys) = capped.custom.verbSet else {
      Issue.record("My Verbs should travel as a list.")
      return
    }
    #expect(keys.count == PracticeSet.maximumListCount)
  }

  @Test func theLevelTravelsOnlyWhileAPartIsLeftToIt() {
    let tensesOnly = PracticeSet(sharing: CustomQuiz(tenses: [.imparfait]), level: .elementary, myVerbs: [])
    #expect(tensesOnly.level == .elementary)
    let verbsOnly = PracticeSet(sharing: CustomQuiz(verbSet: .band(.top300)), level: .intermediate, myVerbs: [])
    #expect(verbsOnly.level == .intermediate)
    let both = PracticeSet(sharing: CustomQuiz(tenses: [.imparfait], verbSet: .band(.top300)), level: .intermediate, myVerbs: [])
    #expect(both.level == nil)
  }

  @Test func theScopeAsksTheSetAtItsLevelUnranked() throws {
    let practiceSet = PracticeSet(custom: CustomQuiz(verbSet: .collection(.pronominal)), level: .beginner)
    let scope = practiceSet.scope(source: .qrCode)
    #expect(scope.level == .beginner)
    #expect(scope.slots(at: .advanced) == QuizLevel.beginner.slots)
    #expect(scope.source == .qrCode)
    #expect(scope.title == L.PracticeSet.title)
    #expect(scope.verbs?.count == VerbCollection.pronominal.verbs.count)
    #expect(scope.namedCollection == .pronominal)
    #expect(!scope.isRanked)
    #expect(scope.continues)
    #expect(!scope.startsLiveActivity)
  }

  @Test func aSetWithNothingToAskCannotStart() throws {
    let falloirModel = try verb("falloir").model
    #expect(!PracticeSet(custom: CustomQuiz(tenses: [.impératif], verbSet: .model(falloirModel)), level: nil).canBeAsked(levelFallback: .advanced))
    #expect(PracticeSet(custom: CustomQuiz(tenses: [.imparfait]), level: .beginner).canBeAsked(levelFallback: .advanced))
  }

  @Test func theShareTextCarriesTheSummaryTheLinkAndTheAppStore() throws {
    let practiceSet = PracticeSet(custom: CustomQuiz(tenses: [.imparfait, .futurSimple]), level: .elementary)
    let text = practiceSet.shareText(levelFallback: .advanced)
    #expect(text.contains("Imparfait, Futur Simple"))
    #expect(text.contains(QuizLevel.elementary.localizedName))
    #expect(text.contains(try #require(practiceSet.deeplink(source: .sharedLink)).absoluteString))
    #expect(text.contains(URL.appStore.absoluteString))
    #expect(practiceSet.summary(levelFallback: .advanced).components(separatedBy: "\n").count == 2)
  }

  private func decodedQRCode(_ text: String) throws -> String? {
    let image = try #require(QRCode.image(for: text))
    let cgImage = try #require(image.cgImage)
    let detector = try #require(CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]))
    return detector.features(in: CIImage(cgImage: cgImage)).compactMap { ($0 as? CIQRCodeFeature)?.messageString }.first
  }

  @Test func theQRCodeReadsBackAsTheLink() throws {
    let practiceSet = PracticeSet(custom: CustomQuiz(tenses: [.passéComposé], verbSet: .collection(.irregularFutur)), level: nil)
    let link = try #require(practiceSet.deeplink(source: .qrCode)).absoluteString
    #expect(try decodedQRCode(link) == link)
  }

  @Test func theLongestVerbsAListCanHoldStillFitACode() throws {
    let longest = Verb.verbs.values
      .sorted { $0.dictionaryKey.utf8.count > $1.dictionaryKey.utf8.count }
      .prefix(PracticeSet.maximumListCount)
    let practiceSet = PracticeSet(sharing: CustomQuiz(tenses: Set(QuizTenseSlot.allCases), verbSet: .myVerbs), level: .advanced, myVerbs: Array(longest))
    let link = try #require(practiceSet.deeplink(source: .qrCode)).absoluteString
    #expect(try decodedQRCode(link) == link)
    #expect(PracticeSet(url: try url(link)) == practiceSet)
  }

  @Test func aKeptListSurvivesARelaunch() {
    let store = GetterSetterFake()
    let settings = Settings(getterSetter: store)
    let custom = CustomQuiz(tenses: [.imparfait], verbSet: .list(["parler", "haïr France"]))
    settings.customQuiz = custom
    let reloaded = Settings(getterSetter: store)
    Self.retainedSettings += [settings, reloaded]
    #expect(reloaded.customQuiz == custom)
  }

  @Test func theEditorOffersAKeptListOnlyWhileItIsTheChoice() {
    let list = QuizVerbSet.list(["parler"])
    #expect(QuizVerbSet.editorChoices(showsMyVerbs: false, current: list).contains(list))
    #expect(!QuizVerbSet.editorChoices(showsMyVerbs: false, current: .all).contains { $0.key == QuizVerbSet.listKey })
  }
}

extension DeeplinkTests {
  @MainActor
  @Suite("Practice-set links")
  struct PracticeSetDeeplinkTests {
    private func url(_ string: String) throws -> URL {
      try #require(URL(string: string))
    }

    @Test func aSetLinkShowsTheSetWithoutStartingAQuizOrSwitchingTabs() throws {
      Current.practiceSet = nil
      Current.selectedTab = .info
      let quizState = Current.quiz.quizState

      Current.handleURL(try url("conjuguer://quiz/set?tenses=imparfait&level=beginner&source=qrCode"))

      let request = try #require(Current.practiceSet)
      #expect(request.practiceSet == PracticeSet(custom: CustomQuiz(tenses: [.imparfait]), level: .beginner))
      #expect(request.source == .qrCode)
      #expect(Current.selectedTab == .info)
      #expect(Current.quiz.quizState == quizState)
      Current.practiceSet = nil
    }

    @Test func aLinkThatNamesNothingShowsWhy() throws {
      Current.practiceSet = nil
      Current.handleURL(try url("conjuguer://quiz/set?tenses=aoriste"))
      let request = try #require(Current.practiceSet)
      #expect(request.practiceSet == nil)
      #expect(request.source == .deeplink)
      Current.practiceSet = nil
    }

    @Test func aLaterLinkReplacesTheSet() throws {
      Current.handleURL(try url("conjuguer://quiz/set?tenses=imparfait"))
      let first = try #require(Current.practiceSet)
      Current.handleURL(try url("conjuguer://quiz/set?verbs=etre"))
      let second = try #require(Current.practiceSet)
      #expect(first.id != second.id)
      #expect(second.practiceSet?.custom.verbSet == .collection(.être))

      Current.handleURL(try url("conjuguer://verb/parler"))
      #expect(Current.practiceSet == nil)
      Current.verb = nil
    }
  }
}

extension QuizTests {
  @MainActor
  @Suite("Practice-set sessions")
  struct PracticeSetSessionTests {
    @Test func aSetIsAskedAtItsLevelAndPostsNothing() throws {
      let original = Current.analytics
      let spy = AnalyticsSpy()
      Current.analytics = spy
      defer {
        Current.analytics = original
      }
      Current.settings.quizLevel = .advanced
      let bestScores = Current.settings.bestScores
      let gameCenter = GameCenterSpy()
      let quiz = Quiz(gameCenter: gameCenter, seed: 3)
      let practiceSet = PracticeSet(custom: CustomQuiz(verbSet: .band(.top300)), level: .beginner)

      quiz.start(scope: practiceSet.scope(source: .qrCode))

      #expect(quiz.level == .beginner)
      #expect(quiz.questions.count == Quiz.questionCount)
      #expect(quiz.questions.allSatisfy { QuizTenseSlot(tense: $0.tense).map(QuizLevel.beginner.slots.contains) == true })
      #expect(quiz.questions.allSatisfy { $0.verb.isIn(.top300) })
      let start = try #require(spy.signalParameters.first)
      #expect(start[ParameterKey.level.rawValue] == "beginner")
      #expect(start[ParameterKey.source.rawValue] == "qrCode")
      #expect(start[ParameterKey.customChoice.rawValue] == "verbs")
      #expect(Current.settings.quizLevel == .advanced)

      quiz.quit()
      #expect(gameCenter.reports.isEmpty)
      #expect(Current.settings.bestScores == bestScores)
    }

    @Test func sharingAndKeepingSayHowButNotWhat() throws {
      let original = Current.analytics
      let spy = AnalyticsSpy()
      Current.analytics = spy
      defer {
        Current.analytics = original
      }
      PracticeSet(custom: CustomQuiz(tenses: [.imparfait], verbSet: .model("1-9")), level: nil).signalShare(method: PracticeSet.qrCodeMethod)
      #expect(spy.signalNames == [.tapSharePracticeSet])
      #expect(spy.signalParameters.first == [
        ParameterKey.customChoice.rawValue: "both",
        ParameterKey.method.rawValue: "qrCode"
      ])
    }
  }
}
