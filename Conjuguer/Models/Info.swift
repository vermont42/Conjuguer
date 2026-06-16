//
//  Info.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/5/21.
//

import Foundation

struct Info: Identifiable, Hashable {
  let heading: String
  let richTextBlocks: [RichTextBlock]
  let alwaysUsesFrenchPronunciation: Bool
  let imageInfo: ImageInfo?
  let category: InfoCategory

  var id: String { heading }

  private init(heading: String, text: String, category: InfoCategory, alwaysUsesFrenchPronunciation: Bool = false, imageInfo: ImageInfo? = nil) {
    self.heading = heading
    richTextBlocks = text.richTextBlocks
    self.category = category
    self.alwaysUsesFrenchPronunciation = alwaysUsesFrenchPronunciation
    self.imageInfo = imageInfo
  }

  static let infos: [Info] = [
    Info(heading: L.Info.dedicationHeading, text: L.Info.dedicationText, category: .about, imageInfo: ImageInfo(filename: "Compton", accessibilityLabel: L.ImageInfo.davidCompton)),
    Info(heading: L.Info.valuePropositionHeading, text: L.Info.valuePropositionText, category: .about),
    Info(heading: L.Info.terminologyHeading, text: L.Info.terminologyText, category: .concepts),
    Info(heading: L.Info.irregularitiesHeading, text: L.Info.irregularitiesText, category: .concepts),
    Info(heading: L.Info.defectivenessHeading, text: L.Info.defectivenessText, category: .concepts),
    Info(heading: L.Info.participePasséHeading, text: L.Info.participePasséText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.participePrésentHeading, text: L.Info.participePrésentText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.radicalFuturHeading, text: L.Info.radicalFuturText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.indicatifPrésentHeading, text: L.Info.indicatifPrésentText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.passéSimpleHeading, text: L.Info.passéSimpleText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.imparfaitHeading, text: L.Info.imparfaitText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.futurSimpleHeading, text: L.Info.futurSimpleText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.conditionnelPrésentHeading, text: L.Info.conditionnelPrésentText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.subjonctifPrésentHeading, text: L.Info.subjonctifPrésentText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.subjonctifImparfaitHeading, text: L.Info.subjonctifImparfaitText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.impératifHeading, text: L.Info.impératifText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.passéComposéHeading, text: L.Info.passéComposéText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.plusQueParfaitHeading, text: L.Info.plusQueParfaitText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.passéAntérieurHeading, text: L.Info.passéAntérieurText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.passéSurcomposéHeading, text: L.Info.passéSurcomposéText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.futurAntérieurHeading, text: L.Info.futurAntérieurText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.conditionnelPasséHeading, text: L.Info.conditionnelPasséText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.subjonctifPasséHeading, text: L.Info.subjonctifPasséText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.subjonctifPlusQueParfaitHeading, text: L.Info.subjonctifPlusQueParfaitText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.impératifPasséHeading, text: L.Info.impératifPasséText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(heading: L.Info.questionsAndResponsesHeading, text: L.Info.questionsAndResponsesText, category: .about),
    Info(heading: L.Info.creditsHeading, text: L.Info.creditsText, category: .about, imageInfo: ImageInfo(filename: "Adams", accessibilityLabel: L.ImageInfo.joshAdams))
  ]

  static var sections: [(category: InfoCategory, infos: [Info])] {
    InfoCategory.allCases.compactMap { category in
      let matching = infos.filter { $0.category == category }
      return matching.isEmpty ? nil : (category, matching)
    }
  }

  static func headingToIndex(heading: String) -> Int? {
    infos.firstIndex { $0.heading.lowercased() == heading.lowercased() }
  }
}

enum InfoCategory: CaseIterable {
  case about
  case concepts
  case tenses

  var title: String {
    switch self {
    case .about:
      return L.InfoBrowseView.sectionAbout
    case .concepts:
      return L.InfoBrowseView.sectionConcepts
    case .tenses:
      return L.InfoBrowseView.sectionTenses
    }
  }
}
