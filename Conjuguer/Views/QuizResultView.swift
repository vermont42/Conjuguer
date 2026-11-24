//
//  QuizResultView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/8/21.
//

import SwiftUI

struct QuizResultView: View {
  let quizResult: QuizResult
  /// The verb's example sentence, offered on the first right answer of each verb: a reward shown
  /// after the quiz, never during it, since the quiz moves on at once after a right answer.
  var example: Example?
  @State private var isShowingExample = false

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing / 2) {
      HStack(spacing: Layout.defaultSpacing) {
        Image(systemName: quizResult.conjugationResult.feedbackIconString)
          .font(.title2)
          .foregroundStyle(quizResult.conjugationResult.feedbackColor)

        if let prompt = quizResult.recognitionPrompt {
          Text(AttributedString(mixedCaseString: prompt))
            .subheadingLabel()
        } else {
          Text(quizResult.infinitif)
            .subheadingLabel()
        }
      }

      if quizResult.recognitionPrompt == nil {
        Text(quizResult.tense.titleCaseName + quizResult.tense.pronounDecorator(pronounGender: quizResult.pronounGender ?? Current.settings.pronounGender))
          .smallLabel()
      }

      if let sentence = quizResult.sentence {
        Text(verbatim: sentence)
          .font(bodyFont)
          .italic()
          .foregroundStyle(Color.customForeground)
          .fixedSize(horizontal: false, vertical: true)
          .frenchPronunciation()
      }

      if quizResult.isReask {
        Text(L.QuizView.askedAgain)
          .smallLabel()
          .foregroundStyle(Color.customBlue)
      }

      if let firstAttempt = quizResult.firstAttempt {
        answerText(label: L.ResultsView.firstTryWithColon, answer: firstAttempt)
      }
      answerText(label: L.ResultsView.yourAnswerWithColon, answer: quizResult.actualAnswer)
      answerText(label: L.ResultsView.correctWithColon, answer: quizResult.correctAnswer)

      if let example {
        exampleReward(example)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.bottom, Layout.defaultSpacing)
  }

  @ViewBuilder
  private func exampleReward(_ example: Example) -> some View {
    Button {
      withAnimation {
        isShowingExample.toggle()
      }
    } label: {
      // Not a Label, which a List lays out with its icon in a column of its own.
      HStack(spacing: 4) {
        Image(systemName: isShowingExample ? "quote.bubble.fill" : "quote.bubble")
        Text(L.VerbView.exampleUse)
      }
      .font(captionFont)
      .foregroundStyle(Color.customBlue)
    }
    // Borderless, so that only the button, not the whole row, takes the tap.
    .buttonStyle(.borderless)
    .padding(.top, Layout.defaultSpacing / 2)
    .accessibilityAddTraits(isShowingExample ? .isSelected : [])
    .accessibilityHint(L.ResultsView.exampleHint)
    .accessibilityIdentifier("results_example_\(quizResult.verbKey ?? quizResult.infinitif)")

    if isShowingExample {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing / 2) {
        Text(example.styledFrench)
          .bodyLabel()
          .frenchPronunciation()
        Text(example.en)
          .translationLabel()
          .englishPronunciation()
        Text(example.provenance.attribution)
          .smallLabel()
      }
      .fixedSize(horizontal: false, vertical: true)
      .padding(.leading, Layout.defaultSpacing)
      .accessibilityIdentifier("results_example_text")
    }
  }

  private func answerText(label: String, answer: String) -> Text {
    var attributed = AttributedString("\(label) ")
    attributed.foregroundColor = Color.customGray
    attributed += AttributedString(mixedCaseString: answer)
    return Text(attributed)
      .font(bodyFont)
  }
}
