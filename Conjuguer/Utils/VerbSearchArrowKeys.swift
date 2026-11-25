//
//  VerbSearchArrowKeys.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import UIKit

// Hack: the arrow keys reach a focused search field as cursor movement, which outranks
// .onKeyPress, .keyboardShortcut, and .commands alike (Konjugieren tried all three on iOS 26.3).
// A UIKeyCommand that asks for priority over system behavior is the one way to see them. It must
// sit on a responder above the field, so it goes on the window's root view controller, and its
// action is defined on every view controller because SwiftUI's own controllers are the ones the
// chain reaches. It is installed only while the verb search field is focused, so the Models
// search, the quiz's answer field, and the tutor keep their arrow keys. Each window keeps its own
// installation, since two windows can each have a verb list with a field.
enum VerbSearchArrowKeys {
  private final class Installation {
    weak var window: UIWindow?
    weak var host: UIViewController?
    let commands: [UIKeyCommand]
    let move: (Int) -> Void

    init(window: UIWindow, host: UIViewController, move: @escaping (Int) -> Void) {
      self.window = window
      self.host = host
      self.move = move
      let down = UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(UIViewController.verbSearchMoveDown(_:)))
      let up = UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(UIViewController.verbSearchMoveUp(_:)))
      for command in [down, up] {
        command.wantsPriorityOverSystemBehavior = true
      }
      commands = [down, up]
      commands.forEach(host.addKeyCommand)
    }

    func remove() {
      commands.forEach { host?.removeKeyCommand($0) }
    }
  }

  private static var installations: [Installation] = []

  static func install(in window: UIWindow, move: @escaping (Int) -> Void) {
    uninstall(from: window)
    guard let root = window.rootViewController else {
      return
    }
    installations.append(Installation(window: window, host: root, move: move))
  }

  static func uninstall(from window: UIWindow) {
    installations.filter { $0.window === window || $0.window == nil }.forEach { $0.remove() }
    installations.removeAll { $0.window === window || $0.window == nil }
  }

  /// Moves the highlight of the verb list in `window`, if that window's field has the keys.
  static func move(by offset: Int, in window: UIWindow?) {
    guard let window else {
      return
    }
    installations.first { $0.window === window }?.move(offset)
  }
}

extension UIViewController {
  @objc fileprivate func verbSearchMoveDown(_ sender: UIKeyCommand) {
    VerbSearchArrowKeys.move(by: 1, in: viewIfLoaded?.window)
  }

  @objc fileprivate func verbSearchMoveUp(_ sender: UIKeyCommand) {
    VerbSearchArrowKeys.move(by: -1, in: viewIfLoaded?.window)
  }
}
