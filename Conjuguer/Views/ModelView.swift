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
        }

        Text(model.description)

        Spacer()
          .frame(height: 16)

        Text("Radical Futur: ") + Text(mixedCaseString: model.futurStemsRecursive(infinitif: model.exemplar)[0])

        Spacer()
          .frame(height: 16)

        Group {
          Text("Endings")

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
          ForEach(stemAlterations, id: \.self) { alteration in
            // TODO: Prefix with (for example) "r1s: ". Use Tense.shorthandForNonCompoundTense(appliesTo:) to build the prefix label.
            // Add an info button describing abbreviations to the right of "Stem Alterations".
            //   static func shorthandForNonCompoundTense(appliesTo: Set<Tense>) -> String {
            let appliesToString = Tense.shorthandForNonCompoundTense(appliesTo: alteration.appliesTo)
            Text(appliesToString + ": ") + Text(mixedCaseString: alteration.toString)
          }
        }

        Spacer()
      }
    }
    .navigationTitle(model.exemplar + " (\(model.id))")
  }
}
