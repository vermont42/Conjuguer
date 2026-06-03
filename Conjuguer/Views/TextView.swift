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

  func makeCoordinator() -> TextViewDelegate {
    TextViewDelegate()
  }

  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.isEditable = false
    textView.backgroundColor = UIColor(Color.customBackground)
    textView.delegate = context.coordinator
    textView.contentOffset = .zero
    return textView
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.attributedText = text
  }
}

class TextViewDelegate: NSObject, UITextViewDelegate {
  func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
    guard case let .link(url) = textItem.content else {
      return defaultAction
    }

    let cleansedUrlString = firstLetterLowercasedString(parenlessString((url.absoluteString.removingPercentEncoding ?? "")))

    if let infoIndex = Info.headingToIndex(heading: cleansedUrlString) {
      let infoDeepLinkUrlString = URL.conjuguerUrlPrefix + "\(URL.infoHost)/\(infoIndex)"
      URL(string: infoDeepLinkUrlString).map {
        Current.handleInAppURL($0)
      }
      return nil
    } else if Verb.verbs[cleansedUrlString] != nil {
      let verbDeepLinkUrlString = URL.conjuguerUrlPrefix + "\(URL.verbHost)/\(parenlessString(firstLetterLowercasedString(url.absoluteString)))"
      URL(string: verbDeepLinkUrlString).map {
        Current.handleInAppURL($0)
      }
      return nil
    } else {
      return defaultAction
    }
  }

  private func parenlessString(_ input: String) -> String {
    input
      .replacingOccurrences(of: "(", with: "")
      .replacingOccurrences(of: ")", with: "")
  }

  private func firstLetterLowercasedString(_ input: String) -> String {
    input.prefix(1).lowercased() + input.dropFirst()
  }
}
