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
          if shouldShowVerbHeading {
            Text(verb.infinitifWithPossibleExtraLetters)
              .headingLabel()
            Spacer()
          }

          Text(L.VerbView.overview)
            .subheadingLabel()
            .leftAligned()

          Text(verb.translation)
            .bodyLabel()

          if let model = VerbModel.models[verb.model] {
            Text("\(L.VerbView.model) \(model.exemplar) (\(model.id))")
              .bodyLabel()
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

            if verb.auxiliary == .être {
              Text(L.VerbView.auxiliaryÊtre)
                .bodyLabel()
            } else {
              Text(L.VerbView.auxiliaryAvoir)
                .bodyLabel()
            }

            if let frequency = verb.frequency {
              Text("\(L.VerbView.frequency): \(frequency) / \(FrequencyParser.maxFrequency)")
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

                if let source = verb.source {
                  Text(source)
                    .smallLabel()
                    .rightAligned()
                }
              }
            }
          }

          Group {
            Spacer()

            Text(L.VerbView.personlessConjugations)
              .subheadingLabel()

            let passéPart = Text(verb: verb, tense: .participePassé).font(bodyFont) + Text(", ").font(bodyFont)
            let présentPart = Text(verb: verb, tense: .participePrésent).font(bodyFont) + Text(", ").font(bodyFont)
            let futurPart = Text(verb: verb, tense: .radicalFutur).font(bodyFont)

            passéPart + présentPart + futurPart

            Spacer()

            Group {
              Text(Tense.indicatifPrésent(.firstSingular).titleCaseName)
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .indicatifPrésent(personNumber)).font(bodyFont)
              }

              Spacer()

              Text(Tense.passéSimple(.firstSingular).titleCaseName)
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .passéSimple(personNumber)).font(bodyFont)
              }

              Spacer()
            }

            Group {
              Text(Tense.imparfait(.firstSingular).titleCaseName)
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .imparfait(personNumber)).font(bodyFont)
              }
              Spacer()

              Text(Tense.futurSimple(.firstSingular).titleCaseName)
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .futurSimple(personNumber)).font(bodyFont)
              }

              Spacer()

              Text(Tense.conditionnelPrésent(.firstSingular).titleCaseName)
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .conditionnelPrésent(personNumber)).font(bodyFont)
              }

              Spacer()
            }

            Group {
              Text(Tense.subjonctifPrésent(.firstSingular).titleCaseName)
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .subjonctifPrésent(personNumber)).font(bodyFont)
              }

              Spacer()

              Text(Tense.subjonctifImparfait(.firstSingular).titleCaseName)
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .subjonctifImparfait(personNumber)).font(bodyFont)
              }

              Spacer()

              Text(Tense.impératif(.firstPlural).titleCaseName)
                .subheadingLabel()
              ForEach(PersonNumber.impératifPersonNumbers, id: \.self) { personNumber in
                Text(verb: verb, tense: .impératif(personNumber)).font(bodyFont)
              }
            }
          }

          Spacer()

          Toggle(isOn: $shouldShowCompoundTenses) {
            Text(L.VerbView.showCompoundTenses)
              .subheadingLabel()
          }
          .toggleStyle(SwitchToggleStyle(tint: .customRed))

          if shouldShowCompoundTenses {
            Group {
              Spacer()

              Group {
                Text(Tense.passéComposé(.firstSingular).titleCaseName)
                  .subheadingLabel()
                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  Text(verb: verb, tense: .passéComposé(personNumber)).font(bodyFont)
                }

                Spacer()

                Text(Tense.plusQueParfait(.firstSingular).titleCaseName)
                  .subheadingLabel()
                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  Text(verb: verb, tense: .plusQueParfait(personNumber)).font(bodyFont)
                }

                Spacer()

                Text(Tense.passéAntérieur(.firstSingular).titleCaseName)
                  .subheadingLabel()
                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  Text(verb: verb, tense: .passéAntérieur(personNumber)).font(bodyFont)
                }

                Spacer()
              }

              Group {
                Text(Tense.passéSurcomposé(.firstSingular).titleCaseName)
                  .subheadingLabel()
                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  Text(verb: verb, tense: .passéSurcomposé(personNumber)).font(bodyFont)
                }

                Spacer()

                Text(Tense.futurAntérieur(.firstSingular).titleCaseName)
                  .subheadingLabel()
                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  Text(verb: verb, tense: .futurAntérieur(personNumber)).font(bodyFont)
                }

                Spacer()

                Text(Tense.conditionnelPassé(.firstSingular).titleCaseName)
                  .subheadingLabel()
                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  Text(verb: verb, tense: .conditionnelPassé(personNumber)).font(bodyFont)
                }

                Spacer()
              }

              Group {
                Text(Tense.subjonctifPassé(.firstSingular).titleCaseName)
                  .subheadingLabel()
                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  Text(verb: verb, tense: .subjonctifPassé(personNumber)).font(bodyFont)
                }

                Spacer()

                Text(Tense.subjonctifPlusQueParfait(.firstSingular).titleCaseName)
                  .subheadingLabel()
                ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                  Text(verb: verb, tense: .subjonctifPlusQueParfait(personNumber)).font(bodyFont)
                }

                Spacer()

                Text(Tense.impératifPassé(.firstSingular).titleCaseName)
                  .subheadingLabel()
                ForEach(PersonNumber.impératifPersonNumbers, id: \.self) { personNumber in
                  Text(verb: verb, tense: .impératifPassé(personNumber)).font(bodyFont)
                }
              }
            }
          }
        }
      }
        .navigationTitle(verb.infinitifWithPossibleExtraLetters)
        .customNavigationBarItems()
    }
  }
}
