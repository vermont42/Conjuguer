//
//  VerbSearchCommands.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

// A top-level menu rather than a CommandGroup beside .textEditing: there the system's own Find
// item claims Command-F, and the command never fires (Konjugieren, iPadOS 26.3). The arrow keys
// through results are in VerbSearchArrowKeys, because a menu command cannot take an arrow key
// from a focused text field.
struct VerbSearchCommands: Commands {
  var body: some Commands {
    CommandMenu(L.Navigation.verbs) {
      Button(L.VerbBrowseView.findVerb) {
        Current.openSearch(text: nil, source: .tab)
      }
      .keyboardShortcut("f")
    }
  }
}
