//
//  VerbEssentialsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite("Verb Essentials")
struct VerbEssentialsTests {
  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  private func answer(_ question: QuizQuestion, gender: PronounGender) -> String? {
    Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: question.verb.extraLetters, pronounGender: gender)?.lowercased()
  }

  @Test func aStepAsksTheThreeKeyConjugationsTogether() throws {
    let step = QuizDraw.verbEssentialsStep(verb: try verb("venir"))

    #expect(step.map(\.tense) == [.indicatifPrésent(.thirdSingular), .passéComposé(.thirdSingular), .futurSimple(.thirdSingular)])
    #expect(step.map(\.tense) == Verb.keyTenses)
    let stepID = try #require(step.first?.stepID)
    #expect(step.allSatisfy { $0.stepID == stepID && !$0.isReask })
    #expect(QuizDraw.verbEssentialsStep(verb: try verb("venir")).first?.stepID != stepID)
  }

  @Test(arguments: [
    (key: "venir", masculine: ["vient", "est venu", "viendra"], feminine: ["vient", "est venue", "viendra"]),
    (key: "aller", masculine: ["va", "est allé", "ira"], feminine: ["va", "est allée", "ira"]),
    (key: "souvenir", masculine: ["souvient", "est souvenu", "souviendra"], feminine: ["souvient", "est souvenue", "souviendra"]),
    (key: "faire", masculine: ["fait", "a fait", "fera"], feminine: ["fait", "a fait", "fera"]),
    (key: "envoyer", masculine: ["envoie", "a envoyé", "enverra"], feminine: ["envoie", "a envoyé", "enverra"]),
    (key: "voir", masculine: ["voit", "a vu", "verra"], feminine: ["voit", "a vu", "verra"])
  ])
  func eachBlanksAnswerFollowsThePronounGender(key: String, masculine: [String], feminine: [String]) throws {
    let step = QuizDraw.verbEssentialsStep(verb: try verb(key))

    #expect(step.map { answer($0, gender: .masculine) } == masculine)
    #expect(step.map { answer($0, gender: .feminine) } == feminine)
  }

  @Test func aPronominalVerbsFrameCarriesItsPronoun() throws {
    let step = QuizDraw.verbEssentialsStep(verb: try verb("souvenir"))

    let frames = step.map {
      AnswerFrame.quizFrame(for: $0.tense, answer: answer($0, gender: .masculine) ?? "", isReflexive: true, hasAspiratedH: false, pronounGender: .masculine)
    }

    #expect(frames.map(\.leadingSegments) == [[.pronoun("il se")], [.pronoun("il s'")], [.pronoun("il se")]])
  }

  @Test(arguments: [
    (key: "venir", tense: Tense.passéComposé(.thirdSingular), answer: "a venu"),
    (key: "souvenir", tense: Tense.passéComposé(.thirdSingular), answer: "est souvenu"),
    (key: "faire", tense: Tense.futurSimple(.thirdSingular), answer: "faira"),
    (key: "prendre", tense: Tense.passéComposé(.thirdSingular), answer: "a prendu"),
    (key: "aller", tense: Tense.passéComposé(.thirdSingular), answer: "est allé")
  ])
  func theFixturesWrongAnswersAreDiagnosedWithTheFeminineDefault(key: String, tense: Tense, answer: String) throws {
    let verb = try verb(key)
    let correct = try #require(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: .feminine))

    #expect(AnswerDiagnosis.diagnose(proposedAnswer: answer, correctAnswers: correct, verb: verb, tense: tense, pronounGender: .feminine) != nil)
  }

  @Test(arguments: [
    (key: "venir", isAsked: true),
    (key: "aller", isAsked: true),
    (key: "être", isAsked: true),
    (key: "avoir", isAsked: true),
    (key: "souvenir", isAsked: true),
    (key: "parler", isAsked: false),
    (key: "manger", isAsked: false),
    (key: "finir", isAsked: false),
    (key: "rendre", isAsked: false),
    (key: "attendre", isAsked: false),
    (key: "gésir", isAsked: false),
    (key: "sortir obtain", isAsked: false),
    (key: "sortir exit", isAsked: true)
  ])
  func onlyVerbsLearnedVerbByVerbWithAllThreeAreAsked(key: String, isAsked: Bool) throws {
    #expect(try verb(key).isAskedByVerbEssentials == isAsked)
  }

  @Test func aRoundDrawsDistinctAskableVerbsOfTheBand() {
    let band = Verb.verbs(in: .top100)
    for seed in UInt64(1) ... 20 {
      var generator = SeededRandomNumberGenerator(seed: seed)
      let steps = QuizDraw.verbEssentialsSteps(verbs: band, count: QuizScope.verbEssentialsVerbCount, asked: [], using: &generator)
      let verbs = steps.compactMap(\.first?.verb)

      #expect(steps.count == QuizScope.verbEssentialsVerbCount)
      #expect(steps.allSatisfy { $0.count == Verb.keyTenses.count })
      #expect(Set(verbs.map(\.id)).count == verbs.count)
      #expect(verbs.allSatisfy { $0.isAskedByVerbEssentials && $0.isIn(.top100) })
      #expect(verbs.allSatisfy(VerbDraw.isIrregular))
    }
  }

  @Test func askedVerbsAreDrawnOnlyOnceTheOthersRunOut() throws {
    let verbs = try ["venir", "faire", "voir", "aller", "parler", "prendre"].map(verb)
    let asked: Set<String> = ["venir", "faire"]
    var generator = SeededRandomNumberGenerator(seed: 5)

    let steps = QuizDraw.verbEssentialsSteps(verbs: verbs, count: 4, asked: asked, using: &generator)
    let drawn = steps.compactMap(\.first?.verb.id)

    #expect(drawn.count == 4)
    #expect(Set(drawn.prefix(3)) == ["voir", "aller", "prendre"])
    #expect(asked.contains(drawn[3]))
    #expect(!drawn.contains("parler"))
  }

  @Test func theScopeIsAnUnrankedRoundOfFifteen() {
    let scope = QuizScope.verbEssentials()

    #expect(scope.questionCount == 15)
    #expect(scope.isVerbEssentials)
    #expect(scope.source == .verbEssentials)
    #expect(!scope.isRanked)
    #expect(!scope.mixesDueItems)
    #expect(scope.continues)
    #expect(scope.asksByLevel)
    #expect(scope.sessionTitle == L.VerbEssentials.title)
    #expect(QuizScope.allVerbs.sessionTitle == nil)
    #expect(LastQuizResult.Kind(scope: scope) == .verbEssentials)
  }

  @Test func aMissedBlankReturnsAfterTheNextVerbAndASecondMissJoinsIt() throws {
    var questions = try ["venir", "faire", "voir"].flatMap { QuizDraw.verbEssentialsStep(verb: try verb($0)) }

    let first = Quiz.reaskPlacement(of: 0, in: questions)
    #expect(first.position == 6)
    let firstStep = try #require(first.stepID)
    #expect(![questions[0].stepID, questions[3].stepID].contains(firstStep))
    questions.insert(questions[0].reasked(stepID: first.stepID), at: first.position)

    let second = Quiz.reaskPlacement(of: 2, in: questions)
    #expect(second.position == 7)
    #expect(second.stepID == firstStep)
    questions.insert(questions[2].reasked(stepID: second.stepID), at: second.position)

    #expect(questions[6 ... 7].map(\.tense) == [.indicatifPrésent(.thirdSingular), .futurSimple(.thirdSingular)])
    #expect(questions[8].verb.id == "voir")
  }

  @Test func aMissInTheLastVerbReturnsAtTheEnd() throws {
    let questions = try ["venir", "faire"].flatMap { QuizDraw.verbEssentialsStep(verb: try verb($0)) }

    let placement = Quiz.reaskPlacement(of: 4, in: questions)

    #expect(placement.position == questions.count)
    #expect(placement.stepID != nil)
    #expect(placement.stepID != questions[4].stepID)
  }

  @Test func aQuestionShownAloneKeepsItsGap() throws {
    let questions = try (0 ..< 10).map { _ in QuizQuestion(verb: try verb("parler"), tense: .indicatifPrésent(.firstSingular)) }

    let placement = Quiz.reaskPlacement(of: 2, in: questions)

    #expect(placement.position == Quiz.reaskPosition(after: 2, in: questions.count))
    #expect(placement.stepID == nil)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Verb Essentials sessions")
  struct VerbEssentialsSessionTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func restorePractice() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    private func correctAnswer(for question: QuizQuestion) -> String {
      let conjugated = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: question.verb.extraLetters) ?? ""
      return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
    }

    private func answerRightly(_ quiz: Quiz) {
      if let question = quiz.currentQuestion {
        quiz.process(proposedAnswer: correctAnswer(for: question))
      }
    }

    private func makeQuiz(seed: UInt64 = 3) -> Quiz {
      Current.settings.quizLevel = .beginner
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: seed)
      quiz.start(scope: .verbEssentials())
      return quiz
    }

    @Test func aRoundIsFiveStepsOfThreeKeyConjugations() {
      let quiz = makeQuiz()
      defer {
        quiz.quit()
      }

      #expect(quiz.questions.count == 15)
      for start in stride(from: 0, to: 15, by: 3) {
        let step = quiz.questions[start ..< start + 3]
        #expect(step.map(\.tense) == Verb.keyTenses)
        #expect(Set(step.compactMap(\.stepID)).count == 1)
        #expect(Set(step.map(\.verb.id)).count == 1)
      }
      #expect(Set(quiz.questions.map(\.verb.id)).count == 5)
      #expect(quiz.isFirstQuestionOfStep)
    }

    @Test func eachBlankIsGradedAndRecordedAlone() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let quiz = makeQuiz()
      let verb = try #require(quiz.currentQuestion?.verb)

      answerRightly(quiz)
      #expect(!quiz.isFirstQuestionOfStep)
      quiz.process(proposedAnswer: "x")
      quiz.continueAfterCorrection()
      answerRightly(quiz)
      quiz.quit()

      let entries = PracticeItem.Stem.shown.map { practice.record.entry(for: .keyConjugation(verb: verb.dictionaryKey, stem: $0))?.lastAnswerWasRight }
      #expect(entries == [true, false, true])
      #expect(practice.record.entries.count == 3)
      #expect(quiz.score == 20)
    }

    @Test func theRowsShowWhatWasAnsweredAndWhatIsToCome() throws {
      let quiz = makeQuiz()
      defer {
        quiz.quit()
      }
      answerRightly(quiz)

      let rows = try #require(quiz.essentialsRows)
      #expect(rows.map(\.question.tense) == Verb.keyTenses)
      guard case .answered(let result) = rows[0].content else {
        Issue.record("The présent row was not answered.")
        return
      }
      #expect(result.conjugationResult == .totalMatch)
      guard case .current = rows[1].content, case .pending = rows[2].content else {
        Issue.record("The passé composé row is not current, or the futur row not pending.")
        return
      }
    }

    @Test func aReaskStepGivesTheOtherRows() throws {
      let quiz = makeQuiz()
      defer {
        quiz.quit()
      }
      let missedVerb = try #require(quiz.currentQuestion?.verb)
      quiz.process(proposedAnswer: "x")
      #expect(quiz.correction?.willBeReasked == true)
      quiz.continueAfterCorrection()
      for _ in 0 ..< 5 {
        answerRightly(quiz)
      }

      let question = try #require(quiz.currentQuestion)
      #expect(question.isReask)
      #expect(question.verb.id == missedVerb.id)
      #expect(quiz.isFirstQuestionOfStep)
      let rows = try #require(quiz.essentialsRows)
      guard case .current = rows[0].content, case .given(let passéComposé) = rows[1].content, case .given = rows[2].content else {
        Issue.record("A re-ask's other rows are not given.")
        return
      }
      #expect(passéComposé == Conjugator.conjugatedString(infinitif: missedVerb.infinitif, tense: .passéComposé(.thirdSingular), extraLetters: missedVerb.extraLetters))
    }

    @Test func aDiagnosedBlankEarnsOneMoreTryAtHalfPoints() throws {
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 1)
      quiz.start(scope: .verbEssentials([try #require(Verb.verbs["faire"])]))
      defer {
        quiz.quit()
      }
      answerRightly(quiz)
      answerRightly(quiz)

      quiz.process(proposedAnswer: "faira")
      #expect(quiz.isAwaitingSecondAttempt)
      #expect(quiz.firstAttemptDiagnosis != nil)
      answerRightly(quiz)

      #expect(quiz.score == 25)
      #expect(quiz.quizResults.last?.conjugationResult == .secondAttemptMatch)
    }

    @Test func fiveMoreAsksNewVerbsAndNothingRanksOrIsSent() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let original = Current.analytics
      let spy = AnalyticsSpy()
      Current.analytics = spy
      defer {
        Current.analytics = original
      }
      let gameCenter = GameCenterSpy()
      Current.settings.quizLevel = .beginner
      let bestScore = Current.settings.bestScore(at: .beginner)
      let quiz = Quiz(gameCenter: gameCenter, seed: 8)
      quiz.start(scope: .verbEssentials())
      let firstVerbs = Set(quiz.questions.map(\.verb.id))

      while quiz.quizState == .inProgress {
        answerRightly(quiz)
      }

      #expect(quiz.score == 150)
      #expect(quiz.canContinue)
      #expect(Current.settings.bestScore(at: .beginner) == bestScore)
      #expect(practice.lastResult?.kind == .verbEssentials)
      #expect(practice.lastResult?.title == L.VerbEssentials.title)
      #expect(practice.lastResult?.level == .beginner)
      let start = try #require(spy.signalParameters.first)
      #expect(spy.signalNames.first == .quizStart)
      #expect(start[ParameterKey.source.rawValue] == AnalyticsSource.verbEssentials.rawValue)
      #expect(spy.signalParameters.last?[ParameterKey.questionCount.rawValue] == "15")
      #expect(gameCenter.reports.isEmpty)

      quiz.continueSession()
      #expect(quiz.questions.count == 30)
      #expect(firstVerbs.isDisjoint(with: Set(quiz.questions[15...].map(\.verb.id))))
      quiz.quit()
    }
  }
}
