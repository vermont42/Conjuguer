//
//  DailyChallenge.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import UIKit

/// Five questions a day at each level, the same on every device on the same date, taken once and
/// shared as a short text.
enum DailyChallenge {
  static let questionCount = 5

  /// Draws repeat until no verb is asked twice, since in five questions a second être would be a
  /// fifth of the challenge. The limit keeps a band that cannot comply from looping forever.
  static let distinctVerbAttempts = 20

  static var maximumScore: Int {
    questionCount * ConjugationResult.totalMatch.score
  }

  /// A day's challenge at a level. The day is the learner's own calendar day, so that learners in
  /// different time zones share a challenge by date, not by instant.
  struct Key: Codable, Hashable {
    let day: String
    let levelKey: String

    var level: QuizLevel {
      QuizLevel(rawValue: levelKey) ?? Settings.quizLevelDefault
    }

    init(date: Date, level: QuizLevel) {
      day = WidgetDateHelper.dateString(for: date)
      levelKey = level.rawValue
    }

    /// The challenge a shared link names, or nil for a day that is not a date, such as
    /// 2026-02-30.
    init?(day: String, level: QuizLevel) {
      guard let date = WidgetDateHelper.date(fromDateString: day), WidgetDateHelper.dateString(for: date) == day else {
        return nil
      }
      self.day = day
      levelKey = level.rawValue
    }

    /// Changing this text changes every challenge on every device.
    var seedText: String {
      "challenge-\(day)-\(levelKey)"
    }

    var seed: UInt64 {
      WidgetQuizQuestion.stableSeed(for: seedText)
    }

    /// Noon of the day, which no change of time zone moves to another date.
    var date: Date {
      WidgetDateHelper.date(fromDateString: day)
        .flatMap { WidgetDateHelper.calendar.date(byAdding: .hour, value: 12, to: $0) } ?? .now
    }
  }

  /// How one question went, in the colors of the results' marks.
  enum Outcome: String, Codable {
    case right
    case secondTry
    case wrong

    init(_ result: ConjugationResult) {
      switch result {
      case .totalMatch:
        self = .right
      case .secondAttemptMatch:
        self = .secondTry
      case .noMatch:
        self = .wrong
      }
    }

    var conjugationResult: ConjugationResult {
      switch self {
      case .right:
        return .totalMatch
      case .secondTry:
        return .secondAttemptMatch
      case .wrong:
        return .noMatch
      }
    }

    var dot: String {
      switch self {
      case .right:
        return "🟢"
      case .secondTry:
        return "🟠"
      case .wrong:
        return "🔴"
      }
    }

    var points: Int {
      conjugationResult.score
    }
  }

  private static var cache: [Key: [QuizQuestion]] = [:]

  static func questions(for key: Key) -> [QuizQuestion] {
    if let cached = cache[key] {
      return cached
    }
    let drawn = draw(for: key)
    if !drawn.isEmpty {
      cache[key] = drawn
    }
    return drawn
  }

  /// The default quiz's balanced draw from the level's tenses and band, and then each question's
  /// person, all from a generator seeded by the key alone, so that nothing on the device enters
  /// it: not the practice record, not My Verbs, and not the settings. Two devices agree while they
  /// run the same build and the same verbs, since `QuizDraw` uses the standard library's
  /// `randomElement` and `shuffled`, whose use of the generator a new toolchain could change.
  static func draw(for key: Key) -> [QuizQuestion] {
    let level = key.level
    var generator = SeededRandomNumberGenerator(seed: key.seed)
    var drawn: [QuizDrawnQuestion] = []
    for _ in 0 ..< distinctVerbAttempts {
      drawn = QuizDraw.questions(slots: level.slots, band: level.band, count: questionCount, asked: [], using: &generator)
      if Set(drawn.map(\.verb.id)).count == drawn.count {
        break
      }
    }
    return drawn.compactMap { question(of: $0, using: &generator) }
  }

