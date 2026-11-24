//
//  ChoiceQuestionTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/24/26.
//

@testable import Conjuguer
import Foundation
import Testing

/// The machine check of `choice_questions.json`: both sentences of every item are the
/// Conjugator's conjugations of their cells, the same sentence but for them, in the tenses the
/// item's reason names, and asked from the reason's level. What it cannot judge, whether a
/// speaker would choose the right sentence and whether the reason is true of it, is the reread's.
@MainActor
@Suite("Choice questions")
struct ChoiceQuestionTests {
  private static let narrowSpace = "\u{202F}"
  private static let elisions = ["j’": "je ", "qu’": "que ", "n’": "ne ", "m’": "me ", "t’": "te ", "s’": "se ", "d’": "de "]

  static func item(_ json: String) throws -> ChoiceQuestion {
    try #require(ChoiceQuestions.decode(Data("[\(json)]".utf8)).first)
  }

  static let siImparfait = #"{"id": "avoir.imparfait.9", "verb": "avoir", "person": "fs", "setting": "conversation", "reason": "siImparfait", "right": {"tense": "imparfait", "fr": "Si j’{avais} le temps, je viendrais."}, "other": {"tense": "conditionnelPrésent", "fr": "Si j’{aurais} le temps, je viendrais."}, "en": "If I had time, I'd come.", "reviewed": true}"#

