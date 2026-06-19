//
//  SnapshotReader.swift
//  ConjuguerWidget
//

import Foundation

enum SnapshotReader {
  static func read() -> WidgetSnapshot? {
    guard
      let url = WidgetConstants.snapshotURL,
      let data = try? Data(contentsOf: url),
      let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    else {
      return nil
    }
    return snapshot
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