  private static func question(of drawn: QuizDrawnQuestion, using generator: inout SeededRandomNumberGenerator) -> QuizQuestion? {
    guard let constructor = drawn.slot.constructor else {
      return drawn.slot.cells.first.map { QuizQuestion(verb: drawn.verb, tense: $0) }
    }
    let persons = drawn.slot.persons.filter { drawn.verb.hasCell(constructor($0)) }
    return persons.randomElement(using: &generator).map { QuizQuestion(verb: drawn.verb, tense: constructor($0)) }
  }

  /// The app's language, which can differ from the region's, for the shared date.
  static var appLocale: Locale {
    Locale(identifier: Bundle.main.preferredLocalizations.first ?? "en")
  }
}

/// A finished challenge, kept on the device and sent nowhere, so that the hub can show the day's
/// result and share it, and so that a challenge is taken once.
struct DailyChallengeResult: Codable, Equatable {
  static let storageKey = "dailyChallengeResults"
  /// A week's challenges at a level, and a few opened from links.
  static let keptCount = 12

  let key: DailyChallenge.Key
  let outcomes: [DailyChallenge.Outcome]

  init(key: DailyChallenge.Key, outcomes: [DailyChallenge.Outcome]) {
    self.key = key
    self.outcomes = outcomes
  }

  init(key: DailyChallenge.Key, results: [QuizResult]) {
    self.init(key: key, outcomes: results.filter { !$0.isReask }.prefix(DailyChallenge.questionCount).map { DailyChallenge.Outcome($0.conjugationResult) })
  }

  var score: Int {
    outcomes.reduce(0) { $0 + $1.points }
  }

  var dots: String {
    outcomes.map(\.dot).joined()
  }

  var pointsLine: String {
    "\(score) / \(DailyChallenge.maximumScore)"
  }

  /// What VoiceOver reads for the dots, which it would otherwise read as five circles.
  var spokenSummary: String {
    L.DailyChallenge.spokenResult(
      right: outcomes.filter { $0 == .right }.count,
      secondTry: outcomes.filter { $0 == .secondTry }.count,
      count: outcomes.count,
      score: score,
      maximum: DailyChallenge.maximumScore
    )
  }

  func shareText(locale: Locale = DailyChallenge.appLocale) -> String {
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.calendar = WidgetDateHelper.calendar
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return L.DailyChallenge.shareText(
      date: formatter.string(from: key.date),
      level: key.level.localizedName,
      tally: "\(dots)  \(pointsLine)",
      link: Deeplink.challenge(day: key.day, level: key.level, source: .challengeLink).url.absoluteString,
      appStoreLink: URL.appStore.absoluteString
    )
  }

  /// `tapShareChallenge` names the level, never the result, since no signal carries accuracy.
  func signalShare() {
    Current.analytics.signal(name: .tapShareChallenge, parameters: [ParameterKey.level.rawValue: key.levelKey])
  }

  func share(anchorRect: CGRect?) {
    signalShare()
    ShareSheet.present(
      text: shareText(),
      title: L.DailyChallenge.title,
      icon: UIImage(named: Current.settings.appIcon.previewAssetName),
      anchorLabel: L.DailyChallenge.share,
      anchorRect: anchorRect
    )
  }
}

extension QuizScope {
  /// A day's challenge at the key's level, whatever the learner's, since a challenge opened from a
  /// friend's link must ask the friend's questions. Never ranked, continued, or re-asked, so that
  /// the results show what the shared text says.
  static func challenge(_ key: DailyChallenge.Key, source: AnalyticsSource = .challenge) -> QuizScope {
    QuizScope(verbs: nil, questionCount: DailyChallenge.questionCount, source: source, kind: .challenge(key))
  }
}

/// A request, from a shared link or the quiz widget, that the Quiz tab start a challenge.
struct DailyChallengeRequest: Equatable {
  let id = UUID()
  /// Nil asks for today's at the learner's level.
  let key: DailyChallenge.Key?
  let source: AnalyticsSource
}
