//
//  Modifiers.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/28/21.
//

import SwiftUI

struct SubheadingLabel: ViewModifier {
  @Environment(\.colorScheme) var colorScheme

  func body(content: Content) -> some View {
    content
      .font(.system(.subheadline))
      .foregroundColor(colorScheme == .dark ? Color(UIColor.lightGray) : Color(UIColor.darkGray))
  }
}

struct BodyLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.system(.body))
  }
}

struct HeadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.system(.headline))
  }
}
