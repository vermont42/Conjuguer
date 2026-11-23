//
//  ConjuguerShortcuts.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import AppIntents

// The phrases are English only by choice: offering them in the app's other language was
// considered and rejected.
struct ConjuguerShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: LookUpVerbIntent(),
      phrases: [
        "Look up a verb with \(.applicationName)",
        "Look up a word with \(.applicationName)",
        "Look up a conjugation with \(.applicationName)"
      ],
      shortTitle: LocalizedStringResource("Intent.lookUpVerbTitle", defaultValue: "Look Up a Verb"),
      systemImageName: "magnifyingglass"
    )

    AppShortcut(
      intent: OpenQuizIntent(),
      phrases: [
        "Start a quiz with \(.applicationName)",
        "Quiz me with \(.applicationName)"
      ],
      shortTitle: LocalizedStringResource("Intent.startQuizShortTitle", defaultValue: "Start Quiz"),
      systemImageName: "pencil.circle"
    )

    AppShortcut(
      intent: OpenRandomVerbIntent(),
      phrases: [
        "Show a random verb with \(.applicationName)",
        "Random verb with \(.applicationName)"
      ],
      shortTitle: LocalizedStringResource("Intent.randomVerbShortTitle", defaultValue: "Random Verb"),
      systemImageName: "shuffle"
    )
  }
}
