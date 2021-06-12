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

        if verb.isReflexive && verb.isDefective {
          Text("Reflexive, Defective")
            .bodyLabel()
        } else if !verb.isReflexive && verb.isDefective {
          Text("Defective")
            .bodyLabel()
        } else if verb.isReflexive && !verb.isDefective {
          Text("Reflexive")
            .bodyLabel()
        }

        if verb.auxiliary == .être {
          Text("Auxiliary: être")
            .bodyLabel()
        } else {
          Text("Auxiliary: avoir")
            .bodyLabel()
        }

        Spacer()

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
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .indicatifPrésent(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
                  .bodyLabel()
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for indicatif présent.")
              }
            }

            Spacer()

            Text("Passé Simple")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .passéSimple(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
                  .bodyLabel()
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for passé simple.")
              }
            }

            Spacer()
          }

          Group {
            Text("Imparfait")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .imparfait(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
                  .bodyLabel()
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for imparfait.")
              }
            }
            Spacer()

            Text("Futur Simple")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .futurSimple(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
                  .bodyLabel()
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for futur simple.")
              }
            }

            Spacer()

            Text("Conditionnel Présent")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .conditionnelPrésent(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
                  .bodyLabel()
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for conditionnel présent.")
              }
            }

            Spacer()
          }

          Group {
            Text("Subjonctif Présent")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .subjonctifPrésent(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
                  .bodyLabel()
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for subjonctif présent.")
              }
            }

            Spacer()

            Text("Subjonctif Imparfait")
              .subheadingLabel()
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .subjonctifImparfait(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
                  .bodyLabel()
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for subjonctif imparfait.")
              }
            }

            Spacer()

            Text("Impératif")
              .subheadingLabel()
            ForEach(PersonNumber.impératifPersonNumbers, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .impératif(personNumber)) {
              case .success(let value):
                Text(mixedCaseString: value)
                  .bodyLabel()
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for impératif.")
              }
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
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .passéComposé(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                    .bodyLabel()
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for passé composé.")
                }
              }

              Spacer()

              Text("Plus Que Parfait")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .plusQueParfait(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                    .bodyLabel()
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for plus que parfait.")
                }
              }

              Spacer()

              Text("Passé Antérieur")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .passéAntérieur(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                    .bodyLabel()
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for passé antérieur.")
                }
              }

              Spacer()
            }

            Group {
              Text("Passé Surcomposé")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .passéSurcomposé(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                    .bodyLabel()
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for passé surcomposé.")
                }
              }

              Spacer()

              Text("Futur Antérieur")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .futurAntérieur(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                    .bodyLabel()
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for futur antérieur.")
                }
              }

              Spacer()

              Text("Conditionnel Passé")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .conditionnelPassé(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                    .bodyLabel()
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for conditionnel passé")
                }
              }

              Spacer()
            }

            Group {
              Text("Subjonctif Passé")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .subjonctifPassé(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                    .bodyLabel()
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for subjonctif passé.")
                }
              }

              Spacer()

              Text("Subjonctif Plus Que Parfait")
                .subheadingLabel()
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .subjonctifPlusQueParfait(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                    .bodyLabel()
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for subjonctif plus que parfait.")
                }
              }

              Spacer()

              Text("Impératif Passé")
                .subheadingLabel()
              ForEach(PersonNumber.impératifPersonNumbers, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .impératifPassé(personNumber)) {
                case .success(let value):
                  Text(mixedCaseString: value)
                    .bodyLabel()
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for impératif passé.")
                }
              }
            }
          }
        }
      }
    }
    .navigationTitle(verb.infinitif)
    .customNavigationBarItems()
  }
}
