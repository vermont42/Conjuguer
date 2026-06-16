//
//  URLProtocolStub.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/19/21.
//

import Foundation

nonisolated class URLProtocolStub: URLProtocol {
  // Safety invariant: test-only fixture. Tests populate `testURLs` before any request is
  // issued and never mutate it concurrently with the URL Loading System's reads, so the
  // unsynchronized access is safe in practice. Revisit (e.g. move behind a Mutex) if this
  // stub is ever driven from concurrent test cases.
  nonisolated(unsafe) static var testURLs = [URL?: Data]()

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    if let url = request.url {
      // The async URLSession.data(for:) API requires a non-nil URLResponse and traps without
      // one, so always supply a response even though the legacy dataTask path tolerated its
      // absence.
      if let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      if let data = URLProtocolStub.testURLs[url] {
        self.client?.urlProtocol(self, didLoad: data)
      }
    }
    self.client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() { }
}
