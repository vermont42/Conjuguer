//
//  GapSentenceTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

/// The machine check of `gap_sentences.json`: every blank is the Conjugator's conjugation of its
/// cell, agreement included, so no sentence can teach a wrong conjugation. What it cannot judge,
/// whether a sentence is natural and its English faithful, is the reread's.
@MainActor
@Suite("Phrases à trous")
struct GapSentenceTests {
  private static let narrowSpace = "\u{202F}"

  static func sentence(_ json: String) throws -> GapSentence {
    let decoded = GapSentences.decode(Data("[\(json)]".utf8))
    return try #require(decoded.first)
  }

  private func conjugation(_ sentence: GapSentence, verb: Verb, tense: Tense, gender: PronounGender) -> [String] {
    (Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: gender) ?? "")
      .lowercased()
      .components(separatedBy: Tense.alternateConjugationSeparator)
  }

  @Test func theFileDecodesWhole() throws {
    let url = try #require(Bundle.main.url(forResource: "gap_sentences", withExtension: "json"))
    let array = try #require(try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [Any])
    #expect(!GapSentences.all.isEmpty)
    #expect(GapSentences.all.count == array.count)
  }

  @Test func everySentenceIsWellFormed() {
    var ids: Set<String> = []
    for sentence in GapSentences.all {
      #expect(ids.insert(sentence.id).inserted, "\(sentence.id) is not unique")
      let prefix = "\(sentence.verbKey.replacingOccurrences(of: " ", with: "_")).\(sentence.tenseKey)."
      #expect(sentence.id.hasPrefix(prefix) && Int(sentence.id.dropFirst(prefix.count)) != nil, "\(sentence.id) is not verb.tense.n")
      #expect(sentence.parts != nil, "\(sentence.id) needs exactly one pair of braces around a conjugation")
      #expect(sentence.verb != nil, "\(sentence.id) names no verb")
      #expect(sentence.tense != nil, "\(sentence.id) names no cell")
      #expect(sentence.genderKey == nil || sentence.pronounGender != nil, "\(sentence.id) has an unknown gender")
      #expect(!sentence.english.isEmpty, "\(sentence.id) has no English")
      #expect(!sentence.french.contains("'"), "\(sentence.id) has a straight apostrophe")
      for mark in ["!", "?", ":", ";"] where sentence.french.contains(mark) {
        let unspaced = sentence.french.components(separatedBy: mark).dropLast().contains { !$0.hasSuffix(Self.narrowSpace) }
        #expect(!unspaced, "\(sentence.id) lacks the narrow no-break space before \(mark)")
      }
    }
  }

  /// A sentence's subject is a noun or a pronoun the Conjugator never sees, so the gender it fixes
  /// is recorded, and a sentence whose answer would change with the learner's setting must fix one.
  @Test func everyBlankIsTheConjugatorsConjugation() throws {
    for sentence in GapSentences.all {
      let verb = try #require(sentence.verb, "\(sentence.id)")
      let tense = try #require(sentence.tense, "\(sentence.id)")
      #expect(verb.hasCell(tense), "\(sentence.id): \(verb.infinitif) has no such cell")
      let gender = sentence.pronounGender ?? .masculine
      let answers = conjugation(sentence, verb: verb, tense: tense, gender: gender)
      #expect(answers.contains(sentence.answer.lowercased()), "\(sentence.id): {\(sentence.answer)} is not \(answers.joined(separator: " or "))")
      if sentence.pronounGender == nil {
        let feminine = conjugation(sentence, verb: verb, tense: tense, gender: .feminine)
        #expect(feminine == answers, "\(sentence.id): the agreement varies, so the sentence needs a gender")
      }
      let correctAnswers = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: gender) ?? ""
      let grade = ConjugationResult.grade(proposedAnswer: sentence.answer, correctAnswers: correctAnswers, verb: verb, tense: tense)
      #expect(grade.result == .totalMatch, "\(sentence.id): the quiz would not accept its own answer")
    }
  }

  @Test func everySentenceIsAskedAtSomeLevel() {
    for sentence in GapSentences.all {
      #expect(QuizLevel.allCases.contains { sentence.isAskable(at: $0) }, "\(sentence.id) is asked at no level")
    }
  }

  /// Five sentences for each of the 25 most frequent verbs, one for each group of tenses and one in
  /// the passé simple; three for each of the next 75; and two for each of the next 200, which
  /// Beginner, asking only the top 100, never asks. A doubled infinitive counts as one verb.
  @Test func everyTopThreeHundredVerbHasItsSentences() {
    var counts: [String: Int] = [:]
    for sentence in GapSentences.all {
      if let verb = sentence.verb {
        counts[verb.infinitif, default: 0] += 1
      }
    }
    var seen: Set<String> = []
    for verb in Verb.verbs(in: .top300) where seen.insert(verb.infinitif).inserted {
      let required = verb.frequency <= 25 ? 5 : verb.frequency <= 100 ? 3 : 2
      #expect((counts[verb.infinitif] ?? 0) >= required, "\(verb.infinitif), ranked \(verb.frequency), has \(counts[verb.infinitif] ?? 0) of \(required)")
    }
    #expect(seen.count == FrequencyBand.top300.rawValue)
  }

  @Test func aCompoundTensesFrameMarksTheGenderBesideTheBlank() throws {
    let sentence = try Self.sentence(#"{"id": "a", "verb": "aller", "tense": "passéComposé", "person": "fp", "gender": "f", "fr": "Hier, Marie et moi, nous {sommes allées} au marché.", "en": "x", "reviewed": true}"#)
    let frame = sentence.frame(pronounGender: try #require(sentence.pronounGender))

    #expect(frame.segments == [.context("Hier, Marie et moi, nous "), .gender(isFeminine: true), .blank, .context(" au marché.")])
    #expect(frame.isSentence)
    #expect(frame.sentenceWords.before == ["Hier,", "Marie", "et", "moi,", "nous"])
    #expect(frame.sentenceWords.touchingBefore == nil)
    #expect(frame.sentenceWords.after == ["au", "marché."])
    #expect(frame.spokenPrompt == "Hier, Marie et moi, nous, feminine, blank, au marché")
    #expect(sentence.answer == "sommes allées")
    #expect(sentence.completed == "Hier, Marie et moi, nous sommes allées au marché.")
  }

  @Test func aWordThatTouchesTheBlankStaysBesideIt() throws {
    let elided = try Self.sentence(#"{"id": "a", "verb": "finir", "tense": "passéComposé", "person": "fs", "fr": "Ce matin, j’{ai fini} mon travail.", "en": "x", "reviewed": true}"#)
    let words = elided.frame(pronounGender: .masculine).sentenceWords
    #expect(words.before == ["Ce", "matin,"])
    #expect(words.touchingBefore == "j’")
    #expect(words.touchingAfter == nil)

    let exclamation = try Self.sentence(#"{"id": "b", "verb": "venir", "tense": "impératif", "person": "ss", "fr": "{Viens}\#u{202F}!", "en": "x", "reviewed": true}"#)
    let frame = exclamation.frame(pronounGender: .feminine)
    #expect(frame.segments == [.addressee("tu"), .blank, .context("\u{202F}!")])
    #expect(frame.spokenPrompt == "tu, blank")
    #expect(frame.sentenceWords.touchingAfter == "\u{202F}!")
    #expect(frame.sentenceWords.after.isEmpty)
  }

  @Test func aThirdPersonOrSimpleTensesFrameShowsNoGender() throws {
    let third = try Self.sentence(#"{"id": "a", "verb": "partir", "tense": "passéComposé", "person": "ts", "gender": "f", "fr": "Ma sœur {est partie} tôt.", "en": "x", "reviewed": true}"#)
    let simple = try Self.sentence(#"{"id": "b", "verb": "parler", "tense": "indicatifPrésent", "person": "fp", "fr": "Nous {parlons} français.", "en": "x", "reviewed": true}"#)
    let participle = try Self.sentence(#"{"id": "c", "verb": "chanter", "tense": "participePrésent", "fr": "Il marche en {chantant}.", "en": "x", "reviewed": true}"#)

    #expect(third.frame(pronounGender: .feminine).segments == [.context("Ma sœur "), .blank, .context(" tôt.")])
    #expect(simple.frame(pronounGender: .feminine).segments == [.context("Nous "), .blank, .context(" français.")])
    #expect(participle.tense == .participePrésent)
    #expect(participle.personNumber == nil)
  }

  @Test func aSentenceNamingNoCellIsNotAsked() throws {
    let badPerson = try Self.sentence(#"{"id": "a", "verb": "venir", "tense": "impératif", "person": "fs", "fr": "{Viens}.", "en": "x", "reviewed": true}"#)
    let badTense = try Self.sentence(#"{"id": "b", "verb": "venir", "tense": "futur", "person": "fs", "fr": "Je {viendrai}.", "en": "x", "reviewed": true}"#)
    let twoBlanks = try Self.sentence(#"{"id": "c", "verb": "venir", "tense": "passéComposé", "person": "fs", "fr": "Je {suis} déjà {venu}.", "en": "x", "reviewed": true}"#)
    let falloir = try Self.sentence(#"{"id": "d", "verb": "falloir", "tense": "indicatifPrésent", "person": "fp", "fr": "Nous {fallons}.", "en": "x", "reviewed": true}"#)

    #expect(badPerson.tense == nil)
    #expect(badTense.tense == nil)
    #expect(twoBlanks.parts == nil)
    #expect(QuizLevel.allCases.allSatisfy { !badPerson.isAskable(at: $0) && !badTense.isAskable(at: $0) && !falloir.isAskable(at: $0) })
  }

  @Test func eachLevelAsksItsBandAndTenses() {
    for level in QuizLevel.allCases {
      let askable = GapSentences.askable(at: level, includesDrafts: true)
      #expect(!askable.isEmpty)
      for sentence in askable {
        #expect(sentence.slot.map(level.slots.contains) == true)
        #expect(level.band.map { sentence.verb?.isIn($0) == true } ?? true)
      }
    }
    #expect(GapSentences.askable(at: .beginner, includesDrafts: true).allSatisfy { $0.slot == .indicatifPrésent || $0.slot == .impératif })
    #expect(GapSentences.askable(at: .advanced, includesDrafts: true).count == GapSentences.all.count)
  }

  @Test func aReleaseBuildAsksNoDraft() throws {
    let draft = try Self.sentence(#"{"id": "a", "verb": "parler", "tense": "indicatifPrésent", "person": "fp", "fr": "Nous {parlons}.", "en": "x", "reviewed": false}"#)
    let reviewed = try Self.sentence(#"{"id": "b", "verb": "parler", "tense": "indicatifPrésent", "person": "fs", "fr": "Je {parle}.", "en": "x", "reviewed": true}"#)

    #expect(GapSentences.askable(at: .beginner, from: [draft, reviewed], includesDrafts: false) == [reviewed])
    #expect(GapSentences.askable(at: .beginner, from: [draft, reviewed], includesDrafts: true).count == 2)
  }

  @Test func aRoundTakesOneSentenceAVerbAndUnaskedOnesFirst() throws {
    let candidates = GapSentences.askable(at: .elementary, includesDrafts: true)
    var generator = SeededRandomNumberGenerator(seed: 3)
    let round = QuizDraw.sentences(from: candidates, count: 10, excluded: [], using: &generator)
    #expect(round.count == 10)
    #expect(Set(round.map(\.verbKey)).count == 10)

    let next = QuizDraw.sentences(from: candidates, count: 10, excluded: Set(round.map(\.id)), using: &generator)
    #expect(Set(next.map(\.id)).isDisjoint(with: round.map(\.id)))

    let three = Array(candidates.prefix(3))
    let short = QuizDraw.sentences(from: three, count: 10, excluded: [], using: &generator)
    #expect(Set(short) == Set(three))
    let again = QuizDraw.sentences(from: three, count: 10, excluded: Set(three.map(\.id)), using: &generator)
    #expect(Set(again) == Set(three))
  }

  @Test func theScopeIsPracticeNamedAndUnranked() {
    let scope = QuizScope.sentences
    #expect(!scope.isRanked)
    #expect(scope.asksByLevel)
    #expect(scope.continues)
    #expect(scope.sendsQuestionCounts)
    #expect(scope.source == .sentences)
    #expect(scope.sessionTitle == L.Sentences.title)
    #expect(LastQuizResult.Kind(scope: scope) == .sentences)
  }

  @Test func theFixtureFindsEverySentenceItNames() {
    let ids = Set(GapSentences.all.map(\.id))
    #expect(Quiz.sentencesFixtureIDs.allSatisfy(ids.contains))
  }

  @Test func theFirstRightAnswerOfEachVerbOffersItsExample() {
    func result(_ verbKey: String, _ conjugationResult: ConjugationResult) -> QuizResult {
      QuizResult(infinitif: verbKey, tense: .participePassé, conjugationResult: conjugationResult, correctAnswer: "", actualAnswer: "", verbKey: verbKey)
    }
    let results = [
      result("venir", .noMatch),
      result("venir", .secondAttemptMatch),
      result("venir", .totalMatch),
      result("aller", .totalMatch),
      result("être", .noMatch)
    ]

    #expect(QuizResult.firstRightOfEachVerb(in: results).map(\.id) == [results[1].id, results[3].id])
  }
}

extension QuizTests {
  @MainActor
  @Suite("Phrases à trous sessions")
  struct SentenceSessionTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func restorePractice() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
    }

    private func makeQuiz(level: QuizLevel = .beginner, seed: UInt64 = 7, gameCenter: GameCenterSpy = GameCenterSpy()) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(gameCenter: gameCenter, seed: seed)
      quiz.start(scope: .sentences)
      return quiz
    }

    @Test func aSentencesGenderWinsOverTheSetting() throws {
      let original = Current.settings.pronounGender
      defer {
        Current.settings.pronounGender = original
      }
      Current.settings.pronounGender = .masculine
      let feminine = try #require(QuizQuestion(sentence: try GapSentenceTests.sentence(#"{"id": "a", "verb": "partir", "tense": "passéComposé", "person": "fs", "gender": "f", "fr": "Je {suis partie} tôt.", "en": "x", "reviewed": true}"#)))
      let unmarked = try #require(QuizQuestion(sentence: try GapSentenceTests.sentence(#"{"id": "b", "verb": "finir", "tense": "passéComposé", "person": "fs", "fr": "J’{ai fini}.", "en": "x", "reviewed": true}"#)))

      #expect(feminine.pronounGender == .feminine)
      #expect(feminine.answerFrame.segments.contains(.gender(isFeminine: true)))
      #expect(unmarked.pronounGender == .masculine)
      #expect(unmarked.answerFrame.segments.contains(.gender(isFeminine: false)))
    }

    @Test func aRoundAsksTheLevelsSentencesOneAVerb() {
      for level in QuizLevel.allCases {
        let quiz = makeQuiz(level: level)
        defer {
          quiz.quit()
        }

        #expect(quiz.questions.count == Quiz.questionCount)
        #expect(Set(quiz.questions.map(\.verb.dictionaryKey)).count == Quiz.questionCount)
        for question in quiz.questions {
          let sentence = question.sentence
          #expect(sentence?.isAskable(at: level) == true)
          #expect(sentence?.tense == question.tense)
          #expect(question.answerFrame.isSentence || sentence?.parts?.before.isEmpty == true && sentence?.parts?.after.isEmpty == true)
        }
      }
    }

    @Test func aRightRoundScoresRecordsAndContinuesWithNewSentences() throws {
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

      while let question = quiz.currentQuestion, quiz.quizState == .inProgress {
        quiz.process(proposedAnswer: try #require(question.sentence).answer)
      }

      #expect(quiz.score == 100)
      #expect(quiz.correctCount == 10)
      #expect(quiz.quizResults.allSatisfy { $0.sentence != nil && $0.verbKey != nil })
      #expect(!practice.record.entries.isEmpty)
      #expect(practice.lastResult?.kind == .sentences)
      #expect(practice.lastResult?.level == .beginner)
      #expect(practice.lastResult?.title == L.Sentences.title)
      #expect(gameCenter.reports.isEmpty)
      #expect(Current.settings.bestScore(at: .beginner) == bestScore)
      #expect(spy.signalParameters.first?[ParameterKey.source.rawValue] == AnalyticsSource.sentences.rawValue)
      #expect(spy.signalParameters.last?[ParameterKey.questionCount.rawValue] == "10")
      #expect(quiz.canContinue)

      let firstRound = Set(quiz.questions.compactMap(\.sentence?.id))
      quiz.continueSession()
      #expect(quiz.questions.count == 20)
      #expect(Set(quiz.questions[10...].compactMap(\.sentence?.id)).isDisjoint(with: firstRound))
      quiz.quit()
    }

    @Test func aWrongAnswerHoldsTheCompletedSentenceAndComesBackInIt() throws {
      _ = freshPractice()
      defer {
        restorePractice()
      }
      let quiz = makeQuiz()
      defer {
        quiz.quit()
      }
      let asked = try #require(quiz.currentQuestion?.sentence)

      quiz.process(proposedAnswer: "zzzz")

      #expect(quiz.correction?.willBeReasked == true)
      #expect(quiz.quizResults.last?.sentence == asked.completed)
      let reask = try #require(quiz.questions.first { $0.isReask })
      #expect(reask.sentence == asked)
      quiz.continueAfterCorrection()
      #expect(quiz.currentQuestion?.sentence != asked)
    }
  }
}
