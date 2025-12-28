//
//  VerbView.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/28/21.
//

import SwiftUI

struct VerbView: View {
  let verb: Verb
  let shouldShowVerbHeading: Bool
  @State var shouldShowCompoundTenses = false

  init(verb: Verb, shouldShowVerbHeading: Bool = false) {
    self.verb = verb
    self.shouldShowVerbHeading = shouldShowVerbHeading
  }

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading) {
          Text(verb.infinitifWithPossibleExtraLetters)
            .headingLabel()
            .frenchPronunciation()
          Spacer()

          Text(L.VerbView.overview)
            .subheadingLabel()
            .leftAligned()

          Text(verb.translation)
            .bodyLabel()
            .englishPronunciation()

          if let model = VerbModel.models[verb.model] {
            HStack {
              Text(L.VerbView.modelWithColon + " ")
                .bodyLabel()
              Text(model.exemplar + " ")
                .bodyLabel()
                .frenchPronunciation()
              Text("(\(model.id))")
                .bodyLabel()
              Spacer()
            }
          }

          if verb.isReflexive {
            Text(L.VerbView.reflexive)
              .bodyLabel()
          }

          if verb.hasAspiratedH {
            Text(L.VerbView.aspiratedH)
              .bodyLabel()
          }

          HStack {
            Text(L.VerbView.auxiliaryWithColon + " ")
              .bodyLabel()
            Text(verb.auxiliary.verb)
              .bodyLabel()
              .frenchPronunciation()
            Spacer()
          }

          if let frequency = verb.frequency {
            Text("\(L.VerbView.frequencyWithColon) \(frequency) / \(FrequencyParser.maxFrequency)")
              .bodyLabel()
          }

          if
            let defectGroupId = verb.defectGroupId,
            let defectGroup = DefectGroup.defectGroups[defectGroupId]
          {
            Text("\(L.VerbView.defective) " + defectGroup.description())
                .bodyLabel()
          }

          if let example = verb.example {
            Spacer()

            Text(L.VerbView.exampleUse)
              .subheadingLabel()
              .leftAligned()

            Text(example)
              .bodyLabel()
              .frenchPronunciation()

            if let source = verb.source {
              Text(source)
                .smallLabel()
                .rightAligned()
                .frenchPronunciation()
            }
          }

          Spacer()

          Text(L.VerbView.personlessConjugations)
            .subheadingLabel()
            .frenchPronunciation()
            .padding(.bottom, -1.0 * Layout.defaultSpacing)

          ZStack {
            Color.customBackground
              .accessibility(value: Text(verb.personlessConjugations))
              .frenchPronunciation()

            let passéPart = Text(verb: verb, tense: .participePassé).font(bodyFont) + Text(", ").font(bodyFont)
            let présentPart = Text(verb: verb, tense: .participePrésent).font(bodyFont) + Text(", ").font(bodyFont)
            let futurPart = Text(verb: verb, tense: .radicalFutur).font(bodyFont)

            (passéPart + présentPart + futurPart)
              .leftAligned()
              .accessibilityHidden(true)
          }

          TenseSectionView(verb: verb, tenseBuilder: { .indicatifPrésent($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: true)
          TenseSectionView(verb: verb, tenseBuilder: { .passéSimple($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
          TenseSectionView(verb: verb, tenseBuilder: { .imparfait($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
          TenseSectionView(verb: verb, tenseBuilder: { .futurSimple($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
          TenseSectionView(verb: verb, tenseBuilder: { .conditionnelPrésent($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
          TenseSectionView(verb: verb, tenseBuilder: { .subjonctifPrésent($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
          TenseSectionView(verb: verb, tenseBuilder: { .subjonctifImparfait($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
          TenseSectionView(verb: verb, tenseBuilder: { .impératif($0) }, personNumbers: PersonNumber.impératifPersonNumbers, isFirstInGroup: false)

          Spacer()

          Toggle(isOn: $shouldShowCompoundTenses) {
            Text(L.VerbView.showCompoundTenses)
              .subheadingLabel()
          }
          .toggleStyle(SwitchToggleStyle(tint: .customRed))
          .padding(.top, Layout.defaultSpacing)

          if shouldShowCompoundTenses {
            TenseSectionView(verb: verb, tenseBuilder: { .passéComposé($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: true)
            TenseSectionView(verb: verb, tenseBuilder: { .plusQueParfait($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
            TenseSectionView(verb: verb, tenseBuilder: { .passéAntérieur($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
            TenseSectionView(verb: verb, tenseBuilder: { .passéSurcomposé($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
            TenseSectionView(verb: verb, tenseBuilder: { .futurAntérieur($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
            TenseSectionView(verb: verb, tenseBuilder: { .conditionnelPassé($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
            TenseSectionView(verb: verb, tenseBuilder: { .subjonctifPassé($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
            TenseSectionView(verb: verb, tenseBuilder: { .subjonctifPlusQueParfait($0) }, personNumbers: PersonNumber.allCases, isFirstInGroup: false)
            TenseSectionView(verb: verb, tenseBuilder: { .impératifPassé($0) }, personNumbers: PersonNumber.impératifPersonNumbers, isFirstInGroup: false)

            Spacer()
          }
        }
        .onAppear {
          Current.analytics.recordViewAppeared("\(VerbView.self)")
        }
      }
      .customNavigationBarItems()
    }
  }
}

private struct TenseSectionView: View {
  let verb: Verb
  let tenseBuilder: (PersonNumber) -> Tense
  let personNumbers: [PersonNumber]
  let isFirstInGroup: Bool

  var body: some View {
    Spacer()

    Text(tenseBuilder(personNumbers[0]).titleCaseName)
      .subheadingLabel()
      .frenchPronunciation()
      .padding(.bottom, -1.0 * Layout.defaultSpacing)
      .padding(.top, isFirstInGroup ? 0 : Layout.defaultSpacing)

    ForEach(personNumbers, id: \.self) { personNumber in
      ZStack {
        Color.customBackground
          .accessibility(value: Text(verb: verb, tense: tenseBuilder(personNumber), shouldShowIrregularities: false))
          .frenchPronunciation()

        Text(verb: verb, tense: tenseBuilder(personNumber)).font(bodyFont)
          .leftAligned()
          .accessibilityHidden(true)
      }
    }
    .padding(.bottom, -1.0 * Layout.defaultSpacing)
  }
}
