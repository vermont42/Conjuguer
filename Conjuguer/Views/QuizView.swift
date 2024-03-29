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
  @State private var currentAnimationAmount = 2.5
  private let initialAnimationAmount = 2.5
  private let animationModifier = 1.5
  private let animationDuration = 2.0
  private let gameCenterAuthView = GameCenterAuthView()

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        Spacer()
          .frame(height: Layout.tripleDefaultSpacing)

        Text(L.Navigation.quiz)
          .headingLabel()
          .foregroundColor(.customBlue)

        Spacer()
          .frame(height: Layout.defaultSpacing)

        if quiz.quizState == .inProgress {
          Text("\(L.QuizView.verbWithColon) \(quiz.questions[quiz.currentQuestionIndex].0.infinitifWithPossibleExtraLetters)")
            .constrainedBodyLabel()
            .frenchPronunciation()

          Spacer()
            .frame(height: Layout.defaultSpacing)

          Text("\(L.QuizView.translationWithColon) \(quiz.questions[quiz.currentQuestionIndex].0.translation)")
            .constrainedBodyLabel()
            .englishPronunciation()

          Spacer()
            .frame(height: Layout.defaultSpacing)

          Text("\(L.QuizView.pronounWithColon) \(quiz.questions[quiz.currentQuestionIndex].1.pronounWithGender)")
            .constrainedBodyLabel()
            .frenchPronunciation()

          Spacer()
            .frame(height: Layout.defaultSpacing)

          Text("\(L.QuizView.tenseWithColon) \(quiz.questions[quiz.currentQuestionIndex].1.titleCaseName.lowercased())")
            .constrainedBodyLabel()
            .frenchPronunciation()

          Spacer()
            .frame(height: Layout.defaultSpacing)

          HStack {
            Text("\(L.QuizView.progressWithColon) \(quiz.currentQuestionIndex + 1) / \(quiz.questions.count)")
              .constrainedBodyLabel()
              .foregroundColor(.customBlue)

            Spacer()

            Text("\(L.QuizView.scoreWithColon) \(quiz.score)")
              .constrainedBodyLabel()
              .foregroundColor(.customBlue)
          }

          Spacer()
            .frame(height: Layout.defaultSpacing)

          HStack {
            Text("\(L.QuizView.elapsedWithColon) \(quiz.elapsedTime.timeString)")
              .constrainedBodyLabel()
              .foregroundColor(.customBlue)

            Spacer()

            Button(L.QuizView.quit) {
              quit()
            }
            .buttonLabel()
            .funButton()
          }

          TextField(L.QuizView.conjugation, text: $input)
            .focused($conjugationFieldIsFocused)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .onSubmit {
              quiz.process(proposedAnswer: input)
              input = ""
              conjugationFieldIsFocused = true
            }

          Spacer()
        }

        gameCenterAuthView

        if quiz.quizState == .notStarted {
          Spacer()

          HStack {
            Spacer()

            Button(L.QuizView.start) {
              start()
            }
            .buttonLabel()
            .onAppear {
              self.currentAnimationAmount = initialAnimationAmount - animationModifier
            }
            .onDisappear {
              self.currentAnimationAmount = initialAnimationAmount
            }
            .scaleEffect(currentAnimationAmount)
            .animation(.linear(duration: animationDuration), value: currentAnimationAmount)
            .funButton()

            Spacer()
          }

          Spacer()
            .frame(height: Layout.defaultSpacing)
        }
      }
      .padding(.leading, Layout.doubleDefaultSpacing)
      .padding(.trailing, Layout.doubleDefaultSpacing)
      .sheet(
        isPresented: $quiz.shouldShowResults,
        onDismiss: {
          quiz.shouldShowResults = false
          Current.gameCenter.showLeaderboard()
        },
        content: {
          QuizResultsView()
            .environmentObject(quiz)
        }
      )
      .onAppear {
        Current.analytics.recordViewAppeared("\(QuizView.self)")
        if quiz.quizState == .notStarted && !Current.gameCenter.isAuthenticated {
          Current.gameCenter.authenticate(onViewController: gameCenterAuthView.gameCenterAuthVC)
        }
      }
    }
  }

  private func start() {
    quiz.start()
    let delayForFocus: TimeInterval = 0.1 // https://stackoverflow.com/a/69134653
    DispatchQueue.main.asyncAfter(deadline: .now() + delayForFocus) {
      conjugationFieldIsFocused = true
    }
  }

  private func quit() {
    conjugationFieldIsFocused = false
    input = ""
    quiz.quit()
  }
}
