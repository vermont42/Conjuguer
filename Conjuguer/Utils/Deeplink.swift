//
//  Deeplink.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/25/26.
//

import Foundation

/// A `conjuguer://` link, parsed. The grammar is in docs/feature_architecture.md § Deeplinks.
/// `init?(url:)` is its only parser and `url` its only builder, so every route round-trips. A
/// link names its targets by key and does not resolve them: `World` looks them up, so that a
/// link naming nothing can change nothing.
enum Deeplink: Equatable {
  /// `conjuguer://verb/aller?source=lookup&match=vais`. A `match` names a conjugation that the
  /// page marks, as it marks a search's match.
  case verb(VerbTarget, source: AnalyticsSource = .deeplink, match: String? = nil)

  /// `conjuguer://search?q=suis&source=lookup`. With no `q`, or an empty one, the search opens
  /// empty and focused for typing.
  case search(text: String?, source: AnalyticsSource = .deeplink)

  /// `conjuguer://model/6-7?source=sharedLink`.
  case model(String, source: AnalyticsSource = .deeplink)

  /// `conjuguer://list/top100?source=sharedLink`, a featured collection.
  case list(String, source: AnalyticsSource = .deeplink)

  /// `conjuguer://info/futur_simple`, or a legacy position (`info/0`). The stable key survives a
  /// reordering of the articles, which a position does not.
  case info(String)

  /// `conjuguer://quiz/set?tenses=imparfait&verbs=etre&source=qrCode`: the custom quiz's stored
  /// form, and the sharer's level while a part is left to it. The choice is as the link spells
  /// it; `PracticeSet(linked:level:)` drops what this install cannot ask.
  case practiceSet(CustomQuiz, level: QuizLevel?, source: AnalyticsSource = .deeplink)

  /// `conjuguer://quiz/daily?source=reminder`.
  case dailySession(source: AnalyticsSource = .deeplink)

  /// `conjuguer://quiz/challenge?date=2026-11-24&level=elementary&source=challengeLink`. With no
  /// date, as the quiz widget sends it, today's challenge.
  case challenge(day: String?, level: QuizLevel?, source: AnalyticsSource = .deeplink)

  /// `conjuguer://quiz/start`, and any other target of the quiz route.
  case startQuiz(source: AnalyticsSource = .deeplink)

  /// A verb link's target: a `Verb.verbs` key, so that each entry of a doubled infinitive has its
  /// own (`ha%C3%AFr%20France`), or a draw.
  enum VerbTarget: Equatable {
    case key(String)
    case random
  }

  init?(url: URL) {
    guard
      url.scheme == Self.scheme,
      let host = url.host,
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else {
      return nil
    }
    let items = components.queryItems ?? []
    let value = { (name: String) in
      items.first { $0.name == name }?.value
    }
    let source = value(Self.sourceName).flatMap(AnalyticsSource.init(rawValue:)) ?? .deeplink

    if host == Self.searchHost {
      guard url.pathComponents.count <= 1 else {
        return nil
      }
      self = .search(text: value(Self.searchTextName), source: source)
      return
    }

    guard url.pathComponents.count == 2 else {
      return nil
    }
    let target = url.pathComponents[1]
    switch host {
    case Self.verbHost:
      self = .verb(target == Self.randomTarget ? .random : .key(target), source: source, match: value(Self.matchName))
    case Self.modelHost:
      self = .model(target, source: source)
    case Self.listHost:
      self = .list(target, source: source)
    case Self.infoHost:
      self = .info(target)
    case Self.quizHost:
      let level = value(Self.levelName).flatMap(QuizLevel.init(rawValue:))
      switch target {
      case Self.practiceSetTarget:
        self = .practiceSet(CustomQuiz(rawValue: components.percentEncodedQuery ?? "") ?? CustomQuiz(), level: level, source: source)
      case Self.dailySessionTarget:
        self = .dailySession(source: source)
      case Self.challengeTarget:
        self = .challenge(day: value(Self.dateName), level: level, source: source)
      default:
        self = .startQuiz(source: source)
      }
    default:
      return nil
    }
  }

  var url: URL {
    switch self {
    case let .verb(target, source, match):
      let path: String
      switch target {
      case .key(let key):
        path = key
      case .random:
        path = Self.randomTarget
      }
      return Self.url(host: Self.verbHost, target: path, items: [Self.item(source), match.map { URLQueryItem(name: Self.matchName, value: $0) }])
    case let .search(text, source):
      return Self.url(host: Self.searchHost, target: nil, items: [text.map { URLQueryItem(name: Self.searchTextName, value: $0) }, Self.item(source)])
    case let .model(id, source):
      return Self.url(host: Self.modelHost, target: id, items: [Self.item(source)])
    case let .list(key, source):
      return Self.url(host: Self.listHost, target: key, items: [Self.item(source)])
    case .info(let target):
      return Self.url(host: Self.infoHost, target: target, items: [])
    case let .practiceSet(custom, level, source):
      var components = URLComponents()
      components.percentEncodedQuery = custom.rawValue
      return Self.url(host: Self.quizHost, target: Self.practiceSetTarget, items: (components.queryItems ?? []) + [Self.item(level), Self.item(source)])
    case .dailySession(let source):
      return Self.url(host: Self.quizHost, target: Self.dailySessionTarget, items: [Self.item(source)])
    case let .challenge(day, level, source):
      return Self.url(host: Self.quizHost, target: Self.challengeTarget, items: [day.map { URLQueryItem(name: Self.dateName, value: $0) }, Self.item(level), Self.item(source)])
    case .startQuiz(let source):
      return Self.url(host: Self.quizHost, target: Self.startQuizTarget, items: [Self.item(source)])
    }
  }

  /// The `source` item names the surface that built the link, because a widget or an intent can
  /// hand the app only a URL. A link without one counts as `deeplink`, so that value is left out.
  private static func item(_ source: AnalyticsSource) -> URLQueryItem? {
    source == .deeplink ? nil : URLQueryItem(name: sourceName, value: source.rawValue)
  }

  private static func item(_ level: QuizLevel?) -> URLQueryItem? {
    level.map { URLQueryItem(name: levelName, value: $0.rawValue) }
  }

  /// Text always travels in a query item, never in the path, because it can hold spaces,
  /// apostrophes, and slashes ("j'ai mangé").
  private static func url(host: String, target: String?, items: [URLQueryItem?]) -> URL {
    var components = URLComponents()
    components.scheme = scheme
    components.host = host
    components.path = target.map { "/\($0)" } ?? ""
    let items = items.compactMap { $0 }
    components.queryItems = items.isEmpty ? nil : items
    // A scheme, a host, and a path that is empty or begins with a slash always make a URL.
    return components.url ?? URL(filePath: "/")
  }

  private static let scheme = "conjuguer"
  private static let verbHost = "verb"
  private static let modelHost = "model"
  private static let infoHost = "info"
  private static let quizHost = "quiz"
  private static let searchHost = "search"
  private static let listHost = "list"
  private static let randomTarget = "random"
  private static let practiceSetTarget = "set"
  private static let dailySessionTarget = "daily"
  private static let challengeTarget = "challenge"
  private static let startQuizTarget = "start"
  private static let sourceName = "source"
  private static let matchName = "match"
  private static let searchTextName = "q"
  private static let dateName = "date"
  private static let levelName = "level"
}
