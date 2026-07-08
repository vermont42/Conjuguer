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

  private static let referenceDate: Date = {
    WidgetDateHelper.calendar.date(from: DateComponents(year: 2025, month: 1, day: 1)) ?? Date()
  }()

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
  @MainActor static func writeSnapshots() -> Bool {
    let snapshots = generateSnapshots()
    guard
      !snapshots.isEmpty,
      let url = WidgetConstants.snapshotsURL,
      let data = try? JSONEncoder().encode(snapshots)
    else {
      return false
    }
    // The snapshot is keyed on the calendar day and the pronoun-gender setting, so
    // re-foregrounding within the same day re-encodes identical bytes. Skip both the
    // write and the reload in that case rather than spending the reload budget on a no-op.
    if let existing = try? Data(contentsOf: url), existing == data {
      return false
    }
    try? data.write(to: url, options: .atomic)
    return true
  }

  // One snapshot per day for today plus the next `dayCount - 1` days.
  @MainActor static func generateSnapshots(from date: Date = Date(), dayCount: Int = futureDayCount) -> [WidgetSnapshot] {
    let startOfToday = WidgetDateHelper.startOfDay(for: date)
    return (0 ..< dayCount).compactMap { offset in
      guard let day = WidgetDateHelper.calendar.date(byAdding: .day, value: offset, to: startOfToday) else {
        return nil
      }
      return generateSnapshot(date: day)
    }
  }

  @MainActor static func generateSnapshot(date: Date = Date()) -> WidgetSnapshot? {
    let eligible = eligibleVerbs()
    guard !eligible.isEmpty else {
      return nil
    }

    let verb = verbOfTheDay(from: eligible, date: date)
    let paradigm = présentParadigm(for: verb)
    let participePassé = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .participePassé, extraLetters: nil) ?? ""

    let example = ExampleData.example(for: verb)
    let etymology = Etymology.text(for: verb.infinitif).map { truncateToSentenceBoundary($0, maxLength: 360) }
    let quiz = generateQuizQuestion(verb: verb, date: date)

    return WidgetSnapshot(
      infinitif: verb.infinitif,
      translation: verb.translation,
      auxiliary: verb.auxiliary.verb,
      frequency: verb.frequency ?? 0,
      présentParadigm: paradigm,
      participePassé: participePassé,
      etymologySnippet: etymology,
      exampleFrench: example?.fr,
      exampleEnglish: example?.en,
      exampleSource: example?.source,
      quizQuestion: quiz,
      dateString: dateString(for: date)
    )
  }

  @MainActor static func eligibleVerbs() -> [Verb] {
    Verb.verbs.values
      .filter { $0.frequency != nil }
      .sorted { ($0.frequency ?? .max, $0.infinitif) < ($1.frequency ?? .max, $1.infinitif) }
  }

  @MainActor static func verbOfTheDay(from eligible: [Verb], date: Date) -> Verb {
    let daysSinceReference = WidgetDateHelper.calendar.dateComponents([.day], from: referenceDate, to: date).day ?? 0
    let index = abs(daysSinceReference * 127) % eligible.count
    return eligible[index]
  }

  @MainActor private static func présentParadigm(for verb: Verb) -> [WidgetConjugation] {
    PersonNumber.allCases.map { personNumber in
      let form = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .indicatifPrésent(personNumber), extraLetters: nil) ?? "—"
      return WidgetConjugation(pronoun: compactPronoun(personNumber), form: form)
    }
  }

  @MainActor private static func compactPronoun(_ personNumber: PersonNumber) -> String {
    let gender = Current.settings.pronounGender
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
    let daysSinceReference = WidgetDateHelper.calendar.dateComponents([.day], from: referenceDate, to: date).day ?? 0
    let seed = abs(daysSinceReference)
    let personNumber = PersonNumber.allCases[seed % PersonNumber.allCases.count]
    // Decorrelate the tense from the person: both collections have 6 elements, so
    // indexing both by `seed % 6` would weld each person to a single tense forever.
    let tenseIndex = (seed / PersonNumber.allCases.count) % quizTenseFamilies.count
    let makeTense = quizTenseFamilies[tenseIndex]
    let tense = makeTense(personNumber)

    let correctAnswer = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: nil) ?? "—"
    let wrongAnswers = generateWrongAnswers(verb: verb, makeTense: makeTense, personNumber: personNumber, correctAnswer: correctAnswer)

    return WidgetQuizQuestion(
      infinitif: verb.infinitif,
      tenseDisplay: tense.titleCaseName,
      pronoun: compactPronoun(personNumber),
      correctAnswer: correctAnswer,
      wrongAnswers: wrongAnswers,
      questionID: "\(dateString(for: date))-\(verb.infinitif)"
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
      consider(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: makeTense(otherPerson), extraLetters: nil))
    }

    for otherFamily in quizTenseFamilies {
      consider(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: otherFamily(personNumber), extraLetters: nil))
    }

    // Broaden to the full tense × person cross-product before any fallback, so
    // distractors stay real conjugations of this verb.
    for family in quizTenseFamilies {
      for otherPerson in PersonNumber.allCases {
        consider(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: family(otherPerson), extraLetters: nil))
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
    let prefix = String(text.prefix(maxLength))
    if let lastPeriod = prefix.lastIndex(of: ".") {
      return rebalanceTildes(String(prefix[...lastPeriod]))
    }
    return rebalanceTildes(prefix) + "…"
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
