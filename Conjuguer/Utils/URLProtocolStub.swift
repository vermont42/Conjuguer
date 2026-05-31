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
      if let data = URLProtocolStub.testURLs[url] {
        self.client?.urlProtocol(self, didLoad: data)
      }
    }
    self.client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() { }
}
