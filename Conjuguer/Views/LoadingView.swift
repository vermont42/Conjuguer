//
//  LoadingView.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/3/26.
//

import SwiftUI

struct LoadingView: View {
  var body: some View {
    VStack(spacing: Layout.doubleDefaultSpacing) {
      Image("Splash")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 120)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityHidden(true)

      Text("Conjuguer")
        .font(largeTitleFont)
        .foregroundStyle(Color.customBlue)

      ProgressView()
        .controlSize(.large)
        .padding(.top, Layout.defaultSpacing)
    }
    .screenBackground()
    .accessibilityIdentifier("loading_indicator")
  }
}

#if DEBUG
#Preview {
  LoadingView()
}
#endif
