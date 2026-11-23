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
  static let questionCount = 30

  private(set) var quizState = QuizState.notStarted
  private(set) var elapsedTime = 0
  private(set) var score = 0
  private(set) var correctnessScore = 0.0
  private(set) var difficulty = QuizDifficulty.regular
  private(set) var currentQuestionIndex = 0
  private(set) var questions: [QuizQuestion] = []
  private(set) var scope = QuizScope.allVerbs
  private(set) var quizResults: [QuizResult] = []
  var shouldShowResults = false
  /// A wrong or partly right answer, held on its question with the clock stopped until
  /// `continueAfterCorrection()`. A right answer advances at once.
  private(set) var correction: QuizCorrection?

  private var timer: Timer?
  private let gameCenter: GameCenter
  private var shouldShuffle = true
  private var generator: QuizRandomNumberGenerator
  private var liveActivity: LiveActivity?
  // The instant the timer started, handed to the Live Activity so its Lock Screen /
  // Dynamic Island timer animates via the OS rather than a per-answer frozen String.
  private var liveActivityStartDate = Date.now

  // Elapsed time for the Live Activity. Reuses Int.timeString so it matches the in-app
  // formatting past an hour (1:01:05, not 61:05) rather than diverging.
  var elapsedTimeString: String {
    elapsedTime.timeString
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

  /// A `seed` makes every quiz this instance builds repeatable, for tests.
  init(gameCenter: GameCenter, shouldShuffle: Bool = true, seed: UInt64? = nil) {
    self.gameCenter = gameCenter
    self.shouldShuffle = shouldShuffle
    generator = QuizRandomNumberGenerator(seeded: seed.map(SeededRandomNumberGenerator.init(seed:)))
  }

  func start(scope: QuizScope = .allVerbs) {
    self.scope = scope
    resetDecks()
    shuffleDecks()
    resetPublishedProperties()
    buildQuiz()
    guard !questions.isEmpty else {
      return
    }
    quizState = .inProgress
    announcePublishedProperties()
    if scope.startsLiveActivity {
      startLiveActivity()
    }
    Current.soundPlayer.play(Sound.randomGun)
    var startParameters = [
      ParameterKey.difficulty.rawValue: difficulty.rawValue,
      ParameterKey.source.rawValue: scope.source.rawValue
    ]
    if let collection = scope.collection {
      startParameters[ParameterKey.collection.rawValue] = collection.analyticsValue
    }
    Current.analytics.signal(name: .quizStart, parameters: startParameters)

    timer = Timer.scheduledTimer(
      withTimeInterval: 1.0,
      repeats: true,
      block: { [weak self] _ in
        // Scheduled from this @MainActor method, so the block fires on the main run loop;
        // assumeIsolated bridges that known main-actor callback back to main-actor isolation
        // to mutate elapsedTime synchronously (no per-tick Task hop, identical timing).
        MainActor.assumeIsolated {
          self?.clockTicked()
        }
      }
    )
  }

  func clockTicked() {
    guard correction == nil else {
      return
    }
    elapsedTime += 1
  }

  func quit() {
    Current.soundPlayer.play(Sound.randomSadTrombone)
    Current.analytics.signal(name: .quizQuit, parameters: [
      ParameterKey.difficulty.rawValue: difficulty.rawValue,
      ParameterKey.lastQuestionIndex.rawValue: "\(currentQuestionIndex)",
      ParameterKey.elapsedTime.rawValue: "\(elapsedTime)",
      ParameterKey.source.rawValue: scope.source.rawValue
    ])
    teardown()
  }

  // Pure teardown shared by quit() and completeQuiz(). Completing a quiz must NOT
  // route through quit(), which would emit a spurious .quizQuit signal and play the
  // sad-trombone quit sound over the completion applause.
  private func teardown() {
    timer?.invalidate()
    quizState = .notStarted
    correction = nil
    endLiveActivity()
  }

  private func startLiveActivity() {
    endLiveActivity()
    liveActivityStartDate = Date.now
    liveActivity = Current.liveActivities.start(
      attributes: QuizActivityAttributes(difficulty: difficulty.localizedDifficulty, totalQuestions: questions.count),
      initialState: QuizActivityAttributes.ContentState(
        currentQuestion: 1,
        score: 0,
        correctCount: 0,
        startDate: liveActivityStartDate,
        elapsedTime: "0:00",
        isFinished: false
      )
    )
  }

  private func updateLiveActivity(isFinished: Bool) {
    guard let liveActivity else {
      return
    }
    // The Lock Screen's timer counts from its start date and cannot pause, so after a held
    // correction the start date moves later by the time the clock stood still.
    liveActivityStartDate = Date.now.addingTimeInterval(-Double(elapsedTime))
    let state = QuizActivityAttributes.ContentState(
      currentQuestion: min(currentQuestionIndex + 1, questions.count),
      score: score,
      correctCount: correctCount,
      startDate: liveActivityStartDate,
      elapsedTime: elapsedTimeString,
      isFinished: isFinished
    )
    Current.liveActivities.update(liveActivity, state: state)
  }

  private func endLiveActivity() {
    guard let liveActivity else {
      return
    }
    let finalState = QuizActivityAttributes.ContentState(
      currentQuestion: currentQuestionIndex,
      score: score,
      correctCount: correctCount,
      startDate: liveActivityStartDate,
      elapsedTime: elapsedTimeString,
      isFinished: true
    )
    Current.liveActivities.end(liveActivity, finalState: finalState)
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
    personNumbers.shuffle(using: &generator)
    impératifPersonNumbers.shuffle(using: &generator)
    regularErs.shuffle(using: &generator)
    regularIrs.shuffle(using: &generator)
    regularRes.shuffle(using: &generator)
    bigThrees.shuffle(using: &generator)
    indicatifPrésentStemChangers.shuffle(using: &generator)
    êtreAuxiliaries.shuffle(using: &generator)
    irregularParticipePassés.shuffle(using: &generator)
    topThirties.shuffle(using: &generator)
    regularRadicauxFuturs.shuffle(using: &generator)
    irregularRadicauxFuturs.shuffle(using: &generator)
  }

  private func resetPublishedProperties() {
    elapsedTime = 0
    score = 0
    correctnessScore = 0.0
    // A scoped quiz asks Regular's mix whatever the setting, since Ridiculous is a fixed list.
    difficulty = scope.isRanked ? Current.settings.quizDifficulty : .regular
    currentQuestionIndex = 0
    questions = []
    quizResults = []
    correction = nil
  }

  private func buildQuiz() {
    if scope.verbs != nil {
      questions = scope.questions(using: &generator)
      return
    }

    #if DEBUG
    // Screenshot driver hook: when launched with `-CONJUGUER_QUIZ_FIXTURE screenshot`,
    // build a deterministic 30-question quiz and export the correct answers so the
    // screenshot driver can type them. See docs/screenshot_playbook.md.
    switch UserDefaults.standard.string(forKey: "CONJUGUER_QUIZ_FIXTURE") {
    case "screenshot":
      questions = generateScreenshotFixture()
      exportFixtureAnswers(questions)
      return
    case "grading":
      questions = generateGradingFixture()
      return
    case "frames":
      questions = generateFramesFixture()
      return
    case "corrections":
      questions = generateCorrectionsFixture()
      return
    default:
      break
    }
    #endif

    switch difficulty {
    case .regular:
      [regularErVerb, regularErVerb, regularIrVerb, regularIrVerb, regularReVerb, bigThreeVerb, indicatifPrésentStemChangerVerb].forEach {
        questions.append(question(verb: $0, tense: Tense.indicatifPrésent))
      }

      [regularErVerb, regularIrVerb, regularReVerb, bigThreeVerb, êtreAuxiliaryVerb, irregularParticipePasséVerb].forEach {
        questions.append(question(verb: $0, tense: Tense.passéComposé))
      }

      [regularErVerb, regularIrVerb, regularReVerb, bigThreeVerb].forEach {
        questions.append(question(verb: $0, tense: Tense.subjonctifPrésent))
      }

      for _ in 0 ..< 3 {
        questions.append(question(from: { topThirtyVerb }, tense: Tense.imparfait))
      }

      [regularRadicalFuturVerb, regularRadicalFuturVerb].forEach {
        questions.append(question(verb: $0, tense: Tense.futurSimple))
      }
      questions.append(question(from: { irregularRadicalFuturVerb }, tense: Tense.futurSimple))

      [regularRadicalFuturVerb, regularRadicalFuturVerb].forEach {
        questions.append(question(verb: $0, tense: Tense.conditionnelPrésent))
      }
      questions.append(question(from: { irregularRadicalFuturVerb }, tense: Tense.conditionnelPrésent))

      for _ in 0 ..< 3 {
        questions.append(question(from: { topThirtyVerb }, tense: Tense.impératif))
      }

      questions.append(question(from: { topThirtyVerb }, tense: { _ in .participePrésent }))

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
        let verb = Verb.verbForInfinitif(infinitif)
        if let personNumber = tense.personNumber, let constructor = tense.constructor {
          questions.append(question(verb: verb, tense: constructor, drawn: personNumber))
        } else {
          questions.append(QuizQuestion(verb: verb, tense: tense))
        }
      }
    }

    if shouldShuffle {
      questions.shuffle(using: &generator)
    }
  }

  /// The question of `tense` for `verb` in the next person from the deck, or in the next person
  /// after it that the verb's defect group has: falloir is asked only in the third-person
  /// singular. Only a verb without the whole tense, such as faillir in the impératif, gets an
  /// impossible question, so a pool that holds one draws through `question(from:tense:)`.
  private func question(verb: Verb, tense: (PersonNumber) -> Tense) -> QuizQuestion {
    let drawn = tense(.secondSingular).isImpératif ? impératifPersonNumber : personNumber
    return question(verb: verb, tense: tense, drawn: drawn)
  }

  private func question(verb: Verb, tense: (PersonNumber) -> Tense, drawn: PersonNumber) -> QuizQuestion {
    let persons = tense(.secondSingular).isImpératif ? PersonNumber.impératifPersonNumbers : PersonNumber.allCases
    let start = persons.firstIndex(of: drawn) ?? 0
    let rotated = persons[start...] + persons[..<start]
    let personNumber = rotated.first { verb.hasCell(tense($0)) } ?? drawn
    return QuizQuestion(verb: verb, tense: tense(personNumber))
  }

  private func question(from nextVerb: () -> Verb, tense: (PersonNumber) -> Tense) -> QuizQuestion {
    let maximumDraws = 50
    var verb = nextVerb()
    for _ in 1 ..< maximumDraws where !hasTense(verb, tense) {
      verb = nextVerb()
    }
    return question(verb: verb, tense: tense)
  }

  private func hasTense(_ verb: Verb, _ tense: (PersonNumber) -> Tense) -> Bool {
    let persons = tense(.secondSingular).isImpératif ? PersonNumber.impératifPersonNumbers : PersonNumber.allCases
    return persons.contains { verb.hasCell(tense($0)) }
  }

  #if DEBUG
  // A fixed, locale-independent 30-question plan for App Store screenshots. The
  // verbs are all common enough to exist in every build of verbs.xml, and the
  // tenses are picked to look representative (présent, passé composé, imparfait,
  // futur, conditionnel, impératif). See docs/screenshot_playbook.md.
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

  // Ten questions whose right answers the grading accepts only since it reads pronouns and
  // standard variants, repeated to thirty, unshuffled. The answers to type are in
  // docs/feature_architecture.md § Grading and Scoring.
  private func generateGradingFixture() -> [QuizQuestion] {
    let plan: [(infinitif: String, tense: Tense)] = [
      ("connaître", .indicatifPrésent(.thirdSingular)),
      ("parler", .indicatifPrésent(.firstSingular)),
      ("parler", .passéComposé(.firstSingular)),
      ("aller", .passéComposé(.firstPlural)),
      ("étiqueter", .indicatifPrésent(.firstSingular)),
      ("céder", .futurSimple(.firstSingular)),
      ("souvenir", .indicatifPrésent(.firstSingular)),
      ("souvenir", .impératif(.secondSingular)),
      ("être", .indicatifPrésent(.secondPlural)),
      ("plaire", .indicatifPrésent(.thirdSingular))
    ]
    let questions = plan.map { spec in
      QuizQuestion(verb: Verb.verbForInfinitif(spec.infinitif), tense: spec.tense)
    }
    return Array(repeating: questions, count: 3).flatMap { $0 }
  }

  // One question for each kind of answer frame, repeated to thirty, unshuffled. The frames are
  // listed in docs/feature_architecture.md § Quiz.
  private func generateFramesFixture() -> [QuizQuestion] {
    let plan: [(infinitif: String, tense: Tense)] = [
      ("parler", .indicatifPrésent(.firstSingular)),
      ("aimer", .indicatifPrésent(.firstSingular)),
      ("haïr France", .indicatifPrésent(.firstSingular)),
      ("parler", .indicatifPrésent(.thirdSingular)),
      ("parler", .futurSimple(.thirdPlural)),
      ("parler", .passéComposé(.firstSingular)),
      ("aller", .passéComposé(.firstPlural)),
      ("souvenir", .indicatifPrésent(.firstSingular)),
      ("absenter", .indicatifPrésent(.firstSingular)),
      ("souvenir", .passéComposé(.secondSingular)),
      ("souvenir", .impératif(.secondSingular)),
      ("finir", .impératif(.firstPlural)),
      ("aller", .impératifPassé(.secondPlural)),
      ("parler", .participePrésent),
      ("venir", .participePassé)
    ]
    let questions = plan.map { spec in
      QuizQuestion(verb: Verb.verbForInfinitif(spec.infinitif), tense: spec.tense)
    }
    return Array(repeating: questions, count: 2).flatMap { $0 }
  }

  // Eight questions, unshuffled, each with a wrong answer to type that shows a kind of marking.
  // The answers are listed in docs/feature_architecture.md § Quiz.
  private func generateCorrectionsFixture() -> [QuizQuestion] {
    let plan: [(infinitif: String, tense: Tense)] = [
      ("parler", .passéComposé(.firstSingular)),
      ("être", .indicatifPrésent(.secondPlural)),
      ("finir", .indicatifPrésent(.firstPlural)),
      ("aller", .futurSimple(.firstSingular)),
      ("venir", .passéComposé(.thirdSingular)),
      ("prendre", .indicatifPrésent(.thirdPlural)),
      ("souvenir", .indicatifPrésent(.firstSingular)),
      ("écrire", .imparfait(.secondSingular))
    ]
    return plan.map { spec in
      QuizQuestion(verb: Verb.verbForInfinitif(spec.infinitif), tense: spec.tense)
    }
  }

  // Write the correct answers for the fixture to Documents/screenshot_fixture_answers.json
  // so the driver can read and type them. The exported answer is the first of any
  // slash-separated alternates, which the quiz scores as a total match.
  //
  // Lowercased on the way out. Conjugator's mixed case is correct output, not a defect —
  // uppercase marks irregular characters for red highlighting (see ConjugationText.swift) —
  // but the answer field in a screenshot depicts what a *user* typed, and no human types
  // "SUIS". Scoring is unaffected: ConjugationResult.grade lowercases both sides, and the
  // app grades against its own in-memory value, never this file. Lowercasing must happen
  // here rather than in the driver, because shell `tr '[:upper:]' '[:lower:]'` works on
  // bytes and silently skips every accented capital.
  private func exportFixtureAnswers(_ questions: [QuizQuestion]) {
    let payload = questions.map { question -> [String: String] in
      let conjugated = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: nil) ?? ""
      let answer = conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated
      return [
        "infinitif": question.verb.infinitif,
        "tense": "\(question.tense)",
        "answer": answer.lowercased()
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
    guard quizState == .inProgress, correction == nil, currentQuestionIndex < questions.count else {
      return
    }
    let question = questions[currentQuestionIndex]
    let verb = question.verb
    let tense = question.tense
    let correctAnswers: String
    if let answers = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters) {
      correctAnswers = answers
    } else {
      // Unreachable with today's data; degrade to an empty correct answer (scored as
      // incorrect) so the quiz still advances instead of crashing mid-run.
      assertionFailure("Conjugation failed.")
      correctAnswers = ""
    }
    let grade = ConjugationResult.grade(proposedAnswer: proposedAnswer, correctAnswers: correctAnswers, verb: verb, tense: tense)
    let conjugationResult = grade.result
    if conjugationResult != .totalMatch || currentQuestionIndex != questions.count - 1 {
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
        actualAnswer: proposedAnswer,
        shownSpelling: grade.shownSpelling
      )
    )
    if conjugationResult == .totalMatch {
      advance()
    } else {
      correction = QuizCorrection(
        result: conjugationResult,
        difference: AnswerDifference.nearest(
          answer: proposedAnswer,
          correctAnswers: correctAnswers,
          tense: tense,
          isReflexive: verb.isReflexive
        )
      )
    }
  }

  func continueAfterCorrection() {
    guard correction != nil else {
      return
    }
    correction = nil
    advance()
  }

  private func advance() {
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
    if scope.isRanked {
      if score > Current.settings.bestScore {
        Current.settings.bestScore = score
      }
      ChangeDifficultyTip.quizCompleted.sendDonation()
      gameCenter.reportScore(score)
    }
    shouldShowResults = true
    Current.soundPlayer.play(Sound.randomApplause)
    Current.analytics.signal(name: .quizCompletion, parameters: [
      ParameterKey.difficulty.rawValue: difficulty.rawValue,
      ParameterKey.score.rawValue: "\(score)",
      ParameterKey.elapsedTime.rawValue: "\(elapsedTime)",
      ParameterKey.source.rawValue: scope.source.rawValue
    ])
    teardown()
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
        if let shownSpelling = quizResults.last?.shownSpelling {
          Utterer.utter(L.QuizView.alsoSpelledWithColon, localeString: currentLocaleString)
          Utterer.utter(shownSpelling.lowercased(), localeString: Utterer.frenchLocaleString)
        }
        Utterer.utter(L.QuizView.verbWithColon, localeString: currentLocaleString)
        Utterer.utter(question.verb.infinitif, localeString: Utterer.frenchLocaleString)
        Utterer.utter(L.QuizView.translationWithColon, localeString: currentLocaleString)
        Utterer.utter(question.verb.translation, localeString: Utterer.englishLocaleString)
        Utterer.utter(L.QuizView.pronounWithColon, localeString: currentLocaleString)
        Utterer.utter(question.tense.pronoun, localeString: Utterer.frenchLocaleString)
        if question.tense.isCompound {
          Utterer.utter(question.tense.gender, localeString: currentLocaleString)
        }
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

private extension Tense {
  var isImpératif: Bool {
    switch self {
    case .impératif, .impératifPassé:
      return true
    default:
      return false
    }
  }

  var constructor: ((PersonNumber) -> Tense)? {
    switch self {
    case .indicatifPrésent:
      return Tense.indicatifPrésent
    case .passéSimple:
      return Tense.passéSimple
    case .imparfait:
      return Tense.imparfait
    case .futurSimple:
      return Tense.futurSimple
    case .conditionnelPrésent:
      return Tense.conditionnelPrésent
    case .subjonctifPrésent:
      return Tense.subjonctifPrésent
    case .subjonctifImparfait:
      return Tense.subjonctifImparfait
    case .impératif:
      return Tense.impératif
    case .passéComposé:
      return Tense.passéComposé
    case .plusQueParfait:
      return Tense.plusQueParfait
    case .passéAntérieur:
      return Tense.passéAntérieur
    case .passéSurcomposé:
      return Tense.passéSurcomposé
    case .futurAntérieur:
      return Tense.futurAntérieur
    case .conditionnelPassé:
      return Tense.conditionnelPassé
    case .subjonctifPassé:
      return Tense.subjonctifPassé
    case .subjonctifPlusQueParfait:
      return Tense.subjonctifPlusQueParfait
    case .impératifPassé:
      return Tense.impératifPassé
    case .participePassé, .participePrésent, .radicalFutur:
      return nil
    }
  }
}

struct QuizCorrection: Equatable {
  let result: ConjugationResult
  let difference: AnswerDifference
}

private struct QuizRandomNumberGenerator: RandomNumberGenerator {
  var seeded: SeededRandomNumberGenerator?
  private var system = SystemRandomNumberGenerator()

  init(seeded: SeededRandomNumberGenerator?) {
    self.seeded = seeded
  }

  mutating func next() -> UInt64 {
    if seeded != nil {
      return seeded!.next()
    }
    return system.next()
  }
}
