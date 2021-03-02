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

struct TableText: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.system(.title2))
  }
}

struct HeadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.system(.headline))
  }
}

struct LeftAligned: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

extension View {
    func leftAligned() -> some View {
        return self.modifier(LeftAligned())
    }

  func tableText() -> some View {
      return self.modifier(TableText())
  }
}
