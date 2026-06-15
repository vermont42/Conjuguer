//
//  QuizResultsView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/7/21.
//

import SwiftUI

struct QuizResultsView: View {
  @Environment(World.self) private var world
  @Environment(Quiz.self) var quiz

  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        Text(L.Navigation.results)
          .headingLabel()

        VStack(alignment: .leading, spacing: 0) {
          Text(L.QuizView.scoreWithColon)
            .smallLabel()

          Text("\(quiz.score)")
            .font(Font.custom(workSansSemiBold, size: 64, relativeTo: .largeTitle))
            .foregroundStyle(Color.customBlue)
            .numericText()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
        .padding(.top, Layout.defaultSpacing)

        VStack(alignment: .leading, spacing: Layout.defaultSpacing / 2) {
          Text("\(L.ResultsView.correctWithColon) \(quiz.correctnessScore.asFormattedNumberCorrect()) / \(quiz.questions.count)")

          Text(quiz.difficulty.localizedDifficultyWithLabel)

          Text("\(L.ResultsView.timeWithColon) \(quiz.elapsedTime.timeString)")
        }
        .smallLabel()
      }

      List(quiz.quizResults) { quizResult in
        QuizResultView(quizResult: quizResult)
          .listRowBackground(Color.customBackground)
          .listRowSeparatorTint(.customForeground)
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.leading, Layout.doubleDefaultSpacing)
    .padding(.trailing, Layout.doubleDefaultSpacing)
    .padding(.top, Layout.tripleDefaultSpacing)
    .onAppear {
      world.analytics.recordViewAppeared("\(QuizResultsView.self)")
    }
    .screenBackground()
  }
}
