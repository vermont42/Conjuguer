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
}