  private func conjugations(_ sentence: GapSentence, verb: Verb, tense: Tense, gender: PronounGender) -> [String] {
    (Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: gender) ?? "")
      .lowercased()
      .components(separatedBy: Tense.alternateConjugationSeparator)
  }

  private func unelided(_ text: String) -> String {
    let lowered = text.lowercased()
    for (elided, full) in Self.elisions where lowered.hasSuffix(elided) {
      return String(lowered.dropLast(elided.count)) + full
    }
    return lowered
  }

  @Test func theFileDecodesWhole() throws {
    let url = try #require(Bundle.main.url(forResource: "choice_questions", withExtension: "json"))
    let array = try #require(try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [Any])
    #expect(!ChoiceQuestions.all.isEmpty)
    #expect(ChoiceQuestions.all.count == array.count)
  }

  @Test func everyItemIsWellFormed() {
    var ids: Set<String> = []
    for item in ChoiceQuestions.all {
      #expect(ids.insert(item.id).inserted, "\(item.id) is not unique")
      let prefix = "\(item.verbKey.replacingOccurrences(of: " ", with: "_")).\(item.right.tenseKey)."
      #expect(item.id.hasPrefix(prefix) && Int(item.id.dropFirst(prefix.count)) != nil, "\(item.id) is not verb.rightTense.n")
      #expect(item.setting != nil, "\(item.id) has an unknown setting")
      #expect(item.reason != nil, "\(item.id) has an unknown reason")
      #expect(item.genderKey == nil || item.rightSentence.pronounGender != nil, "\(item.id) has an unknown gender")
      #expect(!item.english.isEmpty, "\(item.id) has no English")
      for sentence in [item.rightSentence, item.otherSentence] {
        #expect(sentence.parts != nil, "\(sentence.id) needs exactly one pair of braces around a conjugation")
        #expect(sentence.tense != nil, "\(sentence.id) names no cell")
        #expect(!sentence.french.contains("'"), "\(sentence.id) has a straight apostrophe")
        for mark in ["!", "?", ":", ";"] where sentence.french.contains(mark) {
          let unspaced = sentence.french.components(separatedBy: mark).dropLast().contains { !$0.hasSuffix(Self.narrowSpace) }
          #expect(!unspaced, "\(sentence.id) lacks the narrow no-break space before \(mark)")
        }
      }
    }
  }

  /// The two sentences differ only in their conjugations, and an elision before them: "Je
  /// {travaillais}" against "J’{ai travaillé}".
  @Test func theTwoSentencesDifferOnlyInTheirConjugations() throws {
    for item in ChoiceQuestions.all {
      let right = try #require(item.rightSentence.parts, "\(item.id)")
      let other = try #require(item.otherSentence.parts, "\(item.id)")
      #expect(unelided(right.before) == unelided(other.before), "\(item.id): the sentences differ before their braces")
      #expect(right.after == other.after, "\(item.id): the sentences differ after their braces")
      #expect(right.answer.lowercased() != other.answer.lowercased(), "\(item.id): the conjugations are the same")
    }
  }

  /// A sentence's subject is a noun or a pronoun the Conjugator never sees, so the gender it fixes
  /// is recorded wherever either sentence's agreement would change with the learner's setting.
  @Test func bothSentencesAreTheConjugators() throws {
    for item in ChoiceQuestions.all {
      for sentence in [item.rightSentence, item.otherSentence] {
        let verb = try #require(sentence.verb, "\(sentence.id)")
        let tense = try #require(sentence.tense, "\(sentence.id)")
        #expect(verb.hasCell(tense), "\(sentence.id): \(verb.infinitif) has no such cell")
        let gender = sentence.pronounGender ?? .masculine
        let answers = conjugations(sentence, verb: verb, tense: tense, gender: gender)
        #expect(answers.contains(sentence.answer.lowercased()), "\(sentence.id): {\(sentence.answer)} is not \(answers.joined(separator: " or "))")
        if sentence.pronounGender == nil {
          #expect(conjugations(sentence, verb: verb, tense: tense, gender: .feminine) == answers, "\(sentence.id): the agreement varies, so the item needs a gender")
        }
      }
      let right = item.rightSentence
      let verb = try #require(right.verb)
      let tense = try #require(right.tense)
      let correctAnswers = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: right.pronounGender ?? .masculine) ?? ""
      let grade = ConjugationResult.grade(proposedAnswer: right.answer, correctAnswers: correctAnswers, verb: verb, tense: tense)
      #expect(grade.result == .totalMatch, "\(item.id): the quiz would not accept the right sentence's conjugation")
    }
  }

  @Test func everyItemTakesItsReasonsTenses() throws {
    for item in ChoiceQuestions.all {
      let reason = try #require(item.reason, "\(item.id)")
      #expect(item.rightSentence.slot.map(reason.rightSlots.contains) == true, "\(item.id): the right sentence is not in the reason's tense")
      #expect(item.otherSentence.slot.map(reason.otherSlots.contains) == true, "\(item.id): the other sentence is not in the reason's tense")
    }
  }

  @Test func everyItemIsAskedFromItsReasonsLevel() throws {
    for item in ChoiceQuestions.all {
      let level = try #require(item.reason?.level, "\(item.id)")
      let index = try #require(QuizLevel.allCases.firstIndex(of: level))
      for (otherIndex, other) in QuizLevel.allCases.enumerated() {
        #expect(item.isAskable(at: other) == (otherIndex >= index), "\(item.id) at \(other)")
      }
    }
  }

  @Test func everyReasonAndSettingIsUsedAndWorded() {
    let reasons = Set(ChoiceQuestions.all.compactMap(\.reason))
    let settings = Set(ChoiceQuestions.all.compactMap(\.setting))
    #expect(reasons == Set(ChoiceReason.allCases))
    #expect(settings == Set(ChoiceSetting.allCases))
    for reason in ChoiceReason.allCases {
      #expect(!reason.line.isEmpty && !reason.line.hasPrefix("Choice."), "\(reason) has no line")
      #expect(!reason.rightSlots.contains { reason.otherSlots.contains($0) }, "\(reason) names one tense for both sentences")
      #expect(reason.rightSlots.allSatisfy(reason.level.slots.contains), "\(reason)'s level does not ask its right tense")
    }
  }

  @Test func theRightSentenceTakesEitherPlace() throws {
    let item = try Self.item(Self.siImparfait)
    let first = ChoicePrompt(question: item, rightIndex: 0)
    let second = ChoicePrompt(question: item, rightIndex: 1)

    #expect(first.options.map(\.answer) == ["avais", "aurais"])
    #expect(second.options.map(\.answer) == ["aurais", "avais"])
    #expect(item.rightSentence.completed == "Si j’avais le temps, je viendrais.")
    #expect(item.rightSentence.tense == .imparfait(.firstSingular))
    #expect(item.otherSentence.tense == .conditionnelPrésent(.firstSingular))
    #expect(item.reason?.level == .elementary)
    #expect(item.setting?.french == "Dans une conversation")
  }

  @Test func beginnerAsksNoneAndAdvancedAsksEvery() {
    #expect(ChoiceQuestions.askable(at: .beginner, includesDrafts: true).isEmpty)
    let elementary = ChoiceQuestions.askable(at: .elementary, includesDrafts: true)
    let intermediate = ChoiceQuestions.askable(at: .intermediate, includesDrafts: true)
    #expect(!elementary.isEmpty)
    #expect(Set(elementary.map(\.id)).isStrictSubset(of: Set(intermediate.map(\.id))))
    #expect(ChoiceQuestions.askable(at: .advanced, includesDrafts: true).count == ChoiceQuestions.all.count)
  }

  @Test func aReleaseBuildAsksNoDraft() throws {
    let reviewed = try Self.item(Self.siImparfait)
    let draft = try Self.item(Self.siImparfait.replacingOccurrences(of: #""reviewed": true"#, with: #""reviewed": false"#))

    #expect(ChoiceQuestions.askable(at: .elementary, from: [draft, reviewed], includesDrafts: false) == [reviewed])
    #expect(ChoiceQuestions.askable(at: .elementary, from: [draft, reviewed], includesDrafts: true).count == 2)
  }

  @Test func theDrawTakesUnaskedItemsFirstAndNeverOpensARound() throws {
    let candidates = ChoiceQuestions.askable(at: .elementary, includesDrafts: true)
    var generator = SeededRandomNumberGenerator(seed: 5)
    let first = try #require(QuizDraw.choice(from: candidates, excluded: [], using: &generator))
    let allButOne = Set(candidates.map(\.id)).subtracting([first.question.id])
    let last = try #require(QuizDraw.choice(from: candidates, excluded: allButOne, using: &generator))
    #expect(last.question.id == first.question.id)
    let again = try #require(QuizDraw.choice(from: candidates, excluded: Set(candidates.map(\.id)), using: &generator))
    #expect(candidates.contains(again.question))
    #expect(QuizDraw.choice(from: [], excluded: [], using: &generator) == nil)

    var rightIndexes: Set<Int> = []
    for _ in 0 ..< 50 {
      let position = QuizDraw.choicePosition(in: 9, using: &generator)
      #expect((1...9).contains(position))
      rightIndexes.insert(try #require(QuizDraw.choice(from: candidates, excluded: [], using: &generator)).rightIndex)
    }
    #expect(rightIndexes == [0, 1])
  }

  @Test func theFixtureFindsEveryItemItNames() {
    let ids = Set(ChoiceQuestions.all.map(\.id))
    #expect(Quiz.choicesFixtureIDs.allSatisfy(ids.contains))
  }
}

extension QuizTests {
  @MainActor
  @Suite("Choice questions in the quiz")
  struct ChoiceSessionTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func restorePractice() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    private func makeQuiz(level: QuizLevel = .elementary, scope: QuizScope = .allVerbs, seed: UInt64 = 3) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: seed)
      quiz.start(scope: scope)
      return quiz
    }

    private func correctAnswer(for question: QuizQuestion) -> String {
      let conjugated = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: question.verb.extraLetters) ?? ""
      return conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
    }

    /// Answers typed questions rightly until the round's choice.
    private func reachTheChoice(_ quiz: Quiz) throws -> ChoicePrompt {
      while let question = quiz.currentQuestion, question.choice == nil {
        quiz.process(proposedAnswer: correctAnswer(for: question))
      }
      return try #require(quiz.currentQuestion?.choice)
    }

    @Test(arguments: QuizLevel.allCases)
    func aDefaultRoundAsksOneChoiceFromElementaryUp(level: QuizLevel) {
      for seed in UInt64(0) ..< 10 {
        let quiz = makeQuiz(level: level, seed: seed)
        defer {
          quiz.quit()
        }
        let choices = quiz.questions.compactMap(\.choice)
        #expect(quiz.questions.count == Quiz.questionCount)
        #expect(choices.count == (level == .beginner ? 0 : 1))
        #expect(quiz.questions.first?.choice == nil, "A round opens on a typed question.")
        #expect(choices.allSatisfy { $0.question.isAskable(at: level) })
      }
    }

    @Test func noOtherQuizAsksAChoice() throws {
      let verbs = Array(QuizLevel.advanced.verbs.prefix(20))
      for scope in [QuizScope.myVerbs(verbs), .sentences, .recognition, .verbPage(try #require(verbs.first))] {
        let quiz = makeQuiz(level: .advanced, scope: scope)
        #expect(quiz.questions.allSatisfy { $0.choice == nil }, "\(scope.source)")
        quiz.quit()
      }
      #expect(!QuizScope.sentences.mixesChoiceQuestions)
      #expect(QuizScope.allVerbs.mixesChoiceQuestions)
    }

    @Test func aRightChoiceHoldsWithItsReasonAndRecordsNothing() throws {
      let practice = freshPractice()
      defer {
        restorePractice()
      }
      let quiz = makeQuiz()
      defer {
        quiz.quit()
      }
      let choice = try reachTheChoice(quiz)
      let index = quiz.currentQuestionIndex
      let score = quiz.score
      let entries = practice.record.entries.count

      quiz.process(proposedAnswer: correctAnswer(for: try #require(quiz.currentQuestion)))
      #expect(quiz.currentQuestionIndex == index, "A choice is not answered by typing.")

      quiz.submitChoice(choice.rightIndex)
      #expect(quiz.heldChoice == choice.rightIndex)
      #expect(quiz.isHeld)
      #expect(quiz.correction == nil)
      #expect(quiz.currentQuestionIndex == index)
      #expect(quiz.score == score + 10)
      #expect(practice.record.entries.count == entries)
      let result = try #require(quiz.quizResults.last)
      #expect(result.conjugationResult == .totalMatch)
      #expect(result.sentence == choice.question.rightSentence.completed)
      #expect(result.actualAnswer == result.correctAnswer)

      let elapsed = quiz.elapsedTime
      quiz.clockTicked()
      #expect(quiz.elapsedTime == elapsed, "The clock stops while the reason is read.")
      quiz.submitChoice(1 - choice.rightIndex)
      #expect(quiz.heldChoice == choice.rightIndex, "A held choice takes no second answer.")

      quiz.continueAfterCorrection()
      #expect(quiz.heldChoice == nil)
      #expect(quiz.currentQuestionIndex == index + 1)
    }

    @Test func aWrongChoiceHoldsAndIsNotAskedAgain() throws {
      _ = freshPractice()
      defer {
        restorePractice()
      }
      let quiz = makeQuiz(level: .intermediate)
      defer {
        quiz.quit()
      }
      let choice = try reachTheChoice(quiz)
      let questionCount = quiz.questions.count
      let score = quiz.score

      quiz.submitChoice(1 - choice.rightIndex)
      #expect(quiz.heldChoice == 1 - choice.rightIndex)
      #expect(quiz.score == score)
      #expect(quiz.questions.count == questionCount)
      #expect(!quiz.isAwaitingSecondAttempt)
      let result = try #require(quiz.quizResults.last)
      #expect(result.conjugationResult == .noMatch)
      #expect(result.actualAnswer == choice.question.otherSentence.answer)
      #expect(result.correctAnswer == choice.question.rightSentence.answer)
    }

    @Test func aRankedRoundWithItsChoiceScoresOutOfOneHundredAndTenMoreAsksANewChoice() throws {
      let gameCenter = GameCenterSpy()
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(gameCenter: gameCenter, seed: 3)
      quiz.start()
      let first = try #require(quiz.questions.compactMap(\.choice).first)
      while let question = quiz.currentQuestion, quiz.quizState == .inProgress {
        if let choice = question.choice {
          quiz.submitChoice(choice.rightIndex)
          quiz.continueAfterCorrection()
        } else {
          quiz.process(proposedAnswer: correctAnswer(for: question))
        }
      }

      #expect(quiz.firstRoundScore == 100)
      #expect(quiz.correctCount == Quiz.questionCount)
      #expect(gameCenter.reports.last?.score == 100)

      quiz.continueSession()
      let next = quiz.questions[Quiz.questionCount...].compactMap(\.choice)
      #expect(next.count == 1)
      #expect(next.first?.question.id != first.question.id)
      quiz.quit()
    }
  }
}
