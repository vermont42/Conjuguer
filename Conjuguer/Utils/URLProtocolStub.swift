//
//  URLProtocolStub.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/19/21.
//

import Foundation

nonisolated class URLProtocolStub: URLProtocol {
  nonisolated(unsafe) static var testURLs = [URL?: Data]()

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    if let url = request.url {
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
