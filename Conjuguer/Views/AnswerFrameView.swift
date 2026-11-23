//
//  AnswerFrameView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

/// An `AnswerFrame` drawn on one line around a field: `nous [ ]`, `j' (fém.) [ ]`, or
/// `(tu) [ ]-toi !`. The frame's words are hidden from VoiceOver, since the field's label reads the
/// whole frame as one prompt (`AnswerFrame.spokenPrompt`).
struct AnswerFrameView<Field: View>: View {
  let frame: AnswerFrame
  @ViewBuilder let field: Field

  var body: some View {
    // The field sits outside both ForEaches, so that it keeps its identity, and the keyboard its
    // focus, when the next question's frame has different words around it.
    HStack(spacing: 0) {
      ForEach(Array(frame.leadingSegments.enumerated()), id: \.offset) { offset, segment in
        segmentView(segment)
          .padding(.trailing, spaceAfterLeadingSegment(at: offset))
      }

      field

      ForEach(Array(frame.trailingSegments.enumerated()), id: \.offset) { _, segment in
        segmentView(segment)
          .padding(.leading, Layout.defaultSpacing / 2)
      }
    }
  }

  @ViewBuilder
  private func segmentView(_ segment: AnswerFrame.Segment) -> some View {
    switch segment {
    case .pronoun(let text), .reflexiveSuffix(let text), .punctuation(let text):
      frameText(text, font: bodyEmphasisFont)
        .foregroundStyle(Color.customForeground)
    case .addressee(let text):
      frameText("(\(text))")
        .foregroundStyle(Color.customGray)
    case .gender(let isFeminine):
      frameText("(\(isFeminine ? L.PronounGender.feminineAbbreviation : L.PronounGender.masculineAbbreviation))", font: captionFont)
        .foregroundStyle(Color.customGray)
    case .blank:
      EmptyView()
    }
  }

  private func frameText(_ text: String, font: Font = bodyFont) -> some View {
    Text(verbatim: text)
      .font(font)
      .fixedSize()
      .accessibilityHidden(true)
  }

  /// The gender mark stays close to the pronoun it qualifies.
  private func spaceAfterLeadingSegment(at offset: Int) -> CGFloat {
    let next = frame.leadingSegments.indices.contains(offset + 1) ? frame.leadingSegments[offset + 1] : nil
    if case .gender = next {
      return Layout.defaultSpacing / 2
    }
    return Layout.defaultSpacing
  }
}
