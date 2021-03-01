//
//  VerbView.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/28/21.
//

import SwiftUI

struct VerbView: View {
  let verb: Verb

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text("Overview")
        .modifier(SubheadingLabel())
        .leftAligned()

        Text(verb.translation)

        if let model = VerbModel.models[verb.model] {
          Text(model.exemplar + " (" + model.id + ")")
        }

        Text((verb.isReflexive ? "Reflexive" : "Not Reflexive") + ", " + (verb.isDefective ? "Defective" : "Not Defective"))

        if verb.auxiliary == .être {
          Text("Auxiliary: être")
        } else {
          Text("Auxiliary: avoir")
        }
      }
    }
      .navigationTitle(verb.infinitif)
  }
}
