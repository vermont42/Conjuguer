//
//  VerbEssentials.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// Verb Essentials: given an irregular verb, the learner supplies its three key conjugations, the
/// il or elle présent, passé composé, and futur simple. Each is its own question, graded alone and
/// recorded as its own item, but the three are shown together as one step, so the learner sees
/// the verb's pattern assemble.
extension QuizScope {
  /// Five verbs make fifteen blanks, about the default quiz's two or three minutes, since a verb's
  /// second and third blanks come quickly.
  static let verbEssentialsVerbCount = 5

  /// Nil asks the irregular verbs of the learner's band.
  static func verbEssentials(_ verbs: [Verb]? = nil) -> QuizScope {
    QuizScope(
      verbs: verbs,
      questionCount: verbEssentialsVerbCount * PracticeItem.Stem.shown.count,
      source: .verbEssentials,
      isVerbEssentials: true
    )
  }

  /// What the title bar and the Live Activity call a session whose questions look like any
  /// quiz's: Review, My Mistakes, or Verb Essentials.
  var sessionTitle: String? {
    if let modelPractice {
      return modelPractice.title
    }
    if isVerbEssentials {
      return L.VerbEssentials.title
    }
    return recordSession?.title
  }
}

extension Verb {
  /// Whether Verb Essentials asks the verb: one learned verb by verb, whose three key
  /// conjugations the record keeps, and which has all three. Rendre's verbs are learned by their
  /// pattern, and gésir has only its présent.
  var isAskedByVerbEssentials: Bool {
    !PracticeItem.isLearnedByPattern(self)
      && !QuizDraw.excludedEntries.contains(dictionaryKey)
      && PracticeItem.keyConjugations(of: self).count == PracticeItem.Stem.shown.count
  }
}

extension QuizDraw {
  /// One step of Verb Essentials: the verb's key conjugations, in the order the verb page shows
  /// them. `PracticeItem.exercised` maps each back to its own key conjugation in the record.
  static func verbEssentialsStep(verb: Verb) -> [QuizQuestion] {
    let stepID = UUID()
    return Verb.keyTenses.map { QuizQuestion(verb: verb, tense: $0, stepID: stepID) }
  }

  /// A round of Verb Essentials: `count` distinct verbs drawn from `verbs` that it can ask. Verbs
  /// whose IDs are in `asked` are drawn only once every other verb has been, so that five more
  /// verbs are new for as long as the band lasts.
  static func verbEssentialsSteps(
    verbs: [Verb],
    count: Int,
    asked: Set<String>,
    using generator: inout some RandomNumberGenerator
  ) -> [[QuizQuestion]] {
    let askable = verbs.filter(\.isAskedByVerbEssentials)
    let fresh = askable.filter { !asked.contains($0.id) }.shuffled(using: &generator)
    let repeated = askable.filter { asked.contains($0.id) }.shuffled(using: &generator)
    return (fresh + repeated).prefix(count).map(verbEssentialsStep)
  }
}

extension Quiz {
  struct EssentialsRow: Identifiable {
    enum Content {
      /// Asked earlier in the step, and answered.
      case answered(QuizResult)
      /// The question the answer field asks.
      case current
      /// A re-ask asks only the missed key conjugations, and shows the others as hints.
      case given(String)
      /// Asked later in the step.
      case pending
    }

    let question: QuizQuestion
    let content: Content

    var id: String {
      question.tense.articleKey
    }
  }

  /// The questions of the current step, which a Verb Essentials verb's three share. Any other
  /// question is a step of its own.
  var currentStepRange: Range<Int> {
    let index = currentQuestionIndex
    guard index < questions.count, let stepID = questions[index].stepID else {
      return index ..< (index + 1)
    }
    var lower = index
    while lower > 0, questions[lower - 1].stepID == stepID {
      lower -= 1
    }
    var upper = index + 1
    while upper < questions.count, questions[upper].stepID == stepID {
      upper += 1
    }
    return lower ..< upper
  }

  var isFirstQuestionOfStep: Bool {
    currentStepRange.lowerBound == currentQuestionIndex
  }

  /// The current verb's three rows, in the verb page's order. Nil unless the question belongs to a
  /// step of Verb Essentials. Each answered question has its result at the same index, since a
  /// re-ask is only ever inserted after the current question.
  var essentialsRows: [EssentialsRow]? {
    guard scope.isVerbEssentials, let question = currentQuestion, question.stepID != nil else {
      return nil
    }
    let step = currentStepRange
    return Verb.keyTenses.map { tense in
      let row = QuizQuestion(verb: question.verb, tense: tense)
      guard let index = step.first(where: { questions[$0].tense == tense }) else {
        let given = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: tense, extraLetters: question.verb.extraLetters) ?? ""
        return EssentialsRow(question: row, content: .given(given))
      }
      let content: EssentialsRow.Content
      if index < currentQuestionIndex, quizResults.indices.contains(index) {
        content = .answered(quizResults[index])
      } else if index == currentQuestionIndex {
        content = .current
      } else {
        content = .pending
      }
      return EssentialsRow(question: row, content: content)
    }
  }

  /// Where a missed question returns, and the step it joins.
  ///
  /// A question shown alone returns after `reaskGap` others. A Verb Essentials blank returns after
  /// the next verb's step, as a step of its own whose other rows are given, so that a re-ask never
  /// lands among another verb's blanks. A second miss in the same verb joins the first's re-ask,
  /// after it, which keeps the verb page's order.
  static func reaskPlacement(of index: Int, in questions: [QuizQuestion]) -> (position: Int, stepID: UUID?) {
    let question = questions[index]
    guard let stepID = question.stepID else {
      return (reaskPosition(after: index, in: questions.count), nil)
    }
    let later = questions.indices.dropFirst(index + 1)
    if
      let joined = later.first(where: { questions[$0].isReask && questions[$0].verb.id == question.verb.id }),
      let joinedStep = questions[joined].stepID {
      return (stepEnd(from: joined, in: questions, stepID: joinedStep), joinedStep)
    }
    let nextStart = stepEnd(from: index, in: questions, stepID: stepID)
    guard nextStart < questions.count else {
      return (questions.count, UUID())
    }
    return (stepEnd(from: nextStart, in: questions, stepID: questions[nextStart].stepID), UUID())
  }

  /// The index after the last question of the step that holds `index`.
  private static func stepEnd(from index: Int, in questions: [QuizQuestion], stepID: UUID?) -> Int {
    guard stepID != nil else {
      return index + 1
    }
    return questions.indices.dropFirst(index + 1).first { questions[$0].stepID != stepID } ?? questions.count
  }
}
