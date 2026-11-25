//
//  QuickActions.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import UIKit
import UserNotifications

/// The Home Screen quick actions, shown on a long press of the app icon. They are installed at
/// launch rather than declared in Info.plist, so that their titles come from the string catalog
/// like every other string.
enum QuickAction: String, CaseIterable {
  case findVerb = "software.racecondition.Conjuguer.findVerb"

  var item: UIApplicationShortcutItem {
    switch self {
    case .findVerb:
      return UIApplicationShortcutItem(
        type: rawValue,
        localizedTitle: L.VerbBrowseView.findVerb,
        localizedSubtitle: nil,
        icon: UIApplicationShortcutIcon(systemImageName: "magnifyingglass")
      )
    }
  }

  var deeplink: Deeplink {
    switch self {
    case .findVerb:
      return .search(text: "", source: .quickAction)
    }
  }

  static func install() {
    UIApplication.shared.shortcutItems = allCases.map(\.item)
  }

  /// The link goes to the router of the window the action was performed in, which holds it
  /// until the verbs have loaded when the quick action launched the app.
  static func perform(_ item: UIApplicationShortcutItem, in scene: UIScene) -> Bool {
    guard let link = QuickAction(rawValue: item.type)?.deeplink else {
      return false
    }
    SceneRouter.deliver(link, to: scene)
    return true
  }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    QuickAction.install()
    UNUserNotificationCenter.current().delegate = ReminderNotificationDelegate.shared
    return true
  }

  // SwiftUI offers no hook for quick actions, which UIKit delivers to the scene delegate. A
  // delegate named here receives them while SwiftUI still manages the window.
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    configuration.delegateClass = QuickActionSceneDelegate.self
    return configuration
  }
}

final class QuickActionSceneDelegate: NSObject, UIWindowSceneDelegate {
  /// A quick action that launched the app arrives here, not in the method below.
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if let item = connectionOptions.shortcutItem {
      _ = QuickAction.perform(item, in: scene)
    }
  }

  func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    completionHandler(QuickAction.perform(shortcutItem, in: windowScene))
  }
}
