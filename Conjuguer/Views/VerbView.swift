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
          Group {
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
          }

          Group {
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
          }

          Group {
            if
              let defectGroupId = verb.defectGroupId,
              let defectGroup = DefectGroup.defectGroups[defectGroupId]
            {
              Text("\(L.VerbView.defective) " + defectGroup.description())
                  .bodyLabel()
            }

            if let example = verb.example {
              Group {
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
            }
          }

          Group {
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

            Spacer()

            Group {
              Text(Tense.indicatifPrésent(.firstSingular).titleCaseName)
                .subheadingLabel()
                .frenchPronunciation()
                .padding(.bottom, -1.0 * Layout.defaultSpacing)

              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                ZStack {
                  Color.customBackground
                    .accessibility(value: Text(verb: verb, tense: .indicatifPrésent(personNumber), shouldShowIrregularities: false))
                    .frenchPronunciation()

                  Text(verb: verb, tense: .indicatifPrésent(personNumber)).font(bodyFont)
                    .leftAligned()
                    .accessibilityHidden(true)
                }
              }
                .padding(.bottom, -1.0 * Layout.defaultSpacing)

              Spacer()

              Text(Tense.passéSimple(.firstSingular).titleCaseName)
                .subheadingLabel()
                .frenchPronunciation()
                .padding(.bottom, -1.0 * Layout.defaultSpacing)
                .padding(.top, Layout.defaultSpacing)

              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                ZStack {
                  Color.customBackground
                    .accessibility(value: Text(verb: verb, tense: .passéSimple(personNumber), shouldShowIrregularities: false))
                    .frenchPronunciation()

                  Text(verb: verb, tense: .passéSimple(personNumber)).font(bodyFont)
                    .leftAligned()
                    .accessibilityHidden(true)
                }
              }
                .padding(.bottom, -1.0 * Layout.defaultSpacing)

              Spacer()
            }

            Group {
              Text(Tense.imparfait(.firstSingular).titleCaseName)
                .subheadingLabel()
                .frenchPronunciation()
                .padding(.bottom, -1.0 * Layout.defaultSpacing)
                .padding(.top, Layout.defaultSpacing)

              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                ZStack {
                  Color.customBackground
                    .accessibility(value: Text(verb: verb, tense: .imparfait(personNumber), shouldShowIrregularities: false))
                    .frenchPronunciation()

                  Text(verb: verb, tense: .imparfait(personNumber)).font(bodyFont)
                    .leftAligned()
                    .accessibilityHidden(true)
                }
              }
                .padding(.bottom, -1.0 * Layout.defaultSpacing)

              Spacer()

              Text(Tense.futurSimple(.firstSingular).titleCaseName)
                .subheadingLabel()
                .frenchPronunciation()
                .padding(.bottom, -1.0 * Layout.defaultSpacing)
                .padding(.top, Layout.defaultSpacing)

              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                ZStack {
                  Color.customBackground
                    .accessibility(value: Text(verb: verb, tense: .futurSimple(personNumber), shouldShowIrregularities: false))
                    .frenchPronunciation()

                  Text(verb: verb, tense: .futurSimple(personNumber)).font(bodyFont)
                    .leftAligned()
                    .accessibilityHidden(true)
                }
              }
                .padding(.bottom, -1.0 * Layout.defaultSpacing)

              Spacer()

              Text(Tense.conditionnelPrésent(.firstSingular).titleCaseName)
                .subheadingLabel()
                .frenchPronunciation()
                .padding(.bottom, -1.0 * Layout.defaultSpacing)
                .padding(.top, Layout.defaultSpacing)

              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                ZStack {
                  Color.customBackground
                    .accessibility(value: Text(verb: verb, tense: .conditionnelPrésent(personNumber), shouldShowIrregularities: false))
                    .frenchPronunciation()

                  Text(verb: verb, tense: .conditionnelPrésent(personNumber)).font(bodyFont)
                    .leftAligned()
                    .accessibilityHidden(true)
                }
              }
                .padding(.bottom, -1.0 * Layout.defaultSpacing)

              Spacer()
            }

            Group {
              Text(Tense.subjonctifPrésent(.firstSingular).titleCaseName)
                .subheadingLabel()
                .frenchPronunciation()
                .padding(.bottom, -1.0 * Layout.defaultSpacing)
                .padding(.top, Layout.defaultSpacing)

              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                ZStack {
                  Color.customBackground
                    .accessibility(value: Text(verb: verb, tense: .subjonctifPrésent(personNumber), shouldShowIrregularities: false))
                    .frenchPronunciation()

                  Text(verb: verb, tense: .subjonctifPrésent(personNumber)).font(bodyFont)
                    .leftAligned()
                    .accessibilityHidden(true)
                }
              }
                .padding(.bottom, -1.0 * Layout.defaultSpacing)

              Spacer()

              Text(Tense.subjonctifImparfait(.firstSingular).titleCaseName)
                .subheadingLabel()
                .frenchPronunciation()
                .padding(.bottom, -1.0 * Layout.defaultSpacing)
                .padding(.top, Layout.defaultSpacing)

              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                ZStack {
                  Color.customBackground
                    .accessibility(value: Text(verb: verb, tense: .subjonctifImparfait(personNumber), shouldShowIrregularities: false))
                    .frenchPronunciation()

                  Text(verb: verb, tense: .subjonctifImparfait(personNumber)).font(bodyFont)
                    .leftAligned()
                    .accessibilityHidden(true)
                }
              }
                .padding(.bottom, -1.0 * Layout.defaultSpacing)

              Spacer()

              Text(Tense.impératif(.firstPlural).titleCaseName)
                .subheadingLabel()
                .frenchPronunciation()
                .padding(.bottom, -1.0 * Layout.defaultSpacing)
                .padding(.top, Layout.defaultSpacing)

              ForEach(PersonNumber.impératifPersonNumbers, id: \.self) { personNumber in
                ZStack {
                  Color.customBackground
                    .accessibility(value: Text(verb: verb, tense: .impératif(personNumber), shouldShowIrregularities: false))
                    .frenchPronunciation()

                  Text(verb: verb, tense: .impératif(personNumber)).font(bodyFont)
                    .leftAligned()
                    .accessibilityHidden(true)
                }
              }
                .padding(.bottom, -1.0 * Layout.defaultSpacing)
            }
          }

          Spacer()

          Toggle(isOn: $shouldShowCompoundTenses) {
            Text(L.VerbView.showCompoundTenses)
              .subheadingLabel()
          }
            .toggleStyle(SwitchToggleStyle(tint: .customRed))
            .padding(.top, Layout.defaultSpacing)

          if shouldShowCompoundTenses {
            Group {
              Spacer()

              Group {
                Text(Tense.passéComposé(.firstSingular).titleCaseName)
                  .subheadingLabel()
                  .frenchPronunciation()
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)
                  //.padding(.top, Layout.defaultSpacing)

                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  ZStack {
                    Color.customBackground
                      .accessibility(value: Text(verb: verb, tense: .passéComposé(personNumber), shouldShowIrregularities: false))
                      .frenchPronunciation()

                    Text(verb: verb, tense: .passéComposé(personNumber)).font(bodyFont)
                      .leftAligned()
                      .accessibilityHidden(true)
                  }
                }
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)

                Spacer()

                Text(Tense.plusQueParfait(.firstSingular).titleCaseName)
                  .subheadingLabel()
                  .frenchPronunciation()
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)
                  .padding(.top, Layout.defaultSpacing)

                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  ZStack {
                    Color.customBackground
                      .accessibility(value: Text(verb: verb, tense: .plusQueParfait(personNumber), shouldShowIrregularities: false))
                      .frenchPronunciation()

                    Text(verb: verb, tense: .plusQueParfait(personNumber)).font(bodyFont)
                      .leftAligned()
                      .accessibilityHidden(true)
                  }
                }
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)

                Spacer()

                Text(Tense.passéAntérieur(.firstSingular).titleCaseName)
                  .subheadingLabel()
                  .frenchPronunciation()
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)
                  .padding(.top, Layout.defaultSpacing)

                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  ZStack {
                    Color.customBackground
                      .accessibility(value: Text(verb: verb, tense: .passéAntérieur(personNumber), shouldShowIrregularities: false))
                      .frenchPronunciation()

                    Text(verb: verb, tense: .passéAntérieur(personNumber)).font(bodyFont)
                      .leftAligned()
                      .accessibilityHidden(true)
                  }
                }
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)

                Spacer()
              }

              Group {
                Text(Tense.passéSurcomposé(.firstSingular).titleCaseName)
                  .subheadingLabel()
                  .frenchPronunciation()
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)
                  .padding(.top, Layout.defaultSpacing)

                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  ZStack {
                    Color.customBackground
                      .accessibility(value: Text(verb: verb, tense: .passéSurcomposé(personNumber), shouldShowIrregularities: false))
                      .frenchPronunciation()

                    Text(verb: verb, tense: .passéSurcomposé(personNumber)).font(bodyFont)
                      .leftAligned()
                      .accessibilityHidden(true)
                  }
                }
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)

                Spacer()

                Text(Tense.futurAntérieur(.firstSingular).titleCaseName)
                  .subheadingLabel()
                  .frenchPronunciation()
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)
                  .padding(.top, Layout.defaultSpacing)

                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  ZStack {
                    Color.customBackground
                      .accessibility(value: Text(verb: verb, tense: .futurAntérieur(personNumber), shouldShowIrregularities: false))
                      .frenchPronunciation()

                    Text(verb: verb, tense: .futurAntérieur(personNumber)).font(bodyFont)
                      .leftAligned()
                      .accessibilityHidden(true)
                  }
                }
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)

                Spacer()

                Text(Tense.conditionnelPassé(.firstSingular).titleCaseName)
                  .subheadingLabel()
                  .frenchPronunciation()
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)
                  .padding(.top, Layout.defaultSpacing)

                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  ZStack {
                    Color.customBackground
                      .accessibility(value: Text(verb: verb, tense: .conditionnelPassé(personNumber), shouldShowIrregularities: false))
                      .frenchPronunciation()

                    Text(verb: verb, tense: .conditionnelPassé(personNumber)).font(bodyFont)
                      .leftAligned()
                      .accessibilityHidden(true)
                  }
                }
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)

                Spacer()
              }

              Group {
                Text(Tense.subjonctifPassé(.firstSingular).titleCaseName)
                  .subheadingLabel()
                  .frenchPronunciation()
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)
                  .padding(.top, Layout.defaultSpacing)

                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  ZStack {
                    Color.customBackground
                      .accessibility(value: Text(verb: verb, tense: .subjonctifPassé(personNumber), shouldShowIrregularities: false))
                      .frenchPronunciation()

                    Text(verb: verb, tense: .subjonctifPassé(personNumber)).font(bodyFont)
                      .leftAligned()
                      .accessibilityHidden(true)
                  }
                }
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)

                Spacer()

                Text(Tense.subjonctifPlusQueParfait(.firstSingular).titleCaseName)
                  .subheadingLabel()
                  .frenchPronunciation()
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)
                  .padding(.top, Layout.defaultSpacing)

                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  ZStack {
                    Color.customBackground
                      .accessibility(value: Text(verb: verb, tense: .subjonctifPlusQueParfait(personNumber), shouldShowIrregularities: false))
                      .frenchPronunciation()

                    Text(verb: verb, tense: .subjonctifPlusQueParfait(personNumber)).font(bodyFont)
                      .leftAligned()
                      .accessibilityHidden(true)
                  }
                }
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)

                Spacer()

                Text(Tense.impératifPassé(.firstSingular).titleCaseName)
                  .subheadingLabel()
                  .frenchPronunciation()
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)
                  .padding(.top, Layout.defaultSpacing)

                ForEach(PersonNumber.impératifPersonNumbers, id: \.self) { personNumber in
                  ZStack {
                    Color.customBackground
                      .accessibility(value: Text(verb: verb, tense: .impératifPassé(personNumber), shouldShowIrregularities: false))
                      .frenchPronunciation()

                    Text(verb: verb, tense: .impératifPassé(personNumber)).font(bodyFont)
                      .leftAligned()
                      .accessibilityHidden(true)
                  }
                }
                  .padding(.bottom, -1.0 * Layout.defaultSpacing)

                Spacer()
              }
            }
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
