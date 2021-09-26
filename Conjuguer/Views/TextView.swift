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
    let v = UITextView()
    v.isEditable = false
    v.contentOffset = .zero
    return v
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.backgroundColor = UIColor(Color.customBackground)
    uiView.attributedText = text
    uiView.contentOffset = .zero
    uiView.delegate = textViewDelegate
  }
}

class TextViewDelegate: NSObject, UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    let cleansedUrlString = url.absoluteString.removingPercentEncoding ?? ""

    if let infoIndex = Info.headingToIndex(heading: cleansedUrlString) {
      let infoDeepLinkUrlString = URL.conjuguerUrlPrefix + "\(URL.infoHost)/\(infoIndex)"
      print(infoDeepLinkUrlString)
      URL(string: infoDeepLinkUrlString).map {
        UIApplication.shared.open($0)
      }
      return false
    } else if Verb.verbs[cleansedUrlString] != nil {
      let verbDeepLinkUrlString = URL.conjuguerUrlPrefix + "\(URL.verbHost)/\(url.absoluteString)"
      print(verbDeepLinkUrlString)
      URL(string: verbDeepLinkUrlString).map {
        UIApplication.shared.open($0)
      }
      return false
    }

    // TODO: If there is an http prefix, just return true. See InfoVC.swift.
    // Otherwise, check the value against verbs, model IDs, and Infos. (Spanish titles are tricky.)
    // Note that Info titles map to Ints.
    // Construct a conjuguer URL, open that, and return false.
    return true
  }
}
