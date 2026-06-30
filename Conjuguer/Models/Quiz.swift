//
//  Quiz.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/16/21.
//

import ActivityKit
import Observation
import SwiftUI
import TipKit

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
    Current.analytics.signal(name: .quizStart, parameters: [
      ParameterKey.difficulty.rawValue: Current.settings.quizDifficulty.rawValue
    ])

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
    Current.analytics.signal(name: .quizQuit, parameters: [
      ParameterKey.difficulty.rawValue: Current.settings.quizDifficulty.rawValue,
      ParameterKey.lastQuestionIndex.rawValue: "\(currentQuestionIndex)",
      ParameterKey.elapsedTime.rawValue: "\(elapsedTime)"
    ])
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
    #if DEBUG
    // Screenshot driver hook: when launched with `-CONJUGUER_QUIZ_FIXTURE screenshot`,
    // build a deterministic 30-question quiz and export the correct answers so the
    // screenshot driver can type them. See docs/screenshot-playbook.md.
    if UserDefaults.standard.string(forKey: "CONJUGUER_QUIZ_FIXTURE") == "screenshot" {
      questions = generateScreenshotFixture()
      exportFixtureAnswers(questions)
      return
    }
    #endif

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
        ("réaliser", .indicatifPrésent(.firstSingular)),
        ("devenir", .participePassé),
        ("voir", .passéSimple(personNumber)),
        ("choir", .participePassé),
        ("clore", .indicatifPrésent(personNumber)),
        ("partir", .futurSimple(personNumber)),
        ("naître", .participePassé),
        ("avoir", .subjonctifImparfait(personNumber)),
        ("avoir", .subjonctifPrésent(personNumber)),
        ("aller", .subjonctifPrésent(personNumber)),
        ("être", .passéSimple(personNumber)),
        ("être", .subjonctifImparfait(personNumber)),
        ("parler", .indicatifPrésent(personNumber)),
        ("prendre", .passéSimple(personNumber)),
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
        ("recevoir", .participePassé),
        ("lire", .passéSimple(personNumber)),
        ("mettre", .indicatifPrésent(personNumber)),
        ("moudre", .indicatifPrésent(personNumber)),
        ("ouvrir", .imparfait(personNumber)),
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

  #if DEBUG
  // A fixed, locale-independent 30-question plan for App Store screenshots. The
  // verbs are all common enough to exist in every build of verbs.xml, and the
  // tenses are picked to look representative (présent, passé composé, imparfait,
  // futur, conditionnel, impératif). See docs/screenshot-playbook.md.
  private func generateScreenshotFixture() -> [QuizQuestion] {
    let plan: [(infinitif: String, tense: Tense)] = [
      ("parler", .indicatifPrésent(.firstSingular)),
      ("avoir", .indicatifPrésent(.thirdSingular)),
      ("être", .indicatifPrésent(.firstSingular)),
      ("aller", .futurSimple(.thirdSingular)),
      ("finir", .indicatifPrésent(.secondSingular)),
      ("faire", .passéComposé(.firstSingular)),
      ("prendre", .passéComposé(.thirdSingular)),
      ("venir", .passéComposé(.thirdSingular)),
      ("voir", .indicatifPrésent(.thirdSingular)),
      ("pouvoir", .indicatifPrésent(.firstSingular)),
      ("vouloir", .indicatifPrésent(.firstSingular)),
      ("devoir", .indicatifPrésent(.firstSingular)),
      ("savoir", .indicatifPrésent(.firstSingular)),
      ("dire", .indicatifPrésent(.secondPlural)),
      ("manger", .imparfait(.firstPlural)),
      ("donner", .indicatifPrésent(.thirdPlural)),
      ("aimer", .conditionnelPrésent(.firstSingular)),
      ("partir", .passéComposé(.thirdSingular)),
      ("mettre", .indicatifPrésent(.firstSingular)),
      ("connaître", .indicatifPrésent(.thirdSingular)),
      ("écrire", .imparfait(.firstSingular)),
      ("lire", .indicatifPrésent(.thirdSingular)),
      ("boire", .indicatifPrésent(.thirdPlural)),
      ("croire", .indicatifPrésent(.firstSingular)),
      ("recevoir", .indicatifPrésent(.firstSingular)),
      ("ouvrir", .indicatifPrésent(.thirdSingular)),
      ("sentir", .indicatifPrésent(.firstSingular)),
      ("rendre", .indicatifPrésent(.thirdSingular)),
      ("choisir", .futurSimple(.firstSingular)),
      ("penser", .impératif(.secondSingular))
    ]
    return plan.map { spec in
      QuizQuestion(verb: Verb.verbForInfinitif(spec.infinitif), tense: spec.tense)
    }
  }

  // Write the correct answers for the fixture to Documents/screenshot_fixture_answers.json
  // so the driver can read and type them. The exported answer is the first of any
  // slash-separated alternates, which the quiz scores as a total match.
  private func exportFixtureAnswers(_ questions: [QuizQuestion]) {
    let payload = questions.map { question -> [String: String] in
      let conjugated = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: nil) ?? ""
      let answer = conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
      return [
        "infinitif": question.verb.infinitif,
        "tense": "\(question.tense)",
        "answer": answer
      ]
    }
    guard
      let data = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted),
      let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    else {
      return
    }
    try? data.write(to: docs.appendingPathComponent("screenshot_fixture_answers.json"))
  }
  #endif

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
    ChangeDifficultyTip.quizCompleted.sendDonation()
    gameCenter.reportScore(score)
    Current.analytics.signal(name: .quizCompletion, parameters: [
      ParameterKey.difficulty.rawValue: Current.settings.quizDifficulty.rawValue,
      ParameterKey.score.rawValue: "\(score)",
      ParameterKey.elapsedTime.rawValue: "\(elapsedTime)"
    ])
    quit()
  }

  private func announcePublishedProperties() {
    if UIAccessibility.isVoiceOverRunning {
      let announcementDelay = 1.0
      Task { @MainActor in
        try? await Task.sleep(for: .seconds(announcementDelay))
        let currentLocaleString: String
        let currentRegion = Locale.current.region?.identifier ?? "none"
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "none"
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
