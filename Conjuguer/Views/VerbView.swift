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

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text("Overview")
          .modifier(SubheadingLabel())
          .leftAligned()

        Text(verb.translation)

        if let model = VerbModel.models[verb.model] {
          Text(model.exemplar + " (" + model.id + ")")
        }

        Text((verb.isReflexive ? "Reflexive" : "Not Reflexive") + ", " + (verb.isDefective ? "Defective" : "Not Defective"))

        if verb.auxiliary == .être {
          Text("Auxiliary: être")
        } else {
          Text("Auxiliary: avoir")
        }

        Spacer()

        Group {
          Group {
            Text("Indicatif Présent")
              .modifier(SubheadingLabel())
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .indicatifPrésent(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for indicatif présent.")
              }
            }

            Spacer()

            Text("Passé Simple")
              .modifier(SubheadingLabel())
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .passéSimple(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for passé simple.")
              }
            }

            Spacer()

            Text("Imparfait")
              .modifier(SubheadingLabel())
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .imparfait(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for imparfait.")
              }
            }
            Spacer()
          }

          Group {
            Text("Futur Simple")
              .modifier(SubheadingLabel())
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .futurSimple(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for futur simple.")
              }
            }

            Spacer()

            Text("Conditionnel Présent")
              .modifier(SubheadingLabel())
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .conditionnelPrésent(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for conditionnel présent.")
              }
            }

            Spacer()
          }

          Group {
            Text("Subjonctif Présent")
              .modifier(SubheadingLabel())
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .subjonctifPrésent(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for subjonctif présent.")
              }
            }

            Spacer()

            Text("Subjonctif Imparfait")
              .modifier(SubheadingLabel())
            ForEach(PersonNumber.allCases, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .subjonctifImparfait(personNumber)) {
              case .success(let value):
                let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                Text(mixedCaseString: pronounAndConjugation)
              default:
                fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for subjonctif imparfait.")
              }
            }

            Spacer()

            Text("Impératif")
              .modifier(SubheadingLabel())
            ForEach(PersonNumber.impératifPersonNumbers, id: \.self) { personNumber in
              switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .impératif(personNumber)) {
              case .success(let value):
                Text(mixedCaseString: value)
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
                .modifier(SubheadingLabel())
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .passéComposé(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for passé composé.")
                }
              }

              Spacer()

              Text("Plus Que Parfait")
                .modifier(SubheadingLabel())
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .plusQueParfait(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for plus que parfait.")
                }
              }

              Spacer()

              Text("Passé Antérieur")
                .modifier(SubheadingLabel())
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .passéAntérieur(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for passé antérieur.")
                }
              }

              Spacer()
            }

            Group {
              Text("Passé Surcomposé")
                .modifier(SubheadingLabel())
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .passéSurcomposé(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for passé surcomposé.")
                }
              }

              Spacer()

              Text("Futur Antérieur")
                .modifier(SubheadingLabel())
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .futurAntérieur(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for futur antérieur.")
                }
              }

              Spacer()

              Text("Conditionnel Passé")
                .modifier(SubheadingLabel())
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .conditionnelPassé(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for conditionnel passé")
                }
              }

              Spacer()
            }

            Group {
              Text("Subjonctif Passé")
                .modifier(SubheadingLabel())
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .subjonctifPassé(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for subjonctif passé.")
                }
              }

              Spacer()

              Text("Subjonctif Plus Que Parfait")
                .modifier(SubheadingLabel())
              ForEach(PersonNumber.allCases, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .subjonctifPlusQueParfait(personNumber)) {
                case .success(let value):
                  let pronounAndConjugation = personNumber.pronounAndConjugation(value, isReflexive: verb.isReflexive)
                  Text(mixedCaseString: pronounAndConjugation)
                default:
                  fatalError("Could not conjugate \(verb.infinitif) \(personNumber.shortDisplayName) for subjonctif plus que parfait.")
                }
              }

              Spacer()

              Text("Impératif Passé")
                .modifier(SubheadingLabel())
              ForEach(PersonNumber.impératifPersonNumbers, id: \.self) { personNumber in
                switch Conjugator.conjugate(infinitif: verb.infinitif, tense: .impératifPassé(personNumber)) {
                case .success(let value):
                  Text(mixedCaseString: value)
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
  }
}
