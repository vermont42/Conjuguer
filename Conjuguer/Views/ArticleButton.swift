//
//  ArticleButton.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import SwiftUI

/// The red question-mark diamond beside a heading, which opens an Info article.
struct ArticleButton: View {
  let hint: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: "questionmark.diamond.fill")
    }
    .buttonStyle(.borderless)
    .tint(.customRed)
    .accessibilityLabel(Text(L.Navigation.info))
    .accessibilityHint(Text(hint))
  }
}
