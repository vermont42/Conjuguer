//
//  Info.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/5/21.
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
    Info(heading: L.Info.participePasséHeading, text: L.Info.participePasséText),
    Info(heading: L.Info.participePrésentHeading, text: L.Info.participePrésentText),
    Info(heading: L.Info.radicalFuturHeading, text: L.Info.radicalFuturText),
    Info(heading: L.Info.indicatifPrésentHeading, text: L.Info.indicatifPrésentText),
    Info(heading: L.Info.passéSimpleHeading, text: L.Info.passéSimpleText),
    Info(heading: L.Info.imparfaitHeading, text: L.Info.imparfaitText),
    Info(heading: L.Info.futurSimpleHeading, text: L.Info.futurSimpleText),
    Info(heading: L.Info.conditionnelPrésentHeading, text: L.Info.conditionnelPrésentText),
    Info(heading: L.Info.subjonctifPrésentHeading, text: L.Info.subjonctifPrésentText),
    Info(heading: L.Info.subjonctifImparfaitHeading, text: L.Info.subjonctifImparfaitText),
    Info(heading: L.Info.impératifHeading, text: L.Info.impératifText),
    Info(heading: L.Info.passéComposéHeading, text: L.Info.passéComposéText),
    Info(heading: L.Info.plusQueParfaitHeading, text: L.Info.plusQueParfaitText),
    Info(heading: L.Info.passéAntérieurHeading, text: L.Info.passéAntérieurText),
    Info(heading: L.Info.passéSurcomposéHeading, text: L.Info.passéSurcomposéText),
    Info(heading: L.Info.futurAntérieurHeading, text: L.Info.futurAntérieurText),
    Info(heading: L.Info.conditionnelPasséHeading, text: L.Info.conditionnelPasséText),
    Info(heading: L.Info.subjonctifPasséHeading, text: L.Info.subjonctifPasséText),
    Info(heading: L.Info.subjonctifPlusQueParfaitHeading, text: L.Info.subjonctifPlusQueParfaitText),
    Info(heading: L.Info.impératifPasséHeading, text: L.Info.impératifPasséText),
    Info(heading: L.Info.questionsAndResponsesHeading, text: L.Info.questionsAndResponsesText),
    Info(heading: L.Info.creditsHeading, text: L.Info.creditsText)
  ]
}
