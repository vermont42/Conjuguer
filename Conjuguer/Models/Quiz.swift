//
//  Quiz.swift
//  Conjuguer
//
//  Created by Josh Adams on 10/16/21.
//

import SwiftUI

class Quiz: ObservableObject {
  @Published private(set) var quizState = QuizState.notStarted
  @Published private(set) var elapsedTime: Int = 0
  private(set) var score: Int = 0
  private(set) var currentQuestionIndex = 0
  private(set) var proposedAnswers: [String] = []
  private(set) var correctAnswers: [String] = []
  private(set) var questions: [(String, Tense, PersonNumber)] = []

  private var timer: Timer?
  private var timer2: Timer?
  private var gameCenter: GameCenterable?
  private var shouldShuffle = true

  private var regularErs = QuizVerbs.regularErs
  private var regularErsIndex = 0
  private var regularIrs = QuizVerbs.regularIrs
  private var regularIrsIndex = 0
  private var regularRes = QuizVerbs.regularRes
  private var regularResIndex = 0
  private var bigThrees = QuizVerbs.bigThrees
  private var bigThreesIndex = 0
  private var indicatifPrésentStemChangers = QuizVerbs.indicatifPrésentStemChangers
  private var indicatifPrésentStemChangersIndex = 0
  private var êtreAuxiliaries = QuizVerbs.êtreAuxiliaries
  private var êtreAuxiliariesIndex = 0
  private var irregularParticipePassés = QuizVerbs.irregularParticipePassés
  private var irregularParticipePassésIndex = 0
  private var subjonctifPrésentStemChangers = QuizVerbs.subjonctifPrésentStemChangers
  private var subjonctifPrésentStemChangersIndex = 0
  private var topThirties = QuizVerbs.topThirties
  private var topThirtiesIndex = 0
  private var regularRadicauxFuturs = QuizVerbs.regularRadicauxFuturs
  private var regularRadicauxFutursIndex = 0
  private var irregularRadicauxFuturs = QuizVerbs.irregularRadicauxFuturs
  private var irregularRadicauxFutursIndex = 0

  init(gameCenter: GameCenterable, shouldShuffle: Bool = true) {
    self.gameCenter = gameCenter
    self.shouldShuffle = shouldShuffle
  }

  func start() {
    quizState = .inProgress
    elapsedTime = 0
    timer = Timer.scheduledTimer(
      withTimeInterval: 1.0,
      repeats: true,
      block: { [weak self] _ in
        self?.elapsedTime += 1
      }
    )
  }

  func quit() {
    timer?.invalidate()
    quizState = .notStarted
  }

  @objc func eachSecond() {
    elapsedTime += 1
  }
}
