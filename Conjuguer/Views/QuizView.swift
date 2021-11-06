//
//  QuizView.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/30/21.
//

import SwiftUI

struct QuizView: View {
  @EnvironmentObject var quiz: Quiz
  @State var input = ""
  @FocusState private var conjugationFieldIsFocused: Bool

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        Spacer()
          .frame(height: Layout.tripleDefaultSpacing)

        Text(L.Navigation.quiz)
          .headingLabel()
          .foregroundColor(Color.customBlue)

        Spacer()
          .frame(height: Layout.defaultSpacing)

        if quiz.quizState == .inProgress {
          Group {
            Text("\(L.Quiz.verbWithColon) \(quiz.questions[quiz.currentQuestionIndex].0.infinitifWithPossibleExtraLetters)")
              .bodyLabel()

            Spacer()
              .frame(height: Layout.defaultSpacing)

            Text("\(L.Quiz.translationWithColon) \(quiz.questions[quiz.currentQuestionIndex].0.translation)")
              .bodyLabel()
          }

          Spacer()
            .frame(height: Layout.defaultSpacing)

          Group {
            Text("\(L.Quiz.pronounWithColon) \(quiz.questions[quiz.currentQuestionIndex].1.pronounString)")
              .bodyLabel()

            Spacer()
              .frame(height: Layout.defaultSpacing)

            Text("\(L.Quiz.tenseWithColon) \(quiz.questions[quiz.currentQuestionIndex].1.titleCaseName.lowercased())")
              .bodyLabel()

            Spacer()
              .frame(height: Layout.defaultSpacing)

            HStack {
              Text("\(L.Quiz.progressWithColon) \(quiz.currentQuestionIndex + 1) / \(quiz.questions.count)")
                .bodyLabel()
                .foregroundColor(Color.customBlue)

              Spacer()

              Text("\(L.Quiz.scoreWithColon) \(quiz.score)")
                .bodyLabel()
                .foregroundColor(Color.customBlue)
            }

            Spacer()
              .frame(height: Layout.defaultSpacing)

            HStack {
              Text("\(L.Quiz.elapsedWithColon) \(quiz.elapsedTime)")
                .bodyLabel()
                .foregroundColor(Color.customBlue)

              Spacer()

              Button(L.Quiz.quit) {
                quit()
              }
              .buttonLabel()
              .foregroundColor(Color.customRed)
            }

            TextField(L.Quiz.conjugation, text: $input)
              .focused($conjugationFieldIsFocused)
              .autocapitalization(.none)
              .onSubmit {
                quiz.process(proposedAnswer: input)
                input = ""
                conjugationFieldIsFocused = true
              }
          }

          Spacer()
        }

        if quiz.quizState == .notStarted {
          Spacer()

          HStack {
            Spacer()

            Button(L.Quiz.start) {
              start()
            }
            .buttonLabel()
            .foregroundColor(Color.customRed)

            Spacer()
          }

          Spacer()
            .frame(height: Layout.defaultSpacing)
        }
      }
    }
    .padding(.leading, Layout.doubleDefaultSpacing)
    .padding(.trailing, Layout.doubleDefaultSpacing)
    .alert(String(format: L.Quiz.quizComplete, quiz.lastScore), isPresented: $quiz.shouldShowLastScore) {
      Button(L.Quiz.cool, role: .cancel) {
        quiz.shouldShowLastScore = false
      }
    }
  }

  private func quit() {
    SoundPlayer.play(Sound.randomSadTrombone)
    conjugationFieldIsFocused = false
    input = ""
    quiz.quit()
  }

  private func start() {
    quiz.start()
    let delayForFocus: TimeInterval = 0.1 // https://stackoverflow.com/a/69134653
    DispatchQueue.main.asyncAfter(deadline: .now() + delayForFocus) {
      conjugationFieldIsFocused = true
    }
  }
}
