//
//  StringExtensions.swift
//  Conjuguer
//
//  Created by Josh Adams on 4/2/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import SwiftUI

enum RichTextBlock: Hashable {
  case body([TextSegment])
  case subheading(String)
}

enum ConjugationPart: Hashable {
  case irregular(String)
  case regular(String)
}

enum TextSegment: Hashable {
  case bold(String)
  case conjugation([ConjugationPart])
  case link(text: String, url: URL)
  case plain(String)
}

extension String {
  static var subheadingSeparator: Character {
    "`"
  }

  static var boldSeparator: Character {
    "~"
  }

  static var linkSeparator: Character {
    "%"
  }

  static var conjugationSeparator: Character {
    "$"
  }

  var etymologyAttributedString: AttributedString {
    var result = AttributedString()
    var isBold = false
    for segment in components(separatedBy: String(String.boldSeparator)) {
      var piece = AttributedString(segment)
      piece.foregroundColor = Color.customForeground
      piece.font = isBold ? bodyEmphasisFont : bodyFont
      result.append(piece)
      isBold.toggle()
    }
    return result
  }

  func trimmingLeadingNewlines() -> String {
    var result = self
    while result.hasPrefix("\n") {
      result.removeFirst()
    }
    return result
  }

  var richTextBlocks: [RichTextBlock] {
    var blocks: [RichTextBlock] = []
    var currentText = ""
    var inSubheading = false

    func flushBody() {
      let trimmed = currentText.trimmingLeadingNewlines()
      currentText = ""
      guard !trimmed.isEmpty else {
        return
      }
      blocks.append(.body(trimmed.bodySegments))
    }

    for char in self {
      if char == String.subheadingSeparator {
        if inSubheading {
          let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
          if !trimmed.isEmpty {
            blocks.append(.subheading(trimmed))
          }
          currentText = ""
          inSubheading = false
        } else {
          flushBody()
          inSubheading = true
        }
      } else {
        currentText.append(char)
      }
    }

    flushBody()

    return blocks
  }

  var bodySegments: [TextSegment] {
    var segments: [TextSegment] = []
    var currentText = ""
    var inBold = false
    var inLink = false
    var inConjugation = false
    var markupStart = startIndex

    func flushPlain() {
      guard !currentText.isEmpty else {
        return
      }
      segments.append(.plain(currentText))
      currentText = ""
    }

    func markupContent(endingAt index: Index) -> String {
      String(self[self.index(after: markupStart) ..< index])
    }

    for index in indices {
      let char = self[index]

      if char == String.boldSeparator {
        if inBold {
          let content = markupContent(endingAt: index)
          flushPlain()
          segments.append(.bold(content))
          inBold = false
        } else {
          flushPlain()
          inBold = true
          markupStart = index
        }
      } else if char == String.linkSeparator {
        if inLink {
          let content = markupContent(endingAt: index)
          flushPlain()
          segments.append(Self.linkSegment(for: content))
          inLink = false
        } else {
          flushPlain()
          inLink = true
          markupStart = index
        }
      } else if char == String.conjugationSeparator {
        if inConjugation {
          let content = markupContent(endingAt: index)
          flushPlain()
          segments.append(.conjugation(content.conjugationParts))
          inConjugation = false
        } else {
          flushPlain()
          inConjugation = true
          markupStart = index
        }
      } else if !inBold && !inLink && !inConjugation {
        currentText.append(char)
      }
    }

    flushPlain()

    if inBold || inLink || inConjugation {
      segments.append(.plain(String(self[self.index(after: markupStart)...])))
    }

    return segments
  }

  private static func linkSegment(for content: String) -> TextSegment {
    let urlString: String
    if content.hasPrefix("http") {
      urlString = content
    } else {
      urlString = content.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? content
    }
    if let url = URL(string: urlString) {
      return .link(text: content, url: url)
    }
    return .plain(content)
  }

  var conjugationParts: [ConjugationPart] {
    guard !isEmpty else {
      return []
    }

    var parts: [ConjugationPart] = []
    var currentRun = ""
    var currentIsIrregular: Bool?

    func flushRun() {
      guard !currentRun.isEmpty, let isIrregular = currentIsIrregular else {
        return
      }
      parts.append(isIrregular ? .irregular(currentRun) : .regular(currentRun))
      currentRun = ""
    }

    for char in self {
      let isIrregular = char.isUppercase
      if isIrregular != currentIsIrregular {
        flushRun()
        currentIsIrregular = isIrregular
      }
      currentRun += char.lowercased()
    }
    flushRun()

    return parts
  }
}
