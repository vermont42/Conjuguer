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
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
          .shadow(color: Color.customForeground.opacity(0.2), radius: 8, y: 4)
          .accessibilityLabel(imageInfo.accessibilityLabel)
      }

      if shouldShowInfoHeading {
        Text(info.heading)
          .headingForegroundLabel()
        Spacer()
      }

      TextView(text: info.attributedText)
        .frame(minWidth: 0, maxWidth: 680, minHeight: 0, maxHeight: .infinity)
        .navigationTitle(shouldShowInfoHeading ? "" : info.heading)
    }
    .padding(.leading, Layout.doubleDefaultSpacing)
    .padding(.trailing, Layout.doubleDefaultSpacing)
    .recordsAppearance(as: "\(InfoView.self)")
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
