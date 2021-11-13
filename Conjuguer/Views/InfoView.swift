//
//  InfoView.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/6/21.
//

import SwiftUI
import UIKit

struct InfoView: View {
  let info: Info
  let shouldShowInfoHeading: Bool

  init(info: Info, shouldShowInfoHeading: Bool = false) {
    self.info = info
    self.shouldShowInfoHeading = shouldShowInfoHeading
  }

  var body: some View {
    VStack {
      if let imageName = info.imageName {
        Image(imageName)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 270)
      }

      if shouldShowInfoHeading {
        Text(info.heading)
          .headingLabel()
        Spacer()
      }

      TextView(text: info.attributedText)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .navigationTitle(info.heading)
        .customNavigationBarItems()
    }
      .padding(.leading, Layout.doubleDefaultSpacing)
      .padding(.trailing, Layout.doubleDefaultSpacing)
  }
}
