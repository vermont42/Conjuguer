//
//  WidgetSnapshot.swift
//  Conjuguer
//
//  Shared between the app and the widget extension.
//

import Foundation

// The verb-of-the-day payload the app precomputes and writes to the shared container.
// The widget extension only decodes and renders this — it never loads the verb data or
// runs the conjugation engine itself.
struct WidgetSnapshot: Codable, Equatable {
  let infinitif: String
  let translation: String
  let auxiliary: String
  let frequency: Int
  let présentParadigm: [WidgetConjugation]
  let participePassé: String
  let etymologySnippet: String?
  let exampleFrench: String?
  let exampleEnglish: String?
  let exampleSource: String?
  let quizQuestion: WidgetQuizQuestion
  let dateString: String
}

struct WidgetConjugation: Codable, Equatable {
  let pronoun: String
  let form: String
}

struct WidgetQuizQuestion: Codable, Equatable {
  let infinitif: String
  let tenseDisplay: String
  let pronoun: String?
  let correctAnswer: String
  let wrongAnswers: [String]
  let questionID: String
}
