//
//  StandardVariants.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// Standard spellings beside the one the conjugator writes: the 1990 rectifications (il plait
/// beside il plaît, j'amoncèle beside j'amoncelle), doublets that dictionaries list (il éclôt
/// beside il éclot), and passer's compound tenses with avoir (j'ai passé beside je suis passé).
/// The quiz accepts them, and the verb page keeps the conjugator's spelling.
enum StandardVariants {
  /// The variants of one lowercased conjugation, as `Conjugator` writes it for `tense` of `verb`:
  /// one alternate, with its auxiliary in a compound tense ("ai absous").
  static func variants(of conjugation: String, verb: Verb, tense: Tense) -> [String] {
    var variants: [String] = []
    func add(_ variant: String?) {
      if let variant, variant != conjugation, !variants.contains(variant) {
        variants.append(variant)
      }
    }

    let infinitif = verb.infinitif
    add(withoutCircumflexes(conjugation, infinitif: infinitif, tense: tense))
    add(withOtherSpellingOfOpenE(conjugation, infinitif: infinitif))
    add(withGraveInFuturStem(conjugation, verb: verb, tense: tense))
    add(rectifiedSpelling(conjugation, verb: verb, tense: tense))
    add(doublet(conjugation, infinitif: infinitif, tense: tense))
    add(withAvoir(conjugation, verb: verb, tense: tense))

    let rectified = variants
    for variant in rectified {
      add(withoutCircumflexes(variant, infinitif: infinitif, tense: tense))
    }
    return variants
  }

  // The rectifications drop the circumflex from i and u except where it distinguishes: in the
  // passé simple's -îmes and -îtes and the subjonctif imparfait's -ît (vînmes, fûtes, qu'il
  // eût), in dû, and in croître, which would otherwise be read as croire (il croît, crû). The
  // exception does not reach derivatives, so accroître gives accroit and redevoir redu. Jeûner
  // keeps it as jeûne does.
  private static func withoutCircumflexes(_ conjugation: String, infinitif: String, tense: Tense) -> String? {
    guard infinitif != "croître", infinitif != "jeûner", conjugation.contains(where: { $0 == "î" || $0 == "û" }) else {
      return nil
    }
    let keepsEndings = keepsCircumflexOfEnding(tense)
    let words = conjugation.split(separator: " ", omittingEmptySubsequences: false).map { word -> String in
      guard word != "dû" else {
        return String(word)
      }
      var characters = Array(word)
      for index in characters.indices where characters[index] == "î" || characters[index] == "û" {
        let rest = String(characters[(index + 1)...])
        if keepsEndings, ["mes", "tes", "t", "nmes", "ntes", "nt"].contains(rest) {
          continue
        }
        characters[index] = characters[index] == "î" ? "i" : "u"
      }
      return String(characters)
    }
    return words.joined(separator: " ")
  }

  private static func keepsCircumflexOfEnding(_ tense: Tense) -> Bool {
    switch tense {
    case .passéSimple, .subjonctifImparfait, .passéAntérieur, .subjonctifPlusQueParfait:
      return true
    default:
      return false
    }
  }

  // The rectifications conjugate every -eler and -eter verb as peler and acheter are, with è
  // and one consonant before a mute e (il étiquète, j'amoncèlerai), except appeler, jeter, and
  // their compounds. Interpeller has a rule of its own. The conjugator writes some of these
  // verbs the traditional way (étiquette) and some the rectified way (ruissèle), so the other
  // spelling is the variant, except for the verbs whose traditional spelling already has the è
  // (Larousse gives only il harcèle, il modèle).
  private static func withOtherSpellingOfOpenE(_ conjugation: String, infinitif: String) -> String? {
    guard
      infinitif.hasSuffix("eler") || infinitif.hasSuffix("eter"),
      !infinitif.hasSuffix("appeler"), !infinitif.hasSuffix("jeter"), infinitif != "interpeller"
    else {
      return nil
    }
    let rectified = rewritingEachWord(of: conjugation) { characters in
      guard let index = characters.indices.dropLast(3).last(where: { index in
        characters[index] == "e" &&
          ["l", "t"].contains(characters[index + 1]) &&
          characters[index + 1] == characters[index + 2] &&
          characters[index + 3] == "e"
      }) else {
        return false
      }
      characters[index] = "è"
      characters.remove(at: index + 1)
      return true
    }
    guard rectified == nil, !traditionallyOpenE.contains(infinitif) else {
      return rectified
    }
    return rewritingEachWord(of: conjugation) { characters in
      guard let index = characters.indices.dropLast(2).last(where: { index in
        characters[index] == "è" && ["l", "t"].contains(characters[index + 1]) && characters[index + 2] == "e"
      }) else {
        return false
      }
      characters[index] = "e"
      characters.insert(characters[index + 1], at: index + 1)
      return true
    }
  }

