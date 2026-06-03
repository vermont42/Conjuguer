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
    VStack {
      HStack {
        Spacer()

        Text(quizResult.infinitif)
          .subheadingLabel()

        Image(systemName: quizResult.conjugationResult.iconString)
          .foregroundStyle(Color.customGray)

        Spacer()
      }

      Text(quizResult.tense.titleCaseName + quizResult.tense.pronounDecorator)

      Text(mixedCaseString: quizResult.correctAnswer)
        .font(bodyFont)

      Text(mixedCaseString: quizResult.actualAnswer)
        .font(bodyFont)
    }
    .padding(.bottom, Layout.defaultSpacing)
  }
}
