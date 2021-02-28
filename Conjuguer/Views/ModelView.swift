//
//  ModelView.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/22/21.
//

import SwiftUI

struct ModelView: View {
  let model: VerbModel

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        if
          let parentId = model.parentId,
          let parent = VerbModel.models[parentId]
        {
          Text("Parent: \(parent.exemplar) (\(parent.id))")
            .modifier(HeadingLabel())
        }

        Text(model.description)
          .modifier(HeadingLabel())

        Spacer()
          .frame(height: 16)

        Group {
          Text("Endings")
            .modifier(SubheadingLabel())

          Text("Participe Passé: ") + Text(mixedCaseString: model.participeEndingRecursive)

          Text("Ind. Présent: ") + Text(mixedCaseString: model.indicatifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterations))

          Text("Impératif: ") + Text(mixedCaseString: model.indicatifPrésentGroupRecursive.impératifEndings(stemAlterations: model.stemAlterations))

          Text("Passé Simple: ") + Text(mixedCaseString: model.passéSimpleGroupRecursive.endings)

          Text("Subj. Présent: ") + Text(mixedCaseString: model.subjonctifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterations))

          Text("Subj. Imp.: ") + Text(mixedCaseString: model.passéSimpleGroupRecursive.subjonctifImparfaitEndings)
        }

        Spacer()
          .frame(height: 16)

        if let stemAlterations = model.stemAlterationsRecursive {
          Text("Stem Alterations")
            .modifier(SubheadingLabel())
          ForEach(stemAlterations, id: \.self) { alteration in
            // TODO: Add an info button describing abbreviations to the right of "Stem Alterations".
            let appliesToString = Tense.shorthandForNonCompoundTense(appliesTo: alteration.appliesTo)
            Text(appliesToString + ": ") + Text(mixedCaseString: alteration.toString)
          }
        }

        Spacer()
      }
    }
    .navigationTitle(model.exemplar + " (\(model.id))")
    .padding()
  }
}
