//
//  InfoView.swift
//  Conjuguer
//
//  Created by Joshua Adams on 8/6/21.
//

import SwiftUI
import UIKit

struct InfoView: View {
  let info: Info

  var body: some View {
      TextView(text: info.attributedText)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .navigationTitle(info.heading)
        .customNavigationBarItems()
  }
}
