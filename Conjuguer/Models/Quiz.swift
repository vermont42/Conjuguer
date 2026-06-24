//
//  Quiz.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/16/21.
//

import ActivityKit
import Observation
import SwiftUI

@Observable
class Quiz {
  private(set) var quizState = QuizState.notStarted
  private(set) var elapsedTime = 0
  private(set) var score = 0
  private(set) var correctnessScore = 0.0
  private(set) var difficulty = QuizDifficulty.regular
  private(set) var currentQuestionIndex = 0
  private(set) var questions: [QuizQuestion] = []
  private(set) var quizResults: [QuizResult] = []
  var shouldShowResults = false
  private(set) var previousIncorrectAnswer: String?
  private(set) var previousCorrectAnswer: String?

  private var timer: Timer?
  private let gameCenter: GameCenter
  private var shouldShuffle = true
  private var liveActivity: Activity<QuizActivityAttributes>?

  // Elapsed time formatted m:ss for the Live Activity.
  var elapsedTimeString: String {
    String(format: "%d:%02d", elapsedTime / 60, elapsedTime % 60)
  }

  private var correctCount: Int {
    quizResults.filter { $0.conjugationResult == .totalMatch }.count
  }

  private var personNumbers = CyclingDeck(PersonNumber.allCases)
  private var impératifPersonNumbers = CyclingDeck(PersonNumber.impératifPersonNumbers)
  private var regularErs = CyclingDeck(QuizVerbs.regularErs)
  private var regularIrs = CyclingDeck(QuizVerbs.regularIrs)
  private var regularRes = CyclingDeck(QuizVerbs.regularRes)
  private var bigThrees = CyclingDeck(QuizVerbs.bigThrees)
  private var indicatifPrésentStemChangers = CyclingDeck(QuizVerbs.indicatifPrésentStemChangers)
  private var êtreAuxiliaries = CyclingDeck(QuizVerbs.êtreAuxiliaries)
  private var irregularParticipePassés = CyclingDeck(QuizVerbs.irregularParticipePassés)
  private var topThirties = CyclingDeck(QuizVerbs.topThirties)
  private var regularRadicauxFuturs = CyclingDeck(QuizVerbs.regularRadicauxFuturs)
  private var irregularRadicauxFuturs = CyclingDeck(QuizVerbs.irregularRadicauxFuturs)

  init(gameCenter: GameCenter, shouldShuffle: Bool = true) {
    self.gameCenter = gameCenter
    self.shouldShuffle = shouldShuffle
  }

  func start() {
    resetDecks()
    shuffleDecks()
    resetPublishedProperties()
    buildQuiz()
    quizState = .inProgress
    announcePublishedProperties()
    startLiveActivity()
    Current.soundPlayer.play(Sound.randomGun)
    Current.analytics.recordQuizStart(difficulty: Current.settings.quizDifficulty)

    timer = Timer.scheduledTimer(
      withTimeInterval: 1.0,
      repeats: true,
      block: { [weak self] _ in
        // Scheduled from this @MainActor method, so the block fires on the main run loop;
        // assumeIsolated bridges that known main-actor callback back to main-actor isolation
        // to mutate elapsedTime synchronously (no per-tick Task hop, identical timing).
        MainActor.assumeIsolated {
          self?.elapsedTime += 1
        }
      }
    )
  }

  func quit() {
    Current.soundPlayer.play(Sound.randomSadTrombone)
    timer?.invalidate()
    quizState = .notStarted
    endLiveActivity()
    Current.analytics.recordQuizQuit(difficulty: Current.settings.quizDifficulty, lastQuestionIndex: currentQuestionIndex, elapsedTime: elapsedTime)
  }

  private func startLiveActivity() {
    endLiveActivity()
    liveActivity = LiveActivityManager.startQuizActivity(
      difficulty: difficulty.localizedDifficulty,
      totalQuestions: questions.count
    )
  }

