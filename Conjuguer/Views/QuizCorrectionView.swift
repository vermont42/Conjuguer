//
//  QuizCorrectionView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import SwiftUI

extension EnvironmentValues {
  /// True on the pages a quiz pushes over a held correction, which offer no quiz of their own.
  @Entry var isBeneathQuiz = false
}

/// A wrong or partly right answer, held: what the learner typed and the right answer, with the
/// letters that differ marked, links to the verb's page and its model's page, and Continue.
struct QuizCorrectionView: View {
  let question: QuizQuestion
  let correction: QuizCorrection
  /// False in a quiz begun from the verb's own page, where a link back to it would be circular.
  let showsVerbLink: Bool
  var accessibilityIsFocused: AccessibilityFocusState<Bool>.Binding
  let onOpen: (any Hashable) -> Void
  let onContinue: () -> Void

  static let continueButtonID = "quiz_continue_button"

  // As wide as an iPhone's, and no wider on an iPad, where the quiz spans the screen.
  private static let continueMaxWidth: CGFloat = 400
  private static let maxSpokenLetters = 3

  private var difference: AnswerDifference {
    correction.difference
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        answerRow(label: L.QuizView.yourAnswer, text: Self.givenText(difference))
        answerRow(label: L.QuizView.correctAnswer, text: Self.expectedText(difference))
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(spokenCorrection)
      .accessibilityHint(L.QuizView.correctionHint)
      .accessibilityFocused(accessibilityIsFocused)
      .accessibilityIdentifier("quiz_correction")

      HStack(spacing: Layout.defaultSpacing) {
        if showsVerbLink {
          link(Text(verbatim: question.verb.infinitifWithPossibleExtraLetters), systemImage: "book.fill", isFrench: true, identifier: "quiz_correction_verb") {
            onOpen(VerbDestination(
              verb: question.verb,
              source: .quizCorrection,
              marks: MarkedConjugations(tenses: [question.tense])
            ))
          }
        }
        if let model = VerbModel.models[question.verb.model] {
          link(modelText(model), systemImage: "key.fill", isFrench: false, identifier: "quiz_correction_model") {
            onOpen(ModelDestination(model: model))
          }
        }
      }

      Button(action: onContinue) {
        Label(L.QuizView.continueAfterCorrection, systemImage: "arrow.right")
          .buttonLabel()
          .frame(maxWidth: Self.continueMaxWidth)
      }
      .funButton()
      .controlSize(.large)
      .frame(maxWidth: .infinity)
      .accessibilityHint(L.QuizView.continueHint)
      .accessibilityIdentifier(Self.continueButtonID)
      .id(Self.continueButtonID)
    }
    .card(accent: correction.result.feedbackColor)
  }

  private func answerRow(label: String, text: Text) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(label)
        .smallLabel()
      text
        .font(bodyEmphasisFont)
        .fixedSize(horizontal: false, vertical: true)
        .frenchPronunciation()
    }
  }

  private func modelText(_ model: VerbModel) -> Text {
    Text(verbatim: "\(L.VerbView.modelWithColon) \(model.exemplar) (\(model.id))")
  }

  private func link(_ text: Text, systemImage: String, isFrench: Bool, identifier: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Label {
        text
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      } icon: {
        Image(systemName: systemImage)
      }
      .font(captionFont)
      .foregroundStyle(Color.customBlue)
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(Color.customBlue.opacity(0.1), in: Capsule())
    }
    .buttonStyle(.plain)
    .frenchPronunciation(forReal: isFrench)
    .accessibilityHint(L.QuizView.correctionLinkHint)
    .accessibilityIdentifier(identifier)
  }

  /// "Incorrect. Your Answer: parle. Correct Answer: parlé. Letters that differ: é." The letters
  /// are named only while there are few enough to help.
  private var spokenCorrection: String {
    let verdict = correction.result == .partialMatch ? L.QuizView.partlyRight : L.QuizView.incorrect
    let given = difference.given.isEmpty ? L.QuizView.none : difference.given
    var spoken = "\(verdict) \(L.QuizView.yourAnswer) \(given). \(L.QuizView.correctAnswer) \(difference.expected.lowercased())."
    let letters = difference.expectedMarkedLetters
    if !letters.isEmpty, letters.count <= Self.maxSpokenLetters {
      spoken += " " + L.QuizView.differingLetters(letters.joined(separator: ", "))
    }
    return spoken
  }

  // The red letters of a conjugation mark its irregularity, so a difference is shown another
  // way: a tinted background, struck through in the learner's answer and underlined in the right
  // one.
  static func givenText(_ difference: AnswerDifference) -> Text {
    guard !difference.given.isEmpty else {
      return Text(verbatim: "—").foregroundStyle(Color.customGray)
    }
    var result = AttributedString()
    for (character, isMarked) in zip(Array(difference.given), difference.givenMarks) {
      var part = AttributedString(String(character))
      part.foregroundColor = Color.customForeground
      if isMarked {
        part.foregroundColor = Color.customRed
        part.backgroundColor = Color.customRed.opacity(0.35)
        part.strikethroughStyle = Text.LineStyle(pattern: .solid, color: .customRed)
      }
      result.append(part)
    }
    return Text(result)
  }

  static func expectedText(_ difference: AnswerDifference) -> Text {
    var result = AttributedString()
    for (character, isMarked) in zip(Array(difference.expected), difference.expectedMarks) {
      let isIrregular = character.isLetter && !character.isLowercase
      var part = AttributedString(character.lowercased())
      part.foregroundColor = isIrregular ? Color.customRed : Color.customBlue
      if isMarked {
        part.backgroundColor = Color.customGreen.opacity(0.4)
        part.underlineStyle = Text.LineStyle(pattern: .solid, color: .customGreen)
      }
      result.append(part)
    }
    return Text(result)
  }
}
