//
//  SceneRoot.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/25/26.
//

import CoreSpotlight
import SwiftUI

/// One window's content. It owns that window's router, so that what a link, a Spotlight
/// result, a quick action, or the widget's stashed link opens appears in this window alone.
struct SceneRoot: View {
  let verbData: VerbData
  @State private var router = SceneRouter()
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    Group {
      switch verbData.state {
      case .loading:
        LoadingView()
      case .loaded:
        MainTabView()
          .environment(Current)
          .environment(router)
          .fullScreenCover(isPresented: Binding(
            get: { OnboardingDisplay.onboardingEnabled && !Current.settings.hasSeenOnboarding },
            set: { newValue in
              if !newValue {
                Current.settings.hasSeenOnboarding = true
              }
            }
          )) {
            OnboardingView()
              .environment(router)
          }
      }
    }
    .background(WindowReader(router: router))
    .focusedSceneValue(\.sceneRouter, router)
    .task {
      await verbData.load()
      // Replay any link that arrived (via onOpenURL) before the data was ready.
      router.drainPendingDeeplink()
#if DEBUG
      // Verification hook: `-CONJUGUER_SECOND_WINDOW YES` opens a second window, which the
      // simulator offers no other scriptable way to do.
      if UserDefaults.standard.bool(forKey: "CONJUGUER_SECOND_WINDOW"), UIApplication.shared.connectedScenes.count == 1 {
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: nil, options: nil)
      }
#endif
    }
    .onOpenURL(perform: router.handleURL(_:))
    .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
      guard let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
        return
      }
      router.handle(.verb(.key(VerbSpotlight.verbKey(fromSpotlightIdentifier: identifier)), source: .spotlight))
    }
    .onChange(of: scenePhase, initial: true) {
      guard scenePhase == .active else {
        return
      }
      router.claimUnaddressedLink()
      drainPendingWidgetDeeplink()
    }
  }

  /// The control and the shortcuts stash their link in the App Group, since they run outside the
  /// app. The first window to become active takes it, and removing it at once keeps a second
  /// window from taking it too.
  private func drainPendingWidgetDeeplink() {
    guard
      let deeplink = WidgetConstants.sharedDefaults?.string(forKey: WidgetConstants.pendingDeeplinkKey),
      let url = URL(string: deeplink)
    else {
      return
    }
    WidgetConstants.sharedDefaults?.removeObject(forKey: WidgetConstants.pendingDeeplinkKey)
    router.handleURL(url)
  }
}

/// Tells the router which window it serves, once SwiftUI has put the content in one. SwiftUI
/// names no window or scene to a view, so a view of UIKit's asks its own.
private struct WindowReader: UIViewRepresentable {
  let router: SceneRouter

  func makeUIView(context: Context) -> ReaderView {
    ReaderView(router: router)
  }

  func updateUIView(_ view: ReaderView, context: Context) {}

  final class ReaderView: UIView {
    private let router: SceneRouter

    init(router: SceneRouter) {
      self.router = router
      super.init(frame: .zero)
      isUserInteractionEnabled = false
      isAccessibilityElement = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
      super.didMoveToWindow()
      if let window {
        router.attach(to: window)
      }
    }
  }
}
