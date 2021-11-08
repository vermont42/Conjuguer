//
//  ResultsView.swift
//  Conjuguer
//
//  Created by Joshua Adams on 11/7/21.
//

import SwiftUI

struct ResultsView: View {
  @EnvironmentObject var quiz: Quiz

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        Spacer()
          .frame(height: Layout.tripleDefaultSpacing)

//        HStack {
//          Text(L.Navigation.results)
//            .modifier(HeadingLabel())
//            .foregroundColor(Color.customBlue)
//            .padding(.leading, Layout.doubleDefaultSpacing)
//
//          Spacer()
//        }

        Text(L.Navigation.results)
          .modifier(HeadingLabel())
          .foregroundColor(Color.customBlue)

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
          Text("\(quiz.score)")
          Text(quiz.numberCorrect.asFormattedNumberCorrect())
        }
      }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, Layout.doubleDefaultSpacing)
        .padding(.trailing, Layout.doubleDefaultSpacing)
    }
  }
}
