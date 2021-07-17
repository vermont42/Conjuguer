//
//  ModelView.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/22/21.
//

import SwiftUI

struct ModelView: View {
  let model: VerbModel

  init(model: VerbModel) {
    self.model = model
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        if
          let parentId = model.parentId,
          let parent = VerbModel.models[parentId]
        {
          Text("Parent: \(parent.exemplarWithPossibleExtraLetters) (\(parent.id))")
            .headingLabel()
        }

        Text(model.description)
          .headingLabel()

        if
          let defectGroupId = model.defectGroupId,
          let defectGroup = DefectGroup.defectGroups[defectGroupId]
        {
          Group {
            Spacer()
              .frame(height: 16)
            Text("Defective")
              .subheadingLabel()
            Text(defectGroup.description())
              .bodyLabel()
          }
        }

        Spacer()
          .frame(height: 16)

        Group {
          Text("Endings")
            .subheadingLabel()

          Text("Participe Passé: ").font(bodyFont) + Text(mixedCaseString: model.participeEndingRecursive).font(bodyFont)

          Text("Ind. Présent: ").font(bodyFont) + Text(mixedCaseString: model.indicatifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterations)).font(bodyFont)

          Text("Impératif: ").font(bodyFont) + Text(mixedCaseString: model.indicatifPrésentGroupRecursive.impératifEndings(stemAlterations: model.stemAlterations)).font(bodyFont)

          Text("Passé Simple: ").font(bodyFont) + Text(mixedCaseString: model.passéSimpleGroupRecursive.endings).font(bodyFont)

          Text("Subj. Présent: ").font(bodyFont) + Text(mixedCaseString: model.subjonctifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterations)).font(bodyFont)

          Text("Subj. Imp.: ").font(bodyFont) + Text(mixedCaseString: model.passéSimpleGroupRecursive.subjonctifImparfaitEndings).font(bodyFont)
        }

        Spacer()
          .frame(height: 16)

        if let stemAlterations = model.stemAlterationsRecursive {
          Text("Stem Alterations")
            .subheadingLabel()
          ForEach(stemAlterations, id: \.self) { alteration in
            // TODO: Add an info button describing abbreviations to the right of "Stem Alterations".
            let appliesToString = Tense.shorthandForNonCompoundTense(appliesTo: alteration.appliesTo)
            Text(appliesToString + ": ").font(bodyFont) + Text(mixedCaseString: alteration.toString).font(bodyFont)
          }
        }

        Spacer()
      }
    }
    .navigationTitle(model.exemplarWithPossibleExtraLetters + " (\(model.id))")
    .customNavigationBarItems()
    .padding()
  }
}
