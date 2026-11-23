//
//  CustomQuizTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct CustomQuizTests {
  private static var retainedSettings: [Settings] = []

  private func verb(_ infinitif: String) throws -> Verb {
    try #require(Verb.verbs.values.first { $0.infinitif == infinitif && $0.extraLetters == nil })
  }

  // The stored form is permanent: a learner's choice is kept between launches and can travel in
  // a link.
  @Test func theStoredFormIsPinned() {
    let custom = CustomQuiz(tenses: [.imparfait, .indicatifPrésent], verbSet: .collection(.être))
    #expect(custom.rawValue == "tenses=indicatif_present,imparfait&verbs=etre")
    #expect(CustomQuiz(rawValue: custom.rawValue) == custom)
    #expect(CustomQuiz(tenses: [.passéSimple]).rawValue == "tenses=passe_simple")
    #expect(CustomQuiz(verbSet: .model("1-3A")).rawValue == "verbs=model-1-3A")
    #expect(CustomQuiz().rawValue.isEmpty)
    #expect(CustomQuiz(rawValue: "") == CustomQuiz())
  }

  @Test func everyTenseKeyIsDistinctAndReadsBack() {
    let keys = QuizTenseSlot.allCases.map(\.key)
    #expect(Set(keys).count == QuizTenseSlot.allCases.count)
    #expect(!keys.contains(""))
    for slot in QuizTenseSlot.allCases {
      #expect(QuizTenseSlot(key: slot.key) == slot)
      #expect(CustomQuiz(rawValue: CustomQuiz(tenses: [slot]).rawValue)?.tenses == [slot])
    }
  }

  @Test func everyVerbSetKeyReadsBack() {
    let sets = QuizVerbSet.editorChoices(showsMyVerbs: true) + VerbModel.models.keys.map { QuizVerbSet.collection(.model($0)) }
    #expect(Set(sets.map(\.key)).count == sets.count)
    for verbSet in sets {
      #expect(QuizVerbSet(key: verbSet.key) == verbSet)
    }
  }

  @Test func theTop100CollectionReadsBackAsTheBand() {
    #expect(QuizVerbSet(key: QuizVerbSet.collection(.top100).key) == .band(.top100))
    #expect(!QuizVerbSet.editorChoices(showsMyVerbs: true).contains(.collection(.top100)))
  }

  @Test func myVerbsIsOfferedOnlyWhenAsked() {
    #expect(QuizVerbSet.editorChoices(showsMyVerbs: true).contains(.myVerbs))
    #expect(!QuizVerbSet.editorChoices(showsMyVerbs: false).contains(.myVerbs))
  }

  @Test func unknownKeysAreDroppedAndTheRestKept() {
    let custom = CustomQuiz(rawValue: "tenses=imparfait,aoriste&verbs=nonsense")
    #expect(custom?.tenses == [.imparfait])
    #expect(custom?.verbSet == nil)
    #expect(CustomQuiz(rawValue: "verbs=pronominal&level=advanced")?.verbSet == .collection(.pronominal))
    #expect(CustomQuiz(rawValue: "verbs=model-")?.verbSet == nil)
  }

  @Test func aModelThatNamesNothingCannotStart() throws {
    let custom = try #require(CustomQuiz(rawValue: "verbs=model-9-99"))
    #expect(custom.verbSet == .model("9-99"))
    #expect(!custom.canBeAsked(at: .advanced, myVerbs: []))
  }

  @Test(arguments: QuizLevel.allCases)
  func anUnchosenPartIsTheLevels(level: QuizLevel) {
    let verbsOnly = QuizScope.custom(CustomQuiz(verbSet: .band(.top300)), myVerbs: [])
    #expect(verbsOnly.slots(at: level) == level.slots)
    #expect(verbsOnly.band(at: level) == .top300)

    let tensesOnly = QuizScope.custom(CustomQuiz(tenses: [.passéSimple, .indicatifPrésent]), myVerbs: [])
    #expect(tensesOnly.slots(at: level) == [.indicatifPrésent, .passéSimple])
    #expect(tensesOnly.band(at: level) == level.band)
    #expect(tensesOnly.verbs == nil)
  }

  @Test func everyVerbIsTheWholeList() {
    let scope = QuizScope.custom(CustomQuiz(verbSet: .all), myVerbs: [])
    #expect(scope.verbs == nil)
    #expect(scope.band(at: .beginner) == nil)
  }

  @Test func aListIsAskedAsItIs() throws {
    let myVerbs = try [verb("parler"), verb("venir")]
    let scope = QuizScope.custom(CustomQuiz(verbSet: .myVerbs), myVerbs: myVerbs)
    #expect(scope.verbs?.map(\.id) == myVerbs.map(\.id))
    #expect(QuizScope.custom(CustomQuiz(verbSet: .collection(.être)), myVerbs: []).verbs?.count == VerbCollection.être.verbs.count)
  }

  @Test func aCustomQuizIsNeverRanked() {
    for custom in [
      CustomQuiz(tenses: [.imparfait]),
      CustomQuiz(verbSet: .band(.top100)),
      CustomQuiz(tenses: [.futurSimple], verbSet: .all)
    ] {
      let scope = QuizScope.custom(custom, myVerbs: [])
      #expect(!scope.isRanked)
      #expect(scope.continues)
      #expect(scope.startsLiveActivity)
      #expect(scope.source == .custom)
    }
  }

  @Test func theChoiceParameterSaysWhatKindButNotWhich() {
    #expect(CustomQuiz(tenses: [.imparfait]).choiceParameter == "tenses")
    #expect(CustomQuiz(verbSet: .collection(.pronominal)).choiceParameter == "verbs")
    #expect(CustomQuiz(tenses: [.imparfait], verbSet: .myVerbs).choiceParameter == "both")
  }

  @Test func aModelIsNamedOnlyAsAModel() {
    let scope = QuizScope.custom(CustomQuiz(verbSet: .model("1-9")), myVerbs: [])
    #expect(scope.namedCollection?.analyticsValue == "model")
    #expect(QuizScope.custom(CustomQuiz(verbSet: .band(.top100)), myVerbs: []).namedCollection == nil)
  }

  @Test func aChoiceWithNothingToAskCannotStart() throws {
    #expect(!CustomQuiz().canBeAsked(at: .advanced, myVerbs: []))
    #expect(!CustomQuiz(verbSet: .myVerbs).canBeAsked(at: .advanced, myVerbs: []))
    #expect(CustomQuiz(verbSet: .myVerbs).canBeAsked(at: .advanced, myVerbs: [try verb("parler")]))
    let falloirModel = try verb("falloir").model
    #expect(!CustomQuiz(tenses: [.impératif], verbSet: .model(falloirModel)).canBeAsked(at: .beginner, myVerbs: []))
    #expect(CustomQuiz(tenses: [.indicatifPrésent], verbSet: .model(falloirModel)).canBeAsked(at: .beginner, myVerbs: []))
    #expect(CustomQuiz(tenses: [.passéSimple]).canBeAsked(at: .beginner, myVerbs: []))
  }

  // Any tense may be chosen, above the learner's level or not.
  @Test func chosenTensesAreAskedAtAnyLevel() {
    let custom = CustomQuiz(tenses: [.passéSimple, .subjonctifImparfait])
    for seed in UInt64(1) ... 40 {
      var generator = SeededRandomNumberGenerator(seed: seed)
      let drawn = QuizDraw.questions(
        slots: custom.slots(at: .beginner),
        band: QuizLevel.beginner.band,
        count: Quiz.questionCount,
        asked: [],
        using: &generator
      )
      #expect(drawn.count == Quiz.questionCount)
      #expect(drawn.allSatisfy { custom.tenses.contains($0.slot) })
      #expect(drawn.allSatisfy { $0.verb.isIn(.top100) })
    }
  }

  @Test func theChoiceSurvivesARelaunch() {
    let store = GetterSetterFake()
    let settings = Settings(getterSetter: store)
    #expect(settings.customQuiz.isEmpty)
    let custom = CustomQuiz(tenses: [.subjonctifPrésent], verbSet: .model("3-1"))
    settings.customQuiz = custom
    let reloaded = Settings(getterSetter: store)
    Self.retainedSettings += [settings, reloaded]
    #expect(reloaded.customQuiz == custom)
  }
}

