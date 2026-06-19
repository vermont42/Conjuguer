//
//  WidgetL.swift
//  Conjuguer
//
//  Centralized, typo-safe localization keys for the widget extension — mirrors the app's
//  `L` enum. Keys are stable identifiers (never the English text, which would be ambiguous
//  across languages); the English source rides along as each entry's `defaultValue`, and
//  translations live in the widget target's `Localizable.xcstrings`.
//
//  Note: AppIntent `title` / `@Parameter(title:)` strings are NOT here. AppIntents extracts
//  that metadata at compile time and requires a string literal or a direct initializer call,
//  so it can't reference these constants — those intents keep their explicit `Widget.*` keys
//  inline (see AnswerQuizIntent, OpenQuizIntent, OpenRandomVerbIntent).
//

import Foundation

enum WidgetL {
  enum VerbWidget {
    static let name = LocalizedStringResource("Widget.verbOfTheDayName", defaultValue: "Verb of the Day")
    static let description = LocalizedStringResource("Widget.verbOfTheDayDescription", defaultValue: "A daily French verb with its présent conjugations.")
  }

  enum QuizWidget {
    static let name = LocalizedStringResource("Widget.quizName", defaultValue: "Conjugation Quiz")
    static let description = LocalizedStringResource("Widget.quizDescription", defaultValue: "Test your French verb conjugation skills.")
    static let correct = LocalizedStringResource("Widget.quizCorrect", defaultValue: "Correct!")
    static let incorrect = LocalizedStringResource("Widget.quizIncorrect", defaultValue: "Incorrect")
  }

  enum Controls {
    static let quickQuizName = LocalizedStringResource("Widget.quickQuizName", defaultValue: "Quick Quiz")
    static let quickQuizDescription = LocalizedStringResource("Widget.quickQuizDescription", defaultValue: "Launch the conjugation quiz.")
    static let randomVerbName = LocalizedStringResource("Widget.randomVerbName", defaultValue: "Random Verb")
    static let randomVerbDescription = LocalizedStringResource("Widget.randomVerbDescription", defaultValue: "Open a random French verb.")
  }

  enum LiveActivity {
    static let title = LocalizedStringResource("Widget.liveActivityTitle", defaultValue: "Conjuguer Quiz")
  }
}
