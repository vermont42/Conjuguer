//
//  URLSessionExtension.swift
//  Conjuguer
//
//  Created by Joshua Adams on 12/19/21.
//

import Foundation

extension URLSession {
  static func stubSession(ratingsCount: Int) -> URLSession {
    URLProtocolStub.testURLs = [RatingsFetcher.iTunesURL: RatingsFetcher.stubData(ratingsCount: ratingsCount)]
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [URLProtocolStub.self]
    return URLSession(configuration: config)
  }
}
