//
//  SettingsView.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/30/21.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var current: World
  @ObservedObject var store = SelectionStore()

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        Spacer()
          .frame(height: Layout.tripleDefaultSpacing)

        HStack {
          Text(L.Navigation.settings)
            .modifier(HeadingLabel())
            .foregroundColor(Color.customBlue)
            .padding(.leading, Layout.doubleDefaultSpacing)

          Spacer()
        }

        ScrollView(.vertical) {
          Group {
            Text(L.Settings.quizDifficulty)
              .modifier(SettingsSubheadingLabel())

            Picker("", selection: $store.quizDifficulty) {
              ForEach(QuizDifficulty.allCases, id: \.self) { quizDifficulty in
                Text(quizDifficulty.localizedDifficulty).tag(quizDifficulty)
              }
            }
              .modifier(SegmentedPicker())
              .onAppear {
                self.store.quizDifficulty = self.current.settings.quizDifficulty
                self.store.current = self.current
              }

            Text(L.Settings.quizDifficultyDescription)
              .modifier(SettingsLabel())

            Spacer(minLength: Layout.tripleDefaultSpacing)
          }

          Spacer()

          Group {
            Text(L.Settings.pronounGender)
              .modifier(SettingsSubheadingLabel())

            Picker("", selection: $store.pronounGender) {
              ForEach(PronounGender.allCases, id: \.self) { pronounGender in
                Text(pronounGender.localizedGender).tag(pronounGender)
              }
            }
              .modifier(SegmentedPicker())
              .onAppear {
                self.store.pronounGender = self.current.settings.pronounGender
                self.store.current = self.current
              }

            Text(L.Settings.pronounGenderDescription)
              .modifier(SettingsLabel())

            Spacer(minLength: Layout.tripleDefaultSpacing)
          }
        }
      }
    }
  }
}

final class SelectionStore: ObservableObject {
  var current: World?

  var quizDifficulty: QuizDifficulty = Settings.quizDifficultyDefault {
    didSet {
      current?.settings.quizDifficulty = quizDifficulty
    }
  }

  var pronounGender: PronounGender = Settings.pronounGenderDefault {
    didSet {
      current?.settings.pronounGender = pronounGender
    }
  }
}
