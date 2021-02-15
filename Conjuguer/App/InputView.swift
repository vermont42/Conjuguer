//
//  InputView.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/1/21.
//

import SwiftUI

struct InputView: View {
  @State var infinitif: String = ""
  @State var model: String = "1-1"
  @State var translation: String = ""
  @State var auxiliary: String = "a"
  @State var reflexive: String = "f"

  var body: some View {
    ZStack {
      Color.black
      VStack {
        TextField("Infinitif", text: $infinitif)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .autocapitalization(UITextAutocapitalizationType.none)
          .disableAutocorrection(true)
          .padding()
        TextField("Model", text: $model)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .autocapitalization(UITextAutocapitalizationType.none)
          .disableAutocorrection(true)
          .padding()
        TextField("Translation", text: $translation)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .autocapitalization(UITextAutocapitalizationType.none)
          .disableAutocorrection(true)
          .padding()
        TextField("Auxiliary", text: $auxiliary)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .autocapitalization(UITextAutocapitalizationType.none)
          .disableAutocorrection(true)
          .padding()
        TextField("Reflexive", text: $reflexive)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .autocapitalization(UITextAutocapitalizationType.none)
          .disableAutocorrection(true)
          .padding()
        Button("Add") {
          add()
        }
        Button("Print") {
          print()
        }
      }
    }
  }

  private func add() {
    defer {
      resetFields()
    }

    let currentAuxiliary = Auxiliary(rawValue: auxiliary) ?? .avoir
    if infinitif == "" || translation == "" || model == "" || auxiliary == "" {
      Swift.print("Input field was blank.")
      return
    }

    let isReflexive = reflexive == "t" ? true : false

    if Verb.verbs[infinitif] != nil {
      Swift.print("\(infinitif) has already been inpat.")
      return
    }

    if VerbModel.models[model] == nil {
      Swift.print("Invalid model \(model) inpat.")
      return
    }

    let verb = Verb(
      infinitif: infinitif,
      translation: translation,
      model: model,
      auxiliary: currentAuxiliary,
      isReflexive: isReflexive,
      frequency: nil
    )
    Verb.verbs[infinitif] = verb
    conjugate(infinitif)
  }

  private func resetFields() {
    infinitif = ""
    translation = ""
    model = "1-1"
    auxiliary = "a"
    reflexive = "f"
  }

  private func conjugate(_ verb: String) {
    var output = "\(verb)"

    output += "  •  PRESENT: "

    let personNumbers: [PersonNumber] = PersonNumber.allCases

    for personNumber in personNumbers {
      let présentResult = Conjugator.conjugate(infinitif: verb, tense: .indicatifPrésent(personNumber))
      switch présentResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  IMPERFECT: "

    for personNumber in personNumbers {
      let imparfaitResult = Conjugator.conjugate(infinitif: verb, tense: .imparfait(personNumber))
      switch imparfaitResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  FUTURE: "

    for personNumber in personNumbers {
      let futurResult = Conjugator.conjugate(infinitif: verb, tense: .futurSimple(personNumber))
      switch futurResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  CONDITIONAL: "

    for personNumber in personNumbers {
      let conditionnelResult = Conjugator.conjugate(infinitif: verb, tense: .conditionnelPrésent(personNumber))
      switch conditionnelResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  SIMPLE PAST: "

    for personNumber in personNumbers {
      let passéSimpleResult = Conjugator.conjugate(infinitif: verb, tense: .passéSimple(personNumber))
      switch passéSimpleResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  SUBJ. PRESENT: "

    for personNumber in personNumbers {
      let subjonctifPrésentResult = Conjugator.conjugate(infinitif: verb, tense: .subjonctifPrésent(personNumber))
      switch subjonctifPrésentResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  SUBJ. IMPERFECT: "

    for personNumber in personNumbers {
      let subjonctifImparfaitResult = Conjugator.conjugate(infinitif: verb, tense: .subjonctifImparfait(personNumber))
      switch subjonctifImparfaitResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    let participePassé: String
    let participePasséResult = Conjugator.conjugate(infinitif: verb, tense: .participePassé)
    switch participePasséResult {
    case .success(let value):
      participePassé = value
    default:
      fatalError()
    }
    output += "  •  PAST PARTICIPLE: \(participePassé) "

    let participePrésent: String
    let participePrésentResult = Conjugator.conjugate(infinitif: verb, tense: .participePrésent)
    switch participePrésentResult {
    case .success(let value):
      participePrésent = value
    default:
      fatalError()
    }
    output += " •  PRESENT PARTICIPLE: \(participePrésent) "

    output += " •  IMPERATIVE: "

    for personNumber in PersonNumber.impératifPersonNumbers {
      let impératifResult = Conjugator.conjugate(infinitif: verb, tense: .impératif(personNumber))
      switch impératifResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    let radicalFuturResult = Conjugator.conjugate(infinitif: verb, tense: .radicalFutur)
    switch radicalFuturResult {
    case .success(let value):
      output += " •  FUTURE STEM: \(value) "
    default:
      fatalError()
    }

    if
      let actualVerb = Verb.verbs[verb],
      actualVerb.auxiliary == .être
    {
      output += " •  auxiliary: être "
    }

    Swift.print("\(output)\n")
  }

  private func print() {
    var output = """
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE verbs [
        <!ELEMENT verbs (verb+)>
        <!ELEMENT verb (verb*)>
        <!ATTLIST verb in CDATA #REQUIRED>
        <!ATTLIST verb tn CDATA #REQUIRED>
        <!ATTLIST verb mo CDATA #REQUIRED>
        <!ATTLIST verb ay CDATA #IMPLIED>
        <!ATTLIST verb fr CDATA #IMPLIED>
    ]>

    <verbs>
    """
    output += "\n"

    let french = Locale(identifier: "fr")
    let verbArray = Verb.verbs.values.sorted { lhs, rhs in
      lhs.infinitif.compare(rhs.infinitif, locale: french) == .orderedAscending
    }

    for verb in verbArray {
      output += "  <verb in=\"" + verb.infinitif + "\" tn=\"" + verb.translation + "\" "
      if verb.auxiliary == .être {
        output += "ay=\"e\" "
      }
      if verb.isReflexive {
        output += "re=\"t\" "
      }
      output += "mo=\"" + verb.model.uppercased() + "\" "
      if let frequency = verb.frequency {
        output += "fr=\"\(frequency)\" "
      }
      output += "/>\n"
    }
    output  += "</verbs>"
    Swift.print(output)
  }
}

struct InputView_Previews: PreviewProvider {
  static var previews: some View {
    InputView()
  }
}
