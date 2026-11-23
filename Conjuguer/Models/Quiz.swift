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
  private(set) var level = QuizLevel.beginner
  private(set) var currentQuestionIndex = 0
  private(set) var questions: [QuizQuestion] = []
  private(set) var scope = QuizScope.allVerbs
  private(set) var quizResults: [QuizResult] = []
  var shouldShowResults = false
  /// A wrong answer, held on its question with the clock stopped until
  /// `continueAfterCorrection()`. A right answer advances at once.
  private(set) var correction: QuizCorrection?
  /// A slip that earned one more attempt at the current question, which waits for it with the
  /// clock running. A question gets one more attempt at most, whatever earned it.
  private(set) var firstAttempt: String?

  var isAwaitingSecondAttempt: Bool {
    firstAttempt != nil
  }

  private var timer: Timer?
  private let gameCenter: GameCenter
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

  /// Right on the first attempt. A right second attempt is counted apart.
  var correctCount: Int {
    quizResults.filter { $0.conjugationResult == .totalMatch }.count
  }

  var secondAttemptCount: Int {
    quizResults.filter { $0.conjugationResult == .secondAttemptMatch }.count
  }

  private var personNumbers = CyclingDeck(PersonNumber.allCases)
  private var impératifPersonNumbers = CyclingDeck(PersonNumber.impératifPersonNumbers)
  private var verbDecks = Dictionary(uniqueKeysWithValues: QuizVerbPool.allCases.map { ($0, CyclingDeck($0.infinitifs)) })

  /// A `seed` makes every quiz this instance builds repeatable, for tests.
  init(gameCenter: GameCenter, seed: UInt64? = nil) {
    self.gameCenter = gameCenter
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
      ParameterKey.level.rawValue: level.rawValue,
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
      ParameterKey.level.rawValue: level.rawValue,
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
    firstAttempt = nil
    endLiveActivity()
  }

  private func startLiveActivity() {
    endLiveActivity()
    liveActivityStartDate = Date.now
    liveActivity = Current.liveActivities.start(
      attributes: QuizActivityAttributes(level: level.localizedName, totalQuestions: questions.count),
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
    for pool in QuizVerbPool.allCases {
      verbDecks[pool]?.reset()
    }
  }

  private func shuffleDecks() {
    personNumbers.shuffle(using: &generator)
    impératifPersonNumbers.shuffle(using: &generator)
    for pool in QuizVerbPool.allCases {
      verbDecks[pool]?.shuffle(using: &generator)
    }
  }

  private func resetPublishedProperties() {
    elapsedTime = 0
    score = 0
    level = Current.settings.quizLevel
    currentQuestionIndex = 0
    questions = []
    quizResults = []
    correction = nil
    firstAttempt = nil
  }

  private func buildQuiz() {
    if scope.verbs != nil {
      questions = scope.questions(level: level, using: &generator)
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
    case "slips":
      questions = generateSlipsFixture()
      return
    case "levels":
      questions = generateLevelsFixture()
      return
    default:
      break
    }
    #endif

    let slots = level.slots
    for _ in 0 ..< scope.questionCount {
      guard let slot = QuizTenseSlot.drawWeighted(from: slots, using: &generator) else {
        break
      }
      questions.append(question(of: slot))
    }
  }

  /// The question of `tense` for `verb` in the next person from the deck, or in the next person
  /// after it that the verb's defect group has: falloir is asked only in the third-person
  /// singular. Only a verb without the whole tense, such as faillir in the impératif, gets an
  /// impossible question, so `question(of:)` draws past it.
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

  private func question(of slot: QuizTenseSlot) -> QuizQuestion {
    let pool = slot.verbPools.randomElement(using: &generator) ?? .topThirty
    let maximumDraws = 50
    var verb = nextVerb(from: pool)
    for _ in 1 ..< maximumDraws where !slot.cells.contains(where: verb.hasCell) {
      verb = nextVerb(from: pool)
    }
    guard let constructor = slot.constructor else {
      return QuizQuestion(verb: verb, tense: slot.cells.first ?? .participePassé)
    }
    return question(verb: verb, tense: constructor)
  }

  private func nextVerb(from pool: QuizVerbPool) -> Verb {
    Verb.verbForInfinitif(verbDecks[pool]?.next() ?? "être")
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

  // Twelve questions, unshuffled, each with a wrong answer to type. The answers, and which of
  // them earn one more try, are listed in docs/feature_architecture.md § Quiz.
  private func generateSlipsFixture() -> [QuizQuestion] {
    let plan: [(infinitif: String, tense: Tense)] = [
      ("être", .indicatifPrésent(.secondPlural)),
      ("acheter", .indicatifPrésent(.firstSingular)),
      ("finir", .futurSimple(.firstPlural)),
      ("placer", .passéSimple(.thirdSingular)),
      ("parler", .passéComposé(.firstSingular)),
      ("aller", .passéComposé(.firstSingular)),
      ("prendre", .indicatifPrésent(.thirdPlural)),
      ("parler", .participePassé),
      ("prendre", .subjonctifImparfait(.thirdSingular)),
      ("avoir", .subjonctifImparfait(.thirdSingular)),
      ("venir", .indicatifPrésent(.thirdSingular)),
      ("vouloir", .indicatifPrésent(.firstSingular))
    ]
    return plan.map { spec in
      QuizQuestion(verb: Verb.verbForInfinitif(spec.infinitif), tense: spec.tense)
    }
  }

  // One question in each tense that only Advanced asks, unshuffled. The answers are listed in
  // docs/feature_architecture.md § Quiz.
  private func generateLevelsFixture() -> [QuizQuestion] {
    let plan: [(infinitif: String, tense: Tense)] = [
      ("finir", .futurAntérieur(.firstPlural)),
      ("venir", .subjonctifPassé(.secondSingular)),
      ("prendre", .passéSimple(.thirdPlural)),
      ("être", .subjonctifImparfait(.thirdSingular)),
      ("partir", .subjonctifPlusQueParfait(.firstSingular)),
      ("voir", .passéAntérieur(.thirdSingular)),
      ("parler", .passéSurcomposé(.firstSingular)),
      ("rentrer", .impératifPassé(.secondPlural))
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
    let isSecondAttempt = firstAttempt != nil
    if grade.result == .noMatch, !isSecondAttempt, AnswerSlip.isSlip(proposedAnswer: proposedAnswer, correctAnswers: correctAnswers, verb: verb, tense: tense) {
      firstAttempt = proposedAnswer
      Current.soundPlayer.play(.chirp)
      announceSecondAttempt()
      return
    }

    let conjugationResult: ConjugationResult = grade.result == .totalMatch && isSecondAttempt ? .secondAttemptMatch : grade.result
    if conjugationResult == .noMatch || currentQuestionIndex != questions.count - 1 {
      Current.soundPlayer.play(conjugationResult.sound)
    }
    score += conjugationResult.score
    quizResults.append(
      QuizResult(
        infinitif: verb.infinitifWithPossibleExtraLetters,
        tense: tense,
        conjugationResult: conjugationResult,
        correctAnswer: correctAnswers,
        actualAnswer: proposedAnswer,
        shownSpelling: grade.shownSpelling,
        firstAttempt: firstAttempt
      )
    )
    firstAttempt = nil
    if conjugationResult == .noMatch {
      correction = QuizCorrection(
        difference: AnswerDifference.nearest(
          answer: proposedAnswer,
          correctAnswers: correctAnswers,
          tense: tense,
          isReflexive: verb.isReflexive
        )
      )
    } else {
      advance()
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
    if scope.isRanked {
      if score > Current.settings.bestScore {
        Current.settings.bestScore = score
      }
      ChangeLevelTip.quizCompleted.sendDonation()
      gameCenter.reportScore(score)
    }
    shouldShowResults = true
    Current.soundPlayer.play(Sound.randomApplause)
    Current.analytics.signal(name: .quizCompletion, parameters: [
      ParameterKey.level.rawValue: level.rawValue,
      ParameterKey.score.rawValue: "\(score)",
      ParameterKey.elapsedTime.rawValue: "\(elapsedTime)",
      ParameterKey.source.rawValue: scope.source.rawValue
    ])
    teardown()
  }

  private var currentLocaleString: String {
    let currentRegion = Locale.current.region?.identifier ?? "none"
    let currentLanguage = Locale.current.language.languageCode?.identifier ?? "none"
    return currentLanguage == "fr" ? Utterer.frenchLocaleString : currentLanguage + "-" + currentRegion
  }

  // The first attempt stays in the field for the learner to edit, and VoiceOver's focus with it.
  private func announceSecondAttempt() {
    guard UIAccessibility.isVoiceOverRunning else {
      return
    }
    Utterer.utter(L.QuizView.almost, localeString: currentLocaleString)
  }

  private func announcePublishedProperties() {
    if UIAccessibility.isVoiceOverRunning {
      let announcementDelay = 1.0
      Task { @MainActor in
        try? await Task.sleep(for: .seconds(announcementDelay))
        let currentLocaleString = self.currentLocaleString
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
}

struct QuizCorrection: Equatable {
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
