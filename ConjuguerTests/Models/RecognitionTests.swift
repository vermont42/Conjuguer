//
//  RecognitionTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite("Name the Conjugation")
struct RecognitionTests {
  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  private func question(_ key: String, _ tense: Tense, level: QuizLevel = .advanced) throws -> RecognitionQuestion {
    RecognitionQuestion(verb: try verb(key), tense: tense, slots: level.slots)
  }

  private func answer(_ infinitif: String, _ slot: QuizTenseSlot, _ personNumber: PersonNumber? = nil) -> RecognitionAnswer {
    RecognitionAnswer(infinitif: infinitif, slot: slot, personNumber: personNumber)
  }

  @Test(arguments: [
    (key: "être", tense: Tense.passéSimple(.firstPlural), prompt: "fûmes", cells: [
      RecognitionCell(verbKey: "être", tense: .passéSimple(.firstPlural))
    ]),
    (key: "suivre", tense: Tense.indicatifPrésent(.firstSingular), prompt: "suis", cells: [
      RecognitionCell(verbKey: "suivre", tense: .indicatifPrésent(.firstSingular)),
      RecognitionCell(verbKey: "suivre", tense: .indicatifPrésent(.secondSingular)),
      RecognitionCell(verbKey: "suivre", tense: .impératif(.secondSingular)),
      RecognitionCell(verbKey: "être", tense: .indicatifPrésent(.firstSingular))
    ]),
    (key: "vivre", tense: Tense.indicatifPrésent(.firstSingular), prompt: "vis", cells: [
      RecognitionCell(verbKey: "vivre", tense: .indicatifPrésent(.firstSingular)),
      RecognitionCell(verbKey: "vivre", tense: .indicatifPrésent(.secondSingular)),
      RecognitionCell(verbKey: "vivre", tense: .impératif(.secondSingular)),
      RecognitionCell(verbKey: "voir", tense: .passéSimple(.firstSingular)),
      RecognitionCell(verbKey: "voir", tense: .passéSimple(.secondSingular))
    ]),
    (key: "parler", tense: Tense.subjonctifPrésent(.thirdSingular), prompt: "parle", cells: [
      RecognitionCell(verbKey: "parler", tense: .indicatifPrésent(.firstSingular)),
      RecognitionCell(verbKey: "parler", tense: .indicatifPrésent(.thirdSingular)),
      RecognitionCell(verbKey: "parler", tense: .subjonctifPrésent(.firstSingular)),
      RecognitionCell(verbKey: "parler", tense: .subjonctifPrésent(.thirdSingular)),
      RecognitionCell(verbKey: "parler", tense: .impératif(.secondSingular))
    ]),
    (key: "faire", tense: Tense.participePassé, prompt: "fait", cells: [
      RecognitionCell(verbKey: "faire", tense: .indicatifPrésent(.thirdSingular)),
      RecognitionCell(verbKey: "faire", tense: .participePassé)
    ]),
    (key: "souvenir", tense: Tense.indicatifPrésent(.firstSingular), prompt: "me souviens", cells: [
      RecognitionCell(verbKey: "souvenir", tense: .indicatifPrésent(.firstSingular))
    ]),
    (key: "souvenir", tense: Tense.impératif(.secondSingular), prompt: "souviens-toi", cells: [
      RecognitionCell(verbKey: "souvenir", tense: .impératif(.secondSingular))
    ]),
    (key: "finir", tense: Tense.indicatifPrésent(.firstPlural), prompt: "finissons", cells: [
      RecognitionCell(verbKey: "finir", tense: .indicatifPrésent(.firstPlural)),
      RecognitionCell(verbKey: "finir", tense: .impératif(.firstPlural))
    ]),
    (key: "prendre", tense: Tense.plusQueParfait(.firstPlural), prompt: "avions pris", cells: [
      RecognitionCell(verbKey: "prendre", tense: .plusQueParfait(.firstPlural))
    ])
  ])
  func everyCellThatWritesThePromptIsARightAnswer(key: String, tense: Tense, prompt: String, cells: [RecognitionCell]) throws {
    let recognition = try question(key, tense)

    #expect(recognition.prompt.lowercased() == prompt)
    #expect(Set(recognition.cells) == Set(cells))
    #expect(recognition.cells.count == cells.count)
  }

  @Test func eachCellWritesThePrompt() throws {
    let prompts: [(String, Tense)] = [
      ("suivre", .indicatifPrésent(.firstSingular)),
      ("vivre", .indicatifPrésent(.firstSingular)),
      ("parler", .subjonctifPrésent(.thirdSingular)),
      ("aller", .passéComposé(.thirdSingular)),
      ("asseoir", .indicatifPrésent(.thirdPlural))
    ]
    for (key, tense) in prompts {
      let recognition = try question(key, tense)
      for cell in recognition.cells {
        let verb = try #require(cell.verb)
        let written = [PronounGender.masculine, .feminine].flatMap { RecognitionQuestion.prompts(of: verb, tense: cell.tense, pronounGender: $0) }
        #expect(written.map { $0.lowercased() }.contains(recognition.prompt.lowercased()), "\(cell) does not write \(recognition.prompt)")
      }
    }
  }

