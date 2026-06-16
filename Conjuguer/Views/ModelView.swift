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

  private static let gridPronouns = ["je", "tu", "il", "nous", "vous", "ils"]
  private static let gridOrder: [PersonNumber] = [.firstSingular, .secondSingular, .thirdSingular, .firstPlural, .secondPlural, .thirdPlural]

  init(model: VerbModel) {
    self.model = model
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        headerCard
          .scrollFade()

        if
          let defectGroupId = model.defectGroupId,
          let defectGroup = DefectGroup.defectGroups[defectGroupId]
        {
          defectiveCard(defectGroup)
            .scrollFade()
        }

        endingsCard
          .scrollFade()

        if let stemAlterations = model.stemAlterationsRecursive {
          stemAlterationsCard(stemAlterations)
            .scrollFade()
        }

        verbsUsingCard
          .scrollFade()
      }
      .padding(.horizontal, Layout.doubleDefaultSpacing)
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
        VerbView(verb: verb)
          .sheetDismissable()
      case .stemAlterationsInfo:
        InfoView(info: Info.infos[Info.headingToIndex(heading: L.Info.irregularitiesHeading) ?? 0], shouldShowInfoHeading: true)
          .sheetDismissable()
      }
    }
    .recordsAppearance(as: "\(ModelView.self)")
  }

  private var headerCard: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack(alignment: .firstTextBaseline) {
        Text(model.exemplarWithPossibleExtraLetters)
          .headingLabel()
          .frenchPronunciation()

        Text("(\(model.id))")
          .headingLabel()

        Spacer()
      }

      Text(model.description)
        .bodyLabel()

      if
        let parentId = model.parentId,
        let parent = VerbModel.models[parentId]
      {
        HStack(spacing: 0) {
          Text("\(L.ModelView.parent): ")
            .smallLabel()
          Text(parent.exemplarWithPossibleExtraLetters)
            .smallLabel()
            .frenchPronunciation()
          Text(" (\(parent.id))")
            .smallLabel()
          Spacer()
        }
      }
    }
    .card()
  }

  private func defectiveCard(_ defectGroup: DefectGroup) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.ModelView.defective)
        .subheadingLabel()
      Text(defectGroup.description())
        .bodyLabel()
    }
    .card()
  }

  private var endingsCard: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.ModelView.endings)
        .subheadingLabel()

      endingRow("\(Tense.participePassé.shortTitleCaseName): ", model.participeEndingRecursive)

      ScrollView(.horizontal, showsIndicators: false) {
        Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
          GridRow(alignment: .firstTextBaseline) {
            ForEach(Self.gridPronouns, id: \.self) { pronoun in
              Text(pronoun)
                .font(gridPronounFont)
                .foregroundStyle(Color.customGray)
                .frenchPronunciation()
                .gridColumnAlignment(.leading)
            }
          }

          ForEach(endingTenses) { tense in
            GridRow {
              Text(tense.label)
                .font(gridTenseLabelFont)
                .foregroundStyle(Color.customGray)
                .gridCellColumns(Self.gridPronouns.count)
            }

            GridRow(alignment: .firstTextBaseline) {
              ForEach(Array(tense.slots.enumerated()), id: \.offset) { _, slot in
                Text(slot ?? AttributedString(" "))
                  .font(gridEndingFont)
                  .frenchPronunciation()
                  .gridColumnAlignment(.leading)
              }
            }
          }
        }
      }
    }
    .card()
  }

  private var endingTenses: [EndingTense] {
    let specs: [(String, [PersonNumber: String])] = [
      (Tense.indicatifPrésent(.firstSingular).shortTitleCaseName, model.indicatifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterationsRecursive)),
      (Tense.impératif(.firstPlural).shortTitleCaseName, model.indicatifPrésentGroupRecursive.impératifEndings(stemAlterations: model.stemAlterationsRecursive)),
      (Tense.passéSimple(.firstSingular).shortTitleCaseName, model.passéSimpleGroupRecursive.endings),
      (Tense.subjonctifPrésent(.firstSingular).shortTitleCaseName, model.subjonctifPrésentGroupRecursive.endings(stemAlterations: model.stemAlterationsRecursive)),
      (Tense.subjonctifImparfait(.firstSingular).shortTitleCaseName, model.passéSimpleGroupRecursive.subjonctifImparfaitEndings)
    ]
    return specs.enumerated().map { index, spec in
      EndingTense(id: index, label: spec.0, slots: endingSlots(spec.1))
    }
  }

  private struct EndingTense: Identifiable {
    let id: Int
    let label: String
    let slots: [AttributedString?]
  }

  private func stemAlterationsCard(_ stemAlterations: [StemAlteration]) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack(spacing: 6) {
        Text(L.ModelView.stemAlterations)
          .subheadingLabel()

        Button {
          detailSheet = .stemAlterationsInfo
        } label: {
          Image(systemName: "questionmark.diamond.fill")
        }
        .buttonStyle(.borderless)
        .tint(.customRed)
        .accessibilityLabel(Text(L.Navigation.info))
        .accessibilityHint(Text(L.ModelView.infoButtonHint))

        Spacer()
      }

      ForEach(stemAlterations, id: \.self) { alteration in
        let appliesToString = Tense.shorthandForNonCompoundTense(appliesTo: alteration.appliesTo)
        endingRow(appliesToString + ": ", alteration.toString)
      }
    }
    .card()
  }

  private var verbsUsingCard: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(model.verbs.count > 1 ? L.ModelView.verbsUsing : L.ModelView.verbUsing)
        .subheadingLabel()
      Text(model.verbsWithDeepLinks())
        .font(bodyFont)
        .frenchPronunciation()
    }
    .card()
  }

  private func endingSlots(_ endings: [PersonNumber: String]) -> [AttributedString?] {
    Self.gridOrder.map { personNumber in
      endings[personNumber].map { ending in
        AttributedString(mixedCaseString: ending.isEmpty ? "_" : ending)
      }
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

struct IrregularityBadge: View {
  let percent: Int

  private var tint: Color {
    percent == 0 ? .customBlue : .customRed
  }

  var body: some View {
    Text("\(percent)%")
      .font(irregularityBadgeFont)
      .foregroundStyle(tint)
      .padding(.horizontal, 10)
      .padding(.vertical, 3)
      .background(Capsule().fill(tint.opacity(0.15)))
      .accessibilityLabel(Text("\(percent)% \(L.ModelView.irregular)"))
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return ModelView(model: PreviewSupport.sampleModel)
    .environment(Current)
}
#endif
