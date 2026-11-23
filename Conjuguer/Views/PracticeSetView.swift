//
//  PracticeSetView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import SwiftUI

/// A shared practice set, opened from a link or a QR code: what it asks, Start, and a way to keep
/// it as the learner's custom quiz. It never starts a quiz unasked.
struct PracticeSetView: View {
  let request: PracticeSetRequest
  @Environment(World.self) private var world
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var isQuizzing = false
  @State private var hasSignaledView = false

  var body: some View {
    Group {
      if let practiceSet = request.practiceSet {
        content(practiceSet)
      } else {
        ContentUnavailableView(
          L.PracticeSet.invalidTitle,
          systemImage: "questionmark.square.dashed",
          description: Text(L.PracticeSet.invalidDescription)
        )
        .accessibilityIdentifier("practice_set_invalid")
      }
    }
    .screenBackground()
    .navigationTitle(L.PracticeSet.title)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      guard !hasSignaledView else {
        return
      }
      hasSignaledView = true
      world.analytics.signal(name: .viewPracticeSet, parameters: [
        ParameterKey.outcome.rawValue: request.practiceSet == nil ? "invalid" : "opened",
        ParameterKey.source.rawValue: request.source.rawValue
      ])
    }
    .sheet(isPresented: $isQuizzing) {
      if let practiceSet = request.practiceSet {
        QuizSheet(scope: practiceSet.scope(source: request.source))
      }
    }
  }

  private func content(_ practiceSet: PracticeSet) -> some View {
    let level = practiceSet.level ?? world.settings.quizLevel
    let canStart = practiceSet.canBeAsked(levelFallback: world.settings.quizLevel)

    return ScrollView {
      VStack(spacing: Layout.doubleDefaultSpacing) {
        VStack(spacing: Layout.doubleDefaultSpacing) {
          Image(systemName: "graduationcap.fill")
            .font(.system(size: 44))
            .foregroundStyle(Color.customBlue)
            .accessibilityHidden(true)

          Text(L.PracticeSet.title)
            .headingLabel()
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)

          Text(L.PracticeSet.description)
            .bodyLabel()
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

          CustomQuizSummaryCard(custom: practiceSet.custom, level: level) { value in
            practiceSet.level == nil ? L.CustomQuiz.byLevel(value) : L.PracticeSet.byLevel(value)
          }
          .accessibilityIdentifier("practice_set_summary")

          if let verbs = listedVerbs(of: practiceSet) {
            verbChips(verbs)
          }

          if !canStart {
            Text(L.CustomQuiz.nothingToAsk)
              .smallLabel()
              .multilineTextAlignment(.center)
              .fixedSize(horizontal: false, vertical: true)
              .accessibilityIdentifier("practice_set_nothing_to_ask")
          }

          Button(L.QuizView.start) {
            isQuizzing = true
          }
          .buttonLabel()
          .lineLimit(1)
          .minimumScaleFactor(0.7)
          .funButton()
          .disabled(!canStart)
          .accessibilityHint(L.PracticeSet.startHint)
          .accessibilityIdentifier("practice_set_start_button")
        }
        .frame(maxWidth: .infinity)
        .card()

        keepButton(practiceSet)
      }
      .frame(maxWidth: CustomQuizLayout.maxWidth)
      .padding(Layout.doubleDefaultSpacing)
      .frame(maxWidth: .infinity)
    }
  }

  private func listedVerbs(of practiceSet: PracticeSet) -> [Verb]? {
    guard case .list = practiceSet.custom.verbSet else {
      return nil
    }
    return practiceSet.custom.verbSet?.listedVerbs(myVerbs: [])
  }

  private static let chipLimit = 12

  private func verbChips(_ verbs: [Verb]) -> some View {
    let shown = verbs.prefix(Self.chipLimit)
    let hiddenCount = verbs.count - shown.count
    return FlowLayout(spacing: Layout.defaultSpacing) {
      ForEach(Array(shown), id: \.id) { verb in
        Text(verb.infinitifWithPossibleExtraLetters)
          .font(captionFont)
          .foregroundStyle(Color.customRed)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(Color.customRed.opacity(0.08), in: Capsule())
          .frenchPronunciation()
      }
      if hiddenCount > 0 {
        Text(L.PracticeSet.moreVerbs(hiddenCount))
          .smallLabel()
          .padding(.vertical, 6)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityIdentifier("practice_set_verbs")
  }

  /// Keeping replaces the learner's own custom quiz, which the footer says. A kept set asks the
  /// learner's level for any part it leaves to the level, as every custom quiz does.
  private func keepButton(_ practiceSet: PracticeSet) -> some View {
    let isKept = world.settings.customQuiz == practiceSet.custom

    return VStack(spacing: Layout.defaultSpacing) {
      Button {
        world.settings.customQuiz = practiceSet.custom
        world.analytics.signal(name: .tapKeepPracticeSet)
        AccessibilityNotification.Announcement(L.PracticeSet.kept).post()
      } label: {
        Label(isKept ? L.PracticeSet.kept : L.PracticeSet.keep, systemImage: isKept ? "checkmark" : "square.and.arrow.down")
          .font(subheadingFont)
      }
      .funButton(tint: .customRed)
      .controlSize(.small)
      .disabled(isKept)
      .accessibilityIdentifier("practice_set_keep_button")

      if !isKept {
        Text(L.PracticeSet.keepFooter)
          .smallLabel()
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

/// A practice set's QR code, big enough to project, with a caption naming what it asks. The
/// screen stays awake while it shows, since a class may take a while to scan it.
struct PracticeSetQRView: View {
  let practiceSet: PracticeSet
  @Environment(World.self) private var world

  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(spacing: Layout.doubleDefaultSpacing) {
          Text(L.PracticeSet.scanTitle)
            .headingLabel()
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)

          // Dark modules on white in either appearance, since some scanners misread a code drawn
          // light on dark.
          if let url = practiceSet.deeplink(source: .qrCode), let image = QRCode.image(for: url.absoluteString) {
            Image(uiImage: image)
              .interpolation(.none)
              .resizable()
              .scaledToFit()
              .padding(Layout.tripleDefaultSpacing)
              .background(.white, in: RoundedRectangle(cornerRadius: 16))
              .frame(maxWidth: max(min(geometry.size.width, geometry.size.height * 0.7) - Layout.tripleDefaultSpacing * 2, 200))
              .accessibilityElement()
              .accessibilityLabel(L.PracticeSet.qrCodeLabel)
              .accessibilityAddTraits(.isImage)
              .accessibilityIdentifier("practice_set_qr_code")
          }

          Text(practiceSet.summary(levelFallback: world.settings.quizLevel))
            .bodyLabel()
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("practice_set_qr_summary")

          Text(L.PracticeSet.scanNote)
            .smallLabel()
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Layout.doubleDefaultSpacing)
        .frame(maxWidth: .infinity)
      }
    }
    .screenBackground()
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      UIApplication.shared.isIdleTimerDisabled = true
    }
    .onDisappear {
      UIApplication.shared.isIdleTimerDisabled = false
    }
  }
}
