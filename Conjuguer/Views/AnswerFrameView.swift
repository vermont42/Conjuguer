//
//  AnswerFrameView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

/// An `AnswerFrame` drawn around a field: on one line, `nous [ ]`, `j' (fém.) [ ]`, or
/// `(tu) [ ]-toi !`, or a sentence wrapped word by word. The frame's words are hidden from
/// VoiceOver, since the field's label reads the whole frame as one prompt
/// (`AnswerFrame.spokenPrompt`).
struct AnswerFrameView<Field: View>: View {
  let frame: AnswerFrame
  @ViewBuilder let field: Field

  var body: some View {
    if frame.isSentence {
      sentence
    } else {
      line
    }
  }

  // The field sits outside both ForEaches, so that it keeps its identity, and the keyboard its
  // focus, when the next question's frame has different words around it.
  private var line: some View {
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

  /// A sentence laid out word by word, wrapping between words, with a field of one width, so that
  /// its width does not hint at the answer's length. A word that touches the blank, such as j’,
  /// stays beside the field. The field is the same child from one sentence to the next, so the
  /// keyboard keeps its focus.
  private var sentence: some View {
    let words = frame.sentenceWords
    let marks = frame.leadingSegments.filter { segment in
      switch segment {
      case .addressee, .gender:
        return true
      default:
        return false
      }
    }
    return FlowLayout(spacing: wordSpacing) {
      ForEach(Array(words.before.enumerated()), id: \.offset) { _, word in
        frameText(word)
          .foregroundStyle(Color.customForeground)
      }

      HStack(spacing: 2) {
        if let touching = words.touchingBefore {
          frameText(touching)
            .foregroundStyle(Color.customForeground)
        }
        ForEach(Array(marks.enumerated()), id: \.offset) { _, mark in
          segmentView(mark)
            .padding(.trailing, 2)
        }
        field
          .frame(width: sentenceFieldWidth)
        if let touching = words.touchingAfter {
          frameText(touching)
            .foregroundStyle(Color.customForeground)
        }
      }

      ForEach(Array(words.after.enumerated()), id: \.offset) { _, word in
        frameText(word)
          .foregroundStyle(Color.customForeground)
      }
    }
  }

  /// About a space's width in the body font, so that the words read as a sentence.
  private var wordSpacing: CGFloat { 5 }
  private var sentenceFieldWidth: CGFloat { 170 }

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
    case .context(let text):
      frameText(text)
        .foregroundStyle(Color.customForeground)
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
