//
//  LoadingView.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/3/26.
//

import SwiftUI

// Shown while the verb/model data is parsed off the main actor at launch. Gates the real
// UI so nothing renders against an empty store. The parse is fast, so this is typically
// on screen only briefly before MainTabView replaces it.
struct LoadingView: View {
  var body: some View {
    ProgressView()
      .controlSize(.large)
      .screenBackground()
      .accessibilityIdentifier("loading_indicator")
  }
}

#if DEBUG
#Preview {
  LoadingView()
}
#endif
