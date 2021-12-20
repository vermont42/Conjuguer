//
//  URLProtocolStub.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/19/21.
//

import Foundation

class URLProtocolStub: URLProtocol {
  static var testURLs = [URL?: Data]()

  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
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
