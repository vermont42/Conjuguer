//
//  InfoView.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/6/21.
//

import SwiftUI

struct InfoView: View {
  @Environment(World.self) private var world
  let info: Info
  let shouldShowInfoHeading: Bool

  init(info: Info, shouldShowInfoHeading: Bool = false) {
    self.info = info
    self.shouldShowInfoHeading = shouldShowInfoHeading
  }

  var body: some View {
    VStack {
      if let imageInfo = info.imageInfo {
        Image(imageInfo.filename)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 270)
          .accessibilityLabel(imageInfo.accessibilityLabel)
      }

      if shouldShowInfoHeading {
        Text(info.heading)
          .headingLabel()
        Spacer()
      }

      TextView(text: info.attributedText)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .navigationTitle(shouldShowInfoHeading ? "" : info.heading)
    }
    .padding(.leading, Layout.doubleDefaultSpacing)
    .padding(.trailing, Layout.doubleDefaultSpacing)
    .onAppear {
      world.analytics.recordViewAppeared("\(InfoView.self)")
    }
    .screenBackground()
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return InfoView(info: PreviewSupport.sampleInfo, shouldShowInfoHeading: true)
    .environment(Current)
}
#endif
