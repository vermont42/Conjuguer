//
//  ModelView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/22/21.
//

import SwiftUI

struct ModelView: View {
  @State private var isPresentingVerb = false
  let model: VerbModel

  init(model: VerbModel) {
    self.model = model
  }

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      ScrollView {
        HStack {
          VStack(alignment: .leading) {
            if
              let parentId = model.parentId,
              let parent = VerbModel.models[parentId]
            {
              Text("\(L.ModelView.parent): \(parent.exemplarWithPossibleExtraLetters) (\(parent.id))")
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
                Text(L.ModelView.defective)
                  .subheadingLabel()
                Text(defectGroup.description())
                  .bodyLabel()
              }
            }

            Spacer()
              .frame(height: 16)

            Group {
              Text(L.ModelView.endings)
                .subheadingLabel()

              Text("\(Tense.participePassé.shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.participeEndingRecursive).font(bodyFont)
              Text("\(Tense.indicatifPrésent(.firstSingular).shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.indicatifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterations)).font(bodyFont)
              Text("\(Tense.impératif(.firstPlural).shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.indicatifPrésentGroupRecursive.impératifEndings(stemAlterations: model.stemAlterations)).font(bodyFont)
              Text("\(Tense.passéSimple(.firstSingular).shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.passéSimpleGroupRecursive.endings).font(bodyFont)
              Text("\(Tense.subjonctifPrésent(.firstSingular).shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.subjonctifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterations)).font(bodyFont)
              Text("\(Tense.subjonctifImparfait(.firstSingular).shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.passéSimpleGroupRecursive.subjonctifImparfaitEndings).font(bodyFont)
            }

            Spacer()
              .frame(height: 16)

            if let stemAlterations = model.stemAlterationsRecursive {
              Text(L.ModelView.stemAlterations)
                .subheadingLabel()
              ForEach(stemAlterations, id: \.self) { alteration in
                // TODO: Add an info button describing abbreviations to the right of "Stem Alterations".
                let appliesToString = Tense.shorthandForNonCompoundTense(appliesTo: alteration.appliesTo)
                Text(appliesToString + ": ").font(bodyFont) + Text(mixedCaseString: alteration.toString).font(bodyFont)
              }
            }

            Spacer()
              .frame(height: 16)

            Group {
              if model.verbs.count > 1 {
                Text(L.ModelView.verbsUsing)
                  .subheadingLabel()
              } else {
                Text(L.ModelView.verbUsing)
                  .subheadingLabel()
              }
              Text(model.verbsWithDeepLinks()).font(bodyFont)
            }
          }
        }
      }
        .navigationTitle(model.exemplarWithPossibleExtraLetters + " (\(model.id))")
        .customNavigationBarItems()
    }
    .onReceive(Current.$verb) { value in
      if value == nil {
        isPresentingVerb = false
      } else {
        isPresentingVerb = true
      }
    }
    .sheet(
      isPresented: $isPresentingVerb,
      onDismiss: {
        Current.verb = nil
        isPresentingVerb = false
      },
      content: {
        Current.verb.map {
          VerbView(verb: $0, shouldShowVerbHeading: true)
        }
      }
    )
  }
}