  private func updateLiveActivity(isFinished: Bool) {
    guard let liveActivity else {
      return
    }
    let state = QuizActivityAttributes.ContentState(
      currentQuestion: min(currentQuestionIndex + 1, questions.count),
      score: score,
      correctCount: correctCount,
      elapsedTime: elapsedTimeString,
      isFinished: isFinished
    )
    LiveActivityManager.updateQuizActivity(liveActivity, state: state)
  }

  private func endLiveActivity() {
    guard let liveActivity else {
      return
    }
    let finalState = QuizActivityAttributes.ContentState(
      currentQuestion: currentQuestionIndex,
      score: score,
      correctCount: correctCount,
      elapsedTime: elapsedTimeString,
      isFinished: true
    )
    LiveActivityManager.endQuizActivity(liveActivity, finalState: finalState)
    self.liveActivity = nil
  }

  private func resetDecks() {
    personNumbers.reset()
    impératifPersonNumbers.reset()
    regularErs.reset()
    regularIrs.reset()
    regularRes.reset()
    bigThrees.reset()
    indicatifPrésentStemChangers.reset()
    êtreAuxiliaries.reset()
    irregularParticipePassés.reset()
    topThirties.reset()
    regularRadicauxFuturs.reset()
    irregularRadicauxFuturs.reset()
  }

  private func shuffleDecks() {
    guard shouldShuffle else {
      return
    }
    personNumbers.shuffle()
    impératifPersonNumbers.shuffle()
    regularErs.shuffle()
    regularIrs.shuffle()
    regularRes.shuffle()
    bigThrees.shuffle()
    indicatifPrésentStemChangers.shuffle()
    êtreAuxiliaries.shuffle()
    irregularParticipePassés.shuffle()
    topThirties.shuffle()
    regularRadicauxFuturs.shuffle()
    irregularRadicauxFuturs.shuffle()
  }

  private func resetPublishedProperties() {
    elapsedTime = 0
    score = 0
    correctnessScore = 0.0
    difficulty = Current.settings.quizDifficulty
    currentQuestionIndex = 0
    questions = []
    quizResults = []
    previousIncorrectAnswer = nil
    previousCorrectAnswer = nil
  }

