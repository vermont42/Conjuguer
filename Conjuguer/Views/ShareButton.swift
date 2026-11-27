//
//  ShareButton.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/27/26.
//

import SwiftUI

/// A button that hands its own frame, in window coordinates, to its action, so that the share
/// sheet it presents points at it from a popover on iPad. The frame is nil until the button has
/// been laid out.
struct ShareButton<Label: View>: View {
  let action: (CGRect?) -> Void
  let label: Label
  @State private var frame: CGRect?

  init(action: @escaping (CGRect?) -> Void, @ViewBuilder label: () -> Label) {
    self.action = action
    self.label = label()
  }

  var body: some View {
    Button {
      action(frame)
    } label: {
      label
    }
    .onGeometryChange(for: CGRect.self) { proxy in
      proxy.frame(in: .global)
    } action: { newFrame in
      frame = newFrame
    }
  }
}
