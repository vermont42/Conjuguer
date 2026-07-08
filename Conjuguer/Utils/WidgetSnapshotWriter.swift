//
//  WidgetSnapshotWriter.swift
//  Conjuguer
//

import Foundation

enum WidgetSnapshotWriter {
  private static let referenceDate: Date = {
    Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1)) ?? Date()
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

  @MainActor static func writeSnapshot() {
    guard
      let snapshot = generateSnapshot(),
      let url = WidgetConstants.snapshotURL,
      let data = try? JSONEncoder().encode(snapshot)
    else {
      return
    }
    try? data.write(to: url, options: .atomic)
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
    let daysSinceReference = Calendar.current.dateComponents([.day], from: referenceDate, to: date).day ?? 0
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
    let daysSinceReference = Calendar.current.dateComponents([.day], from: referenceDate, to: date).day ?? 0
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

    for otherPerson in PersonNumber.allCases where otherPerson != personNumber {
      consider(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: makeTense(otherPerson), extraLetters: nil))
    }

    for otherFamily in quizTenseFamilies {
      consider(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: otherFamily(personNumber), extraLetters: nil))
    }

    while candidates.count < 3 {
      candidates.append(correctAnswer + String(repeating: "x", count: candidates.count + 1))
    }

    return Array(candidates.prefix(3))
  }

  private static func truncateToSentenceBoundary(_ text: String, maxLength: Int) -> String {
    guard text.count > maxLength else {
      return text
    }
    let prefix = String(text.prefix(maxLength))
    if let lastPeriod = prefix.lastIndex(of: ".") {
      return String(prefix[...lastPeriod])
    }
    return prefix + "…"
  }

  static func dateString(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}
