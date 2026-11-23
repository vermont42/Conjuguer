//
//  QuizView.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/30/21.
//

import SwiftUI
import TipKit

struct QuizView: View {
  /// Nil for the Quiz tab. A scope makes this a sheet that starts that quiz as it appears and
  /// closes when the quiz ends.
  var sheetScope: QuizScope?

  @Environment(World.self) private var world
  @Environment(Quiz.self) var quiz
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.dismiss) private var dismiss
  @State private var input = ""
  @State private var tabScope = TabQuizScope.allVerbs
  @FocusState private var conjugationFieldIsFocused: Bool
  @State private var authCoordinator = GameCenterAuthCoordinator()
  private let feedbackSlotHeight: CGFloat = 64

  var body: some View {
    @Bindable var quiz = quiz
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      titleRow

      if quiz.quizState == .inProgress {
        inProgressContent
      }

      if quiz.quizState == .notStarted {
        if sheetScope == nil {
          GeometryReader { proxy in
            ScrollView {
              notStartedBriefing
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
          }
        } else {
          Spacer()
        }
      }

      if sheetScope == nil {
        GameCenterAuthView(coordinator: authCoordinator)
          .frame(width: 0, height: 0)
          .accessibilityHidden(true)
      }
    }
    .padding(.leading, Layout.doubleDefaultSpacing)
    .padding(.trailing, Layout.doubleDefaultSpacing)
    .padding(.top, Layout.tripleDefaultSpacing)
    .sheet(
      isPresented: $quiz.shouldShowResults,
      onDismiss: {
        quiz.shouldShowResults = false
        if sheetScope != nil {
          dismiss()
        } else if quiz.scope.isRanked {
          world.gameCenter.showLeaderboard()
        }
      },
      content: {
        QuizResultsView()
          .environment(quiz)
          .sheetDismissable()
      }
    )
    .onAppear {
      if let sheetScope {
        if quiz.quizState == .notStarted, !quiz.shouldShowResults {
          start(scope: sheetScope)
        }
        return
      }
      world.analytics.signal(name: .viewAppeared, parameters: [ParameterKey.viewName.rawValue: "\(QuizView.self)"])
      if quiz.quizState == .notStarted && !world.gameCenter.isAuthenticated {
        world.gameCenter.authenticate(onViewController: authCoordinator.viewController)
      }
    }
    .sensoryFeedback(trigger: quiz.quizResults.count) { _, newCount in
      guard newCount > 0 else {
        return nil
      }
      return quiz.previousIncorrectAnswer == nil ? .success : .error
    }
    .screenBackground()
  }

  private var titleRow: some View {
    HStack {
      Text(sheetScope?.title ?? L.Navigation.quiz)
        .headingLabel()
        .lineLimit(2)
        .minimumScaleFactor(0.7)

      Spacer()

      if quiz.quizState == .inProgress {
        Button(L.QuizView.quit) {
          quit()
        }
        .buttonLabel()
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .funButton(tint: .customRed)
      }
    }
  }

  private var inProgressContent: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        statusStrip
        questionBlock
        feedbackSlot
        answerField
      }
      .padding(.bottom, Layout.doubleDefaultSpacing)
    }
  }

  private var statusStrip: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      ProgressView(value: Double(quiz.currentQuestionIndex), total: Double(max(quiz.questions.count, 1)))
        .tint(Color.customBlue)
        .animation(.snappy, value: quiz.currentQuestionIndex)

      HStack {
        Text("\(quiz.currentQuestionIndex + 1) / \(quiz.questions.count)")
          .numericText()
          .animation(.snappy, value: quiz.currentQuestionIndex)

        Spacer()

        Text(L.QuizView.score(quiz.score))
          .numericText()
          .animation(.snappy, value: quiz.score)

        Spacer()

        HStack(spacing: Layout.defaultSpacing / 2) {
          Image(systemName: "clock")
          Text(quiz.elapsedTime.timeString)
            .numericText()
            .animation(.snappy, value: quiz.elapsedTime)
        }
      }
      .smallLabel()
    }
  }

  private var questionBlock: some View {
    Group {
      if quiz.currentQuestionIndex < quiz.questions.count {
        let verb = quiz.questions[quiz.currentQuestionIndex].verb
        let tense = quiz.questions[quiz.currentQuestionIndex].tense
        let tenseName = tense.titleCaseName.lowercased()
        let ask = tense.pronounWithGender == L.QuizView.none ? tenseName : "\(tense.pronounWithGender) · \(tenseName)"

        VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
          Text(verb.infinitifWithPossibleExtraLetters)
            .font(largeTitleFont)
            .foregroundStyle(Color.customForeground)
            .frenchPronunciation()

          Text(verb.translation)
            .smallLabel()
            .englishPronunciation()

          Text(ask)
            .font(buttonFont)
            .foregroundStyle(Color.customForeground)
            .frenchPronunciation()
            .padding(.top, Layout.defaultSpacing / 2)
        }
      }
    }
  }

  private var feedbackSlot: some View {
    HStack(alignment: .top, spacing: Layout.defaultSpacing) {
      if let result = quiz.quizResults.last {
        Image(systemName: result.conjugationResult.feedbackIconString)
          .font(.title2)
          .foregroundStyle(result.conjugationResult.feedbackColor)
          .symbolEffect(.bounce, value: quiz.quizResults.count)
          .accessibilityHidden(true)

        if
          let previousIncorrectAnswer = quiz.previousIncorrectAnswer,
          let previousCorrectAnswer = quiz.previousCorrectAnswer
        {
          VStack(alignment: .leading, spacing: 2) {
            lastAnswerText(previousIncorrectAnswer)
              .smallLabel()

            correctAnswerText(previousCorrectAnswer)
              .smallLabel()
          }
        }
      }
    }
    .frame(maxWidth: .infinity, minHeight: feedbackSlotHeight, alignment: .topLeading)
  }

  private var answerField: some View {
    TextField(L.QuizView.conjugation, text: $input)
      .focused($conjugationFieldIsFocused)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
      .font(bodyFont)
      .foregroundStyle(Color.customForeground)
      .padding(Layout.doubleDefaultSpacing)
      .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(Color.customForeground.opacity(0.06))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .strokeBorder(
            conjugationFieldIsFocused ? Color.customBlue : Color.customGray.opacity(0.4),
            lineWidth: conjugationFieldIsFocused ? 2 : 1
          )
      )
      .animation(.easeInOut(duration: 0.15), value: conjugationFieldIsFocused)
      .accessibilityIdentifier("input_quiz_conjugation")
      .accessibilityValue(input)
      .onSubmit {
        quiz.process(proposedAnswer: input)
        input = ""
        conjugationFieldIsFocused = true
      }
  }

  private var notStartedBriefing: some View {
    VStack(spacing: Layout.doubleDefaultSpacing) {
      Image(systemName: "graduationcap.fill")
        .font(.system(size: 44))
        .foregroundStyle(Color.customBlue)
        .accessibilityHidden(true)

      Text(L.QuizView.briefing)
        .bodyLabel()
        .multilineTextAlignment(.center)

      VStack(spacing: Layout.defaultSpacing) {
        Label(briefedDifficulty.localizedDifficultyWithLabel, systemImage: "speedometer")
        Label(L.QuizView.questionCount, systemImage: "list.number")
        if tabScope == .allVerbs, world.settings.bestScore > 0 {
          Label(L.QuizView.bestScore(world.settings.bestScore), systemImage: "trophy")
        }
      }
      .smallLabel()

      VStack(spacing: Layout.defaultSpacing) {
        Picker(L.QuizView.scope, selection: $tabScope.animation(.snappy)) {
          ForEach(TabQuizScope.allCases, id: \.self) { scope in
            Text(scope.displayName)
              .tag(scope)
          }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("quiz_scope_picker")

        if tabScope == .myVerbs {
          Text(myVerbsNote)
            .smallLabel()
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("quiz_my_verbs_note")
        }
      }
      .padding(.top, Layout.defaultSpacing)

      startButton
        .funButton()
        .disabled(tabScope == .myVerbs && myVerbs.isEmpty)
        .padding(.top, Layout.defaultSpacing)
    }
    .frame(maxWidth: .infinity)
    .card()
  }

  @ViewBuilder
  private var startButton: some View {
    let base = Button(L.QuizView.start) {
      start()
    }
    .buttonLabel()
    .lineLimit(1)
    .minimumScaleFactor(0.7)
    .accessibilityIdentifier("quiz_start_button")

    if reduceMotion {
      base
    } else {
      base.phaseAnimator([1.0, 1.1]) { content, scale in
        content.scaleEffect(scale)
      } animation: { _ in
        .easeInOut(duration: 0.9)
      }
    }
  }

  private var myVerbs: [Verb] {
    world.learnerVerbs.myVerbs
  }

  /// A My Verbs quiz asks Regular's mix whatever the setting (`Quiz.resetPublishedProperties`).
  private var briefedDifficulty: QuizDifficulty {
    tabScope == .allVerbs ? world.settings.quizDifficulty : .regular
  }

  private var myVerbsNote: String {
    myVerbs.isEmpty ? L.QuizView.myVerbsEmpty : L.QuizView.myVerbsCount(myVerbs.count)
  }

  private func start() {
    switch tabScope {
    case .allVerbs:
      start(scope: .allVerbs)
    case .myVerbs:
      start(scope: .myVerbs(myVerbs))
    }
    TryQuizTip().invalidate(reason: .actionPerformed)
  }

  private func start(scope: QuizScope) {
    quiz.start(scope: scope)
    Task { @MainActor in
      conjugationFieldIsFocused = true
    }
  }

  private func quit() {
    conjugationFieldIsFocused = false
    input = ""
    quiz.quit()
    if sheetScope != nil {
      dismiss()
    }
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

/// What the Quiz tab's picker offers. A quiz over one verb starts from that verb's page instead.
enum TabQuizScope: CaseIterable {
  case allVerbs
  case myVerbs

  var displayName: String {
    switch self {
    case .allVerbs:
      return L.QuizView.allVerbs
    case .myVerbs:
      return L.MyVerbs.title
    }
  }
}

/// A quiz in a sheet with its own `Quiz`: Test Me's three questions about the verb in view, or a
/// collection's thirty. The learner closes it onto the same page, and a quiz in the Quiz tab
/// carries on. While a question waits, the sheet closes only through Quit, so every quiz started
/// here ends with `quizQuit` or `quizCompletion`.
struct QuizSheet: View {
  let scope: QuizScope
  @State private var quiz = Quiz(gameCenter: Current.gameCenter)

  var body: some View {
    QuizView(sheetScope: scope)
      .environment(quiz)
      .interactiveDismissDisabled(quiz.quizState == .inProgress)
  }
}
