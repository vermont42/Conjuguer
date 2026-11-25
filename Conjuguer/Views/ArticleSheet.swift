//
//  ArticleSheet.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/25/26.
//

import SwiftUI

/// An Info article in a sheet with a stack of its own, opened by a link, a model page, or a
/// tense's heading. Its links to articles and verbs push inside the sheet, and so do the tense
/// articles of a verb page there, so the learner can follow the thread and close the sheet onto
/// whatever lay beneath.
struct ArticleSheet: View {
  let info: Info

  var body: some View {
    InfoView(info: info)
      .sheetDismissable(pushesTenseArticles: true)
  }
}