  private func buildQuiz() {
    switch Current.settings.quizDifficulty {
    case .regular:
      [regularErVerb, regularErVerb, regularIrVerb, regularIrVerb, regularReVerb, bigThreeVerb, indicatifPrésentStemChangerVerb].forEach {
        questions.append(QuizQuestion(verb: $0, tense: .indicatifPrésent(personNumber)))
      }

      [regularErVerb, regularIrVerb, regularReVerb, bigThreeVerb, êtreAuxiliaryVerb, irregularParticipePasséVerb].forEach {
        questions.append(QuizQuestion(verb: $0, tense: .passéComposé(personNumber)))
      }

      [regularErVerb, regularIrVerb, regularReVerb, bigThreeVerb].forEach {
        questions.append(QuizQuestion(verb: $0, tense: .subjonctifPrésent(personNumber)))
      }

      [topThirtyVerb, topThirtyVerb, topThirtyVerb].forEach {
        questions.append(QuizQuestion(verb: $0, tense: .imparfait(personNumber)))
      }

      [regularRadicalFuturVerb, regularRadicalFuturVerb, irregularRadicalFuturVerb].forEach {
        questions.append(QuizQuestion(verb: $0, tense: .futurSimple(personNumber)))
      }

      [regularRadicalFuturVerb, regularRadicalFuturVerb, irregularRadicalFuturVerb].forEach {
        questions.append(QuizQuestion(verb: $0, tense: .conditionnelPrésent(personNumber)))
      }

      [topThirtyVerb, topThirtyVerb, topThirtyVerb].forEach {
        questions.append(QuizQuestion(verb: $0, tense: .impératif(impératifPersonNumber)))
      }

      questions.append(QuizQuestion(verb: topThirtyVerb, tense: .participePrésent))

    case .ridiculous:
      let ridiculousQuestions: [(String, Tense)] = [
        ("ester", .indicatifPrésent(.firstSingular)),
        ("gésir", .participePassé),
        ("gésir", .passéSimple(personNumber)),
        ("choir", .participePassé),
        ("clore", .indicatifPrésent(personNumber)),
        ("courre", .futurSimple(personNumber)),
        ("fiche", .participePassé),
        ("avoir", .subjonctifImparfait(personNumber)),
        ("avoir", .subjonctifPrésent(personNumber)),
        ("aller", .subjonctifPrésent(personNumber)),
        ("être", .passéSimple(personNumber)),
        ("être", .subjonctifImparfait(personNumber)),
        ("béer", .indicatifPrésent(personNumber)),
        ("braire", .passéSimple(personNumber)),
        ("bruire", .subjonctifPrésent(personNumber)),
        ("falloir", .subjonctifImparfait(personNumber)),
        ("faillir", .subjonctifPrésent(personNumber)),
        ("couvrir", .passéSimple(personNumber)),
        ("maudire", .indicatifPrésent(personNumber)),
        ("valoir", .subjonctifImparfait(personNumber)),
        ("résoudre", .indicatifPrésent(personNumber)),
        ("promouvoir", .passéSimple(personNumber)),
        ("pouvoir", .subjonctifPrésent(personNumber)),
        ("plaindre", .passéSimple(personNumber)),
        ("issir", .participePassé),
        ("lire", .passéSimple(personNumber)),
        ("mettre", .indicatifPrésent(personNumber)),
        ("moudre", .indicatifPrésent(personNumber)),
        ("paître", .imparfait(personNumber)),
        ("mouvoir", .passéSimple(personNumber))
      ]
      ridiculousQuestions.forEach { infinitif, tense in
        questions.append(QuizQuestion(verb: Verb.verbForInfinitif(infinitif), tense: tense))
      }
    }

    if shouldShuffle {
      questions.shuffle()
    }
  }

  private var personNumber: PersonNumber {
    personNumbers.next()
  }

  private var impératifPersonNumber: PersonNumber {
    impératifPersonNumbers.next()
  }

  private var regularErVerb: Verb {
    Verb.verbForInfinitif(regularErs.next())
  }

  private var regularIrVerb: Verb {
    Verb.verbForInfinitif(regularIrs.next())
  }

  private var regularReVerb: Verb {
    Verb.verbForInfinitif(regularRes.next())
  }

  private var bigThreeVerb: Verb {
    Verb.verbForInfinitif(bigThrees.next())
  }

  private var indicatifPrésentStemChangerVerb: Verb {
    Verb.verbForInfinitif(indicatifPrésentStemChangers.next())
  }

  private var êtreAuxiliaryVerb: Verb {
    Verb.verbForInfinitif(êtreAuxiliaries.next())
  }

  private var irregularParticipePasséVerb: Verb {
    Verb.verbForInfinitif(irregularParticipePassés.next())
  }

  private var topThirtyVerb: Verb {
    Verb.verbForInfinitif(topThirties.next())
  }

  private var regularRadicalFuturVerb: Verb {
    Verb.verbForInfinitif(regularRadicauxFuturs.next())
  }

  private var irregularRadicalFuturVerb: Verb {
    Verb.verbForInfinitif(irregularRadicauxFuturs.next())
  }

