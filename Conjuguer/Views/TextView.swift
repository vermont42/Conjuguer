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
  let textViewDelegate = TextViewDelegate()

  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.isEditable = false
    textView.contentOffset = .zero
    return textView
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.backgroundColor = UIColor(Color.customBackground)
    uiView.attributedText = text
    uiView.font = UIFont.preferredFont(forTextStyle: .body)
    uiView.contentOffset = .zero
    uiView.delegate = textViewDelegate
  }
}

class TextViewDelegate: NSObject, UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
    let cleansedUrlString = firstLetterLowercasedString(parenlessString((url.absoluteString.removingPercentEncoding ?? "")))

    // InfoView's text is shown as a sheet (in the Info or Models tab), so verb/info links
    // are handled in place via handleInAppURL rather than UIApplication.open. The latter
    // routes through handleURL, which switches selectedTab and would strand the user on a
    // different tab once the presented sheet is dismissed.
    if let infoIndex = Info.headingToIndex(heading: cleansedUrlString) {
      let infoDeepLinkUrlString = URL.conjuguerUrlPrefix + "\(URL.infoHost)/\(infoIndex)"
      URL(string: infoDeepLinkUrlString).map {
        Current.handleInAppURL($0)
      }
      return false
    } else if Verb.verbs[cleansedUrlString] != nil {
      let verbDeepLinkUrlString = URL.conjuguerUrlPrefix + "\(URL.verbHost)/\(parenlessString(firstLetterLowercasedString(url.absoluteString)))"
      URL(string: verbDeepLinkUrlString).map {
        Current.handleInAppURL($0)
      }
      return false
    } else {
      return true
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
