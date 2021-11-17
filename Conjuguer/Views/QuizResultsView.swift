//
//  QuizResultsView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/7/21.
//

import SwiftUI

struct QuizResultsView: View {
  @EnvironmentObject var quiz: Quiz

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        Spacer()
          .frame(height: Layout.tripleDefaultSpacing)

        Text(L.Navigation.results)
          .modifier(HeadingLabel())
          .foregroundColor(.customBlue)

        Spacer()
          .frame(height: Layout.tripleDefaultSpacing)

        Text("\(L.QuizView.scoreWithColon) \(quiz.score)")
          .bodyLabel()

        Text("\(L.ResultsView.correctWithColon) \(quiz.numberCorrect.asFormattedNumberCorrect()) / \(quiz.questions.count)")
          .bodyLabel()

        Text(quiz.difficulty.localizedDifficultyWithLabel)
          .bodyLabel()

        Text("\(L.ResultsView.timeWithColon) \(quiz.elapsedTime.timeString)")
          .bodyLabel()

        ScrollView(.vertical) {
          ForEach(quiz.quizResults, id: \.infinitif) { quizResult in
            QuizResultView(quizResult: quizResult)
              .listRowSeparatorTint(.customForeground) // TODO: Make this work.
          }
        }
      }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, Layout.doubleDefaultSpacing)
        .padding(.trailing, Layout.doubleDefaultSpacing)
        .onAppear {
          Current.analytics.recordViewAppeared("\(QuizResultsView.self)")
        }
    }
  }
}
