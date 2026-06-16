//
//  Example.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/16/26.
//

import Foundation

struct Example: Codable, Hashable {
  let fr: String
  let en: String
  let source: String
  let token: String
  let line: Int?

  var provenance: ExampleSource {
    ExampleSource(rawSource: source)
  }
}
