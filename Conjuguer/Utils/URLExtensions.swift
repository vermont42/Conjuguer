//
//  URLExtensions.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/20/21.
//

import Foundation

extension URL {
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
