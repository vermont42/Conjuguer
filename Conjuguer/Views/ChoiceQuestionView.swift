//
//  ChoiceQuestionView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import SwiftUI

/// A choice question's two sentences, each with its conjugation in bold and its tense named
/// beneath, and, once one is chosen, the reason and Continue.
struct ChoiceQuestionView: View {
  let choice: ChoicePrompt
  /// The chosen sentence, once the learner has chosen.
  let chosenIndex: Int?
  var reasonIsFocused: AccessibilityFocusState<Bool>.Binding
  let onChoose: (Int) -> Void
  let onContinue: () -> Void

  // As wide as an iPhone's, and no wider on an iPad, where the quiz spans the screen.
  private static let continueMaxWidth: CGFloat = 400

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
      Text(L.Choice.prompt)
        .font(subheadingFont)
        .foregroundStyle(Color.customBlue)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("choice_prompt")

      ForEach(Array(choice.options.enumerated()), id: \.offset) { index, option in
        optionButton(option, index: index)
      }

      Text(verbatim: choice.question.english)
        .translationLabel()
        .fixedSize(horizontal: false, vertical: true)
        .englishPronunciation()
        .accessibilityIdentifier("choice_english")

      if let chosenIndex {
        Label(choice.question.reason?.line ?? "", systemImage: "lightbulb.fill")
          .font(bodyFont)
          .foregroundStyle(Color.customForeground)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityElement(children: .ignore)
          .accessibilityLabel(spokenVerdict(isRight: chosenIndex == choice.rightIndex))
          .accessibilityFocused(reasonIsFocused)
          .accessibilityIdentifier("choice_reason")

        Button(action: onContinue) {
          Label(L.QuizView.continueAfterCorrection, systemImage: "arrow.right")
            .buttonLabel()
            .frame(maxWidth: Self.continueMaxWidth)
        }
        .funButton()
        .controlSize(.large)
        .frame(maxWidth: .infinity)
        .keyboardShortcut(.defaultAction)
        .accessibilityHint(L.QuizView.continueHint)
        .accessibilityIdentifier(QuizCorrectionView.continueButtonID)
        .id(QuizCorrectionView.continueButtonID)
      }
    }
  }

  private func optionButton(_ option: GapSentence, index: Int) -> some View {
    let isRight = index == choice.rightIndex
    let isChosen = index == chosenIndex
    let isAnswered = chosenIndex != nil
    let isMarked = isAnswered && (isRight || isChosen)
    let markColor = isRight ? ConjugationResult.totalMatch.feedbackColor : ConjugationResult.noMatch.feedbackColor
    let tenseName = option.tense?.titleCaseName.lowercased() ?? ""

    return Button {
      onChoose(index)
    } label: {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing / 2) {
        HStack(alignment: .firstTextBaseline, spacing: Layout.defaultSpacing) {
          Self.sentenceText(option.french)
            .font(bodyFont)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frenchPronunciation()
          Spacer(minLength: 0)
          if isMarked {
            Image(systemName: isRight ? "checkmark.circle.fill" : "xmark.circle.fill")
              .font(.title2)
              .foregroundStyle(markColor)
          }
        }
        Text(verbatim: tenseName)
          .font(captionFont)
          .foregroundStyle(Color.customGray)
          .frame(maxWidth: .infinity, alignment: .trailing)
          .frenchPronunciation()
      }
      .padding(Layout.doubleDefaultSpacing)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(Color.customForeground.opacity(0.06))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .strokeBorder(isMarked ? markColor : Color.customGray.opacity(0.4), lineWidth: isMarked ? 2 : 1)
      )
      .opacity(isAnswered && !isMarked ? 0.6 : 1)
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    // Not disabled, which would dim the right sentence just when the learner should read it.
    .allowsHitTesting(!isAnswered)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text(verbatim: "\(option.completed), \(tenseName)"))
    .accessibilityValue(accessibilityValue(isRight: isRight, isChosen: isChosen, isAnswered: isAnswered))
    .accessibilityHint(isAnswered ? "" : L.Choice.optionHint)
    .accessibilityAddTraits(.isButton)
    .accessibilityIdentifier("choice_option_\(index)")
  }

  private func accessibilityValue(isRight: Bool, isChosen: Bool, isAnswered: Bool) -> String {
    guard isAnswered else {
      return ""
    }
    return [isChosen ? L.Choice.yourChoice : nil, isRight ? L.Choice.rightChoice : nil]
      .compactMap { $0 }
      .joined(separator: ", ")
  }

  /// "Correct. Après si, …", or after a wrong choice, "Incorrect. The right choice: Si j’avais plus
  /// de temps, je voyagerais. Après si, …"
  private func spokenVerdict(isRight: Bool) -> String {
    let reason = choice.question.reason?.line ?? ""
    guard !isRight else {
      return "\(L.Choice.correct) \(reason)"
    }
    return "\(L.QuizView.incorrect) \(L.Choice.rightChoiceSentence(choice.question.rightSentence.completed)) \(reason)"
  }

  /// The sentence with its braced conjugation in bold blue.
  static func sentenceText(_ french: String) -> Text {
    var result = AttributedString()
    var piece = ""
    func flush(isConjugation: Bool) {
      guard !piece.isEmpty else {
        return
      }
      var part = AttributedString(piece)
      part.foregroundColor = isConjugation ? Color.customBlue : Color.customForeground
      if isConjugation {
        part.font = bodyEmphasisFont
      }
      result.append(part)
      piece = ""
    }
    for character in french {
      switch character {
      case "{":
        flush(isConjugation: false)
      case "}":
        flush(isConjugation: true)
      default:
        piece.append(character)
      }
    }
    flush(isConjugation: false)
    return Text(result)
  }
}
