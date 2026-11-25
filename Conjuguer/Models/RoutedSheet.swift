//
//  RoutedSheet.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/25/26.
//

import Foundation

/// What a link shows in the one sheet that `MainTabView` presents. Each value has an identity of
/// its own, so a second link to the page already showing presents that page afresh: it scrolls
/// to the new mark, opens the compound block if the mark needs it, and begins a new visit.
struct RoutedSheet: Identifiable {
  enum Page {
    case verb(VerbDestination)
    case model(VerbModel)
    case collection(VerbCollectionDestination)
    case article(Info)
    case practiceSet(PracticeSetRequest)

    /// The tab beneath the sheet, which the learner finds on closing it. A practice set shows over
    /// whatever tab is open.
    var tab: MainTab? {
      switch self {
      case .verb:
        return .verbs
      case .model, .collection:
        return .models
      case .article:
        return .info
      case .practiceSet:
        return nil
      }
    }
  }

  let id = UUID()
  let page: Page
}
