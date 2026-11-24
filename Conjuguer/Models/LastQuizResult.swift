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
    case collection
    case custom
    case mistakes
    case modelAlone
    case modelMixed
    case myVerbs
    case practiceSet
    case recognition
    case review
    case sentences
    case verbEssentials
    case verbPage
  }

  static let storageKey = "lastQuizResult"

  let kind: Kind
  /// The `dictionaryKey` of a verb page's verb, the key of a collection, or a practiced model's id.
  let subject: String?
  /// Nil for Review and My Mistakes, which do not ask by level.
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
    case .allVerbs, .custom, .mistakes, .myVerbs, .practiceSet, .recognition, .review, .sentences, .verbEssentials:
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
    case .collection:
      return subject.flatMap(VerbCollection.init(key:))?.title ?? L.PracticeSet.title
    case .custom:
      return L.CustomQuiz.title
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
    if let session = scope.modelPractice {
      self = session.mode == .alone ? .modelAlone : .modelMixed
    } else if let session = scope.recordSession {
      switch session {
      case .review:
        self = .review
      case .mistakes:
        self = .mistakes
      }
    } else if scope.isVerbEssentials {
      self = .verbEssentials
    } else if scope.isRecognition {
      self = .recognition
    } else if scope.isSentences {
      self = .sentences
    } else if scope.isPracticeSet {
      self = .practiceSet
    } else if scope.custom != nil {
      self = .custom
    } else if scope.isVerbPage {
      self = .verbPage
    } else if scope.collection != nil {
      self = .collection
    } else if scope.verbs != nil {
      self = .myVerbs
    } else {
      self = .allVerbs
    }
  }
}
