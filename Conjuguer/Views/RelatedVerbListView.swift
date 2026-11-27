//
//  RelatedVerbListView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

/// Every verb built on one root, which the "All N" chip of a verb page's "Built on" row pushes.
struct RelatedVerbListView: View {
  let root: String
  let verbs: [Verb]

  var body: some View {
    VerbListPage(verbs: verbs, source: .related, identifierPrefix: "related_list")
      .navigationTitle(L.VerbView.builtOn(root))
      .recordsAppearance(as: "\(RelatedVerbListView.self)")
  }
}