extension QuizVerbSet {
  static func model(_ id: String) -> QuizVerbSet {
    .collection(.model(id))
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Custom quiz sessions")
  struct CustomQuizSessionTests {
    private func correctAnswer(for question: QuizQuestion) -> String {
      let conjugated = Conjugator.conjugatedString(
        infinitif: question.verb.infinitif,
        tense: question.tense,
        extraLetters: question.verb.extraLetters
      ) ?? ""
      return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
    }

    private func finishRightly(_ quiz: Quiz) {
      while let question = quiz.currentQuestion, quiz.quizState == .inProgress {
        quiz.process(proposedAnswer: correctAnswer(for: question))
      }
    }

    private func withSpy(_ body: (AnalyticsSpy) throws -> Void) rethrows {
      let original = Current.analytics
      let spy = AnalyticsSpy()
      Current.analytics = spy
      defer {
        Current.analytics = original
      }
      try body(spy)
    }

    @Test func aQuizOverChosenTensesAsksOnlyThemAndPostsNothing() {
      withSpy { spy in
        Current.settings.quizLevel = .elementary
        let bestScores = Current.settings.bestScores
        let gameCenter = GameCenterSpy()
        let quiz = Quiz(gameCenter: gameCenter, seed: 11)
        quiz.start(scope: .custom(CustomQuiz(tenses: [.subjonctifPrésent, .passéSimple]), myVerbs: []))

        #expect(quiz.questions.count == Quiz.questionCount)
        #expect(quiz.questions.allSatisfy { [.subjonctifPrésent, .passéSimple].contains(QuizTenseSlot(tense: $0.tense)) })
        #expect(quiz.questions.allSatisfy { $0.verb.isIn(.top300) })
        let start = spy.signalParameters[spy.signalNames.firstIndex(of: .quizStart) ?? 0]
        #expect(start[ParameterKey.source.rawValue] == "custom")
        #expect(start[ParameterKey.customChoice.rawValue] == "tenses")
        #expect(start[ParameterKey.collection.rawValue] == nil)

        finishRightly(quiz)
        #expect(quiz.shouldShowResults)
        #expect(gameCenter.reports.isEmpty)
        #expect(Current.settings.bestScores == bestScores)
      }
    }

    @Test func aQuizOverAModelAsksOnlyItsVerbsAndContinues() throws {
      try withSpy { spy in
        Current.settings.quizLevel = .beginner
        let custom = CustomQuiz(tenses: [.futurSimple], verbSet: .model("1-3A"))
        let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 5)
        quiz.start(scope: .custom(custom, myVerbs: []))

        #expect(quiz.questions.count == Quiz.questionCount)
        #expect(quiz.questions.allSatisfy { $0.verb.model == "1-3A" })
        #expect(quiz.questions.allSatisfy { QuizTenseSlot(tense: $0.tense) == .futurSimple })
        let start = try #require(spy.signalParameters.first)
        #expect(start[ParameterKey.collection.rawValue] == "model")
        #expect(start[ParameterKey.customChoice.rawValue] == "both")

        finishRightly(quiz)
        #expect(quiz.canContinue)
        quiz.continueSession()
        #expect(quiz.questions.count == Quiz.questionCount * 2)
        #expect(quiz.questions.allSatisfy { $0.verb.model == "1-3A" })
        quiz.quit()
      }
    }
  }
}
