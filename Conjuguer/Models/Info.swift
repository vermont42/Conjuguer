//
//  Info.swift
//  Conjuguer
//
//  Created by Joshua Adams on 8/5/21.
//

import Foundation

struct Info: Hashable {
  let heading: String
  let attributedText: NSAttributedString

  private init(heading: String, text: String) {
//    guard let encodedHeading = heading.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
//      fatalError("Could not URL encode heading \(heading).")
//    }
//
//    self.heading = encodedHeading
    self.heading = heading
    attributedText = text.attributedText
  }

  static let infos: [Info] = [
    Info(heading: L.Info.purposeAndUseHeading, text: L.Info.purposeAndUseText),
    Info(heading: L.Info.terminologyHeading, text: L.Info.terminologyText),
    Info(heading: L.Info.defectivenessHeading, text: L.Info.defectivenessText),
    Info(heading: L.Info.creditsHeading, text: L.Info.creditsText)
  ]
}
