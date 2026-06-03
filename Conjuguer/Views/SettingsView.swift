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
          .foregroundStyle(Color.customBlue)
          .padding(.leading, Layout.doubleDefaultSpacing)

        Spacer()
      }

      ScrollView(.vertical) {
        Text(L.Settings.quizDifficulty)
          .settingsSubheadingLabel()

        Picker("", selection: $settings.quizDifficulty) {
          ForEach(QuizDifficulty.allCases, id: \.self) { quizDifficulty in
            Text(quizDifficulty.localizedDifficulty).tag(quizDifficulty)
          }
        }
        .segmentedPicker()
        .accessibilityIdentifier("picker_settings_quizDifficulty")
        .accessibilityLabel(Text(L.Settings.quizDifficulty))
        .accessibilityValue(settings.quizDifficulty.localizedDifficulty)

        Text(L.Settings.quizDifficultyDescription)
          .settingsLabel()

        Spacer(minLength: Layout.tripleDefaultSpacing)

        Text(L.Settings.pronounGender)
          .settingsSubheadingLabel()

        Picker("", selection: $settings.pronounGender) {
          ForEach(PronounGender.allCases, id: \.self) { pronounGender in
            Text(pronounGender.localizedGender).tag(pronounGender)
          }
        }
        .segmentedPicker()
        .accessibilityIdentifier("picker_settings_pronounGender")
        .accessibilityLabel(Text(L.Settings.pronounGender))
        .accessibilityValue(settings.pronounGender.localizedGender)

        Text(L.Settings.pronounGenderDescription)
          .settingsLabel()

        Spacer(minLength: Layout.tripleDefaultSpacing)

        Text(L.Settings.ratingsAndReviews)
          .subheadingLabel()

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
    .padding(.top, Layout.tripleDefaultSpacing)
    .onAppear {
      world.analytics.recordViewAppeared("\(SettingsView.self)")
      RatingsFetcher.fetchRatingsDescription(completion: { description in
        if description != RatingsFetcher.errorMessage {
          Task { @MainActor in
            self.rateReviewDescription = description
          }
        }
      })
    }
    .screenBackground()
  }
}
