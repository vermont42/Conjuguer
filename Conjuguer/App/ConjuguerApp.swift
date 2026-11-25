//
//  ConjuguerApp.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/1/21.
//

import CoreSpotlight
import SwiftUI
import TipKit
import WidgetKit

struct ConjuguerApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @State private var verbData = VerbData()
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      Group {
        switch verbData.state {
        case .loading:
          LoadingView()
        case .loaded:
          MainTabView()
            .environment(Current)
            .fullScreenCover(isPresented: Binding(
              get: { OnboardingDisplay.onboardingEnabled && !Current.settings.hasSeenOnboarding },
              set: { newValue in
                if !newValue {
                  Current.settings.hasSeenOnboarding = true
                }
              }
            )) {
              OnboardingView()
            }
        }
      }
      .task {
        await verbData.load()
        Current.practice.migrateIfNeeded()
        Current.rescheduleReminders()
        // Replay any deeplink that arrived (via onOpenURL) before the data was ready.
        Current.drainPendingDeeplink()
        refreshWidgets()
        await VerbSpotlight.indexVerbsIfNeeded()
      }
      .onOpenURL(perform: Current.handleURL(_:))
      .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
        guard let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
          return
        }
        Current.handle(.verb(.key(VerbSpotlight.verbKey(fromSpotlightIdentifier: identifier)), source: .spotlight))
      }
      .onChange(of: scenePhase) {
        // The day may have turned, and the record changed, since the reminders were scheduled.
        if scenePhase == .active || scenePhase == .background {
          Current.rescheduleReminders()
        }
        guard scenePhase == .active else {
          return
        }
        drainPendingWidgetDeeplink()
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
    .commands {
      VerbSearchCommands()
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

  @MainActor private func drainPendingWidgetDeeplink() {
    guard
      let deeplink = WidgetConstants.sharedDefaults?.string(forKey: WidgetConstants.pendingDeeplinkKey),
      let url = URL(string: deeplink)
    else {
      return
    }
    WidgetConstants.sharedDefaults?.removeObject(forKey: WidgetConstants.pendingDeeplinkKey)
    Current.handleURL(url)
  }
}
