//
//  QuizView.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/30/21.
//

import SwiftUI

struct QuizView: View {
  @Environment(World.self) private var world
  @Environment(Quiz.self) var quiz
  @State private var input = ""
  @FocusState private var conjugationFieldIsFocused: Bool
  @State private var authCoordinator = GameCenterAuthCoordinator()

  var body: some View {
    @Bindable var quiz = quiz
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.Navigation.quiz)
        .headingLabel()
        .foregroundStyle(Color.customBlue)

      if quiz.quizState == .inProgress {
        Text("\(L.QuizView.verbWithColon) \(quiz.questions[quiz.currentQuestionIndex].0.infinitifWithPossibleExtraLetters)")
          .constrainedBodyLabel()
          .frenchPronunciation()

        Text("\(L.QuizView.translationWithColon) \(quiz.questions[quiz.currentQuestionIndex].0.translation)")
          .constrainedBodyLabel()
          .englishPronunciation()

        Text("\(L.QuizView.pronounWithColon) \(quiz.questions[quiz.currentQuestionIndex].1.pronounWithGender)")
          .constrainedBodyLabel()
          .frenchPronunciation()

        Text("\(L.QuizView.tenseWithColon) \(quiz.questions[quiz.currentQuestionIndex].1.titleCaseName.lowercased())")
          .constrainedBodyLabel()
          .frenchPronunciation()

        HStack {
          Text("\(L.QuizView.progressWithColon) \(quiz.currentQuestionIndex + 1) / \(quiz.questions.count)")
            .constrainedBodyLabel()
            .foregroundStyle(Color.customBlue)

          Spacer()

          Text("\(L.QuizView.scoreWithColon) \(quiz.score)")
            .constrainedBodyLabel()
            .foregroundStyle(Color.customBlue)
        }

        HStack {
          Text("\(L.QuizView.elapsedWithColon) \(quiz.elapsedTime.timeString)")
            .constrainedBodyLabel()
            .foregroundStyle(Color.customBlue)

          Spacer()

          Button(L.QuizView.quit) {
            quit()
          }
          .buttonLabel()
          .funButton()
        }

        if
          let previousIncorrectAnswer = quiz.previousIncorrectAnswer,
          let previousCorrectAnswer = quiz.previousCorrectAnswer
        {
          lastAnswerText(previousIncorrectAnswer)
            .constrainedBodyLabel()

          correctAnswerText(previousCorrectAnswer)
            .constrainedBodyLabel()
        }

        TextField(L.QuizView.conjugation, text: $input)
          .focused($conjugationFieldIsFocused)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .accessibilityIdentifier("input_quiz_conjugation")
          .accessibilityValue(input)
          .onSubmit {
            quiz.process(proposedAnswer: input)
            input = ""
            conjugationFieldIsFocused = true
          }

        Spacer()
      }

      GameCenterAuthView(coordinator: authCoordinator)

      if quiz.quizState == .notStarted {
        Spacer()

        HStack {
          Spacer()

          Button(L.QuizView.start) {
            start()
          }
          .buttonLabel()
          .phaseAnimator([1.0, 1.1]) { content, scale in
            content.scaleEffect(scale)
          } animation: { _ in
            .easeInOut(duration: 0.9)
          }
          .funButton()

          Spacer()
        }
        .padding(.bottom, Layout.defaultSpacing)
      }
    }
    .padding(.leading, Layout.doubleDefaultSpacing)
    .padding(.trailing, Layout.doubleDefaultSpacing)
    .padding(.top, Layout.tripleDefaultSpacing)
    .sheet(
      isPresented: $quiz.shouldShowResults,
      onDismiss: {
        quiz.shouldShowResults = false
        world.gameCenter.showLeaderboard()
      },
      content: {
        QuizResultsView()
          .environment(quiz)
      }
    )
    .onAppear {
      world.analytics.recordViewAppeared("\(QuizView.self)")
      if quiz.quizState == .notStarted && !world.gameCenter.isAuthenticated {
        world.gameCenter.authenticate(onViewController: authCoordinator.viewController)
      }
    }
    .screenBackground()
  }

  private func start() {
    quiz.start()
    Task { @MainActor in
      conjugationFieldIsFocused = true
    }
  }

  private func quit() {
    conjugationFieldIsFocused = false
    input = ""
    quiz.quit()
  }

  private func lastAnswerText(_ incorrectAnswer: String) -> Text {
    var attributed = AttributedString("\(L.QuizView.lastAnswer) ")
    attributed.foregroundColor = Color.customRed
    attributed += AttributedString(incorrectAnswer)
    return Text(attributed)
  }

  private func correctAnswerText(_ correctAnswer: String) -> Text {
    var attributed = AttributedString("\(L.QuizView.correctAnswer) ")
    attributed.foregroundColor = Color.customBlue
    attributed += AttributedString(mixedCaseString: correctAnswer)
    return Text(attributed)
  }
}
