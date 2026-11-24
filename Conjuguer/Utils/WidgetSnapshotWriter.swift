//
//  WidgetSnapshotWriter.swift
//  Conjuguer
//

import Foundation

enum WidgetSnapshotWriter {
  // How many daily snapshots to precompute (today plus the next N - 1 days) so the
  // widget can rotate at midnight from its own timeline without waiting for the app
  // to relaunch.
  static let futureDayCount = 7

  // Returns whether the on-disk snapshot actually changed, so the caller can skip the
  // (budget-limited) widget reload when nothing moved.
  @discardableResult
  @MainActor static func writeSnapshots(now: Date = Date()) -> Bool {
    guard let url = WidgetConstants.snapshotsURL else {
      return false
    }
    let existing = try? Data(contentsOf: url)
    let displayed = existing
      .flatMap { try? JSONDecoder().decode([WidgetSnapshot].self, from: $0) }
      .flatMap { displayedVerb(in: $0, on: now) }
    let snapshots = generateSnapshots(from: now, myVerbs: Current.learnerVerbs.myVerbs, keeping: displayed)
    guard
      !snapshots.isEmpty,
      let data = try? JSONEncoder().encode(snapshots)
    else {
      return false
    }
    // The snapshot is keyed on the calendar day, the pronoun-gender setting, the quiz level, and
    // My Verbs, so
    // re-foregrounding within the same day usually re-encodes identical bytes. Skip both the
    // write and the reload in that case rather than spending the reload budget on a no-op.
    if existing == data {
      return false
    }
    try? data.write(to: url, options: .atomic)
    return true
  }

  /// `keeping` is the verb the widget shows today. The app rewrites the snapshots at every
  /// activation, and My Verbs may have changed since the last write, so a fresh draw could
  /// replace the verb a learner already saw this morning.
  @MainActor static func generateSnapshots(from date: Date = Date(), dayCount: Int = futureDayCount, myVerbs: [Verb] = [], keeping displayed: Verb? = nil) -> [WidgetSnapshot] {
    let startOfToday = WidgetDateHelper.startOfDay(for: date)
    let eligibleMyVerbs = myVerbs.filter(isEligible)
    let eligibleFrequentVerbs = VerbDraw.frequentVerbs.filter(isEligible)
    return (0 ..< dayCount).compactMap { offset in
      guard let day = WidgetDateHelper.calendar.date(byAdding: .day, value: offset, to: startOfToday) else {
        return nil
      }
      let kept = offset == 0 ? displayed : nil
      guard let verb = kept ?? VerbDraw.verbOfTheDay(on: day, myVerbs: eligibleMyVerbs, frequentVerbs: eligibleFrequentVerbs) else {
        return nil
      }
      return generateSnapshot(verb: verb, date: day)
    }
  }

  @MainActor static func displayedVerb(in snapshots: [WidgetSnapshot], on date: Date) -> Verb? {
    let target = dateString(for: date)
    return snapshots
      .first { $0.dateString == target }
      .flatMap { Verb.verbs[$0.verbKey ?? $0.infinitif] }
  }

  // The large widget shows the verb's example, so a verb without one cannot be the verb of the
  // day.
  @MainActor static func isEligible(_ verb: Verb) -> Bool {
    ExampleData.example(for: verb) != nil
  }

  @MainActor static func generateSnapshot(date: Date = Date(), myVerbs: [Verb] = []) -> WidgetSnapshot? {
    let verb = VerbDraw.verbOfTheDay(on: date, myVerbs: myVerbs.filter(isEligible), frequentVerbs: VerbDraw.frequentVerbs.filter(isEligible))
    return verb.map { generateSnapshot(verb: $0, date: date) }
  }

  @MainActor static func generateSnapshot(verb: Verb, date: Date, level: QuizLevel = Current.settings.quizLevel) -> WidgetSnapshot {
    let paradigm = présentParadigm(for: verb)
    let participePassé = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .participePassé, extraLetters: verb.extraLetters) ?? ""

