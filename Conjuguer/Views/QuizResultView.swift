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
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack {
        HStack {
          Spacer()

          Text(quizResult.infinitif)
            .subheadingLabel()

          Text("")

          Image(systemName: quizResult.conjugationResult.iconString)
            .foregroundColor(.customGray)

          Spacer()
        }

        Text(quizResult.tense.titleCaseName + quizResult.tense.pronounDecorator)

        Text(mixedCaseString: quizResult.correctAnswer)
          .font(bodyFont)

        Text(mixedCaseString: quizResult.actualAnswer)
          .font(bodyFont)

        Spacer()
          .frame(height: Layout.defaultSpacing)
      }
    }
  }
}
