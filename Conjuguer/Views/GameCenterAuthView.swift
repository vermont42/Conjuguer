//
//  GameCenterAuthView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/12/21.
//

import SwiftUI
import UIKit

class GameCenterAuthVC: UIViewController {}

// Owns the view controller that Game Center's authentication UI is presented from. QuizView holds
// this in @State so the controller's lifetime is stable across view-struct churn, and the
// controller that gets mounted by GameCenterAuthView is the same one authentication presents from.
@MainActor
final class GameCenterAuthCoordinator {
  let viewController = GameCenterAuthVC()
}

struct GameCenterAuthView: UIViewControllerRepresentable {
  let coordinator: GameCenterAuthCoordinator

  func makeUIViewController(context: Context) -> UIViewController {
    coordinator.viewController
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
