//
//  Info.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/5/21.
//

import Foundation

struct Info: Identifiable, Hashable {
  // Stable, locale-independent key used to build the `info_row_<stableKey>`
  // accessibility identifier in InfoBrowseView. Unlike `heading` (localized),
  // this never changes between English and French, so the screenshot driver can
  // address rows by it. See docs/screenshot-playbook.md.
  let stableKey: String
  let heading: String
  let richTextBlocks: [RichTextBlock]
  let alwaysUsesFrenchPronunciation: Bool
  let imageInfo: ImageInfo?
  let category: InfoCategory

  var id: String { heading }

  private init(stableKey: String, heading: String, text: String, category: InfoCategory, alwaysUsesFrenchPronunciation: Bool = false, imageInfo: ImageInfo? = nil) {
    self.stableKey = stableKey
    self.heading = heading
    richTextBlocks = text.richTextBlocks
    self.category = category
    self.alwaysUsesFrenchPronunciation = alwaysUsesFrenchPronunciation
    self.imageInfo = imageInfo
  }

  static let infos: [Info] = [
    Info(stableKey: "dedication", heading: L.Info.dedicationHeading, text: L.Info.dedicationText, category: .about, imageInfo: ImageInfo(filename: "Compton", accessibilityLabel: L.ImageInfo.davidCompton)),
    Info(stableKey: "value_proposition", heading: L.Info.valuePropositionHeading, text: L.Info.valuePropositionText, category: .about),
    Info(stableKey: "verb_history", heading: L.Info.verbHistoryHeading, text: L.Info.verbHistoryText, category: .concepts),
    Info(stableKey: "terminology", heading: L.Info.terminologyHeading, text: L.Info.terminologyText, category: .concepts),
    Info(stableKey: "irregularities", heading: L.Info.irregularitiesHeading, text: L.Info.irregularitiesText, category: .concepts),
    Info(stableKey: "defectiveness", heading: L.Info.defectivenessHeading, text: L.Info.defectivenessText, category: .concepts),
    Info(stableKey: "participe_passe", heading: L.Info.participePasséHeading, text: L.Info.participePasséText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "participe_present", heading: L.Info.participePrésentHeading, text: L.Info.participePrésentText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "radical_futur", heading: L.Info.radicalFuturHeading, text: L.Info.radicalFuturText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "indicatif_present", heading: L.Info.indicatifPrésentHeading, text: L.Info.indicatifPrésentText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "passe_simple", heading: L.Info.passéSimpleHeading, text: L.Info.passéSimpleText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "imparfait", heading: L.Info.imparfaitHeading, text: L.Info.imparfaitText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "futur_simple", heading: L.Info.futurSimpleHeading, text: L.Info.futurSimpleText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "conditionnel_present", heading: L.Info.conditionnelPrésentHeading, text: L.Info.conditionnelPrésentText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "subjonctif_present", heading: L.Info.subjonctifPrésentHeading, text: L.Info.subjonctifPrésentText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "subjonctif_imparfait", heading: L.Info.subjonctifImparfaitHeading, text: L.Info.subjonctifImparfaitText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "imperatif", heading: L.Info.impératifHeading, text: L.Info.impératifText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "passe_compose", heading: L.Info.passéComposéHeading, text: L.Info.passéComposéText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "plus_que_parfait", heading: L.Info.plusQueParfaitHeading, text: L.Info.plusQueParfaitText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "passe_anterieur", heading: L.Info.passéAntérieurHeading, text: L.Info.passéAntérieurText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "passe_surcompose", heading: L.Info.passéSurcomposéHeading, text: L.Info.passéSurcomposéText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "futur_anterieur", heading: L.Info.futurAntérieurHeading, text: L.Info.futurAntérieurText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "conditionnel_passe", heading: L.Info.conditionnelPasséHeading, text: L.Info.conditionnelPasséText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "subjonctif_passe", heading: L.Info.subjonctifPasséHeading, text: L.Info.subjonctifPasséText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "subjonctif_plus_que_parfait", heading: L.Info.subjonctifPlusQueParfaitHeading, text: L.Info.subjonctifPlusQueParfaitText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "imperatif_passe", heading: L.Info.impératifPasséHeading, text: L.Info.impératifPasséText, category: .tenses, alwaysUsesFrenchPronunciation: true),
    Info(stableKey: "questions_and_responses", heading: L.Info.questionsAndResponsesHeading, text: L.Info.questionsAndResponsesText, category: .about),
    Info(stableKey: "game_instructions", heading: L.Info.gameInstructionsHeading, text: L.Info.gameInstructionsText, category: .about),
    Info(stableKey: "credits", heading: L.Info.creditsHeading, text: L.Info.creditsText, category: .about, imageInfo: ImageInfo(filename: "Adams", accessibilityLabel: L.ImageInfo.joshAdams))
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
