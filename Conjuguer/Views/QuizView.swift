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
  @State private var inputSelection: TextSelection?
  @State private var tabScope = TabQuizScope.allVerbs
  @FocusState private var conjugationFieldIsFocused: Bool
  @AccessibilityFocusState private var correctionHasAccessibilityFocus: Bool
  @State private var authCoordinator = GameCenterAuthCoordinator()
  /// Pages opened from a held correction, pushed over the quiz, which waits beneath them.
  @State private var navigationPath = NavigationPath()
  private let feedbackSlotHeight: CGFloat = 36

  var body: some View {
    @Bindable var quiz = quiz
    NavigationStack(path: $navigationPath) {
      screen
        .toolbar(.hidden, for: .navigationBar)
        .verbPageNavigation(path: $navigationPath)
    }
    .environment(\.isBeneathQuiz, quiz.quizState == .inProgress)
    .accessibilityAction(.magicTap) {
      if quiz.correction != nil {
        continueAfterCorrection()
      }
    }
    // A quiz restarted by a link while a correction's page was open must not show that page.
    .onChange(of: quiz.correction == nil) { _, isReleased in
      if isReleased, !navigationPath.isEmpty {
        navigationPath = NavigationPath()
      }
    }
    // Back from a page opened from the correction, the keyboard returns, so Return continues.
    .onChange(of: navigationPath.isEmpty) { _, isEmpty in
      if isEmpty, quiz.correction != nil {
        refocusAnswer(after: .milliseconds(450))
      }
    }
    .sheet(
      isPresented: $quiz.shouldShowResults,
      onDismiss: {
        quiz.shouldShowResults = false
        if quiz.quizState == .inProgress {
          Task { @MainActor in
            conjugationFieldIsFocused = true
          }
        } else if sheetScope != nil {
          dismiss()
        } else if quiz.scope.isRanked {
          world.gameCenter.showLeaderboard(level: quiz.level)
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
      return quiz.quizResults.last?.conjugationResult == .noMatch ? .error : .success
    }
    .sensoryFeedback(.impact(weight: .light), trigger: quiz.isAwaitingSecondAttempt) { _, isAwaiting in
      isAwaiting
    }
  }

  private var screen: some View {
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
    ScrollViewReader { proxy in
      ScrollView {
        VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
          statusStrip
          questionBlock
          feedbackSlot
          answerField
          correctionBlock
        }
        .padding(.bottom, Layout.doubleDefaultSpacing)
      }
      .onChange(of: quiz.correction != nil) { _, isHeld in
        guard isHeld else {
          return
        }
        correctionHasAccessibilityFocus = true
        refocusAnswer(after: .milliseconds(50))
        withAnimation(reduceMotion ? nil : .default) {
          proxy.scrollTo(QuizCorrectionView.continueButtonID, anchor: .bottom)
        }
      }
    }
  }

  @ViewBuilder
  private var correctionBlock: some View {
    if let correction = quiz.correction, quiz.currentQuestionIndex < quiz.questions.count {
      QuizCorrectionView(
        question: quiz.questions[quiz.currentQuestionIndex],
        correction: correction,
        showsVerbLink: !quiz.scope.isVerbPage,
        accessibilityIsFocused: $correctionHasAccessibilityFocus,
        onOpen: { navigationPath.append($0) },
        onContinue: continueAfterCorrection
      )
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

        if quiz.showsClock {
          Spacer()

          HStack(spacing: Layout.defaultSpacing / 2) {
            Image(systemName: "clock")
            Text(quiz.elapsedTime.timeString)
              .numericText()
              .animation(.snappy, value: quiz.elapsedTime)
          }
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

        VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
          if quiz.questions[quiz.currentQuestionIndex].isReask {
            Label(L.QuizView.askedAgain, systemImage: "arrow.uturn.backward")
              .font(captionFont)
              .foregroundStyle(Color.customBlue)
              .padding(.horizontal, 10)
              .padding(.vertical, 4)
              .background(Color.customBlue.opacity(0.1), in: Capsule())
              .accessibilityIdentifier("quiz_asked_again")
          }

          Text(verb.infinitifWithPossibleExtraLetters)
            .font(largeTitleFont)
            .foregroundStyle(Color.customForeground)
            .frenchPronunciation()

          Text(verb.translation)
            .smallLabel()
            .englishPronunciation()

          Text(tenseName)
            .font(buttonFont)
            .foregroundStyle(Color.customForeground)
            .frenchPronunciation()
            .padding(.top, Layout.defaultSpacing / 2)
        }
      }
    }
  }

  /// The last answer's mark: a right answer's on the next question, a held one's on its own, and
  /// after a slip, the request for one more try. After Continue, the next question starts with a
  /// clear slot, since the correction has been read.
  private var feedbackSlot: some View {
    HStack(alignment: .top, spacing: Layout.defaultSpacing) {
      if quiz.isAwaitingSecondAttempt {
        Label(L.QuizView.almost, systemImage: "hand.raised.fill")
          .font(bodyEmphasisFont)
          .foregroundStyle(Color.secondAttempt)
          .transition(.opacity.combined(with: .scale(scale: 0.9)))
          .accessibilityIdentifier("quiz_almost")
      } else if let result = quiz.lastRoundResult, quiz.correction != nil || result.conjugationResult != .noMatch {
        Image(systemName: result.conjugationResult.feedbackIconString)
          .font(.title2)
          .foregroundStyle(result.conjugationResult.feedbackColor)
          .symbolEffect(.bounce, value: quiz.quizResults.count)
          .accessibilityHidden(true)

        if let shownSpelling = result.shownSpelling {
          Text(AttributedString(mixedCaseString: shownSpelling))
            .smallLabel()
            .accessibilityLabel("\(L.QuizView.alsoSpelledWithColon) \(shownSpelling.lowercased())")
            .accessibilityIdentifier("quiz_shown_spelling")
        }
      }
    }
    .frame(maxWidth: .infinity, minHeight: feedbackSlotHeight, alignment: .topLeading)
    .animation(reduceMotion ? nil : .default, value: quiz.isAwaitingSecondAttempt)
  }

  private var answerFrame: AnswerFrame {
    quiz.currentQuestionIndex < quiz.questions.count ? quiz.questions[quiz.currentQuestionIndex].answerFrame : .bareBlank
  }

  private var answerField: some View {
    let frame = answerFrame
    return AnswerFrameView(frame: frame) {
      conjugationField(spokenPrompt: frame.spokenPrompt)
    }
  }

  private func conjugationField(spokenPrompt: String) -> some View {
    TextField(L.QuizView.conjugation, text: $input, selection: $inputSelection)
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
      .accessibilityLabel(spokenPrompt)
      .accessibilityValue(input)
      .toolbar {
        ToolbarItem(placement: .keyboard) {
          FrenchLetterKeyRow { letter in
            insertLetter(letter)
          }
        }
      }
      .onSubmit {
        if quiz.correction != nil {
          continueAfterCorrection()
          return
        }
        quiz.process(proposedAnswer: input)
        if quiz.isAwaitingSecondAttempt {
          refocusAnswer(after: .milliseconds(50))
        } else if quiz.correction == nil {
          clearInput()
          conjugationFieldIsFocused = true
        }
      }
  }

  private func continueAfterCorrection() {
    clearInput()
    quiz.continueAfterCorrection()
    if quiz.quizState == .inProgress {
      conjugationFieldIsFocused = true
    } else {
      conjugationFieldIsFocused = false
    }
  }

  private func clearInput() {
    input = ""
    inputSelection = nil
  }

  /// Gives the answer field the keyboard while a correction is held, so that Return continues,
  /// and after a slip, so that the learner can edit the first attempt. Return resigns the field,
  /// and a push takes the keyboard away, yet the focus state can still read true afterward, so it
  /// is cleared and set again once the field is back on screen.
  private func refocusAnswer(after delay: Duration) {
    conjugationFieldIsFocused = false
    Task { @MainActor in
      try? await Task.sleep(for: delay)
      if navigationPath.isEmpty, quiz.correction != nil || quiz.isAwaitingSecondAttempt {
        conjugationFieldIsFocused = true
      }
    }
  }

  /// Replaces the selection, or inserts at the cursor, and leaves the cursor after the letter.
  private func insertLetter(_ letter: String) {
    guard
      case .selection(let range) = inputSelection?.indices,
      range.lowerBound >= input.startIndex,
      range.upperBound <= input.endIndex
    else {
      input.append(letter)
      return
    }
    let offset = input.distance(from: input.startIndex, to: range.lowerBound) + letter.count
    input.replaceSubrange(range, with: letter)
    inputSelection = TextSelection(insertionPoint: input.index(input.startIndex, offsetBy: offset))
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
        Label(world.settings.quizLevel.localizedNameWithLabel, systemImage: world.settings.quizLevel.systemImage)
        Label(L.QuizView.questionCount, systemImage: "list.number")
        let bestScore = world.settings.bestScore(at: world.settings.quizLevel)
        if tabScope == .allVerbs, bestScore > 0 {
          Label(L.QuizView.bestScore(bestScore), systemImage: "trophy")
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
    clearInput()
    quiz.quit()
    if sheetScope != nil {
      dismiss()
    }
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
/// collection's ten, which Ten More continues. The learner closes it onto the same page, and a quiz in the Quiz tab
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