  @Test func onlyTheLevelsTensesCount() throws {
    let recognition = try question("parler", .indicatifPrésent(.firstSingular), level: .beginner)

    #expect(recognition.slots == [.indicatifPrésent, .impératif])
    #expect(Set(recognition.cells.map(\.tense)) == [.indicatifPrésent(.firstSingular), .indicatifPrésent(.thirdSingular), .impératif(.secondSingular)])
  }

  @Test func theTensesAreOfferedInTheVerbPagesOrder() {
    let slots = RecognitionQuestion.inPageOrder(QuizLevel.intermediate.slots)

    #expect(slots == [
      .indicatifPrésent, .imparfait, .futurSimple, .conditionnelPrésent, .subjonctifPrésent, .impératif,
      .participePassé, .participePrésent, .passéComposé, .plusQueParfait, .conditionnelPassé
    ])
  }

  @Test func aCompoundPromptAcceptsEitherGenderAndFollowsTheSetting() throws {
    let aller = try verb("aller")
    let feminine = RecognitionQuestion.prompts(of: aller, tense: .passéComposé(.thirdSingular), pronounGender: .feminine)
    let masculine = RecognitionQuestion.prompts(of: aller, tense: .passéComposé(.thirdSingular), pronounGender: .masculine)

    #expect(feminine.map { $0.lowercased() } == ["est allée"])
    #expect(masculine.map { $0.lowercased() } == ["est allé"])
    let asked = RecognitionCell(verbKey: "aller", tense: .passéComposé(.thirdSingular))
    for prompt in feminine + masculine {
      let cells = RecognitionQuestion.cells(writing: prompt, asked: asked, slots: QuizLevel.advanced.slots, map: .bundled)
      #expect(cells == [asked])
    }
  }

  @Test(arguments: [
    (key: "souvenir", tense: Tense.passéComposé(.thirdSingular), prompt: "s'est souvenu"),
    (key: "souvenir", tense: Tense.imparfait(.firstSingular), prompt: "me souvenais"),
    (key: "absenter", tense: Tense.indicatifPrésent(.firstSingular), prompt: "m'absente"),
    (key: "souvenir", tense: Tense.indicatifPrésent(.firstPlural), prompt: "nous souvenons"),
    (key: "souvenir", tense: Tense.participePrésent, prompt: "se souvenant"),
    (key: "souvenir", tense: Tense.participePassé, prompt: "souvenu")
  ])
  func aPronominalPromptCarriesItsReflexivePronoun(key: String, tense: Tense, prompt: String) throws {
    let prompts = RecognitionQuestion.prompts(of: try verb(key), tense: tense, pronounGender: .masculine)

    #expect(prompts.map { $0.lowercased() } == [prompt])
  }

  @Test func aPronominalImpératifPasséIsAskedAsItsPasséComposé() throws {
    let asked = QuizQuestion.recognizing(QuizQuestion(verb: try verb("souvenir"), tense: .impératifPassé(.secondPlural)), slots: QuizLevel.advanced.slots)

    #expect(asked.tense == .passéComposé(.secondPlural))
    #expect(asked.recognition?.prompt.isEmpty == false)
    #expect(asked.answerFrame == .bareBlank)
  }

  @Test(arguments: [
    (key: "être", typed: " Être ", isRight: true),
    (key: "être", typed: "etre", isRight: false),
    (key: "souvenir", typed: "souvenir", isRight: true),
    (key: "souvenir", typed: "se souvenir", isRight: true),
    (key: "souvenir", typed: "s’souvenir", isRight: false),
    (key: "absenter", typed: "s’absenter", isRight: true),
    (key: "absenter", typed: "se absenter", isRight: false),
    (key: "connaître", typed: "connaitre", isRight: true),
    (key: "croître", typed: "croitre", isRight: false)
  ])
  func theInfinitiveIsGradedAsTyped(key: String, typed: String, isRight: Bool) throws {
    #expect(RecognitionQuestion.spells(typed, try verb(key)) == isRight)
  }

  @Test func aPartIsWrongOnlyWhenChangingItCanMakeTheAnswerRight() throws {
    let cases: [(typed: String, slot: QuizTenseSlot, person: PersonNumber?, wrong: Set<RecognitionPart>, earnsMore: Bool)] = [
      ("être", .indicatifPrésent, .firstSingular, [], false),
      ("suivre", .impératif, .secondSingular, [], false),
      ("suivre", .indicatifPrésent, .secondSingular, [], false),
      ("être", .indicatifPrésent, .secondSingular, [.person], true),
      ("suivre", .passéSimple, .firstSingular, [.tense], true),
      ("suivre", .passéSimple, .thirdPlural, [.tense, .person], true),
      ("sivre", .indicatifPrésent, .firstSingular, [.infinitive], true),
      ("sivre", .indicatifPrésent, .thirdPlural, [.infinitive, .person], true),
      ("aller", .participePassé, nil, [.infinitive, .tense], false),
      ("aller", .futurSimple, .thirdPlural, [.infinitive, .tense, .person], false)
    ]
    let recognition = try question("suivre", .indicatifPrésent(.firstSingular))
    for item in cases {
      let grade = recognition.grade(answer(item.typed, item.slot, item.person))

      #expect(grade.wrongParts == item.wrong, "\(item.typed) · \(item.slot) · \(String(describing: item.person))")
      #expect(grade.earnsSecondAttempt == item.earnsMore, "\(item.typed) · \(item.slot) · \(String(describing: item.person))")
    }
  }

  @Test func aParticipleHasNoPersonToJudge() throws {
    let recognition = try question("faire", .participePassé)

    #expect(recognition.grade(answer("faire", .participePassé)).isCorrect)
    #expect(recognition.grade(answer("faire", .indicatifPrésent, .thirdSingular)).isCorrect)
    #expect(recognition.grade(answer("faire", .indicatifPrésent, .firstSingular)).wrongParts == [.person])
    #expect(recognition.grade(answer("faire", .participePrésent)).wrongParts == [.tense])
    #expect(RecognitionQuestion.persons(of: .participePassé).isEmpty)
    #expect(RecognitionQuestion.persons(of: .impératif) == PersonNumber.impératifPersonNumbers)
    #expect(answer("faire", .indicatifPrésent).tense == nil)
    #expect(answer("faire", .impératif, .firstSingular).tense == nil)
  }

  @Test func eachSetOfWrongPartsHasItsOwnLine() {
    let sets: [Set<RecognitionPart>] = [[.infinitive], [.tense], [.person], [.infinitive, .tense], [.infinitive, .person], [.tense, .person]]
    let lines = sets.map { RecognitionGrade(wrongParts: $0, hasRightPart: true).line }

    #expect(Set(lines).count == sets.count)
    #expect(lines.allSatisfy { !$0.isEmpty })
    #expect(lines[1] == L.Recognition.checkTense)
  }

  @Test func theCorrectionListsEveryRightAnswerByVerbAndTense() throws {
    #expect(try question("parler", .subjonctifPrésent(.thirdSingular)).answerLines == [
      "parler · indicatif présent · je, il/elle",
      "parler · subjonctif présent · je, il/elle",
      "parler · impératif · tu"
    ])
    #expect(try question("souvenir", .indicatifPrésent(.firstSingular)).answerLines == ["se souvenir · indicatif présent · je"])
    #expect(try question("faire", .participePassé).answerLines == ["faire · indicatif présent · il/elle", "faire · participe passé"])
    #expect(answer("Être", .passéSimple, .firstPlural).summary == "être · passé simple · nous")
  }

  @Test func aRectifiedInfinitiveShowsTheTraditionalSpelling() throws {
    let recognition = try question("connaître", .indicatifPrésent(.thirdSingular))

    #expect(recognition.preferredSpelling(of: "connaitre") == "connaître")
    #expect(recognition.preferredSpelling(of: "connaître") == nil)
    #expect(try question("souvenir", .indicatifPrésent(.firstSingular)).preferredSpelling(of: "se souvenir") == nil)
    #expect(recognition.nearestInfinitive(to: "conaitre") == "connaître")
  }

  @Test func theScopeIsUnrankedAndAsksByLevel() {
    let scope = QuizScope.recognition

    #expect(scope.isRecognition)
    #expect(!scope.isRanked)
    #expect(!scope.mixesDueItems)
    #expect(scope.asksByLevel)
    #expect(scope.continues)
    #expect(scope.sendsQuestionCounts)
    #expect(scope.source == .recognition)
    #expect(scope.sessionTitle == L.Recognition.title)
    #expect(LastQuizResult.Kind(scope: scope) == .recognition)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Name the Conjugation sessions")
  struct RecognitionSessionTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func restorePractice() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    private func rightAnswer(_ quiz: Quiz) throws -> RecognitionAnswer {
      let cell = try #require(quiz.currentQuestion?.recognition?.cells.first)
      let verb = try #require(cell.verb)
      return RecognitionAnswer(infinitif: verb.infinitif, slot: try #require(QuizTenseSlot(tense: cell.tense)), personNumber: cell.tense.personNumber)
    }

    private func makeQuiz(level: QuizLevel = .beginner, seed: UInt64 = 7, gameCenter: GameCenterSpy = GameCenterSpy()) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(gameCenter: gameCenter, seed: seed)
      quiz.start(scope: .recognition)
      return quiz
    }

    @Test func aRoundDrawsTenPromptsFromTheLevelsTensesAndBand() {
      for level in QuizLevel.allCases {
        let quiz = makeQuiz(level: level)
        defer {
          quiz.quit()
        }

        #expect(quiz.questions.count == Quiz.questionCount)
        for question in quiz.questions {
          let recognition = question.recognition
          #expect(recognition?.slots == RecognitionQuestion.inPageOrder(level.slots))
          #expect(recognition?.prompt.isEmpty == false)
          #expect(level.band.map(question.verb.isIn) ?? true)
          #expect(recognition?.cells.contains(RecognitionCell(verbKey: question.verb.dictionaryKey, tense: question.tense)) == true)
        }
      }
    }

    @Test func aRightAnswerScoresAndRecordsNothing() throws {
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
      let bestScore = Current.settings.bestScore(at: .beginner)
      let quiz = makeQuiz(gameCenter: gameCenter)

      while quiz.quizState == .inProgress {
        quiz.submitRecognition(try rightAnswer(quiz))
      }

      #expect(quiz.score == 100)
      #expect(quiz.correctCount == 10)
      #expect(quiz.quizResults.allSatisfy { $0.recognitionPrompt != nil })
      #expect(practice.record.entries.isEmpty)
      #expect(practice.lastResult?.kind == .recognition)
      #expect(practice.lastResult?.level == .beginner)
      #expect(practice.lastResult?.title == L.Recognition.title)
      #expect(gameCenter.reports.isEmpty)
      #expect(Current.settings.bestScore(at: .beginner) == bestScore)
      #expect(spy.signalParameters.first?[ParameterKey.source.rawValue] == AnalyticsSource.recognition.rawValue)
      #expect(spy.signalParameters.last?[ParameterKey.questionCount.rawValue] == "10")
      #expect(quiz.canContinue)

      quiz.continueSession()
      #expect(quiz.questions.count == 20)
      #expect(quiz.questions[10...].allSatisfy { $0.recognition != nil })
      quiz.quit()
    }

    @Test func anAnswerWithARightPartEarnsOneMoreTryAtHalfPoints() throws {
      let quiz = makeQuiz()
      defer {
        quiz.quit()
      }
      let right = try rightAnswer(quiz)

      quiz.submitRecognition(RecognitionAnswer(infinitif: right.infinitif + "x", slot: right.slot, personNumber: right.personNumber))

      #expect(quiz.isAwaitingSecondAttempt)
      #expect(quiz.secondAttemptPrompt == L.Recognition.checkInfinitive + " " + L.QuizView.tryOnceMore)
      #expect(quiz.quizResults.isEmpty)

      quiz.submitRecognition(right)

      #expect(quiz.quizResults.last?.conjugationResult == .secondAttemptMatch)
      #expect(quiz.quizResults.last?.firstAttempt?.hasSuffix("x · \(right.slot.recognitionName)" + (right.personNumber.map { " · " + RecognitionQuestion.personLabel($0) } ?? "")) == true)
      #expect(quiz.score == 5)
      #expect(quiz.currentQuestionIndex == 1)
    }

    @Test func aWrongAnswerHoldsItsCorrectionAndComesBack() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let quiz = makeQuiz()
      defer {
        quiz.quit()
      }
      let asked = try #require(quiz.currentQuestion)
      let wrongSlot = try #require(QuizLevel.beginner.slots.first { slot in
        asked.recognition?.cells.contains { QuizTenseSlot(tense: $0.tense) == slot } == false
      })

      quiz.submitRecognition(RecognitionAnswer(infinitif: "zzz", slot: wrongSlot, personNumber: wrongSlot.persons.first { person in
        asked.recognition?.cells.contains { $0.tense.personNumber == person } == false
      }))

      let correction = try #require(quiz.correction)
      #expect(!quiz.isAwaitingSecondAttempt)
      #expect(correction.recognitionGrade?.earnsSecondAttempt == false)
      #expect(correction.recognitionAnswer?.infinitif == "zzz")
      #expect(correction.willBeReasked)
      #expect(quiz.quizResults.last?.conjugationResult == .noMatch)
      #expect(quiz.quizResults.last?.correctAnswer == asked.recognition?.answerLines.joined(separator: "\n"))
      quiz.continueAfterCorrection()
      let reask = try #require(quiz.questions.first { $0.isReask })
      #expect(reask.recognition == asked.recognition)
      #expect(practice.record.entries.isEmpty)
    }
  }
}
