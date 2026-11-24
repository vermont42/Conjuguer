//
//  QuizResult.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/8/21.
//

import Foundation

struct QuizResult: Hashable, Identifiable {
  let id = UUID()
  let infinitif: String
  let tense: Tense
  let conjugationResult: ConjugationResult
  let correctAnswer: String
  let actualAnswer: String
  var shownSpelling: String?
  /// The slip that earned a second attempt. `actualAnswer` is the second attempt.
  var firstAttempt: String?
  var isReask = false
  /// The gender the question was asked in, nil for the learner's setting.
  var pronounGender: PronounGender?
  /// A Name the Conjugation question's prompt. `correctAnswer` then holds its right answers, one a
  /// line, and the answers are summaries such as "être · passé simple · nous".
  var recognitionPrompt: String?
  /// A Phrases à trous question's sentence, read with its conjugation written in.
  var sentence: String?
  /// The `dictionaryKey` of the verb asked, whose example sentence the results can offer.
  var verbKey: String?

  /// A right re-ask earns half points on either attempt, as a right second attempt does.
  var points: Int {
    guard isReask, conjugationResult != .noMatch else {
      return conjugationResult.score
    }
    return ConjugationResult.secondAttemptMatch.score
  }
}

extension QuizResult {
  /// The first right answer of each verb, in order, which the results let open the verb's
  /// example sentence, so that a verb asked three times offers it once.
  static func firstRightOfEachVerb(in results: [QuizResult]) -> [QuizResult] {
    var verbs: Set<String> = []
    return results.filter { result in
      guard result.conjugationResult != .noMatch, let verbKey = result.verbKey else {
        return false
      }
      return verbs.insert(verbKey).inserted
    }
  }
}
