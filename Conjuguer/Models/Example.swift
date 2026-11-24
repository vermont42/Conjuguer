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

  /// Project Gutenberg's texts mark italics with underscores, mostly around titles
  /// ("L'_Assommoir_ est venu"), and the examples keep that markup as the source has it.
  var styledFrench: AttributedString {
    Self.styled(fr)
  }

  /// The French without its italics markup, for a surface that sets the whole line one way.
  var plainFrench: String {
    Self.hasBalancedMarkup(fr) ? fr.replacingOccurrences(of: "_", with: "") : fr
  }

  static func styled(_ text: String) -> AttributedString {
    guard hasBalancedMarkup(text) else {
      return AttributedString(text)
    }
    var result = AttributedString()
    for (index, piece) in text.components(separatedBy: "_").enumerated() {
      var part = AttributedString(piece)
      if index.isMultiple(of: 2) == false {
        part.inlinePresentationIntent = .emphasized
      }
      result.append(part)
    }
    return result
  }

  static func hasBalancedMarkup(_ text: String) -> Bool {
    text.filter { $0 == "_" }.count.isMultiple(of: 2)
  }
}
