//
//  GameCenterAuthView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/12/21.
//

import SwiftUI
import UIKit

class GameCenterAuthVC: UIViewController {}

struct GameCenterAuthView: UIViewControllerRepresentable {
  typealias UIViewControllerType = UIViewController
  let gameCenterAuthVC = GameCenterAuthVC()

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

  func makeUIViewController(context: Context) -> UIViewController {
    gameCenterAuthVC
  }
}
