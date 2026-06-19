//
//  WidgetEtymologyText.swift
//  ConjuguerWidget
//
//  Renders the app's `~bold~` etymology markup as a Text with bold spans.
//

import SwiftUI

extension Text {
  init(widgetEtymology etymologyString: String) {
    var attributedString = AttributedString()
    let segments = etymologyString.components(separatedBy: "~")
    for (index, segment) in segments.enumerated() {
      var part = AttributedString(segment)
      if index % 2 == 1 {
        part.inlinePresentationIntent = .stronglyEmphasized
      }
      attributedString.append(part)
    }
    self.init(attributedString)
  }
}
