//
//  Quiz.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/16/21.
//

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
  private(set) var questions: [(Verb, Tense)] = []
  private(set) var quizResults: [QuizResult] = []
  var shouldShowResults = false
  private(set) var previousIncorrectAnswer: String?
  private(set) var previousCorrectAnswer: String?

  private var timer: Timer?
  private let gameCenter: GameCenter
  private var shouldShuffle = true

  private var personNumbers = PersonNumber.allCases
  private var personNumbersIndex = 0
  private var impératifPersonNumbers = PersonNumber.impératifPersonNumbers
  private var impératifPersonNumbersIndex = 0
  private var regularErs = QuizVerbs.regularErs
  private var regularErsIndex = 0
  private var regularIrs = QuizVerbs.regularIrs
  private var regularIrsIndex = 0
  private var regularRes = QuizVerbs.regularRes
  private var regularResIndex = 0
  private var bigThrees = QuizVerbs.bigThrees
  private var bigThreesIndex = 0
  private var indicatifPrésentStemChangers = QuizVerbs.indicatifPrésentStemChangers
  private var indicatifPrésentStemChangersIndex = 0
  private var êtreAuxiliaries = QuizVerbs.êtreAuxiliaries
  private var êtreAuxiliariesIndex = 0
  private var irregularParticipePassés = QuizVerbs.irregularParticipePassés
  private var irregularParticipePassésIndex = 0
  private var topThirties = QuizVerbs.topThirties
  private var topThirtiesIndex = 0
  private var regularRadicauxFuturs = QuizVerbs.regularRadicauxFuturs
  private var regularRadicauxFutursIndex = 0
  private var irregularRadicauxFuturs = QuizVerbs.irregularRadicauxFuturs
  private var irregularRadicauxFutursIndex = 0

  init(gameCenter: GameCenter, shouldShuffle: Bool = true) {
    self.gameCenter = gameCenter
    self.shouldShuffle = shouldShuffle
  }

  func start() {
    resetIndices()
    randomizePersonNumbersAndVerbs()
    resetPublishedProperties()
    buildQuiz()
    quizState = .inProgress
    announcePublishedProperties()
    SoundPlayer.play(Sound.randomGun)
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
    SoundPlayer.play(Sound.randomSadTrombone)
    timer?.invalidate()
    quizState = .notStarted
    Current.analytics.recordQuizQuit(difficulty: Current.settings.quizDifficulty, lastQuestionIndex: currentQuestionIndex, elapsedTime: elapsedTime)
  }

  private func resetIndices() {
    personNumbersIndex = 0
    impératifPersonNumbersIndex = 0
    regularErsIndex = 0
    regularIrsIndex = 0
    regularResIndex = 0
    bigThreesIndex = 0
    indicatifPrésentStemChangersIndex = 0
    êtreAuxiliariesIndex = 0
    irregularParticipePassésIndex = 0
    topThirtiesIndex = 0
    regularRadicauxFutursIndex = 0
    irregularRadicauxFutursIndex = 0
  }

  private func randomizePersonNumbersAndVerbs() {
    if shouldShuffle {
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
        questions.append(($0, .indicatifPrésent(personNumber)))
      }

      [regularErVerb, regularIrVerb, regularReVerb, bigThreeVerb, êtreAuxiliaryVerb, irregularParticipePasséVerb].forEach {
        questions.append(($0, .passéComposé(personNumber)))
      }

      [regularErVerb, regularIrVerb, regularReVerb, bigThreeVerb].forEach {
        questions.append(($0, .subjonctifPrésent(personNumber)))
      }

      [topThirtyVerb, topThirtyVerb, topThirtyVerb].forEach {
        questions.append(($0, .imparfait(personNumber)))
      }

      [regularRadicalFuturVerb, regularRadicalFuturVerb, irregularRadicalFuturVerb].forEach {
        questions.append(($0, .futurSimple(personNumber)))
      }

      [regularRadicalFuturVerb, regularRadicalFuturVerb, irregularRadicalFuturVerb].forEach {
        questions.append(($0, .conditionnelPrésent(personNumber)))
      }

      [topThirtyVerb, topThirtyVerb, topThirtyVerb].forEach {
        questions.append(($0, .impératif(impératifPersonNumber)))
      }

      questions.append((topThirtyVerb, .participePrésent))

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
        questions.append((Verb.verbForInfinitif(infinitif), tense))
      }
    }

    if shouldShuffle {
      questions.shuffle()
    }
  }

  private var personNumber: PersonNumber {
    personNumbersIndex += 1
    if personNumbersIndex == personNumbers.count {
      personNumbersIndex = 0
    }
    return personNumbers[personNumbersIndex]
  }

  private var impératifPersonNumber: PersonNumber {
    impératifPersonNumbersIndex += 1
    if impératifPersonNumbersIndex == impératifPersonNumbers.count {
      impératifPersonNumbersIndex = 0
    }
    return impératifPersonNumbers[impératifPersonNumbersIndex]
  }

  private var regularErVerb: Verb {
    regularErsIndex += 1
    if regularErsIndex == regularErs.count {
      regularErsIndex = 0
    }
    return Verb.verbForInfinitif(regularErs[regularErsIndex])
  }

  private var regularIrVerb: Verb {
    regularIrsIndex += 1
    if regularIrsIndex == regularIrs.count {
      regularIrsIndex = 0
    }
    return Verb.verbForInfinitif(regularIrs[regularIrsIndex])
  }

  private var regularReVerb: Verb {
    regularResIndex += 1
    if regularResIndex == regularRes.count {
      regularResIndex = 0
    }
    return Verb.verbForInfinitif(regularRes[regularResIndex])
  }

  private var bigThreeVerb: Verb {
    bigThreesIndex += 1
    if bigThreesIndex == bigThrees.count {
      bigThreesIndex = 0
    }
    return Verb.verbForInfinitif(bigThrees[bigThreesIndex])
  }

  private var indicatifPrésentStemChangerVerb: Verb {
    indicatifPrésentStemChangersIndex += 1
    if indicatifPrésentStemChangersIndex == indicatifPrésentStemChangers.count {
      indicatifPrésentStemChangersIndex = 0
    }
    return Verb.verbForInfinitif(indicatifPrésentStemChangers[indicatifPrésentStemChangersIndex])
  }

  private var êtreAuxiliaryVerb: Verb {
    êtreAuxiliariesIndex += 1
    if êtreAuxiliariesIndex == êtreAuxiliaries.count {
      êtreAuxiliariesIndex = 0
    }
    return Verb.verbForInfinitif(êtreAuxiliaries[êtreAuxiliariesIndex])
  }

  private var irregularParticipePasséVerb: Verb {
    irregularParticipePassésIndex += 1
    if irregularParticipePassésIndex == irregularParticipePassés.count {
      irregularParticipePassésIndex = 0
    }
    return Verb.verbForInfinitif(irregularParticipePassés[irregularParticipePassésIndex])
  }

  private var topThirtyVerb: Verb {
    topThirtiesIndex += 1
    if topThirtiesIndex == topThirties.count {
      topThirtiesIndex = 0
    }
    return Verb.verbForInfinitif(topThirties[topThirtiesIndex])
  }

  private var regularRadicalFuturVerb: Verb {
    regularRadicauxFutursIndex += 1
    if regularRadicauxFutursIndex == regularRadicauxFuturs.count {
      regularRadicauxFutursIndex = 0
    }
    return Verb.verbForInfinitif(regularRadicauxFuturs[regularRadicauxFutursIndex])
  }

  private var irregularRadicalFuturVerb: Verb {
    irregularRadicauxFutursIndex += 1
    if irregularRadicauxFutursIndex == irregularRadicauxFuturs.count {
      irregularRadicauxFutursIndex = 0
    }
    return Verb.verbForInfinitif(irregularRadicauxFuturs[irregularRadicauxFutursIndex])
  }

  func process(proposedAnswer: String) {
    let question = questions[currentQuestionIndex]
    let verb = question.0
    let tense = question.1
    let correctAnswerResult = Conjugator.conjugate(infinitif: verb.infinitif, tense: tense, extraLetters: nil)
    switch correctAnswerResult {
    case let .success(correctAnswers):
      let conjugationResult = ConjugationResult.score(correctAnswers: correctAnswers, proposedAnswer: proposedAnswer)
      if currentQuestionIndex != questions.count - 1 {
        SoundPlayer.play(conjugationResult.sound)
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
    default:
      fatalError("Conjugation failed.")
    }
    currentQuestionIndex += 1

    if currentQuestionIndex == questions.count {
      completeQuiz()
    } else {
      announcePublishedProperties()
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
    SoundPlayer.play(Sound.randomApplause)
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
        Utterer.utter(L.QuizView.verbWithColon, localeString: currentLocaleString)
        let frenchLocaleString = Utterer.frenchLocaleString
        Utterer.utter(questions[currentQuestionIndex].0.infinitif, localeString: frenchLocaleString)
        Utterer.utter(L.QuizView.translationWithColon, localeString: currentLocaleString)
        Utterer.utter(questions[currentQuestionIndex].0.translation, localeString: Utterer.englishLocaleString)
        Utterer.utter(L.QuizView.pronounWithColon, localeString: currentLocaleString)
        Utterer.utter(questions[currentQuestionIndex].1.pronoun, localeString: Utterer.frenchLocaleString)
        Utterer.utter(questions[currentQuestionIndex].1.gender, localeString: currentLocaleString)
        Utterer.utter(L.QuizView.tenseWithColon, localeString: currentLocaleString)
        Utterer.utter(questions[currentQuestionIndex].1.titleCaseName, localeString: Utterer.frenchLocaleString)
        Utterer.utter(L.QuizView.progressWithColon, localeString: currentLocaleString)
        Utterer.utter("\(currentQuestionIndex + 1) \(L.QuizView.outOf) \(questions.count)", localeString: currentLocaleString)
        Utterer.utter("\(L.QuizView.scoreWithColon) \(score)", localeString: currentLocaleString)
        Utterer.utter("\(L.QuizView.elapsedWithColon) \(elapsedTime) \(L.QuizView.seconds)", localeString: currentLocaleString)
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
