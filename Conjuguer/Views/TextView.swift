//
//  TextView.swift
//  TextView
//
//  Created by Josh Adams on 7/25/21.
//

import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
  let text: NSAttributedString

  func makeUIView(context: Context) -> UITextView {
    let v = UITextView()
    v.isEditable = false
    v.contentOffset = .zero
    return v
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.backgroundColor = UIColor(Color.customBackground)
    uiView.attributedText = text
    uiView.contentOffset = .zero
  }
}
