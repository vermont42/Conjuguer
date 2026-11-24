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

  // The tenses a daily quiz question is drawn from (all carry a person-number;
  // passéComposé is compound, the rest are simple).
  private static let quizTenseFamilies: [(PersonNumber) -> Tense] = [
    Tense.indicatifPrésent,
    Tense.passéComposé,
    Tense.futurSimple,
    Tense.imparfait,
    Tense.subjonctifPrésent,
    Tense.conditionnelPrésent
  ]

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
    // The snapshot is keyed on the calendar day, the pronoun-gender setting, and My Verbs, so
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

  @MainActor static func generateSnapshot(verb: Verb, date: Date) -> WidgetSnapshot {
    let paradigm = présentParadigm(for: verb)
    let participePassé = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .participePassé, extraLetters: verb.extraLetters) ?? ""

    let example = ExampleData.example(for: verb)
    let etymology = Etymology.text(for: verb.infinitif).map { truncateToSentenceBoundary($0, maxLength: 360) }
    let quiz = generateQuizQuestion(verb: verb, date: date)

    return WidgetSnapshot(
      infinitif: verb.infinitifWithPossibleExtraLetters,
      verbKey: verb.dictionaryKey,
      translation: verb.translation,
      auxiliary: verb.auxiliary.verb,
      frequency: verb.frequency,
      présentParadigm: paradigm,
      participePassé: participePassé,
      etymologySnippet: etymology,
      exampleFrench: example?.fr,
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

  @MainActor private static func generateQuizQuestion(verb: Verb, date: Date) -> WidgetQuizQuestion {
    let seed = abs(VerbDraw.dayNumber(of: date))
    let personNumber = PersonNumber.allCases[seed % PersonNumber.allCases.count]
    // Decorrelate the tense from the person: both collections have 6 elements, so
    // indexing both by `seed % 6` would weld each person to a single tense forever.
    let tenseIndex = (seed / PersonNumber.allCases.count) % quizTenseFamilies.count
    let makeTense = quizTenseFamilies[tenseIndex]
    let tense = makeTense(personNumber)

    let correctAnswer = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters) ?? "—"
    let wrongAnswers = generateWrongAnswers(verb: verb, makeTense: makeTense, personNumber: personNumber, correctAnswer: correctAnswer)

    return WidgetQuizQuestion(
      infinitif: verb.infinitifWithPossibleExtraLetters,
      tenseDisplay: tense.titleCaseName,
      pronoun: compactPronoun(personNumber, of: verb),
      correctAnswer: correctAnswer,
      wrongAnswers: wrongAnswers,
      questionID: "\(dateString(for: date))-\(verb.infinitifWithPossibleExtraLetters)"
    )
  }

  // The most common verbs, conjugated in the same tense/person, are the real-form
  // fallback distractors for a verb too defective to supply three of its own.
  private static let fillerInfinitifs = ["être", "avoir", "aller", "faire"]

  @MainActor private static func generateWrongAnswers(
    verb: Verb,
    makeTense: (PersonNumber) -> Tense,
    personNumber: PersonNumber,
    correctAnswer: String
  ) -> [String] {
    var candidates: [String] = []

    func consider(_ form: String?) {
      guard
        let form,
        form != correctAnswer,
        !candidates.contains(form),
        candidates.count < 3
      else {
        return
      }
      candidates.append(form)
    }

    // Nearest-miss distractors first: same tense, other persons; then same person,
    // other tenses — the most plausible wrong answers for this verb.
    for otherPerson in PersonNumber.allCases where otherPerson != personNumber {
      consider(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: makeTense(otherPerson), extraLetters: verb.extraLetters))
    }

    for otherFamily in quizTenseFamilies {
      consider(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: otherFamily(personNumber), extraLetters: verb.extraLetters))
    }

    // Broaden to the full tense × person cross-product before any fallback, so
    // distractors stay real conjugations of this verb.
    for family in quizTenseFamilies {
      for otherPerson in PersonNumber.allCases {
        consider(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: family(otherPerson), extraLetters: verb.extraLetters))
      }
    }

    // Last resort for pathologically defective verbs with too few distinct forms:
    // borrow real conjugations of the most common verbs rather than emitting
    // synthetic (and obviously fake) `xx`-padded strings.
    for filler in fillerInfinitifs {
      for otherPerson in PersonNumber.allCases {
        consider(Conjugator.conjugatedString(infinitif: filler, tense: makeTense(otherPerson), extraLetters: nil))
      }
    }

    return Array(candidates.prefix(3))
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
