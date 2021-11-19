//
//  QuizView.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/30/21.
//

import SwiftUI

struct QuizView: View {
  @EnvironmentObject var current: World
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

        if current.quiz.quizState == .inProgress {
          Group {
            Text("\(L.QuizView.verbWithColon) \(current.quiz.questions[current.quiz.currentQuestionIndex].0.infinitifWithPossibleExtraLetters)")
              .bodyLabel()

            Spacer()
              .frame(height: Layout.defaultSpacing)

            Text("\(L.QuizView.translationWithColon) \(current.quiz.questions[current.quiz.currentQuestionIndex].0.translation)")
              .bodyLabel()
          }

          Spacer()
            .frame(height: Layout.defaultSpacing)

          Group {
            Text("\(L.QuizView.pronounWithColon) \(current.quiz.questions[current.quiz.currentQuestionIndex].1.pronounWithGender)")
              .bodyLabel()

            Spacer()
              .frame(height: Layout.defaultSpacing)

            Text("\(L.QuizView.tenseWithColon) \(current.quiz.questions[current.quiz.currentQuestionIndex].1.titleCaseName.lowercased())")
              .bodyLabel()

            Spacer()
              .frame(height: Layout.defaultSpacing)

            HStack {
              Text("\(L.QuizView.progressWithColon) \(current.quiz.currentQuestionIndex + 1) / \(current.quiz.questions.count)")
                .bodyLabel()
                .foregroundColor(.customBlue)

              Spacer()

              Text("\(L.QuizView.scoreWithColon) \(current.quiz.score)")
                .bodyLabel()
                .foregroundColor(.customBlue)
            }

            Spacer()
              .frame(height: Layout.defaultSpacing)

            HStack {
              Text("\(L.QuizView.elapsedWithColon) \(current.quiz.elapsedTime.timeString)")
                .bodyLabel()
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
              .onSubmit {
                current.quiz.process(proposedAnswer: input)
                input = ""
                conjugationFieldIsFocused = true
              }
          }

          Spacer()
        }

        if current.quiz.quizState == .notStarted {
          Spacer()

          gameCenterAuthView

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
          isPresented: $current.quiz.shouldShowResults,
          onDismiss: {
            current.quiz.shouldShowResults = false
            current.gameCenter.showLeaderboard()
          },
          content: {
            QuizResultsView()
              .environmentObject(current.quiz)
          }
        )
        .onAppear {
          current.analytics.recordViewAppeared("\(QuizView.self)")
          if current.quiz.quizState == .notStarted && !current.gameCenter.isAuthenticated {
            current.gameCenter.authenticate(onViewController: gameCenterAuthView.gameCenterAuthVC)
          }
        }
    }
  }

  private func quit() {
    SoundPlayer.play(Sound.randomSadTrombone)
    conjugationFieldIsFocused = false
    input = ""
    current.quiz.quit()
  }

  private func start() {
    current.quiz.start()
    let delayForFocus: TimeInterval = 0.1 // https://stackoverflow.com/a/69134653
    DispatchQueue.main.asyncAfter(deadline: .now() + delayForFocus) {
      conjugationFieldIsFocused = true
    }
  }
}
