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
  /// A round's questions, re-asks not counted. Ten More adds another round to the session.
  static let questionCount = 10
  /// How many questions come between a miss and its re-ask, fewer near a round's end.
  static let reaskGap = 3

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
  /// A slip or a diagnosed error that earned one more attempt at the current question, which waits
  /// for it with the clock running. A question gets one more attempt at most, whatever earned it.
  private(set) var firstAttempt: String?
  /// What was wrong with `firstAttempt`, nil for a slip.
  private(set) var firstAttemptDiagnosis: AnswerDiagnosis?
  private(set) var firstAttemptRecognition: RecognitionGrade?

  private(set) var roundCount = 0
  private var roundFirstResultIndex = 0

  /// The last answer of this round, whose mark the next question shows. A round of Ten More
  /// starts with none.
  var lastRoundResult: QuizResult? {
    quizResults.count > roundFirstResultIndex ? quizResults.last : nil
  }

  var isAwaitingSecondAttempt: Bool {
    firstAttempt != nil
  }

  /// The request for one more try: the diagnosis's line, or "Almost!" for a slip.
  var secondAttemptPrompt: String {
    if let firstAttemptRecognition {
      return firstAttemptRecognition.line + " " + L.QuizView.tryOnceMore
    }
    guard let firstAttemptDiagnosis else {
      return L.QuizView.almost
    }
    return firstAttemptDiagnosis.line + " " + L.QuizView.tryOnceMore
  }

  private var timer: Timer?
  private let gameCenter: GameCenter
  private var generator: QuizRandomNumberGenerator
  private var liveActivity: LiveActivity?
  // The instant the timer started, handed to the Live Activity so its Lock Screen /
  // Dynamic Island timer animates via the OS rather than a per-answer frozen String.
  private var liveActivityStartDate = Date.now
  private var sessionStartDate = Date.now
  private let now: () -> Date
  /// Names this quiz's entry in `QuizAbandonment`, since a quiz in a sheet can run beside the Quiz
  /// tab's.
  private let abandonmentID = UUID().uuidString

  var showsClock: Bool {
    Current.settings.quizClock == .show
  }

  // Elapsed time for the Live Activity, nil while the clock is hidden. Reuses Int.timeString so
  // it matches the in-app formatting past an hour (1:01:05, not 61:05) rather than diverging.
  var elapsedTimeString: String? {
    showsClock ? elapsedTime.timeString : nil
  }

  var currentQuestion: QuizQuestion? {
    questions.indices.contains(currentQuestionIndex) ? questions[currentQuestionIndex] : nil
  }

  /// The session's questions, re-asks not counted.
  var sessionQuestionCount: Int {
    questions.filter { !$0.isReask }.count
  }

  /// Right on the first attempt, re-asks not counted. A right second attempt is counted apart.
  var correctCount: Int {
    quizResults.filter { !$0.isReask && $0.conjugationResult == .totalMatch }.count
  }

  var secondAttemptCount: Int {
    quizResults.filter { !$0.isReask && $0.conjugationResult == .secondAttemptMatch }.count
  }

  var reaskCount: Int {
    quizResults.filter(\.isReask).count
  }

  var reaskCorrectCount: Int {
    quizResults.filter { $0.isReask && $0.conjugationResult != .noMatch }.count
  }

  /// The first round's points without its re-asks, so that every ranked score has the same
  /// ceiling, 100. Ten More's points are the learner's alone.
  var firstRoundScore: Int {
    quizResults.filter { !$0.isReask }.prefix(scope.questionCount).reduce(0) { $0 + $1.points }
  }

  /// Whether the results offer Ten More. Test Me's three questions do not continue, and Review or
  /// My Mistakes continues only while the record has an item the session has not asked.
  var canContinue: Bool {
    guard shouldShowResults, quizState == .notStarted, scope.continues, !questions.isEmpty else {
      return false
    }
    guard let session = scope.recordSession else {
      return true
    }
    let asked = askedItemKeys
    return session.items(from: Current.practice, at: now()).contains { $0.isAskable && !asked.contains($0.key) }
  }

  /// The record's items this session has asked, which a Review or My Mistakes round skips.
  private var askedItemKeys: Set<String> {
    Set(questions.map { PracticeItem.exercised(by: $0.tense, of: $0.verb).key })
  }

  private var personNumbers = CyclingDeck(PersonNumber.allCases)
  private var impératifPersonNumbers = CyclingDeck(PersonNumber.impératifPersonNumbers)

  /// A `seed` makes every quiz this instance builds repeatable, for tests, and `now` lets them set
  /// the time a quiz takes.
  init(gameCenter: GameCenter, seed: UInt64? = nil, now: @escaping () -> Date = { Date.now }) {
    self.gameCenter = gameCenter
    self.now = now
    generator = QuizRandomNumberGenerator(seeded: seed.map(SeededRandomNumberGenerator.init(seed:)))
  }

  func start(scope: QuizScope = .allVerbs) {
    self.scope = scope
    resetDecks()
    shuffleDecks()
    resetPublishedProperties()
    questions = drawQuestions()
    guard !questions.isEmpty else {
      return
    }
    roundCount = 1
    sessionStartDate = now()
    quizState = .inProgress
    announcePublishedProperties()
    startLiveActivity()
    recordProgress()
    Current.soundPlayer.play(Sound.randomGun)
    var startParameters = [
      ParameterKey.level.rawValue: level.rawValue,
      ParameterKey.source.rawValue: scope.source.rawValue
    ]
    if let collection = scope.namedCollection {
      startParameters[ParameterKey.collection.rawValue] = collection.analyticsValue
    }
    if let custom = scope.custom {
      startParameters[ParameterKey.customChoice.rawValue] = custom.choiceParameter
    }
    Current.analytics.signal(name: .quizStart, parameters: startParameters)
    startTimer()
  }

  /// Ten More: another round in the same session, offered by the results. The score, the clock,
  /// and the questions so far carry on, and the new questions are a fresh draw, so that every
  /// round has the default quiz's mix of verbs.
  func continueSession() {
    guard canContinue else {
      return
    }
    let more = drawQuestions()
    guard !more.isEmpty else {
      return
    }
    questions += more
    roundCount += 1
    roundFirstResultIndex = quizResults.count
    shouldShowResults = false
    correction = nil
    firstAttempt = nil
    firstAttemptDiagnosis = nil
    firstAttemptRecognition = nil
    quizState = .inProgress
    announcePublishedProperties()
    startLiveActivity()
    recordProgress()
    Current.soundPlayer.play(Sound.randomGun)
    startTimer()
  }

  private func startTimer() {
    timer?.invalidate()
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

  /// The question reached, counted from one, re-asks not counted, which `quizQuit` and
  /// `quizAbandon` send as an index. A re-ask is inserted only after a wrong answer, so a position
  /// that counted re-asks would tell how many answers were wrong, and no signal carries accuracy.
  private var questionReached: Int {
    questions.prefix(min(currentQuestionIndex + 1, questions.count)).filter { !$0.isReask }.count
  }

  private var lastQuestionIndex: Int {
    max(questionReached - 1, 0)
  }

  private var durationBand: String {
    AnalyticsBand.quizDuration(now().timeIntervalSince(sessionStartDate))
  }

  func quit() {
    Current.soundPlayer.play(Sound.randomSadTrombone)
    var parameters = [
      ParameterKey.level.rawValue: level.rawValue,
      ParameterKey.duration.rawValue: durationBand,
      ParameterKey.source.rawValue: scope.source.rawValue
    ]
    if scope.sendsQuestionCounts {
      parameters[ParameterKey.lastQuestionIndex.rawValue] = "\(lastQuestionIndex)"
    }
    Current.analytics.signal(name: .quizQuit, parameters: parameters)
    teardown()
  }

  // Pure teardown shared by quit() and completeRound(). Completing a round must NOT
  // route through quit(), which would emit a spurious .quizQuit signal and play the
  // sad-trombone quit sound over the completion applause.
  private func teardown() {
    timer?.invalidate()
    quizState = .notStarted
    correction = nil
    firstAttempt = nil
    firstAttemptDiagnosis = nil
    firstAttemptRecognition = nil
    endLiveActivity()
    QuizAbandonment.clear(id: abandonmentID, getterSetter: Current.getterSetter)
  }

  private func recordProgress() {
    QuizAbandonment.record(
      QuizAbandonment.Entry(level: level.rawValue, source: scope.source.rawValue, lastQuestionIndex: scope.sendsQuestionCounts ? lastQuestionIndex : nil),
      id: abandonmentID,
      getterSetter: Current.getterSetter
    )
  }

  private func startLiveActivity() {
    endLiveActivity()
    guard scope.startsLiveActivity else {
      return
    }
    liveActivity = Current.liveActivities.start(
      attributes: QuizActivityAttributes(level: scope.sessionTitle ?? level.localizedName),
      initialState: liveActivityState(isFinished: false)
    )
  }

  private func updateLiveActivity() {
    guard let liveActivity else {
      return
    }
    Current.liveActivities.update(liveActivity, state: liveActivityState(isFinished: false))
  }

  private func endLiveActivity() {
    guard let liveActivity else {
      return
    }
    Current.liveActivities.end(liveActivity, finalState: liveActivityState(isFinished: true))
    self.liveActivity = nil
  }

  private func liveActivityState(isFinished: Bool) -> QuizActivityAttributes.ContentState {
    if !isFinished {
      // The Lock Screen's timer counts from its start date and cannot pause, so after a held
      // correction the start date moves later by the time the clock stood still.
      liveActivityStartDate = Date.now.addingTimeInterval(-Double(elapsedTime))
    }
    return QuizActivityAttributes.ContentState(
      currentQuestion: isFinished ? min(currentQuestionIndex, questions.count) : min(currentQuestionIndex + 1, questions.count),
      totalQuestions: questions.count,
      score: score,
      correctCount: correctCount,
      startDate: showsClock ? liveActivityStartDate : nil,
      elapsedTime: elapsedTimeString,
      isFinished: isFinished
    )
  }

  private func resetDecks() {
    personNumbers.reset()
    impératifPersonNumbers.reset()
  }

  private func shuffleDecks() {
    personNumbers.shuffle(using: &generator)
    impératifPersonNumbers.shuffle(using: &generator)
  }

  private func resetPublishedProperties() {
    elapsedTime = 0
    score = 0
    level = scope.level ?? Current.settings.quizLevel
    currentQuestionIndex = 0
    roundCount = 0
    roundFirstResultIndex = 0
    questions = []
    quizResults = []
    correction = nil
    firstAttempt = nil
    firstAttemptDiagnosis = nil
    firstAttemptRecognition = nil
    shouldShowResults = false
  }

  /// A round's questions, a fixture's in DEBUG, which Ten More repeats.
  private func drawQuestions() -> [QuizQuestion] {
    if let session = scope.modelPractice {
      return QuizDraw.modelPracticeQuestions(for: session, record: Current.practice.record, asked: questions, using: &generator)
    }

    if scope.isVerbEssentials {
      #if DEBUG
      if UserDefaults.standard.string(forKey: "CONJUGUER_QUIZ_FIXTURE") == "essentials" {
        return generateVerbEssentialsFixture()
      }
      #endif
      return QuizDraw.verbEssentialsSteps(
        verbs: scope.verbs ?? QuizDraw.verbs(in: scope.band(at: level)),
        count: QuizScope.verbEssentialsVerbCount,
        asked: Set(questions.map(\.verb.id)),
        using: &generator
      )
      .flatMap { $0 }
    }

    if scope.isRecognition {
      return recognitionQuestions()
    }

    if scope.isSentences {
      return sentenceQuestions()
    }

    if scope.verbs != nil {
      return scope.questions(level: level, using: &generator)
    }

    if let session = scope.recordSession {
      return QuizDraw.sessionQuestions(
        for: session.items(from: Current.practice, at: now()),
        band: scope.band(at: level),
        excluded: askedItemKeys,
        limit: scope.questionCount,
        using: &generator
      )
    }

    #if DEBUG
    if scope.custom == nil, let fixture = fixtureQuestions() {
      return fixture
    }
    #endif

    let slots = scope.slots(at: level)
    let band = scope.band(at: level)
    let due = scope.mixesDueItems
      ? QuizDraw.dueQuestions(for: Current.practice.dueItems(at: now()), slots: slots, band: band, using: &generator)
      : []
    let asked = Set((questions + due).map(\.verb.id))
    let drawn = QuizDraw.questions(slots: slots, band: band, count: scope.questionCount - due.count, asked: asked, using: &generator)
      .map(question(of:))
    return QuizDraw.mixing(due, into: drawn, using: &generator)
  }

  /// The default quiz's draw from the level's tenses and band, with no due items, so that the
  /// prompts are the conjugations the learner is asked to produce at the level.
  private func recognitionQuestions() -> [QuizQuestion] {
    #if DEBUG
    if UserDefaults.standard.string(forKey: "CONJUGUER_QUIZ_FIXTURE") == "recognition" {
      return generateRecognitionFixture()
    }
    #endif
    let slots = scope.slots(at: level)
    return QuizDraw.questions(slots: slots, band: scope.band(at: level), count: scope.questionCount, asked: Set(questions.map(\.verb.id)), using: &generator)
      .map(question(of:))
      .map { QuizQuestion.recognizing($0, slots: slots) }
  }

  private func sentenceQuestions() -> [QuizQuestion] {
    #if DEBUG
    if UserDefaults.standard.string(forKey: "CONJUGUER_QUIZ_FIXTURE") == "sentences" {
      return generateSentencesFixture()
    }
    #endif
    return QuizDraw.sentences(
      from: GapSentences.askable(at: level),
      count: scope.questionCount,
      excluded: Set(questions.compactMap(\.sentence?.id)),
      using: &generator
    )
    .compactMap(QuizQuestion.init(sentence:))
  }

  #if DEBUG
  private func fixtureQuestions() -> [QuizQuestion]? {
    // Screenshot driver hook: when launched with `-CONJUGUER_QUIZ_FIXTURE screenshot`,
    // build a deterministic 30-question quiz and export the correct answers so the
    // screenshot driver can type them. See docs/screenshot_playbook.md.
    switch UserDefaults.standard.string(forKey: "CONJUGUER_QUIZ_FIXTURE") {
    case "screenshot":
      let fixture = generateScreenshotFixture()
      exportFixtureAnswers(fixture)
      return fixture
    case "grading":
      return generateGradingFixture()
    case "frames":
      return generateFramesFixture()
    case "corrections":
      return generateCorrectionsFixture()
    case "slips":
      return generateSlipsFixture()
    case "levels":
      return generateLevelsFixture()
    case "diagnoses":
      return generateDiagnosesFixture()
    default:
      return nil
    }
  }
  #endif

  /// The question of `tense` for `verb` in the next person from the deck, or in the next person
  /// after it that the verb's defect group has: falloir is asked only in the third-person
  /// singular. `QuizDraw` never draws a verb without the whole tense, such as faillir in the
  /// impératif.
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

  private func question(of drawn: QuizDrawnQuestion) -> QuizQuestion {
    guard let constructor = drawn.slot.constructor else {
      return QuizQuestion(verb: drawn.verb, tense: drawn.slot.cells.first ?? .participePassé)
    }
    return question(verb: drawn.verb, tense: constructor)
  }

  #if DEBUG
  // A fixed, locale-independent ten-question plan for App Store screenshots. The
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
      ("manger", .imparfait(.firstPlural))
    ]
    return plan.map { spec in
      QuizQuestion(verb: Verb.verbForInfinitif(spec.infinitif), tense: spec.tense)
    }
  }

  // Eleven questions whose right answers the grading accepts only since it reads pronouns and
  // standard variants, unshuffled. The answers to type are in
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
      ("plaire", .indicatifPrésent(.thirdSingular)),
      ("passer", .passéComposé(.firstSingular))
    ]
    return plan.map { spec in
      QuizQuestion(verb: Verb.verbForInfinitif(spec.infinitif), tense: spec.tense)
    }
  }

  // One question for each kind of answer frame, unshuffled. The frames are
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
    return plan.map { spec in
      QuizQuestion(verb: Verb.verbForInfinitif(spec.infinitif), tense: spec.tense)
    }
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

  // One question for each class of diagnosis, unshuffled, each with a wrong answer to type. The
  // answers are listed in docs/feature_architecture.md § Quiz.
  private func generateDiagnosesFixture() -> [QuizQuestion] {
    let plan: [(key: String, tense: Tense)] = [
      ("aller", .passéComposé(.firstSingular)),
      ("parler", .passéComposé(.firstSingular)),
      ("venir", .passéComposé(.thirdSingular)),
      ("souvenir", .passéComposé(.firstSingular)),
      ("monter", .passéComposé(.thirdSingular)),
      ("partir", .passéComposé(.firstPlural)),
      ("sortir exit", .indicatifPrésent(.thirdPlural)),
      ("manger", .indicatifPrésent(.firstPlural)),
      ("appeler", .indicatifPrésent(.firstSingular)),
      ("venir", .futurSimple(.firstSingular)),
      ("faire", .indicatifPrésent(.secondPlural)),
      ("finir", .indicatifPrésent(.secondPlural)),
      ("venir", .passéSimple(.thirdSingular)),
      ("prendre", .participePassé),
      ("finir", .indicatifPrésent(.thirdPlural))
    ]
    return plan.map { spec in
      QuizQuestion(verb: Verb.verbForInfinitif(spec.key), tense: spec.tense)
    }
  }

  // Five verbs for Verb Essentials, used only when it is started: venir (être, an irregular
  // futur), se souvenir (pronominal), faire (an irregular futur), prendre, and aller (être, and a
  // futur on another stem). The wrong answers worth typing are listed in
  // docs/feature_architecture.md § Verb Essentials.
  private func generateVerbEssentialsFixture() -> [QuizQuestion] {
    ["venir", "souvenir", "faire", "prendre", "aller"].flatMap { infinitif in
      QuizDraw.verbEssentialsStep(verb: Verb.verbForInfinitif(infinitif))
    }
  }

  // Ten prompts for Name the Conjugation, used only once it is started, each offered every tense
  // of Advanced, most with more than one right answer: fûmes (être alone), suis (être's je, or
  // suivre's je, tu, and impératif), vis (vivre's or voir's), parle (five cells of parler), fait
  // (the participe passé or the présent), est allée or est allé (the setting's gender), me
  // souviens, souviens-toi, finissons (the présent or the impératif), and avions pris. The answers
  // worth trying are listed in docs/feature_architecture.md § Name the Conjugation.
  private func generateRecognitionFixture() -> [QuizQuestion] {
    let plan: [(infinitif: String, tense: Tense)] = [
      ("être", .passéSimple(.firstPlural)),
      ("suivre", .indicatifPrésent(.firstSingular)),
      ("vivre", .indicatifPrésent(.firstSingular)),
      ("parler", .subjonctifPrésent(.thirdSingular)),
      ("faire", .participePassé),
      ("aller", .passéComposé(.thirdSingular)),
      ("souvenir", .indicatifPrésent(.firstSingular)),
      ("souvenir", .impératif(.secondSingular)),
      ("finir", .indicatifPrésent(.firstPlural)),
      ("prendre", .plusQueParfait(.firstPlural))
    ]
    return plan.map { spec in
      QuizQuestion.recognizing(QuizQuestion(verb: Verb.verbForInfinitif(spec.infinitif), tense: spec.tense), slots: QuizLevel.advanced.slots)
    }
  }

  // Phrases à trous, used only once it is started: one sentence for each kind of frame. The
  // answers worth typing are listed in docs/feature_architecture.md § Phrases à trous.
  private func generateSentencesFixture() -> [QuizQuestion] {
    let ids = Self.sentencesFixtureIDs
    let sentences = GapSentences.all.filter { ids.contains($0.id) }
    return ids.compactMap { id in
      sentences.first { $0.id == id }.flatMap(QuizQuestion.init(sentence:))
    }
  }

  static let sentencesFixtureIDs = [
    "venir.impératif.1",
    "aller.passéComposé.1",
    "avoir.passéComposé.1",
    "aller.subjonctifPrésent.1",
    "prendre.participePrésent.1",
    "écouter.impératif.1",
    "falloir.passéComposé.1",
    "faire.passéSimple.1",
    "venir.passéComposé.1",
    "rester.passéComposé.1"
  ]

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
    let pronounGender = question.pronounGender
    let correctAnswers: String
    if let answers = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: pronounGender) {
      correctAnswers = answers
    } else {
      // Unreachable with today's data; degrade to an empty correct answer (scored as
      // incorrect) so the quiz still advances instead of crashing mid-run.
      assertionFailure("Conjugation failed.")
      correctAnswers = ""
    }
    let grade = ConjugationResult.grade(proposedAnswer: proposedAnswer, correctAnswers: correctAnswers, verb: verb, tense: tense)
    let isSecondAttempt = firstAttempt != nil
    let diagnosis = grade.result == .noMatch
      ? AnswerDiagnosis.diagnose(proposedAnswer: proposedAnswer, correctAnswers: correctAnswers, verb: verb, tense: tense, pronounGender: pronounGender)
      : nil
    // A diagnosis is checked before a slip, since it says more: suis allé for suis allée is one
    // letter off, and the agreement is what to fix.
    if grade.result == .noMatch, !isSecondAttempt,
      diagnosis != nil || AnswerSlip.isSlip(proposedAnswer: proposedAnswer, correctAnswers: correctAnswers, verb: verb, tense: tense) {
      firstAttempt = proposedAnswer
      firstAttemptDiagnosis = diagnosis
      Current.soundPlayer.play(.chirp)
      announceSecondAttempt()
      return
    }

    let conjugationResult: ConjugationResult = grade.result == .totalMatch && isSecondAttempt ? .secondAttemptMatch : grade.result
    if conjugationResult == .noMatch || currentQuestionIndex != questions.count - 1 {
      Current.soundPlayer.play(conjugationResult.sound)
    }
    let result = QuizResult(
      infinitif: verb.infinitifWithPossibleExtraLetters,
      tense: tense,
      conjugationResult: conjugationResult,
      correctAnswer: correctAnswers,
      actualAnswer: proposedAnswer,
      shownSpelling: grade.shownSpelling,
      firstAttempt: firstAttempt,
      isReask: question.isReask,
      pronounGender: pronounGender,
      sentence: question.sentence?.completed,
      verbKey: verb.dictionaryKey
    )
    // Each final answer goes into the practice record as it is given, so that a quiz quit after
    // six questions has still practiced six. A slip's right second attempt counts as right.
    Current.practice.recordAnswer(verb: verb, tense: tense, isCorrect: conjugationResult != .noMatch, at: now())
    finish(result) { willBeReasked in
      QuizCorrection(
        difference: AnswerDifference.nearest(
          answer: proposedAnswer,
          correctAnswers: correctAnswers,
          tense: tense,
          isReflexive: verb.isReflexive
        ),
        diagnosis: diagnosis,
        willBeReasked: willBeReasked
      )
    }
  }

  /// A Name the Conjugation answer. An answer with any part right earns one more try at half
  /// points, its line saying which parts to check; otherwise it goes to the correction, which
  /// lists every right answer. Recognizing fûmes is not evidence of producing it, so the answer
  /// moves nothing in the practice record.
  func submitRecognition(_ answer: RecognitionAnswer) {
    guard
      quizState == .inProgress,
      correction == nil,
      currentQuestionIndex < questions.count,
      let recognition = questions[currentQuestionIndex].recognition
    else {
      return
    }
    let question = questions[currentQuestionIndex]
    let grade = recognition.grade(answer)
    let isSecondAttempt = firstAttempt != nil
    if grade.earnsSecondAttempt, !isSecondAttempt {
      firstAttempt = answer.summary
      firstAttemptRecognition = grade
      Current.soundPlayer.play(.chirp)
      announceSecondAttempt()
      return
    }

    let conjugationResult: ConjugationResult = grade.isCorrect ? (isSecondAttempt ? .secondAttemptMatch : .totalMatch) : .noMatch
    if conjugationResult == .noMatch || currentQuestionIndex != questions.count - 1 {
      Current.soundPlayer.play(conjugationResult.sound)
    }
    let result = QuizResult(
      infinitif: question.verb.infinitifWithPossibleExtraLetters,
      tense: question.tense,
      conjugationResult: conjugationResult,
      correctAnswer: recognition.answerLines.joined(separator: "\n"),
      actualAnswer: answer.summary,
      shownSpelling: grade.isCorrect ? recognition.preferredSpelling(of: answer.infinitif) : nil,
      firstAttempt: firstAttempt,
      isReask: question.isReask,
      pronounGender: question.verb.pronounGender,
      recognitionPrompt: recognition.prompt,
      verbKey: question.verb.dictionaryKey
    )
    finish(result) { willBeReasked in
      QuizCorrection(
        difference: AnswerDifference.between(
          given: AnswerSpelling.normalized(answer.infinitif),
          expected: recognition.nearestInfinitive(to: answer.infinitif)
        ),
        willBeReasked: willBeReasked,
        recognitionAnswer: answer,
        recognitionGrade: grade
      )
    }
  }

  private func finish(_ result: QuizResult, correction makeCorrection: (_ willBeReasked: Bool) -> QuizCorrection) {
    let question = questions[currentQuestionIndex]
    score += result.points
    quizResults.append(result)
    firstAttempt = nil
    firstAttemptDiagnosis = nil
    firstAttemptRecognition = nil
    guard result.conjugationResult == .noMatch else {
      advance()
      return
    }
    // A re-ask is not asked a third time, whatever its answer, so that one stubborn question
    // cannot fill a round.
    let willBeReasked = !question.isReask
    if willBeReasked {
      let placement = Self.reaskPlacement(of: currentQuestionIndex, in: questions)
      questions.insert(question.reasked(stepID: placement.stepID), at: placement.position)
    }
    correction = makeCorrection(willBeReasked)
  }

  func continueAfterCorrection() {
    guard correction != nil else {
      return
    }
    correction = nil
    advance()
  }

  /// Where a question missed at `index` returns: after `reaskGap` others, or at the round's end,
  /// before the results, when fewer remain.
  static func reaskPosition(after index: Int, in count: Int) -> Int {
    min(index + 1 + reaskGap, count)
  }

  private func advance() {
    currentQuestionIndex += 1

    if currentQuestionIndex == questions.count {
      completeRound()
    } else {
      announcePublishedProperties()
      updateLiveActivity()
      recordProgress()
    }
  }

  /// Each round ends in its results and a `quizCompletion`, whose question count shows how far
  /// Ten More carried the session. Only the first round ranks.
  private func completeRound() {
    if roundCount == 1, scope.isRanked {
      Current.settings.recordScore(firstRoundScore, at: level)
      ChangeLevelTip.quizCompleted.sendDonation()
      gameCenter.reportScore(firstRoundScore, level: level)
    }
    shouldShowResults = true
    Current.soundPlayer.play(Sound.randomApplause)
    var parameters = [
      ParameterKey.level.rawValue: level.rawValue,
      ParameterKey.duration.rawValue: durationBand,
      ParameterKey.source.rawValue: scope.source.rawValue
    ]
    if scope.sendsQuestionCounts {
      parameters[ParameterKey.questionCount.rawValue] = "\(sessionQuestionCount)"
    }
    Current.analytics.signal(name: .quizCompletion, parameters: parameters)
    Current.practice.recordResult(LastQuizResult(quiz: self, date: now()))
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
    Utterer.utter(secondAttemptPrompt, localeString: currentLocaleString)
  }

  private func announcePublishedProperties() {
    if UIAccessibility.isVoiceOverRunning {
      let announcementDelay = 1.0
      Task { @MainActor in
        try? await Task.sleep(for: .seconds(announcementDelay))
        let currentLocaleString = self.currentLocaleString
        guard let question = currentQuestion else {
          return
        }
        if let shownSpelling = lastRoundResult?.shownSpelling {
          Utterer.utter(L.QuizView.alsoSpelledWithColon, localeString: currentLocaleString)
          Utterer.utter(shownSpelling.lowercased(), localeString: Utterer.frenchLocaleString)
        }
        // A step's later blanks name only their tense, since the verb is already on screen.
        guard isFirstQuestionOfStep else {
          Utterer.utter(L.QuizView.tenseWithColon, localeString: currentLocaleString)
          Utterer.utter(question.tense.titleCaseName, localeString: Utterer.frenchLocaleString)
          return
        }
        if question.isReask {
          Utterer.utter(L.QuizView.askedAgain, localeString: currentLocaleString)
        }
        // A recognition question speaks its prompt alone, since the verb and the cell are what it
        // asks for.
        if let recognition = question.recognition {
          Utterer.utter(L.Recognition.promptWithColon, localeString: currentLocaleString)
          Utterer.utter(recognition.prompt.lowercased(), localeString: Utterer.frenchLocaleString)
          announceProgress(localeString: currentLocaleString)
          return
        }
        Utterer.utter(L.QuizView.verbWithColon, localeString: currentLocaleString)
        Utterer.utter(question.verb.infinitif, localeString: Utterer.frenchLocaleString)
        Utterer.utter(L.QuizView.translationWithColon, localeString: currentLocaleString)
        Utterer.utter(question.verb.translation, localeString: Utterer.englishLocaleString)
        // A sentence speaks itself in place of the pronoun, with the blank where the answer goes,
        // and then its English.
        if let sentence = question.sentence {
          Utterer.utter(L.Sentences.sentenceWithColon, localeString: currentLocaleString)
          Utterer.utter(question.answerFrame.spokenPrompt, localeString: Utterer.frenchLocaleString)
          Utterer.utter(sentence.english, localeString: Utterer.englishLocaleString)
        } else {
          Utterer.utter(L.QuizView.pronounWithColon, localeString: currentLocaleString)
          Utterer.utter(question.tense.pronoun(pronounGender: question.pronounGender), localeString: Utterer.frenchLocaleString)
          if question.tense.isCompound {
            Utterer.utter(question.tense.gender(pronounGender: question.pronounGender), localeString: currentLocaleString)
          }
        }
        Utterer.utter(L.QuizView.tenseWithColon, localeString: currentLocaleString)
        Utterer.utter(question.tense.titleCaseName, localeString: Utterer.frenchLocaleString)
        announceProgress(localeString: currentLocaleString)
      }
    }
  }

  private func announceProgress(localeString: String) {
    Utterer.utter(L.QuizView.progressWithColon, localeString: localeString)
    Utterer.utter(L.QuizView.progress(currentQuestionIndex + 1, of: questions.count), localeString: localeString)
    Utterer.utter(L.QuizView.score(score), localeString: localeString)
    if showsClock {
      Utterer.utter(L.QuizView.elapsed(seconds: elapsedTime), localeString: localeString)
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
  /// For a recognition question, the typed infinitive against the nearest right one.
  let difference: AnswerDifference
  /// What was wrong with the final answer, which may differ from the first attempt's.
  var diagnosis: AnswerDiagnosis?
  var willBeReasked = false
  var recognitionAnswer: RecognitionAnswer?
  var recognitionGrade: RecognitionGrade?
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
