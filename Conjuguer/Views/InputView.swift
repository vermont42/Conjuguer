//
//  InputView.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/1/21.
//

import SwiftUI

#if DEBUG
struct InputView: View {
  @State private var infinitif: String = ""
  @State private var model: String = "1-1"
  @State private var translation: String = ""
  @State private var reflexive: String = "f"

  var body: some View {
    ZStack {
      Color.black
      VStack {
        labeledField("Infinitif", text: $infinitif)
        labeledField("Translation", text: $translation)
        labeledField("Model", text: $model)
        labeledField("Reflexive (t or f)", text: $reflexive)

        Button("Add") {
          add()
        }

        Button("Print") {
          print()
        }
      }
    }
  }

  @ViewBuilder private func labeledField(_ title: String, text: Binding<String>) -> some View {
    Text(title)
      .subheadingLabel()
    TextField(title, text: text)
      .textFieldStyle(.roundedBorder)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
      .padding()
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
      outputError("\(infinitif) has already been input.")
      return
    }

    if VerbModel.models[model.uppercased()] == nil {
      outputError("Invalid model \(model) input.")
      return
    }

    let lastTwo = infinitif.suffix(2)
    let lastThree = infinitif.suffix(3)
    let lastFour = infinitif.suffix(4)

    if !Verb.endingIsValid(infinitif: infinitif) {
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
      defectGroupId: nil
    )
    Verb.verbs[infinitif] = verb
    conjugate(infinitif, extraLetters: nil)
    Current.soundPlayer.play(.chime)
  }

  private func outputError(_ error: String) {
    Swift.print(error)
    Current.soundPlayer.play(Sound.randomSadTrombone)
  }

  private func resetFields() {
    infinitif = ""
    translation = ""
    model = "1-1"
    reflexive = "f"
  }

  private func conjugate(_ verb: String, extraLetters: String?) {
    let all = PersonNumber.allCases
    let specs: [(label: String, tenses: [Tense])] = [
      ("PRESENT", all.map { .indicatifPrésent($0) }),
      ("IMPERFECT", all.map { .imparfait($0) }),
      ("FUTURE", all.map { .futurSimple($0) }),
      ("CONDITIONAL", all.map { .conditionnelPrésent($0) }),
      ("SIMPLE PAST", all.map { .passéSimple($0) }),
      ("SUBJ. PRESENT", all.map { .subjonctifPrésent($0) }),
      ("SUBJ. IMPERFECT", all.map { .subjonctifImparfait($0) }),
      ("PAST PARTICIPLE", [.participePassé]),
      ("PRESENT PARTICIPLE", [.participePrésent]),
      ("IMPERATIVE", PersonNumber.impératifPersonNumbers.map { .impératif($0) }),
      ("FUTURE STEM", [.radicalFutur])
    ]

    func forms(_ tenses: [Tense]) -> String {
      tenses
        .map { tense in
          guard let value = Conjugator.conjugatedString(infinitif: verb, tense: tense, extraLetters: extraLetters) else {
            fatalError("Conjugation failed.")
          }
          return value
        }
        .joined(separator: " ")
    }

    let noTranslation = "NO TRANSLATION"
    var output = "\(verb)  •  \(Verb.verbs[verb]?.translation ?? noTranslation)"
    output += specs
      .map { "  •  \($0.label): \(forms($0.tenses))" }
      .joined()

    if Verb.verbs[verb]?.auxiliary == .être {
      output += "  •  auxiliary: être"
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
        <!ATTLIST verb dg CDATA #IMPLIED>
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
      if let defectGroupId = verb.defectGroupId {
        output += "dg=\"\(defectGroupId)\" "
      }
      if verb.hasAspiratedH {
        output += "ah=\"t\" "
      }
      if let extraLetters = verb.extraLetters {
        output += "ex=\"\(extraLetters)\" "
      }
      output += "/>\n"
    }
    output += "</verbs>"
    Swift.print(output)
  }
}

#Preview {
  PreviewSupport.bootstrap()
  return InputView()
}
#endif
