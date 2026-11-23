//
//  VerbCollectionTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct VerbCollectionTests {
  private func infinitives(_ collection: VerbCollection) -> Set<String> {
    Set(collection.verbs.map(\.infinitif))
  }

  private func resetCurrent() {
    Current.verb = nil
    Current.verbModel = nil
    Current.collection = nil
    Current.info = nil
    Current.pendingDeeplink = nil
    Current.searchRequest = nil
  }

  @Test func featuredKeysRoundTrip() {
    for collection in VerbCollection.featured {
      #expect(VerbCollection(featuredKey: collection.key) == collection)
    }
    #expect(VerbCollection(featuredKey: "model-1-1") == nil)
    #expect(VerbCollection(featuredKey: "modals") == nil)
    #expect(VerbCollection.model("6-7").key == "model-6-7")
  }

  // A shared key must keep opening the same list, so the keys are pinned.
  @Test func featuredKeysAreStable() {
    #expect(VerbCollection.featured.map(\.key) == ["top100", "etre", "irregularFutur", "pronominal"])
  }

  @Test func theTop100HoldsAHundredInfinitives() {
    let verbs = VerbCollection.top100.verbs
    #expect(verbs.count == FrequencyBand.top100.rankLimit)
    #expect(Set(verbs.map(\.infinitif)).count == FrequencyBand.top100.rankLimit)
    #expect(verbs.allSatisfy { $0.frequency <= FrequencyBand.top100.rankLimit })
    #expect(verbs.first?.frequency == 1)
  }

  @Test func êtreHoldsTheVerbsOfMotionAndNoPronominals() {
    let être = infinitives(.être)
    for infinitif in ["aller", "venir", "naître", "mourir", "tomber", "rester", "arriver", "partir", "devenir", "entrer"] {
      #expect(être.contains(infinitif), "\(infinitif)")
    }
    for infinitif in ["avoir", "parler", "souvenir", "être"] {
      #expect(!être.contains(infinitif), "\(infinitif)")
    }
    #expect(VerbCollection.être.verbs.allSatisfy { $0.auxiliary == .être && !$0.isReflexive })
  }

  @Test func irregularFuturHoldsChangedStemsOnly() {
    let futur = infinitives(.irregularFutur)
    for infinitif in ["être", "avoir", "faire", "aller", "venir", "voir", "devoir", "pouvoir", "savoir", "vouloir", "recevoir", "envoyer", "renvoyer", "courir", "mourir", "cueillir", "falloir", "asseoir"] {
      #expect(futur.contains(infinitif), "\(infinitif)")
    }
    // Spelling changes of the first group, regular futurs, and third-group verbs whose futur
    // keeps the infinitive.
    for infinitif in ["parler", "appeler", "jeter", "acheter", "employer", "payer", "finir", "prévoir", "pourvoir", "prendre", "mettre", "dire"] {
      #expect(!futur.contains(infinitif), "\(infinitif)")
    }
  }

  @Test func pronominalHoldsEveryReflexiveVerb() {
    let verbs = VerbCollection.pronominal.verbs
    #expect(verbs.count == Verb.verbs.values.count(where: \.isReflexive))
    #expect(infinitives(.pronominal).contains("souvenir"))
    #expect(!infinitives(.pronominal).contains("aller"))
  }

  @Test func aModelsCollectionIsItsVerbs() throws {
    let model = try #require(VerbModel.models["6-7"])
    let collection = VerbCollection.model(model.id)
    #expect(Set(collection.verbs.map(\.dictionaryKey)) == Set(model.verbs))
    #expect(collection.title == "venir (6-7)")
  }

  @Test func theVerbsComeMostFrequentFirst() {
    for collection in VerbCollection.featured + [.model("1-1")] {
      let ranks = collection.verbs.map(\.frequency)
      #expect(ranks == ranks.sorted(), "\(collection.key)")
    }
  }

  @Test func modelsShareOneAnalyticsValue() {
    #expect(VerbCollection.model("1-9").analyticsValue == "model")
    #expect(VerbCollection.être.analyticsValue == "etre")
  }

  @Test func aListLinkOpensItsCollection() throws {
    for collection in VerbCollection.featured {
      resetCurrent()
      Current.selectedTab = .settings
      Current.handleURL(try #require(collection.deeplink))
      #expect(Current.collection == VerbCollectionDestination(collection: collection, source: .sharedLink))
      #expect(Current.selectedTab == .models)
    }

    resetCurrent()
    Current.handleURL(try #require(URL(string: "conjuguer://list/top100")))
    #expect(Current.collection?.source == .deeplink)
  }

  @Test func anUnknownListLinkDoesNothing() throws {
    resetCurrent()
    Current.selectedTab = .settings
    Current.handleURL(try #require(URL(string: "conjuguer://list/nonsense")))
    #expect(Current.collection == nil)
    #expect(Current.selectedTab == .settings)
  }

  @Test func aModelsSharedLinkOpensTheModel() throws {
    resetCurrent()
    let link = try #require(VerbCollection.model("4-2B").deeplink)
    #expect(link.absoluteString == "conjuguer://model/4-2B?source=sharedLink")
    Current.handleURL(link)
    #expect(Current.verbModel?.id == "4-2B")
    #expect(Current.selectedTab == .models)
  }

  @Test func theShareTextCarriesBothLinksAndCitesPronominals() throws {
    let text = VerbCollection.pronominal.shareText()
    #expect(text.contains(try #require(VerbCollection.pronominal.deeplink).absoluteString))
    #expect(text.contains(URL.appStore.absoluteString))
    #expect(text.contains("se "))

    let single = VerbCollection.model("1-9").shareText()
    #expect(single.contains("aller"))
    #expect(!single.contains("…"))
  }

  @Test func progressCountsOpensNotStars() throws {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    let verbs = VerbCollection.être.verbs
    let aller = try #require(Verb.verbs["aller"])
    let venir = try #require(Verb.verbs["venir"])
    #expect(store.openedCount(of: verbs) == 0)
    store.recordOpen(aller, source: .list)
    store.toggleStar(venir)
    #expect(store.openedCount(of: verbs) == 1)
  }

  @Test func aCollectionsQuizIsUnrankedAndAsksOnlyItsVerbs() {
    let scope = QuizScope.collection(.être)
    #expect(!scope.isRanked)
    #expect(!scope.startsLiveActivity)
    #expect(scope.source == .list)
    #expect(scope.title == VerbCollection.être.title)

    let keys = Set(VerbCollection.être.verbs.map(\.dictionaryKey))
    var generator = SeededRandomNumberGenerator(seed: 14)
    let questions = scope.questions(using: &generator)
    #expect(questions.count == Quiz.questionCount)
    #expect(questions.allSatisfy { keys.contains($0.verb.dictionaryKey) })
  }

  @Test func aCollectionsQuizStartNamesTheCollection() {
    let original = Current.analytics
    let spy = AnalyticsSpy()
    Current.analytics = spy
    defer {
      Current.analytics = original
    }

    let quiz = Quiz(gameCenter: GameCenterStub())
    quiz.start(scope: .collection(.model("6-7")))
    quiz.quit()

    #expect(spy.signalNames == [.quizStart, .quizQuit])
    #expect(spy.signalParameters.first?[ParameterKey.collection.rawValue] == "model")
    #expect(spy.signalParameters.first?[ParameterKey.source.rawValue] == AnalyticsSource.list.rawValue)
  }

  @Test func aCollectionWithNothingToAskHidesItsQuiz() {
    let ester = VerbCollection.model("1-10").verbs.contains { $0.canBeQuizzed }
    let parler = VerbCollection.model("1-1").verbs.contains { $0.canBeQuizzed }
    #expect(!ester)
    #expect(parler)
  }
}
