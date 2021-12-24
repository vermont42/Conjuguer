//
//  Quiz.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/16/21.
//

import SwiftUI

class Quiz: ObservableObject {
  @Published private(set) var quizState = QuizState.notStarted
  @Published private(set) var elapsedTime = 0
  @Published private(set) var score = 0
  @Published private(set) var numberCorrect = 0.0
  @Published private(set) var difficulty = QuizDifficulty.regular
  @Published private(set) var currentQuestionIndex = 0
  @Published private(set) var questions: [(Verb, Tense)] = []
  @Published private(set) var quizResults: [QuizResult] = []
  @Published var shouldShowResults = false

  private var timer: Timer?
  private var timer2: Timer?
  private var gameCenter: GameCenterable?
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
  private var subjonctifPrésentStemChangers = QuizVerbs.subjonctifPrésentStemChangers
  private var subjonctifPrésentStemChangersIndex = 0
  private var topThirties = QuizVerbs.topThirties
  private var topThirtiesIndex = 0
  private var regularRadicauxFuturs = QuizVerbs.regularRadicauxFuturs
  private var regularRadicauxFutursIndex = 0
  private var irregularRadicauxFuturs = QuizVerbs.irregularRadicauxFuturs
  private var irregularRadicauxFutursIndex = 0

  init(gameCenter: GameCenterable, shouldShuffle: Bool = true) {
    self.gameCenter = gameCenter
    self.shouldShuffle = shouldShuffle
  }

  func start() {
    resetIndices()
    randomizePersonNumbersAndVerbs()
    resetPublishedProperties()
    buildQuiz()
    quizState = .inProgress
    SoundPlayer.play(Sound.randomGun)
    Current.analytics.recordQuizStart(difficulty: Current.settings.quizDifficulty)

    timer = Timer.scheduledTimer(
      withTimeInterval: 1.0,
      repeats: true,
      block: { [weak self] _ in
        self?.elapsedTime += 1
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
    subjonctifPrésentStemChangersIndex = 0
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
      subjonctifPrésentStemChangers.shuffle()
      topThirties.shuffle()
      regularRadicauxFuturs.shuffle()
      irregularRadicauxFuturs.shuffle()
    }
  }

  private func resetPublishedProperties() {
    elapsedTime = 0
    score = 0
    numberCorrect = 0.0
    difficulty = Current.settings.quizDifficulty
    currentQuestionIndex = 0
    questions = []
    quizResults = []
  }

  private func buildQuiz() {
//    questions.append((Verb.verbForInfinitif("avoir"), .indicatifPrésent(.firstSingular))) // For testing one conjugation.

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
      questions.append((Verb.verbForInfinitif("ester"), .indicatifPrésent(.firstSingular)))
      questions.append((Verb.verbForInfinitif("gésir"), .participePassé))
      questions.append((Verb.verbForInfinitif("gésir"), .passéSimple(personNumber)))
      questions.append((Verb.verbForInfinitif("choir"), .participePassé))
      questions.append((Verb.verbForInfinitif("clore"), .indicatifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("courre"), .futurSimple(personNumber)))
      questions.append((Verb.verbForInfinitif("fiche"), .participePassé))
      questions.append((Verb.verbForInfinitif("avoir"), .subjonctifImparfait(personNumber)))
      questions.append((Verb.verbForInfinitif("avoir"), .subjonctifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("aller"), .subjonctifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("être"), .passéSimple(personNumber)))
      questions.append((Verb.verbForInfinitif("être"), .subjonctifImparfait(personNumber)))
      questions.append((Verb.verbForInfinitif("béer"), .indicatifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("braire"), .passéSimple(personNumber)))
      questions.append((Verb.verbForInfinitif("bruire"), .subjonctifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("falloir"), .subjonctifImparfait(personNumber)))
      questions.append((Verb.verbForInfinitif("faillir"), .subjonctifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("couvrir"), .passéSimple(personNumber)))
      questions.append((Verb.verbForInfinitif("maudire"), .indicatifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("valoir"), .subjonctifImparfait(personNumber)))
      questions.append((Verb.verbForInfinitif("résoudre"), .indicatifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("promouvoir"), .passéSimple(personNumber)))
      questions.append((Verb.verbForInfinitif("pouvoir"), .subjonctifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("plaindre"), .passéSimple(personNumber)))
      questions.append((Verb.verbForInfinitif("issir"), .participePassé))
      questions.append((Verb.verbForInfinitif("lire"), .passéSimple(personNumber)))
      questions.append((Verb.verbForInfinitif("mettre"), .indicatifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("moudre"), .indicatifPrésent(personNumber)))
      questions.append((Verb.verbForInfinitif("paître"), .imparfait(personNumber)))
      questions.append((Verb.verbForInfinitif("mouvoir"), .passéSimple(personNumber)))
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

  private var subjonctifPrésentStemChangerVerb: Verb {
    subjonctifPrésentStemChangersIndex += 1
    if subjonctifPrésentStemChangersIndex == subjonctifPrésentStemChangers.count {
      subjonctifPrésentStemChangersIndex = 0
    }
    return Verb.verbForInfinitif(subjonctifPrésentStemChangers[subjonctifPrésentStemChangersIndex])
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
      numberCorrect += 1.0 * conjugationResult.percentCorrect
      quizResults.append(
        QuizResult(
          infinitif: verb.infinitifWithPossibleExtraLetters,
          tense: tense,
          conjugationResult: conjugationResult,
          correctAnswer: correctAnswers,
          actualAnswer: proposedAnswer
        )
      )
    default:
      fatalError("Conjugation failed.")
    }
    currentQuestionIndex += 1

    if currentQuestionIndex == questions.count {
      completeQuiz()
    }
  }

  private func completeQuiz() {
    let minimumScoreThatGetsBonus = 150
    if score >= minimumScoreThatGetsBonus {
      score += Quiz.bonusForElapsedTime(elapsedTime)
    }
    shouldShowResults = true
    SoundPlayer.play(Sound.randomApplause)
    Current.gameCenter.reportScore(score)
    Current.analytics.recordQuizCompletion(difficulty: Current.settings.quizDifficulty, elapsedTime: elapsedTime, score: score)
    quit()
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
