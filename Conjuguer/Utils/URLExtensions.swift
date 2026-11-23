//
//  URLExtensions.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/20/21.
//

import Foundation

extension URL {
  var isDeeplink: Bool {
    scheme == URL.deeplinkScheme
  }

  var hasExpectedNumberOfDeeplinkComponents: Bool {
    pathComponents.count == URL.deeplinkComponentCount
  }

  /// The `search` route takes no target, and every other route takes exactly one.
  var hasDeeplinkTarget: Bool {
    host == URL.searchHost ? pathComponents.count <= 1 : hasExpectedNumberOfDeeplinkComponents
  }

  /// The surface that built this link, which a widget, an intent, or an Info article names in a
  /// `source` query item, because the link is all it can hand the app. Nil when the item is
  /// missing or outside the vocabulary.
  var analyticsSource: AnalyticsSource? {
    deeplinkQueryValue(named: URL.sourceQueryName).flatMap(AnalyticsSource.init(rawValue:))
  }

  /// The value of a query item. Text always travels in a query item, never in the path, because
  /// it can hold spaces, apostrophes, and slashes ("j'ai mangé").
  func deeplinkQueryValue(named name: String) -> String? {
    URLComponents(url: self, resolvingAgainstBaseURL: false)?
      .queryItems?
      .first { $0.name == name }?
      .value
  }

  /// `conjuguer://verb/aller?source=lookup&match=vais`. The target is a `Verb.verbs` key, so
  /// each entry of a doubled infinitive has its own (`ha%C3%AFr%20France`). A `match` names a
  /// conjugation that the page marks, as it marks a search's match.
  static func verbDeeplink(_ verbKey: String, source: AnalyticsSource? = nil, match: String? = nil) -> URL? {
    deeplink(host: verbHost, target: verbKey, queryItems: [
      source.map { URLQueryItem(name: sourceQueryName, value: $0.rawValue) },
      match.map { URLQueryItem(name: matchQueryName, value: $0) }
    ])
  }

  /// `conjuguer://search?q=suis&source=lookup`. With no `q`, or an empty one, the search opens
  /// empty and focused for typing.
  static func searchDeeplink(text: String?, source: AnalyticsSource) -> URL? {
    deeplink(host: searchHost, target: nil, queryItems: [
      text.map { URLQueryItem(name: searchTextQueryName, value: $0) },
      URLQueryItem(name: sourceQueryName, value: source.rawValue)
    ])
  }

  /// `conjuguer://info/futur_simple`. The stable key survives a reordering of the articles,
  /// which a position does not.
  static func infoDeeplink(_ info: Info) -> URL? {
    deeplink(host: infoHost, target: info.stableKey, queryItems: [])
  }

  /// `conjuguer://model/1-1`.
  static func modelDeeplink(_ model: VerbModel, source: AnalyticsSource? = nil) -> URL? {
    modelDeeplink(model.id, source: source)
  }

  /// `conjuguer://model/6-7?source=sharedLink`, which a model's collection shares.
  static func modelDeeplink(_ modelID: String, source: AnalyticsSource? = nil) -> URL? {
    deeplink(host: verbModelHost, target: modelID, queryItems: [
      source.map { URLQueryItem(name: sourceQueryName, value: $0.rawValue) }
    ])
  }

  /// `conjuguer://list/top100?source=sharedLink`, a featured collection.
  static func listDeeplink(_ collection: VerbCollection, source: AnalyticsSource? = nil) -> URL? {
    deeplink(host: listHost, target: collection.key, queryItems: [
      source.map { URLQueryItem(name: sourceQueryName, value: $0.rawValue) }
    ])
  }

  private static func deeplink(host: String, target: String?, queryItems: [URLQueryItem?]) -> URL? {
    var components = URLComponents()
    components.scheme = deeplinkScheme
    components.host = host
    components.path = target.map { "/\($0)" } ?? ""
    let items = queryItems.compactMap { $0 }
    components.queryItems = items.isEmpty ? nil : items
    return components.url
  }

  static let deeplinkScheme = "conjuguer"
  static let verbHost = "verb"
  static let verbModelHost = "model"
  static let infoHost = "info"
  static let quizHost = "quiz"
  static let searchHost = "search"
  static let listHost = "list"
  static let randomVerbPath = "random"
  static let sourceQueryName = "source"
  static let matchQueryName = "match"
  static let searchTextQueryName = "q"
  private static let deeplinkComponentCount = 2

  /// Conjuguer's App Store page. With no storefront in the path, the App Store opens the
  /// reader's own.
  static var appStore: URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "apps.apple.com"
    components.path = "/app/conjuguer/id\(RatingsFetcher.iTunesID)"
    return components.url ?? URL(filePath: "/")
  }

  static let developerEmail = "vermontcoder@gmail.com"

  nonisolated private static let mailtoUnreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

  /// A `mailto:` link with the subject and body filled in. Every character outside RFC 3986's
  /// unreserved set is percent-encoded, because a learner's query can hold &, =, #, or an accent.
  nonisolated static func mailto(_ address: String, subject: String, body: String) -> URL? {
    let encode = { (text: String) in text.addingPercentEncoding(withAllowedCharacters: mailtoUnreserved) ?? "" }
    return URL(string: "mailto:\(address)?subject=\(encode(subject))&body=\(encode(body))")
  }
}