  func process(proposedAnswer: String) {
    let question = questions[currentQuestionIndex]
    let verb = question.verb
    let tense = question.tense
    guard let correctAnswers = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: nil) else {
      fatalError("Conjugation failed.")
    }
    let conjugationResult = ConjugationResult.score(correctAnswers: correctAnswers, proposedAnswer: proposedAnswer)
    if currentQuestionIndex != questions.count - 1 {
      Current.soundPlayer.play(conjugationResult.sound)
    }
    score += conjugationResult.score * difficulty.scoreModifier
    correctnessScore += conjugationResult.percentCorrect
    quizResults.append(
      QuizResult(
        infinitif: verb.infinitifWithPossibleExtraLetters,
        tense: tense,
        conjugationResult: conjugationResult,
        correctAnswer: correctAnswers,
        actualAnswer: proposedAnswer
      )
    )
    if conjugationResult == .noMatch {
      previousIncorrectAnswer = proposedAnswer
      previousCorrectAnswer = correctAnswers
    } else {
      previousIncorrectAnswer = nil
      previousCorrectAnswer = nil
    }
    currentQuestionIndex += 1

    if currentQuestionIndex == questions.count {
      completeQuiz()
    } else {
      announcePublishedProperties()
      updateLiveActivity(isFinished: false)
    }
  }

  private func completeQuiz() {
    let minimumScoreThatGetsBonus = 150
    if score >= minimumScoreThatGetsBonus {
      score += Quiz.bonusForElapsedTime(elapsedTime)
    }
    if score > Current.settings.bestScore {
      Current.settings.bestScore = score
    }
    shouldShowResults = true
    Current.soundPlayer.play(Sound.randomApplause)
    gameCenter.reportScore(score)
    Current.analytics.recordQuizCompletion(difficulty: Current.settings.quizDifficulty, elapsedTime: elapsedTime, score: score)
    quit()
  }

  private func announcePublishedProperties() {
    if UIAccessibility.isVoiceOverRunning {
      let announcementDelay = 1.0
      Task { @MainActor in
        try? await Task.sleep(for: .seconds(announcementDelay))
        let currentLocaleString: String
        let currentRegion = Current.analytics.analyticsLocale.regionCode
        let currentLanguage = Current.analytics.analyticsLocale.languageCode
        if currentLanguage == "fr" {
          currentLocaleString = Utterer.frenchLocaleString
        } else {
          currentLocaleString = currentLanguage + "-" + currentRegion
        }
        let question = questions[currentQuestionIndex]
        Utterer.utter(L.QuizView.verbWithColon, localeString: currentLocaleString)
        Utterer.utter(question.verb.infinitif, localeString: Utterer.frenchLocaleString)
        Utterer.utter(L.QuizView.translationWithColon, localeString: currentLocaleString)
        Utterer.utter(question.verb.translation, localeString: Utterer.englishLocaleString)
        Utterer.utter(L.QuizView.pronounWithColon, localeString: currentLocaleString)
        Utterer.utter(question.tense.pronoun, localeString: Utterer.frenchLocaleString)
        Utterer.utter(question.tense.gender, localeString: currentLocaleString)
        Utterer.utter(L.QuizView.tenseWithColon, localeString: currentLocaleString)
        Utterer.utter(question.tense.titleCaseName, localeString: Utterer.frenchLocaleString)
        Utterer.utter(L.QuizView.progressWithColon, localeString: currentLocaleString)
        Utterer.utter(L.QuizView.progress(currentQuestionIndex + 1, of: questions.count), localeString: currentLocaleString)
        Utterer.utter(L.QuizView.score(score), localeString: currentLocaleString)
        Utterer.utter(L.QuizView.elapsed(seconds: elapsedTime), localeString: currentLocaleString)
      }
    }
  }

  private static func bonusForElapsedTime(_ elapsedTime: Int) -> Int {
    switch elapsedTime {
    case 0 ... 120:
      return 450
    case 121 ... 180:
      return 400
    case 181 ... 240:
      return 350
    case 241 ... 300:
      return 300
    case 301 ... 360:
      return 250
    case 361 ... 420:
      return 200
    case 421 ... 480:
      return 150
    case 481 ... 540:
      return 100
    case 541 ... 600:
      return 50
    default:
      return 0
    }
  }
}
