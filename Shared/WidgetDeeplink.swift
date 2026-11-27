//
//  WidgetDeeplink.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import Foundation

/// The links that the widget extension and the intents in `Shared/` hand the app. Neither can see
/// `AnalyticsSource` or `Deeplink`, the app's one builder, so these links are spelled here, once,
/// and `DeeplinkTests` pins each to the URL that `Deeplink` builds for the same place.
nonisolated enum WidgetDeeplink: Hashable, Sendable {
  /// Today's challenge at the learner's level, from the quiz widget, whose question is the
  /// challenge's first.
  case challenge
  /// The verb list with its search field focused for typing, from the Find a Verb control.
  case findVerb
  /// The Quiz tab, from the Quick Quiz control.
  case quiz
  // The control and the Shortcuts app would otherwise run one intent, and an intent cannot tell
  // which of them ran it.
  case randomVerbFromControl
  case randomVerbFromShortcut
  /// A verb's page, from a widget, by its `Verb.verbs` key.
  case verb(String)

  var url: URL? {
    var components = URLComponents()
    components.scheme = "conjuguer"
    let source: String?
    switch self {
    case .challenge:
      components.host = "quiz"
      components.path = "/challenge"
      source = "challengeWidget"
    case .findVerb:
      components.host = "search"
      source = "control"
    case .quiz:
      components.host = "quiz"
      components.path = "/start"
      source = nil
    case .randomVerbFromControl:
      components.host = "verb"
      components.path = "/random"
      source = "control"
    case .randomVerbFromShortcut:
      components.host = "verb"
      components.path = "/random"
      source = "shortcut"
    case .verb(let key):
      components.host = "verb"
      components.path = "/\(key)"
      source = "widget"
    }
    components.queryItems = source.map { [URLQueryItem(name: "source", value: $0)] }
    return components.url
  }
}

extension WidgetSnapshot {
  /// The verb of the day's page. A snapshot written before `verbKey` existed names its verb by
  /// the infinitive, which is the key of every verb that is not doubled.
  var deeplink: WidgetDeeplink {
    .verb(verbKey ?? infinitif)
  }
}
