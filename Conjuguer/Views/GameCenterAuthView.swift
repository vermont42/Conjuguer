//
//  GameCenterAuthView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/12/21.
//

import SwiftUI
import UIKit

class GameCenterAuthVC: UIViewController {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Current.gameCenter.authenticate(onViewController: self)
  }
}

struct GameCenterAuthView: UIViewControllerRepresentable {
  typealias UIViewControllerType = UIViewController
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

  func makeUIViewController(context: Context) -> UIViewController {
    GameCenterAuthVC()
  }
}