    let example = ExampleData.example(for: verb)
    let etymology = Etymology.text(for: verb.infinitif).map { truncateToSentenceBoundary($0, maxLength: 360) }
    let quiz = quizQuestion(on: date, level: level, fallbackVerb: verb)

    return WidgetSnapshot(
      infinitif: verb.infinitifWithPossibleExtraLetters,
      verbKey: verb.dictionaryKey,
      translation: verb.translation,
      auxiliary: verb.auxiliary.verb,
      frequency: verb.frequency,
      présentParadigm: paradigm,
      participePassé: participePassé,
      etymologySnippet: etymology,
      exampleFrench: example?.plainFrench,
      exampleEnglish: example?.en,
      exampleSource: example.map { $0.provenance.attribution },
      quizQuestion: quiz,
      dateString: dateString(for: date)
    )
  }

  @MainActor private static func présentParadigm(for verb: Verb) -> [WidgetConjugation] {
    PersonNumber.allCases.map { personNumber in
      let form = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .indicatifPrésent(personNumber), extraLetters: verb.extraLetters) ?? "—"
      return WidgetConjugation(pronoun: compactPronoun(personNumber, of: verb), form: form)
    }
  }

  @MainActor private static func compactPronoun(_ personNumber: PersonNumber, of verb: Verb) -> String {
    let gender = verb.pronounGender
    switch personNumber {
    case .firstSingular:
      return "je"
    case .secondSingular:
      return "tu"
    case .thirdSingular:
      return gender == .masculine ? "il" : "elle"
    case .firstPlural:
      return "nous"
    case .secondPlural:
      return "vous"
    case .thirdPlural:
      return gender == .feminine ? "elles" : "ils"
    }
  }

  /// The quiz widget's question for a day: the first question of that day's challenge at the
  /// level, so that the widget and the challenge agree.
  @MainActor static func quizQuestion(on date: Date, level: QuizLevel, fallbackVerb verb: Verb) -> WidgetQuizQuestion {
    let key = DailyChallenge.Key(date: date, level: level)
    let question = DailyChallenge.questions(for: key).first ?? QuizQuestion(verb: verb, tense: .indicatifPrésent(.thirdSingular))
    return quizQuestion(for: question, key: key)
  }

  /// The wrong answers are the verb's other cells at the key's level, chosen by a generator
  /// seeded with the question's ID: one of the same tense, one of the same person in another
  /// tense, and one more of either.
  @MainActor static func quizQuestion(for question: QuizQuestion, key: DailyChallenge.Key) -> WidgetQuizQuestion {
    let verb = question.verb
    let tense = question.tense
    let correctAnswer = conjugation(of: verb, in: tense) ?? "—"
    let questionID = "\(key.day)-\(key.levelKey)-\(verb.dictionaryKey)"
    var generator = SeededRandomNumberGenerator(seed: WidgetQuizQuestion.stableSeed(for: questionID))
    return WidgetQuizQuestion(
      infinitif: verb.infinitifWithPossibleExtraLetters,
      tenseDisplay: tense.titleCaseName,
      pronoun: tense.personNumber.map { compactPronoun($0, of: verb) },
      correctAnswer: correctAnswer,
      wrongAnswers: wrongAnswers(for: question, correctAnswer: correctAnswer, slots: key.level.slots, using: &generator),
      questionID: questionID
    )
  }

  private static let wrongAnswerCount = 3

  // The most common verbs, conjugated in the same cell, are the real-form fallback distractors
  // for a verb too defective to supply three of its own.
  private static let fillerInfinitifs = ["être", "avoir", "aller", "faire"]

  @MainActor private static func wrongAnswers(
    for question: QuizQuestion,
    correctAnswer: String,
    slots levelSlots: [QuizTenseSlot],
    using generator: inout SeededRandomNumberGenerator
  ) -> [String] {
    let verb = question.verb
    let tense = question.tense
    let asked = QuizTenseSlot(tense: tense)
    // An impératif carries its pronoun in a pronominal verb (souviens-toi), and a participle
    // stands without one, so either would stand out among a finite question's options.
    let isImpératif = asked?.isImpératif ?? false
    let isParticiple = asked?.isParticiple ?? false
    let slots = levelSlots.filter { (isImpératif || !$0.isImpératif) && (isParticiple || !$0.isParticiple) }
    let sameTense = (asked?.cells ?? []).filter { $0 != tense }.shuffled(using: &generator)
    let samePerson = slots
      .filter { $0 != asked }
      .compactMap { slot in slot.cells.first { $0.personNumber != nil && $0.personNumber == tense.personNumber } }
      .shuffled(using: &generator)
    let anyCell = slots.flatMap(\.cells).filter { $0 != tense }.shuffled(using: &generator)

    var answers: [String] = []
    func take(_ form: String?) {
      guard let form, form != correctAnswer, !answers.contains(form), answers.count < wrongAnswerCount else {
        return
      }
      answers.append(form)
    }
    func take(from cells: [Tense], upTo count: Int) {
      for cell in cells where answers.count < count && verb.hasCell(cell) {
        take(conjugation(of: verb, in: cell))
      }
    }
    take(from: sameTense, upTo: 1)
    take(from: samePerson, upTo: answers.count + 1)
    take(from: anyCell, upTo: wrongAnswerCount)
    for filler in fillerInfinitifs where answers.count < wrongAnswerCount {
      take(Conjugator.conjugatedString(infinitif: filler, tense: tense, extraLetters: nil))
    }
    return answers
  }

  @MainActor private static func conjugation(of verb: Verb, in tense: Tense) -> String? {
    Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters)
  }

  static func truncateToSentenceBoundary(_ text: String, maxLength: Int) -> String {
    guard text.count > maxLength else {
      return text
    }
    let prefixEnd = text.index(text.startIndex, offsetBy: maxLength)
    var searchEnd = prefixEnd
    while let period = text[..<searchEnd].lastIndex(of: ".") {
      let candidate = String(text[...period]) + closingQuote(after: period, in: text)
      if quotesBalance(candidate) {
        return rebalanceTildes(candidate)
      }
      searchEnd = period
    }
    return rebalanceTildes(String(text[..<prefixEnd])) + "…"
  }

  // American punctuation ends a sentence inside a quoted gloss with the period before the
  // closing quote (“to emboss.”), so that quote belongs to the snippet even when it falls just
  // past `maxLength`.
  private static func closingQuote(after period: String.Index, in text: String) -> String {
    let rest = text[text.index(after: period)...]
    if rest.hasPrefix("”") {
      return "”"
    }
    for spacing in ["", " ", "\u{00A0}", "\u{202F}"] where rest.hasPrefix(spacing + "»") {
      return spacing + "»"
    }
    return ""
  }

  // A period inside a gloss (the dots of « ne... pas ») is not a sentence end; cutting there
  // would leave the quotation open.
  private static func quotesBalance(_ text: String) -> Bool {
    text.filter { $0 == "“" }.count == text.filter { $0 == "”" }.count
      && text.filter { $0 == "«" }.count == text.filter { $0 == "»" }.count
  }

  // Etymology snippets use `~…~` bold markup. A mid-string cut can leave an unclosed
  // `~` opener, which the widget's parser (splitting on `~`) would render as bold
  // running to the end of the snippet. Drop the dangling opener so the tail stays plain.
  static func rebalanceTildes(_ text: String) -> String {
    guard !text.filter({ $0 == "~" }).count.isMultiple(of: 2) else {
      return text
    }
    guard let lastTilde = text.lastIndex(of: "~") else {
      return text
    }
    return String(text[..<lastTilde]) + String(text[text.index(after: lastTilde)...])
  }

  static func dateString(for date: Date) -> String {
    WidgetDateHelper.dateString(for: date)
  }
}
