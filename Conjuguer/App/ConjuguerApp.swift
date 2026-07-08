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
              get: { !Current.settings.hasSeenOnboarding },
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
        refreshWidgets()
      }
      .onOpenURL(perform: Current.handleURL(_:))
      .onChange(of: scenePhase) {
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
    }
  }

  init() {
    let appID = Bundle.main.infoDictionary?["TelemetryDeckAppID"] as? String ?? ""
    Current.analytics.initialize(appID: appID)

    Current.soundPlayer.setup()
    Utterer.setup()

    LiveActivityManager.endAllActivities()

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
