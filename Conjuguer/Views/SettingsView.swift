//
//  SettingsView.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/30/21.
//

import SwiftUI
import TipKit

struct SettingsView: View {
  @Environment(World.self) private var world
  @Environment(\.openURL) private var openURL
  @State private var rateReviewDescription = ""
  @State private var showingOnboarding = false
  @State private var showingGame = false
  private let changeDifficultyTip = ChangeDifficultyTip()
  private let playGameTip = PlayGameTip()

  var body: some View {
    @Bindable var settings = world.settings

    VStack(alignment: .leading) {
      HStack {
        Text(L.Navigation.settings)
          .headingLabel()
          .padding(.leading, Layout.doubleDefaultSpacing)

        Spacer()
      }

      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
          settingCard(title: L.Settings.quizDifficulty) {
            Picker("", selection: $settings.quizDifficulty) {
              ForEach(QuizDifficulty.allCases, id: \.self) { quizDifficulty in
                Text(quizDifficulty.localizedDifficulty).tag(quizDifficulty)
              }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("picker_settings_quizDifficulty")
            .accessibilityLabel(Text(L.Settings.quizDifficulty))
            .accessibilityValue(settings.quizDifficulty.localizedDifficulty)

            Text(L.Settings.quizDifficultyDescription)
              .settingsLabel()
          }
          .popoverTip(changeDifficultyTip)
          .onChange(of: settings.quizDifficulty) {
            changeDifficultyTip.invalidate(reason: .actionPerformed)
          }

          settingCard(title: L.Settings.pronounGender) {
            Picker("", selection: $settings.pronounGender) {
              ForEach(PronounGender.allCases, id: \.self) { pronounGender in
                Text(pronounGender.localizedGender).tag(pronounGender)
              }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("picker_settings_pronounGender")
            .accessibilityLabel(Text(L.Settings.pronounGender))
            .accessibilityValue(settings.pronounGender.localizedGender)

            Text(L.Settings.pronounGenderDescription)
              .settingsLabel()
          }

          settingCard(title: L.Settings.appIcon) {
            LazyVGrid(
              columns: Array(
                repeating: GridItem(.flexible(), spacing: Layout.doubleDefaultSpacing),
                count: 2
              ),
              spacing: Layout.doubleDefaultSpacing
            ) {
              ForEach(AppIcon.allCases, id: \.self) { appIcon in
                Button {
                  settings.appIcon = appIcon
                } label: {
                  VStack(spacing: Layout.defaultSpacing) {
                    Image(appIcon.previewAssetName)
                      .resizable()
                      .aspectRatio(1, contentMode: .fit)
                      .frame(width: 112, height: 112)
                      .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                      .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                          .strokeBorder(
                            settings.appIcon == appIcon ? Color.customBlue : Color.clear,
                            lineWidth: 3
                          )
                      )
                      .accessibilityHidden(true)

                    Text(appIcon.localizedName)
                      .settingsLabel()
                      .foregroundStyle(Color.customRed)
                      .multilineTextAlignment(.center)
                  }
                  .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("app_icon_\(appIcon.rawValue)")
                .accessibilityLabel(appIcon.localizedName)
                .accessibilityAddTraits(settings.appIcon == appIcon ? .isSelected : [])
              }
            }
            .accessibilityIdentifier("grid_settings_appIcon")
            .sensoryFeedback(.selection, trigger: settings.appIcon)
          }

          settingCard(title: L.Settings.ratingsAndReviews) {
            Button(L.Settings.rateOrReview) {
              openURL(RatingsFetcher.reviewURL)
            }
            .funButton()

            if rateReviewDescription != "" {
              Text(rateReviewDescription)
                .settingsLabel()
            }
          }

          settingCard(title: L.Onboarding.onboarding) {
            Button(L.Onboarding.showOnboarding) {
              world.analytics.recordEvent("tapShowOnboarding")
              showingOnboarding = true
            }
            .funButton()

            Text(L.Onboarding.showOnboardingDescription)
              .settingsLabel()
          }

          settingCard(title: L.Game.sectionTitle) {
            Button(L.Game.playGame) {
              world.analytics.recordEvent("tapPlayGame")
              playGameTip.invalidate(reason: .actionPerformed)
              showingGame = true
            }
            .funButton()
            .popoverTip(playGameTip)

            Text(L.Game.playGameDescription)
              .settingsLabel()
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Layout.doubleDefaultSpacing)
      }
    }
    .padding(.top, Layout.tripleDefaultSpacing)
    .recordsAppearance(as: "\(SettingsView.self)")
    .task {
      let description = await RatingsFetcher.fetchRatingsDescription()
      if description != RatingsFetcher.errorMessage {
        rateReviewDescription = description
      }
    }
    .fullScreenCover(isPresented: $showingOnboarding) {
      OnboardingView(isReshow: true)
    }
    .fullScreenCover(isPresented: $showingGame) {
      GameView()
    }
    .screenBackground()
  }

  private func settingCard<Content: View>(
    title: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(title)
        .subheadingLabel()

      content()
    }
    .card()
  }
}
