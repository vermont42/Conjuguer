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
  @State private var recognitionSlot: QuizTenseSlot?
  @State private var recognitionPerson: PersonNumber?
  @FocusState private var conjugationFieldIsFocused: Bool
  @AccessibilityFocusState private var correctionHasAccessibilityFocus: Bool
  @AccessibilityFocusState private var choiceReasonHasAccessibilityFocus: Bool
  @State private var authCoordinator = GameCenterAuthCoordinator()
  /// `GameCenter` is not observable, so the tab keeps its own copy for the leaderboard button.
  @State private var isSignedInToGameCenter = false
  /// Pages opened from a held correction, pushed over the quiz, which waits beneath them.
  @State private var navigationPath = NavigationPath()
  @State private var isShowingQRCode = false
  @State private var shareButtonFrame = CGRect.zero
  private let feedbackSlotHeight: CGFloat = 36

  var body: some View {
    @Bindable var quiz = quiz
    NavigationStack(path: $navigationPath) {
      screen
        .toolbar(.hidden, for: .navigationBar)
        .verbPageNavigation(path: $navigationPath)
        .navigationDestination(for: CustomQuizDestination.self) { destination in
          switch destination {
          case .editor:
            CustomQuizEditor()
          case .models:
            CustomQuizModelList()
          }
        }
        .navigationDestination(for: ModelPracticeDestination.self) { _ in
          ModelPracticeListView()
        }
        .navigationDestination(for: MasteryDestination.self) { _ in
          MasteryView()
        }
    }
    .environment(\.isBeneathQuiz, quiz.quizState == .inProgress)
    .accessibilityAction(.magicTap) {
      if quiz.isHeld {
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
      isSignedInToGameCenter = world.gameCenter.isAuthenticated
      if quiz.quizState == .notStarted && !world.gameCenter.isAuthenticated {
        world.gameCenter.authenticate(onViewController: authCoordinator.viewController) { _ in
          Task { @MainActor in
            isSignedInToGameCenter = world.gameCenter.isAuthenticated
          }
        }
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
              VStack(spacing: Layout.doubleDefaultSpacing) {
                notStartedBriefing
                recordSessions
                exercises
                competitionFoot
              }
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
      Text(sheetScope?.title ?? tabSessionTitle ?? L.Navigation.quiz)
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

  /// Review, My Mistakes, or Verb Essentials names itself in the title, since its questions look
  /// like any quiz's.
  private var tabSessionTitle: String? {
    guard sheetScope == nil, quiz.quizState == .inProgress || quiz.shouldShowResults else {
      return nil
    }
    return quiz.scope.sessionTitle
  }

  // A Verb Essentials verb shows its three rows, with the answer field in the current one. The
  // rows before and after the field are separate children around it, so that the field keeps its
  // place in the hierarchy, and the keyboard its focus, as it moves down the rows.
  private var inProgressContent: some View {
    let essentialsRows = quiz.essentialsRows
    let currentRowIndex = essentialsRows?.firstIndex { row in
      if case .current = row.content {
        return true
      }
      return false
    }
    let currentRow = currentRowIndex.flatMap { essentialsRows?[$0] }
    return ScrollViewReader { proxy in
      ScrollView {
        VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
          statusStrip
          questionBlock(showsTense: essentialsRows == nil)
          if let essentialsRows, let currentRowIndex {
            ForEach(essentialsRows.prefix(currentRowIndex)) { row in
              VerbEssentialsRowView(row: row)
            }
          }
          // A Verb Essentials row shows its own answer's mark, so the slot shows only a request
          // for one more try.
          if essentialsRows == nil || quiz.isAwaitingSecondAttempt {
            feedbackSlot
          }
          // The choices come before the field, so that they stay in sight above the keyboard and
          // Return can check the answer once the infinitive is typed.
          if let recognition = quiz.currentQuestion?.recognition {
            RecognitionChoicesView(
              recognition: recognition,
              slot: $recognitionSlot,
              personNumber: $recognitionPerson,
              isLocked: quiz.correction != nil
            )
          }
          if let choice = quiz.currentQuestion?.choice {
            ChoiceQuestionView(
              choice: choice,
              chosenIndex: quiz.heldChoice,
              reasonIsFocused: $choiceReasonHasAccessibilityFocus,
              onChoose: { quiz.submitChoice($0) },
              onContinue: continueAfterCorrection
            )
          } else {
            answerBlock(currentRow: currentRow)
          }
          if quiz.currentQuestion?.recognition != nil, quiz.correction == nil {
            recognitionCheckButton
          }
          correctionBlock
          if let essentialsRows, let currentRowIndex {
            ForEach(essentialsRows.dropFirst(currentRowIndex + 1)) { row in
              VerbEssentialsRowView(row: row)
            }
          }
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
      // A choice's reason and Continue appear below its sentences, out of sight on a small screen.
      .onChange(of: quiz.heldChoice != nil) { _, isHeld in
        guard isHeld else {
          return
        }
        choiceReasonHasAccessibilityFocus = true
        withAnimation(reduceMotion ? nil : .default) {
          proxy.scrollTo(QuizCorrectionView.continueButtonID, anchor: .bottom)
        }
      }
      // A choice question has no field, so the next question's field takes the keyboard once it
      // is back on screen.
      .onChange(of: quiz.currentQuestion?.choice != nil) { _, isChoice in
        guard !isChoice, quiz.quizState == .inProgress else {
          return
        }
        refocusField(after: .milliseconds(100))
      }
    }
  }

  private func answerBlock(currentRow: Quiz.EssentialsRow?) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing / 2) {
      if let currentRow {
        VerbEssentialsRowLabel(tense: currentRow.question.tense)
          .accessibilityHidden(true)
      }
      if quiz.currentQuestion?.recognition != nil {
        Text(L.Recognition.infinitive)
          .font(captionFont)
          .foregroundStyle(Color.customBlue)
          .accessibilityHidden(true)
      }
      answerField(spokenPrefix: currentRow?.question.tense.titleCaseName.lowercased())
      if let sentence = quiz.currentQuestion?.sentence {
        Text(verbatim: sentence.english)
          .translationLabel()
          .fixedSize(horizontal: false, vertical: true)
          .englishPronunciation()
          .padding(.top, Layout.defaultSpacing / 2)
          .accessibilityIdentifier("quiz_sentence_english")
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

  @ViewBuilder
  private var statusStrip: some View {
    if quiz.scope.isSpeedRound {
      speedRoundStatusStrip
    } else {
      questionStatusStrip
    }
  }

  /// The right answers so far and the time left, shown whatever the clock setting, since this is
  /// the one place where the clock counts. Its questions are drawn as it goes, so the bar is the
  /// minute, and its last seconds are red.
  private var speedRoundStatusStrip: some View {
    let secondsLeft = quiz.speedRoundSecondsLeft
    let tint = secondsLeft <= SpeedRound.warningSecondsLeft ? Color.customRed : Color.customBlue
    return VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      ProgressView(value: Double(secondsLeft), total: Double(SpeedRound.duration))
        .tint(tint)
        .animation(.linear(duration: 1), value: secondsLeft)
        .accessibilityHidden(true)

      // Symbols rather than words, which would wrap in French beside the time; VoiceOver reads the
      // words.
      HStack {
        HStack(spacing: Layout.defaultSpacing / 2) {
          Image(systemName: ConjugationResult.totalMatch.feedbackIconString)
            .foregroundStyle(ConjugationResult.totalMatch.feedbackColor)
          Text(verbatim: "\(quiz.correctCount)")
            .numericText()
            .animation(.snappy, value: quiz.correctCount)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L.SpeedRound.rightAnswers(quiz.correctCount))
        .accessibilityIdentifier("speed_round_right_answers")

        Spacer()

        HStack(spacing: Layout.defaultSpacing / 2) {
          Image(systemName: "timer")
          Text(verbatim: secondsLeft.timeString)
            .contentTransition(.numericText(countsDown: true))
            .animation(.snappy, value: secondsLeft)
        }
        .foregroundStyle(tint == .customRed ? Color.customRed : Color.customForeground)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L.SpeedRound.timeLeft(secondsLeft.timeString))
        .accessibilityIdentifier("speed_round_time_left")
      }
      .font(buttonFont.monospacedDigit())
    }
  }

  private var questionStatusStrip: some View {
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

  private func questionBlock(showsTense: Bool) -> some View {
    Group {
      if quiz.currentQuestionIndex < quiz.questions.count {
        let question = quiz.questions[quiz.currentQuestionIndex]
        let verb = question.verb
        let tenseName = question.tense.titleCaseName.lowercased()

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

          // Only a debug build asks a sentence or a choice that has not been approved.
          if question.sentence?.reviewed == false || question.choice?.question.reviewed == false {
            Label(L.Sentences.draft, systemImage: "pencil.and.list.clipboard")
              .font(captionFont)
              .foregroundStyle(Color.customGray)
              .accessibilityIdentifier("quiz_sentence_draft")
          }

          // The verb, its gloss, and its tense are what a recognition question asks for, so none
          // is shown.
          if let recognition = question.recognition {
            RecognitionPromptView(prompt: recognition.prompt)
          } else if let setting = question.choice?.question.setting {
            // The setting decides the choice, so it takes the verb's place, with its gloss.
            Text(verbatim: setting.french)
              .font(largeTitleFont)
              .foregroundStyle(Color.customForeground)
              .fixedSize(horizontal: false, vertical: true)
              .frenchPronunciation()
              .accessibilityIdentifier("choice_setting")

            Text(verbatim: setting.english)
              .smallLabel()
              .englishPronunciation()
          } else {
            Text(verb.infinitifWithPossibleExtraLetters)
              .font(largeTitleFont)
              .foregroundStyle(Color.customForeground)
              .frenchPronunciation()

            Text(verb.translation)
              .smallLabel()
              .englishPronunciation()
          }

          if showsTense, question.recognition == nil, question.choice == nil {
            Text(tenseName)
              .font(buttonFont)
              .foregroundStyle(Color.customForeground)
              .frenchPronunciation()
              .padding(.top, Layout.defaultSpacing / 2)
          }
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
        Label(quiz.secondAttemptPrompt, systemImage: "hand.raised.fill")
          .font(bodyEmphasisFont)
          .foregroundStyle(Color.secondAttempt)
          .fixedSize(horizontal: false, vertical: true)
          .transition(.opacity.combined(with: .scale(scale: 0.9)))
          .accessibilityIdentifier("quiz_almost")
      } else if let miss = quiz.speedRoundMiss {
        SpeedRoundMissLine(miss: miss)
      } else if let result = quiz.lastRoundResult, quiz.isHeld || result.conjugationResult != .noMatch {
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

  /// `spokenPrefix` names a Verb Essentials row's tense, which the screen shows above the field
  /// rather than in the frame.
  private func answerField(spokenPrefix: String?) -> some View {
    let frame = answerFrame
    let isRecognition = quiz.currentQuestion?.recognition != nil
    let spokenPrompt = isRecognition ? L.Recognition.infinitive : [spokenPrefix, frame.spokenPrompt].compactMap { $0 }.joined(separator: ", ")
    return AnswerFrameView(frame: frame) {
      conjugationField(
        placeholder: isRecognition ? L.Recognition.infinitive : L.QuizView.conjugation,
        spokenPrompt: spokenPrompt,
        hint: isRecognition ? L.Recognition.fieldHint : nil,
        isCompact: frame.isSentence
      )
    }
  }

  private func conjugationField(placeholder: String, spokenPrompt: String, hint: String?, isCompact: Bool) -> some View {
    TextField(placeholder, text: $input, selection: $inputSelection)
      .focused($conjugationFieldIsFocused)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
      .font(bodyFont)
      .foregroundStyle(Color.customForeground)
      .padding(.horizontal, isCompact ? Layout.defaultSpacing * 1.5 : Layout.doubleDefaultSpacing)
      .padding(.vertical, isCompact ? Layout.defaultSpacing : Layout.doubleDefaultSpacing)
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
      .accessibilityHint(hint ?? "")
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
        submit()
      }
  }

  private func submit() {
    if quiz.currentQuestion?.recognition != nil {
      guard let answer = recognitionAnswer else {
        // Return with a part missing: the field keeps the keyboard, and VoiceOver says what is
        // missing.
        UIAccessibility.post(notification: .announcement, argument: L.Recognition.incomplete)
        refocusField(after: .milliseconds(50))
        return
      }
      quiz.submitRecognition(answer)
    } else {
      quiz.process(proposedAnswer: input)
    }
    if quiz.isAwaitingSecondAttempt {
      refocusAnswer(after: .milliseconds(50))
    } else if quiz.correction == nil {
      clearInput()
      conjugationFieldIsFocused = true
    }
  }

  /// The recognition answer the card holds, or nil until the infinitive, the tense, and, unless
  /// it is a participle, the person are all given.
  private var recognitionAnswer: RecognitionAnswer? {
    guard let recognitionSlot, !input.trimmingCharacters(in: .whitespaces).isEmpty else {
      return nil
    }
    let answer = RecognitionAnswer(infinitif: input, slot: recognitionSlot, personNumber: recognitionPerson)
    return answer.tense == nil ? nil : answer
  }

  private var recognitionCheckButton: some View {
    Button {
      submit()
    } label: {
      Label(L.Recognition.check, systemImage: "checkmark")
        .buttonLabel()
        .frame(maxWidth: 400)
    }
    .funButton()
    .frame(maxWidth: .infinity)
    .disabled(recognitionAnswer == nil)
    .accessibilityHint(L.Recognition.checkHint)
    .accessibilityIdentifier("recognition_check_button")
  }

  private func refocusField(after delay: Duration) {
    conjugationFieldIsFocused = false
    Task { @MainActor in
      try? await Task.sleep(for: delay)
      conjugationFieldIsFocused = true
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
    recognitionSlot = nil
    recognitionPerson = nil
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
        .fixedSize(horizontal: false, vertical: true)

      VStack(spacing: Layout.doubleDefaultSpacing) {
        Picker(L.QuizView.scope, selection: $tabScope.animation(.snappy)) {
          ForEach(TabQuizScope.allCases, id: \.self) { scope in
            Text(scope.displayName)
              .tag(scope)
          }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("quiz_scope_picker")

        switch tabScope {
        case .allVerbs:
          sessionFacts
        case .myVerbs:
          sessionFacts
          Text(myVerbsNote)
            .smallLabel()
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("quiz_my_verbs_note")
        case .custom:
          customQuizSummary
        }
      }

      startButton
        .funButton()
        .disabled(!canStart)
        .padding(.top, Layout.defaultSpacing)
    }
    .frame(maxWidth: .infinity)
    .card()
  }

  private var sessionFacts: some View {
    HStack(alignment: .top, spacing: Layout.defaultSpacing) {
      QuizFactTile(systemImage: "list.number", value: "\(Quiz.questionCount)", label: L.QuizView.questionsLabel)
      QuizFactTile(systemImage: "timer", value: L.QuizView.sessionMinutes, label: L.QuizView.minutesLabel, accessibilityLabel: L.QuizView.sessionLength)
      levelMenu
    }
    // Equal heights when one label wraps to two lines.
    .fixedSize(horizontal: false, vertical: true)
    .transition(.opacity)
  }

  private var levelMenu: some View {
    let settings = world.settings
    return Menu {
      Picker(L.QuizView.levelLabel, selection: Binding(get: { settings.quizLevel }, set: { settings.quizLevel = $0 })) {
        ForEach(QuizLevel.allCases, id: \.self) { quizLevel in
          Label(quizLevel.localizedName, systemImage: quizLevel.systemImage)
            .tag(quizLevel)
        }
      }
    } label: {
      QuizFactTile(systemImage: level.systemImage, value: level.localizedName, label: L.QuizView.levelLabel, showsMenuIndicator: true)
    }
    .buttonStyle(.plain)
    .accessibilityHint(L.QuizView.levelMenuHint)
    .accessibilityIdentifier("quiz_level_menu")
    .sensoryFeedback(.selection, trigger: settings.quizLevel)
    .onChange(of: settings.quizLevel) {
      ChangeLevelTip().invalidate(reason: .actionPerformed)
    }
  }

  /// The best score and the leaderboard sit below everything else, since competing is beside the
  /// point of practice, though one tap away.
  @ViewBuilder
  private var competitionFoot: some View {
    let bestScore = world.settings.bestScore(at: level)
    if bestScore > 0 || isSignedInToGameCenter {
      VStack(spacing: Layout.defaultSpacing) {
        if bestScore > 0 {
          Label(L.QuizView.bestScore(bestScore), systemImage: "trophy")
            .smallLabel()
            .accessibilityIdentifier("quiz_best_score")
        }

        if isSignedInToGameCenter {
          Button {
            world.gameCenter.showLeaderboard(level: level)
            world.analytics.signal(name: .tapViewLeaderboard, parameters: [ParameterKey.source.rawValue: AnalyticsSource.tab.rawValue])
          } label: {
            Label(L.QuizView.viewLeaderboard, systemImage: "trophy")
              .font(captionFont)
          }
          .buttonStyle(.bordered)
          .tint(Color.customBlue)
          .controlSize(.small)
          .accessibilityHint(L.QuizView.leaderboardHint)
          .accessibilityIdentifier("quiz_leaderboard_button")
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom, Layout.doubleDefaultSpacing)
    }
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

  private var recordSessions: some View {
    VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
      Text(L.PracticeSession.heading)
        .font(subheadingFont)
        .foregroundStyle(Color.customForeground)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("quiz_record_sessions")

      ForEach(QuizRecordSession.allCases, id: \.self) { session in
        let askableCount = session.askableCount(from: world.practice)
        QuizHubRow(
          title: session.title,
          detail: session.hubDetail(askableCount: askableCount, daysUntilNextDue: world.practice.daysUntilNextDue()),
          systemImage: session.hubSystemImage,
          identifier: session.hubIdentifier,
          hint: session.hubHint,
          start: askableCount > 0 ? {
            start(scope: .recordSession(session))
            TryQuizTip().invalidate(reason: .actionPerformed)
          } : nil
        )
      }

      masteryRow

      if let lastResult = world.practice.lastResult {
        LastQuizResultRow(result: lastResult)
      }
    }
    .card()
  }

  private var masteryRow: some View {
    let mastery = Mastery(level: level, record: world.practice.record)
    return NavigationLink(value: MasteryDestination()) {
      QuizHubRowContent(
        title: L.Mastery.title,
        detail: L.Mastery.hubSummary(
          masteredPatterns: mastery.masteredPatternCount,
          patterns: mastery.patternCount,
          masteredVerbs: mastery.masteredVerbCount,
          verbs: mastery.verbs.count
        ),
        systemImage: "chart.bar.doc.horizontal",
        accessorySystemImage: "chevron.right"
      )
    }
    .buttonStyle(.plain)
    .accessibilityHint(L.Mastery.hubHint)
    .accessibilityIdentifier("quiz_mastery_button")
  }

  private var exercises: some View {
    VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
      Text(L.QuizView.exercises)
        .font(subheadingFont)
        .foregroundStyle(Color.customForeground)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("quiz_exercises")

      QuizHubRow(
        title: L.VerbEssentials.title,
        detail: L.VerbEssentials.description,
        systemImage: "square.3.layers.3d",
        identifier: "quiz_verb_essentials",
        hint: L.VerbEssentials.startHint
      ) {
        start(scope: .verbEssentials())
        TryQuizTip().invalidate(reason: .actionPerformed)
      }

      QuizHubRow(
        title: L.Recognition.title,
        detail: L.Recognition.description,
        systemImage: "text.magnifyingglass",
        identifier: "quiz_recognition",
        hint: L.Recognition.startHint
      ) {
        start(scope: .recognition)
        TryQuizTip().invalidate(reason: .actionPerformed)
      }

      let hasSentences = !GapSentences.askable(at: level).isEmpty
      QuizHubRow(
        title: L.Sentences.title,
        detail: hasSentences ? L.Sentences.description : L.Sentences.empty,
        systemImage: "text.insert",
        identifier: "quiz_sentences",
        hint: L.Sentences.startHint,
        start: hasSentences ? {
          start(scope: .sentences)
          TryQuizTip().invalidate(reason: .actionPerformed)
        } : nil
      )

      NavigationLink(value: ModelPracticeDestination()) {
        QuizHubRowContent(
          title: L.ModelPractice.title,
          detail: L.ModelPractice.hubDescription,
          systemImage: "square.grid.3x3.fill",
          accessorySystemImage: "chevron.right"
        )
      }
      .buttonStyle(.plain)
      .accessibilityHint(L.ModelPractice.hubHint)
      .accessibilityIdentifier("quiz_model_practice_button")

      speedRoundRow
    }
    .card()
  }

  private var speedRoundRow: some View {
    let masteredCount = SpeedRound.items(from: world.practice).count
    let opens = masteredCount >= SpeedRound.minimumMasteredCount
    let detail = opens
      ? world.practice.speedRoundBest.map { L.SpeedRound.descriptionWithBest($0) } ?? L.SpeedRound.description
      : L.SpeedRound.locked(needed: SpeedRound.minimumMasteredCount, mastered: masteredCount)
    return QuizHubRow(
      title: L.SpeedRound.title,
      detail: detail,
      systemImage: "bolt.fill",
      identifier: "quiz_speed_round",
      hint: L.SpeedRound.startHint,
      start: opens ? {
        start(scope: .speedRound)
        TryQuizTip().invalidate(reason: .actionPerformed)
      } : nil
    )
  }

  private var myVerbs: [Verb] {
    world.learnerVerbs.myVerbs
  }

  private var myVerbsNote: String {
    myVerbs.isEmpty ? L.QuizView.myVerbsEmpty : L.QuizView.myVerbsCount(myVerbs.count)
  }

  private var customQuiz: CustomQuiz {
    world.settings.customQuiz
  }

  private var level: QuizLevel {
    world.settings.quizLevel
  }

  private var canStart: Bool {
    switch tabScope {
    case .allVerbs:
      return true
    case .myVerbs:
      return !myVerbs.isEmpty
    case .custom:
      return customQuiz.canBeAsked(at: level, myVerbs: myVerbs)
    }
  }

  private var customQuizNote: String {
    if customQuiz.isEmpty {
      return L.CustomQuiz.emptyDescription
    }
    if customQuiz.canBeAsked(at: level, myVerbs: myVerbs) {
      return L.CustomQuiz.description
    }
    return customQuiz.verbSet == .myVerbs && myVerbs.isEmpty ? L.QuizView.myVerbsEmpty : L.CustomQuiz.nothingToAsk
  }

  private var customQuizSummary: some View {
    VStack(spacing: Layout.doubleDefaultSpacing) {
      if !customQuiz.isEmpty {
        CustomQuizSummaryCard(custom: customQuiz, level: level) { L.CustomQuiz.byLevel($0) }
          .accessibilityIdentifier("custom_quiz_summary")
      }

      Text(customQuizNote)
        .smallLabel()
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("custom_quiz_note")

      HStack(spacing: Layout.defaultSpacing) {
        NavigationLink(value: CustomQuizDestination.editor) {
          Label(customQuiz.isEmpty ? L.CustomQuiz.choose : L.CustomQuiz.change, systemImage: "slider.horizontal.3")
            .font(subheadingFont)
            .frame(maxHeight: .infinity)
        }
        .funButton(tint: .customRed)
        .controlSize(.small)
        .accessibilityHint(L.CustomQuiz.chooseHint)
        .accessibilityIdentifier("custom_quiz_choose_button")

        if canStart {
          practiceSetShareMenu
        }
      }
      // Equal heights, since a Menu's label sits a little taller than a NavigationLink's.
      .fixedSize(horizontal: false, vertical: true)
    }
    .fullScreenCover(isPresented: $isShowingQRCode) {
      PracticeSetQRView(practiceSet: sharedPracticeSet)
        .sheetDismissable()
    }
  }

  private var sharedPracticeSet: PracticeSet {
    PracticeSet(sharing: customQuiz, level: level, myVerbs: myVerbs)
  }

  private var practiceSetShareMenu: some View {
    Menu {
      Button {
        sharedPracticeSet.signalShare(method: PracticeSet.linkMethod)
        ShareSheet.present(
          text: sharedPracticeSet.shareText(levelFallback: level),
          title: L.PracticeSet.title,
          icon: UIImage(named: world.settings.appIcon.previewAssetName),
          anchorLabel: L.VerbView.share,
          anchorRect: shareButtonFrame == .zero ? nil : shareButtonFrame
        )
      } label: {
        Label(L.PracticeSet.shareLink, systemImage: "link")
      }
      .accessibilityIdentifier("practice_set_share_link")

      Button {
        sharedPracticeSet.signalShare(method: PracticeSet.qrCodeMethod)
        isShowingQRCode = true
      } label: {
        Label(L.PracticeSet.showQRCode, systemImage: "qrcode")
      }
      .accessibilityIdentifier("practice_set_show_qr_code")
    } label: {
      Label(L.VerbView.share, systemImage: "square.and.arrow.up")
        .font(subheadingFont)
        .frame(maxHeight: .infinity)
    }
    .funButton(tint: .customRed)
    .controlSize(.small)
    .onGeometryChange(for: CGRect.self) { proxy in
      proxy.frame(in: .global)
    } action: { frame in
      shareButtonFrame = frame
    }
    .accessibilityHint(L.PracticeSet.shareHint)
    .accessibilityIdentifier("custom_quiz_share_button")
  }

  private func start() {
    switch tabScope {
    case .allVerbs:
      start(scope: .allVerbs)
    case .myVerbs:
      start(scope: .myVerbs(myVerbs))
    case .custom:
      start(scope: .custom(customQuiz, myVerbs: myVerbs))
    }
    TryQuizTip().invalidate(reason: .actionPerformed)
  }

  private func start(scope: QuizScope) {
    clearInput()
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

/// A Speed Round's missed question, above the next one, since the round does not stop for a
/// correction.
private struct SpeedRoundMissLine: View {
  let miss: SpeedRoundMiss

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: Layout.defaultSpacing) {
      Image(systemName: ConjugationResult.noMatch.feedbackIconString)
        .font(.title2)
        .foregroundStyle(ConjugationResult.noMatch.feedbackColor)

      Text(verbatim: miss.infinitif + " ·")
        .smallLabel()

      Text(AttributedString(mixedCaseString: miss.answer))
        .font(bodyEmphasisFont)
        .fixedSize(horizontal: false, vertical: true)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(L.SpeedRound.missedWithColon + " " + miss.answer.lowercased())
    .accessibilityIdentifier("speed_round_miss")
  }
}

/// A row of the Quiz tab's hub: a button that starts a session while it has questions, and
/// otherwise a line saying why it has none.
private struct QuizHubRow: View {
  let title: String
  let detail: String
  let systemImage: String
  /// Ends in `_button` while the row starts something, and in `_empty` otherwise.
  let identifier: String
  let hint: String
  /// Nil for a row with nothing to start.
  let start: (() -> Void)?

  var body: some View {
    let content = QuizHubRowContent(title: title, detail: detail, systemImage: systemImage, accessorySystemImage: start == nil ? nil : "play.circle.fill")
    if let start {
      Button(action: start) {
        content
      }
      .buttonStyle(.plain)
      .accessibilityHint(hint)
      .accessibilityIdentifier("\(identifier)_button")
    } else {
      content
        .accessibilityIdentifier("\(identifier)_empty")
    }
  }
}

/// A hub row's symbol, title, detail, and what a tap does: a play symbol for a row that starts a
/// session, a chevron for one that opens a list.
private struct QuizHubRowContent: View {
  let title: String
  let detail: String
  let systemImage: String
  let accessorySystemImage: String?

  var body: some View {
    HStack(spacing: Layout.doubleDefaultSpacing) {
      Image(systemName: systemImage)
        .font(.title2)
        .foregroundStyle(Color.customBlue)
        .frame(width: 32)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(bodyEmphasisFont)
          .foregroundStyle(Color.customForeground)
        Text(detail)
          .font(captionFont)
          .foregroundStyle(Color.customGray)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)

      if let accessorySystemImage {
        Image(systemName: accessorySystemImage)
          .font(accessorySystemImage == "chevron.right" ? .body : .title)
          .foregroundStyle(Color.customBlue)
          .accessibilityHidden(true)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(.rect)
    .accessibilityElement(children: .combine)
  }
}

private extension QuizRecordSession {
  func hubDetail(askableCount: Int, daysUntilNextDue: Int?) -> String {
    switch self {
    case .review:
      if askableCount > 0 {
        return L.PracticeSession.reviewCount(askableCount)
      }
      return daysUntilNextDue.map { L.PracticeSession.reviewNextDue(inDays: $0) } ?? L.PracticeSession.reviewEmpty
    case .mistakes:
      return askableCount > 0 ? L.PracticeSession.mistakesCount(askableCount) : L.PracticeSession.mistakesEmpty
    }
  }

  var hubHint: String {
    switch self {
    case .review:
      return L.PracticeSession.reviewHint
    case .mistakes:
      return L.PracticeSession.mistakesHint
    }
  }

  var hubSystemImage: String {
    switch self {
    case .review:
      return "clock.arrow.circlepath"
    case .mistakes:
      return "arrow.uturn.backward.circle"
    }
  }

  var hubIdentifier: String {
    switch self {
    case .review:
      return "quiz_review"
    case .mistakes:
      return "quiz_mistakes"
    }
  }
}

private struct QuizFactTile: View {
  let systemImage: String
  let value: String
  let label: String
  var accessibilityLabel: String?
  var showsMenuIndicator = false

  var body: some View {
    VStack(spacing: Layout.defaultSpacing / 2) {
      Image(systemName: systemImage)
        .font(.title2)
        .foregroundStyle(Color.customBlue)
        .contentTransition(.symbolEffect(.replace))
        .frame(height: 30)
        .accessibilityHidden(true)

      HStack(spacing: 3) {
        Text(verbatim: value)
          .lineLimit(1)
          .minimumScaleFactor(0.6)
        if showsMenuIndicator {
          Image(systemName: "chevron.up.chevron.down")
            .font(.caption2.bold())
            .foregroundStyle(Color.customBlue)
            .accessibilityHidden(true)
        }
      }
      .font(bodyEmphasisFont)
      .foregroundStyle(Color.customForeground)

      Text(label)
        .font(captionFont)
        .foregroundStyle(Color.customGray)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.8)
        .fixedSize(horizontal: false, vertical: true)

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.vertical, Layout.defaultSpacing * 1.5)
    .padding(.horizontal, Layout.defaultSpacing / 2)
    .background(Color.customBlue.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .strokeBorder(Color.customBlue.opacity(0.25), lineWidth: 1)
    }
    .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    .accessibilityElement(children: .combine)
    .modifier(OptionalAccessibilityLabel(label: accessibilityLabel))
  }
}

private struct OptionalAccessibilityLabel: ViewModifier {
  let label: String?

  func body(content: Content) -> some View {
    if let label {
      content.accessibilityLabel(label)
    } else {
      content
    }
  }
}

private struct LastQuizResultRow: View {
  let result: LastQuizResult

  var body: some View {
    HStack(spacing: Layout.doubleDefaultSpacing) {
      Image(systemName: "flag.checkered")
        .font(.title2)
        .foregroundStyle(Color.customBlue)
        .frame(width: 32)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 2) {
        Text(L.QuizView.lastQuiz)
          .font(bodyEmphasisFont)
          .foregroundStyle(Color.customForeground)
        Text(verbatim: subjectLine)
          .font(captionFont)
          .foregroundStyle(Color.customForeground)
          .fixedSize(horizontal: false, vertical: true)
        Text(verbatim: resultLine)
          .font(captionFont.monospacedDigit())
          .foregroundStyle(Color.customGray)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier("quiz_last_result")
  }

  private var subjectLine: String {
    [result.title, result.level?.localizedName, relativeDay].compactMap { $0 }.joined(separator: " · ")
  }

  private var resultLine: String {
    var parts = [L.ResultsView.correct(result.correctCount, of: result.questionCount)]
    if result.secondAttemptCount > 0 {
      parts.append(L.ResultsView.secondTry(result.secondAttemptCount))
    }
    // A Speed Round counts right answers and scores no points.
    if result.kind != .speedRound {
      parts.append(L.QuizView.score(result.score))
    }
    return parts.joined(separator: " · ")
  }

  private var relativeDay: String? {
    guard let days = PracticeRecord.daysBetween(result.date, and: .now) else {
      return nil
    }
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .named
    formatter.unitsStyle = .full
    // The app's language, which can differ from the region's.
    formatter.locale = Locale(identifier: Bundle.main.preferredLocalizations.first ?? "en")
    // A clock set back would otherwise make the last quiz tomorrow's.
    return formatter.localizedString(from: DateComponents(day: -max(days, 0)))
  }
}

// Semantic ordering: the picker's segments, the default first.
/// What the Quiz tab's picker offers. A quiz over one verb starts from that verb's page instead.
/// The tab opens on `allVerbs` at every launch, so the default quiz stays the default.
enum TabQuizScope: CaseIterable {
  case allVerbs
  case myVerbs
  case custom

  var displayName: String {
    switch self {
    case .allVerbs:
      return L.QuizView.allVerbs
    case .myVerbs:
      return L.MyVerbs.title
    case .custom:
      return L.CustomQuiz.segment
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
