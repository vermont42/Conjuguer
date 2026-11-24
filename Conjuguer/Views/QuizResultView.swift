//
//  QuizResultView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/8/21.
//

import SwiftUI

struct QuizResultView: View {
  let quizResult: QuizResult

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing / 2) {
      HStack(spacing: Layout.defaultSpacing) {
        Image(systemName: quizResult.conjugationResult.feedbackIconString)
          .font(.title2)
          .foregroundStyle(quizResult.conjugationResult.feedbackColor)

        Text(quizResult.infinitif)
          .subheadingLabel()
      }

      Text(quizResult.tense.titleCaseName + quizResult.tense.pronounDecorator(pronounGender: quizResult.pronounGender ?? Current.settings.pronounGender))
        .smallLabel()

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
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.bottom, Layout.defaultSpacing)
  }

  private func answerText(label: String, answer: String) -> Text {
    var attributed = AttributedString("\(label) ")
    attributed.foregroundColor = Color.customGray
    attributed += AttributedString(mixedCaseString: answer)
    return Text(attributed)
      .font(bodyFont)
  }
}
