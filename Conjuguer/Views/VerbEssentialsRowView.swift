//
//  VerbEssentialsRowView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import SwiftUI

/// A row of Verb Essentials other than the one the answer field asks: a key conjugation already
/// answered, with how it went, one given as a hint in a re-ask, or one still to come. `QuizView`
/// draws the answer field's own row, keeping the field in one place in its hierarchy so that the
/// keyboard stays up as the field moves down the rows.
struct VerbEssentialsRowView: View {
  let row: Quiz.EssentialsRow

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing / 2) {
      VerbEssentialsRowLabel(tense: row.question.tense)

      AnswerFrameView(frame: row.question.answerFrame) {
        content
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(spokenRow)
  }

  @ViewBuilder
  private var content: some View {
    switch row.content {
    case .answered(let result):
      HStack(spacing: Layout.defaultSpacing) {
        Text(AttributedString(mixedCaseString: Self.shown(result.correctAnswer)))
          .font(bodyFont)
          .foregroundStyle(Color.customForeground)
        Spacer(minLength: 0)
        Image(systemName: result.conjugationResult.feedbackIconString)
          .font(.title3)
          .foregroundStyle(result.conjugationResult.feedbackColor)
      }
      .padding(.vertical, Layout.defaultSpacing)
    case .given(let conjugation):
      HStack {
        Text(AttributedString(mixedCaseString: Self.shown(conjugation)))
          .font(bodyFont)
          .foregroundStyle(Color.customGray)
        Spacer(minLength: 0)
      }
      .padding(.vertical, Layout.defaultSpacing)
    case .pending:
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .strokeBorder(Color.customGray.opacity(0.3), lineWidth: 1)
        .frame(maxWidth: .infinity, minHeight: 40)
    case .current:
      EmptyView()
    }
  }

  /// A cell's alternates, as the verb page shows them.
  private static func shown(_ conjugation: String) -> String {
    conjugation.replacingOccurrences(of: Tense.alternateConjugationSeparator, with: " / ")
  }

  /// "passé composé, il, singular, est venu, right", or for a row to come, "futur simple, il,
  /// singular, not yet asked".
  private var spokenRow: String {
    let prompt = row.question.answerFrame.spokenPrompt
      .replacingOccurrences(of: ", " + L.QuizView.blank, with: "")
    let lead = [row.question.tense.titleCaseName.lowercased(), prompt].joined(separator: ", ")
    switch row.content {
    case .answered(let result):
      let state = result.conjugationResult == .noMatch
        ? L.VerbEssentials.wrong
        : result.conjugationResult == .secondAttemptMatch ? L.VerbEssentials.rightOnSecondTry : L.VerbEssentials.right
      return [lead, Self.shown(result.correctAnswer).lowercased(), state].joined(separator: ", ")
    case .given(let conjugation):
      return [lead, Self.shown(conjugation).lowercased()].joined(separator: ", ")
    case .pending:
      return [lead, L.VerbEssentials.notYetAsked].joined(separator: ", ")
    case .current:
      return lead
    }
  }
}

/// The tense a row asks, above its conjugation.
struct VerbEssentialsRowLabel: View {
  let tense: Tense

  var body: some View {
    Text(tense.titleCaseName.lowercased())
      .font(captionFont)
      .foregroundStyle(Color.customBlue)
      .frenchPronunciation()
  }
}