  private static let traditionallyOpenE: Set<String> = [
    "acheter", "racheter", "bégueter", "corseter", "crocheter", "fileter", "fureter", "haleter",
    "celer", "déceler", "receler", "ciseler", "démanteler", "écarteler", "geler", "congeler", "décongeler",
    "dégeler", "regeler", "surgeler", "harceler", "marteler", "modeler", "remodeler", "peler", "agneler"
  ]

  // The rectifications write the futur and conditionnel of céder's kind with the è of its
  // présent: je cèderai, ils règleraient. A verb whose présent has no è (créer, réserver) is not
  // of that kind.
  private static func withGraveInFuturStem(_ conjugation: String, verb: Verb, tense: Tense) -> String? {
    switch tense {
    case .futurSimple, .conditionnelPrésent:
      break
    default:
      return nil
    }
    guard
      conjugation.contains("é"),
      let présent = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .indicatifPrésent(.thirdSingular), extraLetters: verb.extraLetters),
      présent.lowercased().contains("è")
    else {
      return nil
    }
    return rewritingEachWord(of: conjugation) { characters in
      let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y", "é", "è", "ê", "â", "î", "ô", "û", "œ"]
      for index in characters.indices.reversed() where characters[index] == "é" {
        var next = index + 1
        while next < characters.count, !vowels.contains(characters[next]) {
          next += 1
        }
        if next > index + 1, next + 1 < characters.count, characters[next] == "e", characters[next + 1] == "r" {
          characters[index] = "è"
          return true
        }
      }
      return false
    }
  }

  // Single-verb rectifications: sursoir's futur (the Académie already wrote j'assoirai), the
  // participles absout and dissout, interpeler conjugated as appeler is, and argüer.
  private static func rectifiedSpelling(_ conjugation: String, verb: Verb, tense: Tense) -> String? {
    switch verb.infinitif {
    case "surseoir":
      return conjugation.contains("surseoi") ? conjugation.replacingOccurrences(of: "surseoi", with: "sursoi") : nil
    case "absoudre", "dissoudre":
      let words = conjugation.split(separator: " ").map { word in
        word.hasSuffix("sous") ? word.dropLast() + "t" : word
      }
      return words.joined(separator: " ")
    case "interpeller":
      guard
        conjugation.contains("interpell"),
        let appeler = Conjugator.conjugatedString(infinitif: "appeler", tense: tense, extraLetters: nil, pronounGender: .masculine),
        !appeler.lowercased().contains("ll")
      else {
        return nil
      }
      return conjugation.replacingOccurrences(of: "interpell", with: "interpel")
    case "arguer":
      return conjugation.replacingOccurrences(of: "argu", with: "argü")
    default:
      return nil
    }
  }

  // Doublets that Larousse lists beside the conjugator's form. Vouloir's veuillons and
  // veuillions are formal; the Académie's ninth edition writes il éclôt and il enclôt, as il
  // clôt, where earlier editions wrote éclot.
  private static func doublet(_ conjugation: String, infinitif: String, tense: Tense) -> String? {
    switch (infinitif, tense) {
    case ("vouloir", .impératif(.firstPlural)), ("vouloir", .subjonctifPrésent(.firstPlural)), ("vouloir", .subjonctifPrésent(.secondPlural)):
      return conjugation.replacingOccurrences(of: "voul", with: "veuill")
    case ("éclore", .indicatifPrésent(.thirdSingular)), ("enclore", .indicatifPrésent(.thirdSingular)),
      ("déclore", .indicatifPrésent(.thirdSingular)), ("forclore", .indicatifPrésent(.thirdSingular)):
      return conjugation.hasSuffix("ot") ? String(conjugation.dropLast(2)) + "ôt" : nil
    default:
      return nil
    }
  }

  /// Être verbs whose compound tenses the quiz also accepts with avoir.
  static let avoirAlsoAccepted: Set<String> = ["passer"]

  // Passer takes avoir with a direct object (j'ai passé un examen), its commonest use, and the
  // quiz gives no context to rule one out. The participle does not agree with avoir.
  private static func withAvoir(_ conjugation: String, verb: Verb, tense: Tense) -> String? {
    guard avoirAlsoAccepted.contains(verb.infinitif), !verb.isReflexive, tense.isCompound, let personNumber = tense.personNumber,
      let participle = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .participePassé, extraLetters: verb.extraLetters, pronounGender: .masculine)?
        .components(separatedBy: Tense.alternateConjugationSeparator).first else {
      return nil
    }
    return tense.conjugatedAuxiliary(personNumber: personNumber, auxiliary: .avoir).lowercased() + " " + participle.lowercased()
  }

  private static func rewritingEachWord(of conjugation: String, _ rewrite: (inout [Character]) -> Bool) -> String? {
    var changed = false
    let words = conjugation.split(separator: " ", omittingEmptySubsequences: false).map { word -> String in
      var characters = Array(word)
      if rewrite(&characters) {
        changed = true
      }
      return String(characters)
    }
    return changed ? words.joined(separator: " ") : nil
  }
}
