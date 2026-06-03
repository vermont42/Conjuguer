//
//  ModelView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/22/21.
//

import SwiftUI

struct ModelView: View {
  @Environment(World.self) private var world
  @State private var detailSheet: DetailSheet?
  let model: VerbModel

  init(model: VerbModel) {
    self.model = model
  }

  var body: some View {
    ScrollView {
      HStack {
        VStack(alignment: .leading, spacing: 0) {
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
            Text(L.ModelView.defective)
              .subheadingLabel()
              .padding(.top, Layout.doubleDefaultSpacing)
            Text(defectGroup.description())
              .bodyLabel()
          }

          Text(L.ModelView.endings)
            .subheadingLabel()
            .padding(.top, Layout.doubleDefaultSpacing)

          endingRow("\(Tense.participePassé.shortTitleCaseName): ", model.participeEndingRecursive)

          endingRow("\(Tense.indicatifPrésent(.firstSingular).shortTitleCaseName): ", model.indicatifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterations))

          endingRow("\(Tense.impératif(.firstPlural).shortTitleCaseName): ", model.indicatifPrésentGroupRecursive.impératifEndings(stemAlterations: model.stemAlterations))

          endingRow("\(Tense.passéSimple(.firstSingular).shortTitleCaseName): ", model.passéSimpleGroupRecursive.endings)

          endingRow("\(Tense.subjonctifPrésent(.firstSingular).shortTitleCaseName): ", model.subjonctifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterations))

          endingRow("\(Tense.subjonctifImparfait(.firstSingular).shortTitleCaseName): ", model.passéSimpleGroupRecursive.subjonctifImparfaitEndings)
            .padding(.bottom, Layout.doubleDefaultSpacing)

          if let stemAlterations = model.stemAlterationsRecursive {
            HStack {
              Text(L.ModelView.stemAlterations)
                .subheadingLabel()

              Spacer()

              Button {
                detailSheet = .stemAlterationsInfo
              } label: {
                  Image(systemName: "questionmark.diamond.fill")
              }
              .buttonStyle(.borderless)
              .tint(.customRed)
              .accessibilityLabel(Text(L.Navigation.info))
              .accessibilityHint(Text(L.ModelView.infoButtonHint))
            }

            ForEach(stemAlterations, id: \.self) { alteration in
              let appliesToString = Tense.shorthandForNonCompoundTense(appliesTo: alteration.appliesTo)
              endingRow(appliesToString + ": ", alteration.toString)
            }
          }

          if model.verbs.count > 1 {
            Text(L.ModelView.verbsUsing)
              .subheadingLabel()
              .padding(.top, Layout.doubleDefaultSpacing)
          } else {
            Text(L.ModelView.verbUsing)
              .subheadingLabel()
              .padding(.top, Layout.doubleDefaultSpacing)
          }
          Text(model.verbsWithDeepLinks())
            .font(bodyFont)
            .frenchPronunciation()
        }
      }
      .padding(.leading, Layout.doubleDefaultSpacing)
      .padding(.trailing, Layout.doubleDefaultSpacing)
    }
    .screenBackground()
    .environment(\.openURL, OpenURLAction { url in
      guard
        url.isDeeplink,
        url.hasExpectedNumberOfDeeplinkComponents,
        url.host == URL.verbHost,
        let verb = Verb.verbs[url.pathComponents[1]]
      else {
        return .systemAction
      }
      detailSheet = .verb(verb)
      return .handled
    })
    .sheet(item: $detailSheet) { sheet in
      switch sheet {
      case .verb(let verb):
        VerbView(verb: verb, shouldShowVerbHeading: true)
          .sheetDismissable()
      case .stemAlterationsInfo:
        InfoView(info: Info.infos[Info.headingToIndex(heading: L.Info.irregularitiesHeading) ?? 0], shouldShowInfoHeading: true)
          .sheetDismissable()
      }
    }
    .onAppear {
      world.analytics.recordViewAppeared("\(ModelView.self)")
    }
  }

  private func endingRow(_ label: String, _ mixedCase: String) -> some View {
    var attributed = AttributedString(label)
    attributed += AttributedString(mixedCaseString: mixedCase)
    return Text(attributed)
      .font(bodyFont)
      .frenchPronunciation()
  }

  private enum DetailSheet: Identifiable {
    case verb(Verb)
    case stemAlterationsInfo

    var id: String {
      switch self {
      case .verb(let verb):
        return "verb-\(verb.id)"
      case .stemAlterationsInfo:
        return "stemAlterationsInfo"
      }
    }
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return ModelView(model: PreviewSupport.sampleModel)
    .environment(Current)
}
#endif
