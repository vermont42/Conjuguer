//
//  ViewControllerTransitions.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import UIKit

// Hack: UIKit drops a navigation push made while another view controller is still presenting or
// dismissing ("the navigation stack will not be updated"), and SwiftUI offers no way to know when
// such a transition ends. On iPad, a tap outside an empty search field ends the search, and a
// push from that same tap arrived during the search's dismissal, so a recent verb opened nothing
// (Konjugieren, iPadOS 26.3).
enum ViewControllerTransitions {
  /// Returns once no view controller is mid-transition, or after a second at most. With nothing
  /// presenting or dismissing, as on an iPhone, it returns at once.
  static func waitUntilIdle() async {
    for _ in 0..<20 {
      guard allControllers.contains(where: { $0.transitionCoordinator != nil || $0.isBeingDismissed }) else {
        return
      }
      try? await Task.sleep(for: .milliseconds(50))
    }
  }

  private static var allControllers: [UIViewController] {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .compactMap(\.rootViewController)
      .flatMap(descendants)
  }

  private static func descendants(of controller: UIViewController) -> [UIViewController] {
    let children = controller.children + [controller.presentedViewController].compactMap { $0 }
    return [controller] + children.flatMap(descendants)
  }
}
