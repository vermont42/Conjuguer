//
//  ModelView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/22/21.
//

import SwiftUI
import TipKit

struct ModelView: View {
  @Environment(\.verbPagePush) private var verbPagePush
  @State private var isShowingIrregularitiesArticle = false
  @State private var verbOrder: VerbSort
  let model: VerbModel

  private static let gridPronouns = ["je", "tu", "il", "nous", "vous", "ils"]
  private static let gridOrder: [PersonNumber] = [.firstSingular, .secondSingular, .thirdSingular, .firstPlural, .secondPlural, .thirdPlural]

  init(model: VerbModel, verbOrder: VerbSort = .alphabetical) {
    self.model = model
    _verbOrder = State(initialValue: verbOrder)
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        headerCard
          .scrollFade()

        if
          let defectGroupId = model.defectGroupId,
          let defectGroup = DefectGroup.defectGroups[defectGroupId] {
          defectiveCard(defectGroup)
            .scrollFade()
        }

        endingsCard
          .scrollFade()

        if let stemAlterations = model.stemAlterationsRecursive {
          stemAlterationsCard(stemAlterations)
            .scrollFade()
        }

        ModelPracticeCard(modelID: model.id)
          .scrollFade()

        verbsUsingCard
          .scrollFade()
      }
      .padding(.horizontal, Layout.doubleDefaultSpacing)
    }
    .screenBackground()
    .onAppear {
      ExploreModelsTip().invalidate(reason: .actionPerformed)
    }
    .environment(\.openURL, OpenURLAction { url in
      guard
        case .verb(.key(let key), _, _) = Deeplink(url: url),
        let verb = Verb.verbs[key]
      else {
        return .systemAction
      }
      verbPagePush(.verb(VerbDestination(verb: verb, source: .modelPage)))
      return .handled
    })
    .sheet(isPresented: $isShowingIrregularitiesArticle) {
      ArticleSheet(info: Info.infos[Info.headingToIndex(heading: L.Info.irregularitiesHeading) ?? 0])
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
        let parent = VerbModel.models[parentId] {
        HStack(spacing: 0) {
          Text(L.ModelView.parentLabel + " ")
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

      endingRow(L.ModelView.participleLabel + " ", model.participeEndingRecursive)

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

        ArticleButton(hint: L.ModelView.infoButtonHint) {
          isShowingIrregularitiesArticle = true
        }

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
      Text(L.ModelView.verbsUsing(count: model.verbs.count))
        .subheadingLabel()

      VerbCollectionBar(collection: .model(model.id))
        .padding(.bottom, Layout.defaultSpacing)

      if model.verbs.count > 1 {
        Picker(L.BrowseView.sortOrder, selection: $verbOrder) {
          ForEach([VerbSort.alphabetical, .frequency], id: \.self) { order in
            Text(order.displayName)
              .tag(order)
          }
        }
        .pickerStyle(.segmented)
        .sensoryFeedback(.selection, trigger: verbOrder)
        .accessibilityIdentifier("model_verb_order")
      }

      Text(model.verbsWithDeepLinks(order: verbOrder))
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
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return PreviewStack {
    ModelView(model: PreviewSupport.sampleModel)
  }
}
#endif
