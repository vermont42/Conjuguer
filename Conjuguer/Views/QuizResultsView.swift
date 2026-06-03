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
      VStack(alignment: .leading, spacing: 0) {
        Text(L.Navigation.results)
          .headingLabel()
          .foregroundStyle(Color.customBlue)

        Text("\(L.QuizView.scoreWithColon) \(quiz.score)")
          .bodyLabel()
          .padding(.top, Layout.tripleDefaultSpacing)

        Text("\(L.ResultsView.correctWithColon) \(quiz.numberCorrect.asFormattedNumberCorrect()) / \(quiz.questions.count)")
          .bodyLabel()

        Text(quiz.difficulty.localizedDifficultyWithLabel)
          .bodyLabel()

        Text("\(L.ResultsView.timeWithColon) \(quiz.elapsedTime.timeString)")
          .bodyLabel()
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
