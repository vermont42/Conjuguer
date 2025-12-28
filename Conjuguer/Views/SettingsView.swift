//
//  SettingsView.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/30/21.
//

import SwiftUI

struct SettingsView: View {
  @State private var rateReviewDescription = ""

  var body: some View {
    @Bindable var settings = Current.settings

    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        Spacer()
          .frame(height: Layout.tripleDefaultSpacing)

        HStack {
          Text(L.Navigation.settings)
            .headingLabel()
            .foregroundColor(Color.customBlue)
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

          Text(L.Settings.quizDifficultyDescription)
            .settingsLabel()

          Spacer(minLength: Layout.tripleDefaultSpacing)

          Spacer()

          Text(L.Settings.pronounGender)
            .settingsSubheadingLabel()

          Picker("", selection: $settings.pronounGender) {
            ForEach(PronounGender.allCases, id: \.self) { pronounGender in
              Text(pronounGender.localizedGender).tag(pronounGender)
            }
          }
          .segmentedPicker()

          Text(L.Settings.pronounGenderDescription)
            .settingsLabel()

          Spacer(minLength: Layout.tripleDefaultSpacing)

          Text(L.Settings.ratingsAndReviews)
            .subheadingLabel()

          Button(L.Settings.rateOrReview) {
            UIApplication.shared.open(RatingsFetcher.reviewURL, options: [:])
          }
          .funButton()

          if rateReviewDescription != "" {
            Text(rateReviewDescription)
              .settingsLabel()
          }
        }
      }
      .onAppear {
        Current.analytics.recordViewAppeared("\(SettingsView.self)")
        RatingsFetcher.fetchRatingsDescription(completion: { description in
          if description != RatingsFetcher.errorMessage {
            DispatchQueue.main.async {
              self.rateReviewDescription = description
            }
          }
        })
      }
    }
  }
}
