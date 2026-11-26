//
//  ConjuguerApp.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/1/21.
//

import SwiftUI
import TipKit
import WidgetKit

struct ConjuguerApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @State private var verbData = VerbData()
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      SceneRoot(verbData: verbData)
        .task {
          await verbData.load()
          Current.rescheduleReminders()
          refreshWidgets()
          await VerbSpotlight.indexVerbsIfNeeded()
        }
    }
    .commands {
      VerbSearchCommands()
    }
    // The app's phase, not a window's: these run once however many windows are open.
    .onChange(of: scenePhase) {
      // The day may have turned, and the record changed, since the reminders were scheduled.
      if scenePhase == .active || scenePhase == .background {
        Current.rescheduleReminders()
      }
      guard scenePhase == .active else {
        return
      }
      refreshWidgets()
      Current.languageModelService.refreshAvailability()
    }
    .onChange(of: Current.settings.pronounGender) {
      refreshWidgets()
    }
    // The quiz widget asks the first question of the day's challenge at the learner's level.
    .onChange(of: Current.settings.quizLevel) {
      refreshWidgets()
    }
  }

  init() {
    let appID = Bundle.main.infoDictionary?["TelemetryDeckAppID"] as? String ?? ""
    Current.analytics.initialize(appID: appID)
    QuizAbandonment.reportAndClear(getterSetter: Current.getterSetter, analytics: Current.analytics)

    Current.soundPlayer.setup()
    Utterer.setup()

    Current.liveActivities.endAll()

    if TipDisplay.tipsEnabled {
      try? Tips.configure()
    }
  }

  @MainActor private func refreshWidgets() {
    // Only spend the limited widget reload budget when the snapshot actually changed.
    if WidgetSnapshotWriter.writeSnapshots() {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}
