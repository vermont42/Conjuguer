//
//  SettingsView.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/30/21.
//

import SwiftUI

struct SettingsView: View {
  @Environment(World.self) private var world
  @Environment(\.openURL) private var openURL
  @State private var rateReviewDescription = ""

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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Layout.doubleDefaultSpacing)
      }
    }
    .padding(.top, Layout.tripleDefaultSpacing)
    .onAppear {
      world.analytics.recordViewAppeared("\(SettingsView.self)")
      RatingsFetcher.fetchRatingsDescription(completion: { description in
        if description != RatingsFetcher.errorMessage {
          self.rateReviewDescription = description
        }
      })
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
