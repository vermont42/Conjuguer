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
  @State var reflexive: String = "f"

  var body: some View {
    ZStack {
      Color.black
      VStack {
        Group {
          Text("Infinitif")
            .subheadingLabel()
          TextField("Infinitif", text: $infinitif)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(UITextAutocapitalizationType.none)
            .disableAutocorrection(true)
            .padding()

          Text("Translation")
            .subheadingLabel()
          TextField("Translation", text: $translation)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(UITextAutocapitalizationType.none)
            .disableAutocorrection(true)
            .padding()

          Text("Model")
            .subheadingLabel()
          TextField("Model", text: $model)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(UITextAutocapitalizationType.none)
            .disableAutocorrection(true)
            .padding()
        }

        Group {
          Text("Reflexive (t or f)")
            .subheadingLabel()
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
  }

  private func add() {
    defer {
      resetFields()
    }

    if infinitif == "" || translation == "" || model == "" {
      outputError("Input field was blank.")
      return
    }

    let isReflexive = reflexive == "t" ? true : false

    if Verb.verbs[infinitif] != nil {
      outputError("\(infinitif) has already been inpat.")
      return
    }

    if VerbModel.models[model.uppercased()] == nil {
      outputError("Invalid model \(model) inpat.")
      return
    }

    let lastTwo = infinitif.suffix(2)
    let lastThree = infinitif.suffix(3)
    let lastFour = infinitif.suffix(4)

    if !["er", "ir", "re", "ïr"].contains(lastTwo) {
      outputError("Invalid infinitive \(infinitif).")
      return
    }

    if (lastTwo == "ir" || lastTwo == "re" || lastThree == "cer" || lastFour == "eler" || lastFour == "oyer") && model == "1-1" {
      outputError("1-1 is an invalid model for \(infinitif).")
      return
    }

    let verb = Verb(
      infinitif: infinitif,
      translation: translation,
      model: model.uppercased(),
      auxiliary: isReflexive ? .être : .avoir,
      isReflexive: isReflexive,
      hasAspiratedH: false,
      frequency: nil,
      extraLetters: nil,
      example: nil,
      source: nil,
      defectGroupId: nil
    )
    Verb.verbs[infinitif] = verb
    conjugate(infinitif, extraLetters: nil)
    SoundPlayer.play(.chime)
  }

  private func outputError(_ error: String) {
    Swift.print(error)
    SoundPlayer.play(.sadTrombone)
  }

  private func resetFields() {
    infinitif = ""
    translation = ""
    model = "1-1"
    reflexive = "f"
  }

  private func conjugate(_ verb: String, extraLetters: String?) {
    var output = "\(verb)"

    let noTranslation = "NO TRANSLATION"
    output += "  •  \(Verb.verbs[verb]?.translation ?? noTranslation)  •  PRESENT: "

    let personNumbers: [PersonNumber] = PersonNumber.allCases

    for personNumber in personNumbers {
      let présentResult = Conjugator.conjugate(infinitif: verb, tense: .indicatifPrésent(personNumber), extraLetters: extraLetters)
      switch présentResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  IMPERFECT: "

    for personNumber in personNumbers {
      let imparfaitResult = Conjugator.conjugate(infinitif: verb, tense: .imparfait(personNumber), extraLetters: extraLetters)
      switch imparfaitResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  FUTURE: "

    for personNumber in personNumbers {
      let futurResult = Conjugator.conjugate(infinitif: verb, tense: .futurSimple(personNumber), extraLetters: extraLetters)
      switch futurResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  CONDITIONAL: "

    for personNumber in personNumbers {
      let conditionnelResult = Conjugator.conjugate(infinitif: verb, tense: .conditionnelPrésent(personNumber), extraLetters: extraLetters)
      switch conditionnelResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  SIMPLE PAST: "

    for personNumber in personNumbers {
      let passéSimpleResult = Conjugator.conjugate(infinitif: verb, tense: .passéSimple(personNumber), extraLetters: extraLetters)
      switch passéSimpleResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  SUBJ. PRESENT: "

    for personNumber in personNumbers {
      let subjonctifPrésentResult = Conjugator.conjugate(infinitif: verb, tense: .subjonctifPrésent(personNumber), extraLetters: extraLetters)
      switch subjonctifPrésentResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    output += " •  SUBJ. IMPERFECT: "

    for personNumber in personNumbers {
      let subjonctifImparfaitResult = Conjugator.conjugate(infinitif: verb, tense: .subjonctifImparfait(personNumber), extraLetters: extraLetters)
      switch subjonctifImparfaitResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    let participePassé: String
    let participePasséResult = Conjugator.conjugate(infinitif: verb, tense: .participePassé, extraLetters: extraLetters)
    switch participePasséResult {
    case .success(let value):
      participePassé = value
    default:
      fatalError()
    }
    output += "  •  PAST PARTICIPLE: \(participePassé) "

    let participePrésent: String
    let participePrésentResult = Conjugator.conjugate(infinitif: verb, tense: .participePrésent, extraLetters: extraLetters)
    switch participePrésentResult {
    case .success(let value):
      participePrésent = value
    default:
      fatalError()
    }
    output += " •  PRESENT PARTICIPLE: \(participePrésent) "

    output += " •  IMPERATIVE: "

    for personNumber in PersonNumber.impératifPersonNumbers {
      let impératifResult = Conjugator.conjugate(infinitif: verb, tense: .impératif(personNumber), extraLetters: extraLetters)
      switch impératifResult {
      case .success(let value):
        output += "\(value) "
      default:
        fatalError()
      }
    }

    let radicalFuturResult = Conjugator.conjugate(infinitif: verb, tense: .radicalFutur, extraLetters: extraLetters)
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

    let verbArray = Verb.verbs.values.sorted { lhs, rhs in
      lhs.infinitif.compare(rhs.infinitif, locale: Util.french) == .orderedAscending
    }

    for verb in verbArray {
      output += "  <verb in=\"" + verb.infinitif + "\" tn=\"" + verb.translation + "\" "
      if verb.auxiliary == .être && !verb.isReflexive {
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
