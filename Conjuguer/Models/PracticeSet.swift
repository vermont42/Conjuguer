//
//  PracticeSet.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// A custom quiz shared as a link or a QR code, so that a teacher can hand a class one practice
/// set without accounts or a server. Opening one shows the set with Start rather than starting a
/// quiz unasked.
struct PracticeSet: Equatable {
  var custom: CustomQuiz

  /// The sharer's level, carried only while a part of the choice is left to the level, so that
  /// everyone who opens the set is asked the same tenses and verbs.
  var level: QuizLevel?

  init(custom: CustomQuiz, level: QuizLevel?) {
    self.custom = custom
    self.level = level
  }

  /// The set a learner shares from the Quiz tab. Their My Verbs are their own, so the link carries
  /// the verbs themselves, the first `maximumListCount` of them.
  init(sharing custom: CustomQuiz, level: QuizLevel, myVerbs: [Verb]) {
    var shared = custom
    if custom.verbSet == .myVerbs {
      shared.verbSet = QuizVerbSet(verbKeys: myVerbs.prefix(Self.maximumListCount).map(\.dictionaryKey))
    }
    self.custom = shared
    self.level = shared.tenses.isEmpty || shared.verbSet == nil ? level : nil
  }

  /// Keeps a projected QR code coarse enough to scan from the back of a classroom. Every é of a
  /// percent-encoded infinitive takes nine bytes, so a hundred of the longest overflow a code.
  static let maximumListCount = 50

  /// Nil for any other link, and for a `quiz/set` link that names no tense or verb set this
  /// version knows. Verbs this version lacks are dropped from a list. A link naming My Verbs would
  /// ask the opener's own, which no sharer means, so that part is dropped.
  init?(url: URL) {
    guard
      url.isDeeplink,
      url.host == URL.quizHost,
      url.hasExpectedNumberOfDeeplinkComponents,
      url.pathComponents[1] == URL.practiceSetTarget,
      let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.percentEncodedQuery,
      var custom = CustomQuiz(rawValue: query)
    else {
      return nil
    }
    switch custom.verbSet {
    case .myVerbs:
      custom.verbSet = nil
    case .list(let verbKeys):
      custom.verbSet = QuizVerbSet(verbKeys: verbKeys.filter { Verb.verbs[$0] != nil })
    case .collection(.model(let id)) where VerbModel.models[id] == nil:
      custom.verbSet = nil
    default:
      break
    }
    guard !custom.isEmpty else {
      return nil
    }
    self.custom = custom
    level = url.deeplinkQueryValue(named: URL.levelQueryName).flatMap(QuizLevel.init(rawValue:))
  }

  /// `source` is `sharedLink` in shared text and `qrCode` in a QR code, so that `quizStart` can
  /// tell which reached the learner.
  func deeplink(source: AnalyticsSource) -> URL? {
    URL.practiceSetDeeplink(custom: custom, level: level, source: source)
  }

  /// What a quiz over this set asks: the custom quiz's rules, at the set's level.
  func scope(source: AnalyticsSource) -> QuizScope {
    QuizScope(
      verbs: custom.verbSet?.listedVerbs(myVerbs: []),
      questionCount: Quiz.questionCount,
      source: source,
      title: L.PracticeSet.title,
      custom: custom,
      level: level,
      isPracticeSet: true
    )
  }

  func canBeAsked(levelFallback: QuizLevel) -> Bool {
    custom.canBeAsked(at: level ?? levelFallback, myVerbs: [])
  }

  /// The tenses on one line and the verbs on the next, for the share text and the QR code's
  /// caption.
  func summary(levelFallback: QuizLevel) -> String {
    let level = level ?? levelFallback
    let tenses = custom.tenses.isEmpty
      ? L.PracticeSet.byLevel(level.localizedName)
      : custom.orderedTenses.map(\.name).joined(separator: ", ")
    let verbs = custom.verbSet?.title ?? L.PracticeSet.byLevel(CustomQuiz.levelVerbsDescription(level))
    return [
      L.PracticeSet.summaryLine(label: L.CustomQuiz.tenses, value: tenses),
      L.PracticeSet.summaryLine(label: L.CustomQuiz.verbs, value: verbs)
    ].joined(separator: "\n")
  }

  /// The summary, a link that opens the set for someone who has the app, and the App Store link
  /// for someone who does not. There is no web domain, so there is no universal link.
  func shareText(levelFallback: QuizLevel) -> String {
    L.PracticeSet.shareText(
      summary: summary(levelFallback: levelFallback),
      link: deeplink(source: .sharedLink)?.absoluteString ?? "",
      appStoreLink: URL.appStore.absoluteString
    )
  }

  static let linkMethod = "link"
  static let qrCodeMethod = "qrCode"

  func signalShare(method: String) {
    Current.analytics.signal(name: .tapSharePracticeSet, parameters: [
      ParameterKey.customChoice.rawValue: custom.choiceParameter,
      ParameterKey.method.rawValue: method
    ])
  }
}

/// A practice-set link to show, from `World.handleURL`. A nil set is a `quiz/set` link that names
/// nothing, which shows a sheet saying so rather than doing nothing.
struct PracticeSetRequest: Identifiable {
  let id = UUID()
  let practiceSet: PracticeSet?
  let source: AnalyticsSource
}
