//
//  World.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/15/19.
//  Enhanced by Stephen Celis on 1/16/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import Observation
import SwiftUI

@MainActor var Current = World.chooseWorld()

@MainActor
@Observable
class World {
  var settings: Settings
  var gameCenter: GameCenter
  var quiz: Quiz
  var analytics: Analytics
  var reviewPrompter: ReviewPrompter
  var getterSetter: GetterSetter
  var languageModelService: LanguageModelService
  var soundPlayer: SoundPlayer
  var learnerVerbs: LearnerVerbStore
  var practice: PracticeStore
  var liveActivities: LiveActivities
  var reminderScheduler: ReminderScheduler
  var session: URLSession

  private static let fakeRatingsCount = 1
  private static let fakeSession = URLSession.stubSession(ratingsCount: fakeRatingsCount)

  init(
    settings: Settings,
    gameCenter: GameCenter,
    quiz: Quiz,
    analytics: Analytics,
    reviewPrompter: ReviewPrompter,
    getterSetter: GetterSetter,
    languageModelService: LanguageModelService,
    soundPlayer: SoundPlayer,
    learnerVerbs: LearnerVerbStore,
    practice: PracticeStore,
    liveActivities: LiveActivities,
    reminderScheduler: ReminderScheduler,
    session: URLSession
  ) {
    self.settings = settings
    self.gameCenter = gameCenter
    self.quiz = quiz
    self.analytics = analytics
    self.reviewPrompter = reviewPrompter
    self.getterSetter = getterSetter
    self.languageModelService = languageModelService
    self.soundPlayer = soundPlayer
    self.learnerVerbs = learnerVerbs
    self.practice = practice
    self.liveActivities = liveActivities
    self.reminderScheduler = reminderScheduler
    self.session = session
  }

  static func chooseWorld() -> World {
#if targetEnvironment(simulator)
    let isRunningUnitTests = NSClassFromString("XCTest") != nil
    if isRunningUnitTests {
      return World.unitTest
    } else {
      return World.simulator
    }
#else
    return World.device
#endif
  }

  static let device: World = {
    let getterSetter = GetterSetterReal()
    let settings = Settings(getterSetter: getterSetter)
    let gameCenter = GameCenterReal.shared
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AnalyticsReal()
    let sharedGetterSetter = sharedDefaults()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterReal(settings: settings),
      getterSetter: getterSetter,
      languageModelService: LanguageModelServiceReal(),
      soundPlayer: SoundPlayerReal(),
      learnerVerbs: LearnerVerbStore(getterSetter: sharedGetterSetter),
      practice: PracticeStore(getterSetter: sharedGetterSetter),
      liveActivities: LiveActivitiesReal(),
      reminderScheduler: ReminderSchedulerReal(),
      session: URLSession.shared
    )
  }()

  static let simulator: World = {
    let getterSetter = GetterSetterReal()
    let settings = Settings(getterSetter: getterSetter)
    let gameCenter = GameCenterSpy()
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AnalyticsSpy()
    let sharedGetterSetter = sharedDefaults()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterReal(settings: settings),
      getterSetter: getterSetter,
      languageModelService: LanguageModelServiceReal(),
      soundPlayer: SoundPlayerReal(),
      learnerVerbs: LearnerVerbStore(getterSetter: sharedGetterSetter),
      practice: PracticeStore(getterSetter: sharedGetterSetter),
      liveActivities: LiveActivitiesReal(),
      reminderScheduler: ReminderSchedulerReal(),
      session: fakeSession
    )
  }()

  static let unitTest: World = {
    let getterSetter = GetterSetterFake()
    let settings = Settings(getterSetter: getterSetter)
    let gameCenter = GameCenterSpy()
    let quiz = Quiz(gameCenter: gameCenter)
    let analytics = AnalyticsSpy()
    return World(
      settings: settings,
      gameCenter: gameCenter,
      quiz: quiz,
      analytics: analytics,
      reviewPrompter: ReviewPrompterDummy(),
      getterSetter: getterSetter,
      languageModelService: LanguageModelServiceDummy(),
      soundPlayer: SoundPlayerDummy(),
      learnerVerbs: LearnerVerbStore(getterSetter: GetterSetterFake()),
      practice: PracticeStore(getterSetter: GetterSetterFake()),
      liveActivities: LiveActivitiesSpy(),
      reminderScheduler: ReminderSchedulerSpy(),
      session: fakeSession
    )
  }()

  // The App Group's defaults, where the learner's verbs and practice have always been kept,
  // though the widget reads neither: it reads the snapshots the app writes. Without the group, as
  // in a build lacking the entitlement, the records fall back to the app's own defaults.
  private static func sharedDefaults() -> GetterSetter {
    GetterSetterReal(userDefaults: WidgetConstants.sharedDefaults ?? .standard)
  }
}

extension World {
  /// Settings' Reset Practice: the practice record, the best scores, and which verbs were ever
  /// opened, so that every collection's progress returns to nothing. Stars, Recent, and the daily
  /// challenges' results stay.
  var hasPracticeToReset: Bool {
    practice.hasAnythingToReset || settings.hasBestScore || learnerVerbs.hasFirstOpens
  }

  func resetPractice() {
    practice.reset()
    settings.resetBestScores()
    learnerVerbs.forgetFirstOpens()
    rescheduleReminders()
  }
}
