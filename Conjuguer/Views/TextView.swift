//
//  TextView.swift
//  TextView
//
//  Created by Joshua Adams on 7/25/21.
//

import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
//  @Binding var text: NSAttributedString
  let text: NSAttributedString

  func makeUIView(context: Context) -> UITextView {
    let v = UITextView()
    v.isEditable = false
    v.textColor = UIColor(Color.customForeground)
    v.backgroundColor = UIColor(Color.customBackground)
    return v
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.attributedText = text
    uiView.contentOffset = CGPoint(x: 0.0, y: 0.0)
  }
}
