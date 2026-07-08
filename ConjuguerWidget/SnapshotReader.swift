//
//  SnapshotReader.swift
//  ConjuguerWidget
//

import Foundation

enum SnapshotReader {
  // All precomputed daily snapshots (today first), in the order the app wrote them.
  static func readAll() -> [WidgetSnapshot] {
    guard
      let url = WidgetConstants.snapshotsURL,
      let data = try? Data(contentsOf: url),
      let snapshots = try? JSONDecoder().decode([WidgetSnapshot].self, from: data)
    else {
      return []
    }
    return snapshots
  }

  // The snapshot for `date` (default today); falls back to the most-future available
  // snapshot if the app hasn't written one for that day, then to nil.
  static func read(for date: Date = Date()) -> WidgetSnapshot? {
    let all = readAll()
    let target = WidgetDateHelper.dateString(for: date)
    return all.first { $0.dateString == target } ?? all.last
  }

  static var placeholder: WidgetSnapshot {
    WidgetSnapshot(
      infinitif: "parler",
      translation: "to speak, talk",
      auxiliary: "avoir",
      frequency: 1,
      présentParadigm: [
        WidgetConjugation(pronoun: "je", form: "parle"),
        WidgetConjugation(pronoun: "tu", form: "parles"),
        WidgetConjugation(pronoun: "elle", form: "parle"),
        WidgetConjugation(pronoun: "nous", form: "parlons"),
        WidgetConjugation(pronoun: "vous", form: "parlez"),
        WidgetConjugation(pronoun: "elles", form: "parlent")
      ],
      participePassé: "parlé",
      etymologySnippet: "Du latin ~parabolare~, « raconter ».",
      exampleFrench: "Elle parle français couramment.",
      exampleEnglish: "She speaks French fluently.",
      exampleSource: "Exemple",
      quizQuestion: WidgetQuizQuestion(
        infinitif: "parler",
        tenseDisplay: "Indicatif Présent",
        pronoun: "nous",
        correctAnswer: "parlons",
        wrongAnswers: ["parlez", "parlent", "parle"],
        questionID: "placeholder"
      ),
      dateString: "2026-01-01"
    )
  }
}
