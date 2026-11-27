//
//  LastQuizResult.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// The results of the last quiz the learner saw, which the Quiz tab shows. It is kept on the
/// device beside the practice record and sent nowhere.
struct LastQuizResult: Codable, Equatable {
  /// What was quizzed. A kind, not a title, so that the Quiz tab names it in the app's current
  /// language.
  enum Kind: String, Codable {
    case allVerbs
    case challenge
    case collection
    case custom
    case daily
    case mistakes
    case modelAlone
    case modelMixed
    case myVerbs
    case practiceSet
    case recognition
    case review
    case sentences
    case speedRound
    case verbEssentials
    case verbPage
  }

  static let storageKey = "lastQuizResult"

  let kind: Kind
  /// The `dictionaryKey` of a verb page's verb, the key of a collection, or a practiced model's id.
  let subject: String?
  /// Nil for Review, My Mistakes, a model's practice, and the Speed Round, which do not ask by
  /// level.
  let levelKey: String?
  let score: Int
  let correctCount: Int
  let secondAttemptCount: Int
  let questionCount: Int
  let date: Date

  var level: QuizLevel? {
    levelKey.flatMap(QuizLevel.init(rawValue:))
  }

  init(kind: Kind, subject: String?, level: QuizLevel?, score: Int, correctCount: Int, secondAttemptCount: Int, questionCount: Int, date: Date) {
    self.kind = kind
    self.subject = subject
    levelKey = level?.rawValue
    self.score = score
    self.correctCount = correctCount
    self.secondAttemptCount = secondAttemptCount
    self.questionCount = questionCount
    self.date = date
  }

  /// A Ten More round's results replace its first round's, so that the tab shows the session so
  /// far.
  init(quiz: Quiz, date: Date) {
    let kind = Kind(scope: quiz.scope)
    let subject: String?
    switch kind {
    case .collection:
      subject = quiz.scope.collection?.key
    case .modelAlone, .modelMixed:
      subject = quiz.scope.modelPractice?.modelID
    case .verbPage:
      subject = quiz.scope.verbs?.first?.dictionaryKey
    case .allVerbs, .challenge, .custom, .daily, .mistakes, .myVerbs, .practiceSet, .recognition, .review, .sentences, .speedRound, .verbEssentials:
      subject = nil
    }
    self.init(
      kind: kind,
      subject: subject,
      level: quiz.scope.asksByLevel ? quiz.level : nil,
      score: quiz.score,
      correctCount: quiz.correctCount,
      secondAttemptCount: quiz.secondAttemptCount,
      questionCount: quiz.sessionQuestionCount,
      date: date
    )
  }

  init?(json: String) {
    guard
      let data = json.data(using: .utf8),
      let decoded = try? JSONDecoder().decode(LastQuizResult.self, from: data)
    else {
      return nil
    }
    self = decoded
  }

  var json: String? {
    guard let data = try? JSONEncoder().encode(self) else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }

  @MainActor var title: String {
    switch kind {
    case .allVerbs:
      return L.QuizView.allVerbs
    case .challenge:
      return L.DailyChallenge.title
    case .collection:
      return subject.flatMap(VerbCollection.init(key:))?.title ?? L.PracticeSet.title
    case .custom:
      return L.CustomQuiz.title
    case .daily:
      return L.DailySession.title
    case .mistakes:
      return QuizRecordSession.mistakes.title
    case .modelAlone:
      return subject.map { ModelPracticeSession(modelID: $0, mode: .alone).title } ?? L.ModelPractice.title
    case .modelMixed:
      return subject.map { ModelPracticeSession(modelID: $0, mode: .mixed).title } ?? L.ModelPractice.title
    case .myVerbs:
      return L.MyVerbs.title
    case .practiceSet:
      return L.PracticeSet.title
    case .recognition:
      return L.Recognition.title
    case .review:
      return QuizRecordSession.review.title
    case .sentences:
      return L.Sentences.title
    case .speedRound:
      return L.SpeedRound.title
    case .verbEssentials:
      return L.VerbEssentials.title
    case .verbPage:
      return subject.flatMap { Verb.verbs[$0]?.infinitifWithPossibleExtraLetters } ?? subject ?? L.QuizView.allVerbs
    }
  }
}

extension LastQuizResult.Kind {
  /// A practice set is a custom quiz opened from a link or a code, and a custom quiz over a
  /// collection counts as custom, since the learner chose it in the editor.
  init(scope: QuizScope) {
    switch scope.kind {
    case .modelPractice(let session, _):
      self = session.mode == .alone ? .modelAlone : .modelMixed
    case .recordSession(.review):
      self = .review
    case .recordSession(.mistakes):
      self = .mistakes
    case .verbEssentials:
      self = .verbEssentials
    case .recognition:
      self = .recognition
    case .sentences:
      self = .sentences
    case .speedRound:
      self = .speedRound
    case .daily:
      self = .daily
    case .challenge:
      self = .challenge
    case .practiceSet:
      self = .practiceSet
    case .custom:
      self = .custom
    case .verbPage:
      self = .verbPage
    case .collection:
      self = .collection
    case .myVerbs:
      self = .myVerbs
    case .allVerbs:
      self = .allVerbs
    }
  }
}
