//
//  BrowseLayout.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/22/26.
//

import SwiftUI

enum BrowseLayout {
  static let columns = [
    GridItem(.adaptive(minimum: 250), spacing: Layout.doubleDefaultSpacing)
  ]

  // The iPad idiom, which a Mac running the iPad app also reports.
  static let isPadOrMac = UIDevice.current.userInterfaceIdiom == .pad

  // iPadOS 26 shrinks .automatic search into a toolbar button that ignores .searchFocused, so
  // Command-F could not open it (Konjugieren, iPadOS 26.3). A drawer that stays put accepts
  // programmatic focus. The Models tab uses it too, so that the two tabs look alike.
  static var searchPlacement: SearchFieldPlacement {
    isPadOrMac ? .navigationBarDrawer(displayMode: .always) : .automatic
  }
}
