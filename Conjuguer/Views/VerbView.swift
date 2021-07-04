//
//  VerbView.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/28/21.
//

import SwiftUI

struct VerbView: View {
  let verb: Verb
  @State var shouldShowCompoundTenses = false

  init(verb: Verb) {
    self.verb = verb
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text("Overview")
          .subheadingLabel()
          .leftAligned()

        Text(verb.translation)
          .bodyLabel()

        if let model = VerbModel.models[verb.model] {
          Text(model.exemplar + " (" + model.id + ")")
            .bodyLabel()
        }

        Group {
          if verb.isReflexive {
            Text("Reflexive")
              .bodyLabel()
          }

          if verb.hasAspiratedH {
            Text("Aspirated H")
              .bodyLabel()
          }

          if verb.auxiliary == .être {
            Text("Auxiliary: être")
              .bodyLabel()
          } else {
            Text("Auxiliary: avoir")
              .bodyLabel()
          }
        }

        Group {
          if
            let defectGroupId = verb.defectGroupId,
            let defectGroup = DefectGroup.defectGroups[defectGroupId]
          {
            Text("Defective. " + defectGroup.description())
                .bodyLabel()
            Spacer()
          }

          if let example = verb.example {
            Group {
              Text("Example Use")
                .subheadingLabel()
                .leftAligned()

              Text(example)
                .bodyLabel()

              if let source = verb.source {
                Text(source)
                  .smallLabel()
                  .rightAligned()
              }

              Spacer()
            }
          }
        }

        Group {
          Text("P. Passé, P. Présent, R. Futur")
            .subheadingLabel()

          let passéPart = Text(verb: verb, tense: .participePassé).font(bodyFont) + Text(", ").font(bodyFont)
          let présentPart = Text(verb: verb, tense: .participePrésent).font(bodyFont) + Text(", ").font(bodyFont)
          let futurPart = Text(verb: verb, tense: .radicalFutur).font(bodyFont)

          passéPart + présentPart + futurPart

          Spacer()

          Group {
            Text("Indicatif Présent")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              Text(verb: verb, tense: .indicatifPrésent(personNumber)).font(bodyFont)
            }

            Spacer()

            Text("Passé Simple")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              Text(verb: verb, tense: .passéSimple(personNumber)).font(bodyFont)
            }

            Spacer()
          }

          Group {
            Text("Imparfait")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              Text(verb: verb, tense: .imparfait(personNumber)).font(bodyFont)
            }
            Spacer()

            Text("Futur Simple")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              Text(verb: verb, tense: .futurSimple(personNumber)).font(bodyFont)
            }

            Spacer()

            Text("Conditionnel Présent")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              Text(verb: verb, tense: .conditionnelPrésent(personNumber)).font(bodyFont)
            }

            Spacer()
          }

          Group {
            Text("Subjonctif Présent")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              Text(verb: verb, tense: .subjonctifPrésent(personNumber)).font(bodyFont)
            }

            Spacer()

            Text("Subjonctif Imparfait")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              Text(verb: verb, tense: .subjonctifImparfait(personNumber)).font(bodyFont)
            }

            Spacer()

            Text("Impératif")
              .subheadingLabel()
            ForEach(PersonNumber.impératifPersonNumbers, id: \.self) { personNumber in
              Text(verb: verb, tense: .impératif(personNumber)).font(bodyFont)
            }
          }
        }

        Spacer()

        Toggle(isOn: $shouldShowCompoundTenses) {
          Text("Show Compound Tenses")
        }

        if shouldShowCompoundTenses {
          Group {
            Spacer()

            Group {
              Text("Passé Composé")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .passéComposé(personNumber)).font(bodyFont)
              }

              Spacer()

              Text("Plus Que Parfait")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .plusQueParfait(personNumber)).font(bodyFont)
              }

              Spacer()

              Text("Passé Antérieur")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .passéAntérieur(personNumber)).font(bodyFont)
              }

              Spacer()
            }

            Group {
              Text("Passé Surcomposé")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .passéSurcomposé(personNumber)).font(bodyFont)
              }

              Spacer()

              Text("Futur Antérieur")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .futurAntérieur(personNumber)).font(bodyFont)
              }

              Spacer()

              Text("Conditionnel Passé")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .conditionnelPassé(personNumber)).font(bodyFont)
              }

              Spacer()
            }

            Group {
              Text("Subjonctif Passé")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .subjonctifPassé(personNumber)).font(bodyFont)
              }

              Spacer()

              Text("Subjonctif Plus Que Parfait")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                Text(verb: verb, tense: .subjonctifPlusQueParfait(personNumber)).font(bodyFont)
              }

              Spacer()

              Text("Impératif Passé")
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
