//
//  LookUpVerbIntent.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import AppIntents

/// Says which verb a word belongs to ("vais: Indicatif Présent (je) of aller"), then opens the
/// app: on that verb's page when the word settles one verb, and otherwise on the verb list
/// searched for the word. Answering before opening means the answer arrives even when the
/// learner only wanted to hear it.
struct LookUpVerbIntent: AppIntent {
  static let title = LocalizedStringResource("Intent.lookUpVerbTitle", defaultValue: "Look Up a Verb")
  static let description = IntentDescription(LocalizedStringResource("Intent.lookUpVerbDescription", defaultValue: "Finds the verb that a conjugation, infinitive, or English meaning belongs to, says what it found, and opens it in Conjuguer."))

  // Autocorrection would turn a French word into an English one before the intent saw it
  // (Konjugieren's ging became Going), and the default keyboard type, ASCII, offers no accents.
  @Parameter(
    title: LocalizedStringResource("Intent.lookUpVerbWord", defaultValue: "Word"),
    inputOptions: String.IntentInputOptions(keyboardType: .default, capitalizationType: .none, autocorrect: false),
    requestValueDialog: IntentDialog(LocalizedStringResource("Intent.lookUpVerbWordPrompt", defaultValue: "Which word should Conjuguer look up?"))
  )
  var word: String

  func perform() async throws -> some IntentResult & OpensIntent & ProvidesDialog {
    let word = word
    await VerbData.ensureLoaded()
    let (answer, destination) = await MainActor.run {
      let lookup = VerbLookup(word: word, verbs: Array(Verb.verbs.values))
      return (lookup.answer(pronounGender: Current.settings.pronounGender), lookup.destination.url)
    }
    let open = OpenLookupResultIntent()
    open.url = destination
    return .result(opensIntent: open, dialog: "\(answer)")
  }
}

/// What Look Up a Verb opens once it has answered. An intent's result can open the app only by
/// naming another intent, so this one exists only to be named there.
struct OpenLookupResultIntent: AppIntent {
  static let title = LocalizedStringResource("Intent.openLookupResultTitle", defaultValue: "Open Lookup Result")
  static let openAppWhenRun = true
  static let isDiscoverable = false

  @Parameter(title: LocalizedStringResource("Intent.openLookupResultURL", defaultValue: "Link"))
  var url: URL?

  func perform() async throws -> some IntentResult {
    let url = url
    await MainActor.run {
      if let url {
        Current.handleURL(url)
      }
    }
    return .result()
  }
}
