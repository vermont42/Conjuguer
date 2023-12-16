//
//  ModelView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/22/21.
//

import SwiftUI

struct ModelView: View {
  @State private var isPresentingVerb = false
  @State private var isPresentingStemAlterationsInfo = false
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
            HStack {
              Text(model.exemplarWithPossibleExtraLetters)
                .headingLabel()
                .frenchPronunciation()

              Text(" (\(model.id))")
                .headingLabel()

              Spacer()
            }

            if
              let parentId = model.parentId,
              let parent = VerbModel.models[parentId]
            {
              HStack {
                Text("\(L.ModelView.parent): ")
                  .headingLabel()

                Text(parent.exemplarWithPossibleExtraLetters)
                  .headingLabel()
                  .frenchPronunciation()

                Text(" (\(parent.id))")
                  .headingLabel()

                Spacer()
              }
            }

            Text(model.description)
              .headingLabel()

            if
              let defectGroupId = model.defectGroupId,
              let defectGroup = DefectGroup.defectGroups[defectGroupId]
            {
              Spacer()
                .frame(height: Layout.doubleDefaultSpacing)
              Text(L.ModelView.defective)
                .subheadingLabel()
              Text(defectGroup.description())
                .bodyLabel()
            }

            Spacer()
              .frame(height: Layout.doubleDefaultSpacing)

            Text(L.ModelView.endings)
              .subheadingLabel()

            (Text("\(Tense.participePassé.shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.participeEndingRecursive).font(bodyFont))
              .frenchPronunciation()

            (Text("\(Tense.indicatifPrésent(.firstSingular).shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.indicatifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterations)).font(bodyFont))
              .frenchPronunciation()

            (Text("\(Tense.impératif(.firstPlural).shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.indicatifPrésentGroupRecursive.impératifEndings(stemAlterations: model.stemAlterations)).font(bodyFont))
              .frenchPronunciation()

            (Text("\(Tense.passéSimple(.firstSingular).shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.passéSimpleGroupRecursive.endings).font(bodyFont))
              .frenchPronunciation()

            (Text("\(Tense.subjonctifPrésent(.firstSingular).shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.subjonctifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterations)).font(bodyFont))
              .frenchPronunciation()

            (Text("\(Tense.subjonctifImparfait(.firstSingular).shortTitleCaseName): ").font(bodyFont) + Text(mixedCaseString: model.passéSimpleGroupRecursive.subjonctifImparfaitEndings).font(bodyFont))
              .frenchPronunciation()

            Spacer()
              .frame(height: Layout.doubleDefaultSpacing)

            if let stemAlterations = model.stemAlterationsRecursive {
              HStack {
                Text(L.ModelView.stemAlterations)
                  .subheadingLabel()

                Spacer()

                Button {
                  isPresentingStemAlterationsInfo = true
                } label: {
                    Image(systemName: "questionmark.diamond.fill")
                }
                .buttonStyle(.borderless)
                .tint(.customRed)
                .accessibility(label: Text(L.Navigation.info))
                .accessibility(hint: Text(L.ModelView.infoButtonHint))
              }

              ForEach(stemAlterations, id: \.self) { alteration in
                let appliesToString = Tense.shorthandForNonCompoundTense(appliesTo: alteration.appliesTo)
                (Text(appliesToString + ": ").font(bodyFont) + Text(mixedCaseString: alteration.toString).font(bodyFont))
                  .frenchPronunciation()
              }
            }

            Spacer()
              .frame(height: Layout.doubleDefaultSpacing)

            if model.verbs.count > 1 {
              Text(L.ModelView.verbsUsing)
                .subheadingLabel()
            } else {
              Text(L.ModelView.verbUsing)
                .subheadingLabel()
            }
            Text(model.verbsWithDeepLinks())
              .font(bodyFont)
              .frenchPronunciation()
          }
        }
      }
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
    .sheet(
      isPresented: $isPresentingStemAlterationsInfo,
      onDismiss: {
        isPresentingStemAlterationsInfo = false
      },
      content: {
        InfoView(info: Info.infos[Info.headingToIndex(heading: L.Info.irregularitiesHeading) ?? 0], shouldShowInfoHeading: true)
      }
    )
    .onAppear {
      Current.analytics.recordViewAppeared("\(ModelView.self)")
    }
  }
}
