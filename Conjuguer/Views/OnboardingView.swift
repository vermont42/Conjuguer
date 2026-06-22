//
//  OnboardingView.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/22/26.
//

import SwiftUI

struct OnboardingView: View {
  let isReshow: Bool
  @Environment(\.dismiss) private var dismiss
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var currentPage = 0
  @State private var getStartedOffset: CGFloat = 100
  @State private var getStartedOpacity: Double = 0

  private let lastPageTag = 4
  fileprivate static let entranceAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)

  init(isReshow: Bool = false) {
    self.isReshow = isReshow
  }

  var body: some View {
    ZStack(alignment: .top) {
      Color.customBackground
        .ignoresSafeArea()

      LinearGradient(
        colors: [.customBlue.opacity(0.20), .clear],
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(height: 300)
      .frame(maxWidth: .infinity)
      .allowsHitTesting(false)
      .accessibilityHidden(true)

      VStack {
        HStack {
          Spacer()
          if currentPage < lastPageTag {
            Button(isReshow ? L.Onboarding.dismiss : L.Onboarding.skip) {
              finishOnboarding()
            }
            .foregroundStyle(Color.customBlue)
            .padding(.trailing, Layout.doubleDefaultSpacing)
          }
        }

        TabView(selection: $currentPage) {
          OnboardingPageView(
            symbolName: "wineglass.fill",
            title: L.Onboarding.welcomeTitle,
            bodyText: L.Onboarding.welcomeBody
          )
          .tag(0)

          OnboardingPageView(
            symbolName: "list.bullet.rectangle.portrait.fill",
            title: L.Onboarding.browseTitle,
            bodyText: L.Onboarding.browseBody,
            navigationButtonTitle: L.Onboarding.browseVerbsButton,
            navigationAction: .navigateToTab(.verbs),
            onNavigate: { finishOnboarding() }
          )
          .tag(1)

          OnboardingPageView(
            symbolName: "key.fill",
            title: L.Onboarding.modelsTitle,
            bodyText: L.Onboarding.modelsBody,
            navigationButtonTitle: L.Onboarding.exploreModelsButton,
            navigationAction: .navigateToTab(.models),
            onNavigate: { finishOnboarding() }
          )
          .tag(2)

          OnboardingPageView(
            symbolName: "trophy.fill",
            title: L.Onboarding.quizTitle,
            bodyText: L.Onboarding.quizBody,
            navigationButtonTitle: L.Onboarding.startQuizButton,
            navigationAction: .navigateToTab(.quiz),
            onNavigate: { finishOnboarding() }
          )
          .tag(3)

          OnboardingPageView(
            symbolName: "figure.water.fitness",
            title: L.Onboarding.learnTitle,
            bodyText: L.Onboarding.learnBody,
            navigationButtonTitle: L.Onboarding.readArticlesButton,
            navigationAction: .navigateToTab(.info),
            onNavigate: { finishOnboarding() },
            animateContent: true
          )
          .tag(lastPageTag)
        }
        .tabViewStyle(.page)

        if currentPage == lastPageTag {
          Button(L.Onboarding.getStarted) {
            SoundPlayer.play(.chime)
            finishOnboarding()
          }
          .funButton()
          .padding(.bottom, Layout.tripleDefaultSpacing)
          .offset(y: getStartedOffset)
          .opacity(getStartedOpacity)
        }
      }
    }
    .sensoryFeedback(.impact(weight: .light), trigger: currentPage)
    .onChange(of: currentPage) { oldValue, newValue in
      if newValue == lastPageTag {
        withAnimation(reduceMotion ? nil : OnboardingView.entranceAnimation) {
          getStartedOffset = 0
          getStartedOpacity = 1
        }
      } else if oldValue == lastPageTag {
        getStartedOffset = 100
        getStartedOpacity = 0
      }
    }
  }

  private func finishOnboarding() {
    if !isReshow {
      Current.settings.hasSeenOnboarding = true
    }
    dismiss()
  }
}

private enum OnboardingNavigationAction {
  case none
  case navigateToTab(MainTab)
}

private struct OnboardingPageView: View {
  let symbolName: String
  let title: String
  let bodyText: String
  let navigationButtonTitle: String?
  let navigationAction: OnboardingNavigationAction
  let onNavigate: () -> Void
  let animateContent: Bool

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var contentOffset: CGFloat = 100
  @State private var contentOpacity: Double = 0
  @State private var bounceValue = 0

  init(
    symbolName: String,
    title: String,
    bodyText: String,
    navigationButtonTitle: String? = nil,
    navigationAction: OnboardingNavigationAction = .none,
    onNavigate: @escaping () -> Void = {},
    animateContent: Bool = false
  ) {
    self.symbolName = symbolName
    self.title = title
    self.bodyText = bodyText
    self.navigationButtonTitle = navigationButtonTitle
    self.navigationAction = navigationAction
    self.onNavigate = onNavigate
    self.animateContent = animateContent
  }

  var body: some View {
    VStack(spacing: Layout.doubleDefaultSpacing) {
      Spacer()
        .frame(maxHeight: 100)

      Image(systemName: symbolName)
        .font(.system(size: 80))
        .foregroundStyle(Color.customBlue)
        .symbolEffect(.bounce, value: bounceValue)

      Text(title)
        .headingLabel()
        .multilineTextAlignment(.center)

      Text(bodyText)
        .font(.callout)
        .foregroundStyle(Color.customForeground)
        .multilineTextAlignment(.center)
        .padding(.horizontal, Layout.tripleDefaultSpacing)

      if let navigationButtonTitle {
        Button(navigationButtonTitle) {
          SoundPlayer.play(.chime)
          switch navigationAction {
          case .navigateToTab(let tab):
            Current.selectedTab = tab
          case .none:
            break
          }
          onNavigate()
        }
        .funButton()
      }

      Spacer()
    }
    .offset(y: animateContent ? contentOffset : 0)
    .opacity(animateContent ? contentOpacity : 1)
    .onAppear {
      bounceValue += 1
      if animateContent {
        withAnimation(reduceMotion ? nil : OnboardingView.entranceAnimation) {
          contentOffset = 0
          contentOpacity = 1
        }
      }
    }
  }
}
