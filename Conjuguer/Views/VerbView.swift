//
//  VerbView.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/28/21.
//

import SwiftUI

struct VerbView: View {
  let verb: Verb

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
      }
    }
    .navigationTitle(verb.infinitif)
  }
}
