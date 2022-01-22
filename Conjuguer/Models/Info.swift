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
  let alwaysUsesFrenchPronunciation: Bool
  let imageInfo: ImageInfo?

  private init(heading: String, text: String, alwaysUsesFrenchPronunciation: Bool = false, imageInfo: ImageInfo? = nil) {
    self.heading = heading
    attributedText = text.attributedText
    self.alwaysUsesFrenchPronunciation = alwaysUsesFrenchPronunciation
    self.imageInfo = imageInfo
  }

  static let infos: [Info] = [
    Info(heading: L.Info.dedicationHeading, text: L.Info.dedicationText, imageInfo: ImageInfo(filename: "Compton", accessibilityLabel: L.ImageInfo.davidCompton)),
    Info(heading: L.Info.valuePropositionHeading, text: L.Info.valuePropositionText),
    Info(heading: L.Info.terminologyHeading, text: L.Info.terminologyText),
    Info(heading: L.Info.irregularitiesHeading, text: L.Info.irregularitiesText),
    Info(heading: L.Info.defectivenessHeading, text: L.Info.defectivenessText),
    Info(heading: L.Info.participePasséHeading, text: L.Info.participePasséText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.participePrésentHeading, text: L.Info.participePrésentText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.radicalFuturHeading, text: L.Info.radicalFuturText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.indicatifPrésentHeading, text: L.Info.indicatifPrésentText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.passéSimpleHeading, text: L.Info.passéSimpleText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.imparfaitHeading, text: L.Info.imparfaitText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.futurSimpleHeading, text: L.Info.futurSimpleText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.conditionnelPrésentHeading, text: L.Info.conditionnelPrésentText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.subjonctifPrésentHeading, text: L.Info.subjonctifPrésentText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.subjonctifImparfaitHeading, text: L.Info.subjonctifImparfaitText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.impératifHeading, text: L.Info.impératifText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.passéComposéHeading, text: L.Info.passéComposéText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.plusQueParfaitHeading, text: L.Info.plusQueParfaitText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.passéAntérieurHeading, text: L.Info.passéAntérieurText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.passéSurcomposéHeading, text: L.Info.passéSurcomposéText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.futurAntérieurHeading, text: L.Info.futurAntérieurText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.conditionnelPasséHeading, text: L.Info.conditionnelPasséText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.subjonctifPasséHeading, text: L.Info.subjonctifPasséText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.subjonctifPlusQueParfaitHeading, text: L.Info.subjonctifPlusQueParfaitText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.impératifPasséHeading, text: L.Info.impératifPasséText, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.questionsAndResponsesHeading, text: L.Info.questionsAndResponsesText),
    Info(heading: L.Info.creditsHeading, text: L.Info.creditsText, imageInfo: ImageInfo(filename: "Adams", accessibilityLabel: L.ImageInfo.joshAdams))
  ]

  static func headingToIndex(heading: String) -> Int? {
    for (i, info) in infos.enumerated() {
      if info.heading.lowercased() == heading.lowercased() {
        return i
      }
    }

    return nil
  }
}
