//
//  Conjugator.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/2/21.
//

import Foundation

enum Conjugator {
  static func conjugatedString(infinitif: String, tense: Tense, extraLetters: String?, pronounGender: PronounGender? = nil) -> String? {
    switch conjugate(infinitif: infinitif, tense: tense, extraLetters: extraLetters, pronounGender: pronounGender) {
    case .success(let value):
      return value
    case .failure:
      return nil
    }
  }

  static func conjugate(infinitif: String, tense: Tense, extraLetters: String?, pronounGender: PronounGender? = nil) -> Result<String, ConjugatorError> {
    guard infinitif.count >= Verb.minVerbLength else {
      return .failure(.verbTooShort)
    }

    guard Verb.endingIsValid(infinitif: infinitif) else {
      return .failure(.infinitifEndingInvalid)
    }

    let infinitifWithPossibleExtraLetters: String
    if let extraLetters = extraLetters {
      infinitifWithPossibleExtraLetters = infinitif + " " + extraLetters
    } else {
      infinitifWithPossibleExtraLetters = infinitif
    }

    guard let verb = Verb.verbs[infinitifWithPossibleExtraLetters] else {
      return .failure(.verbNotRecognized)
    }

    guard let model = VerbModel.models[verb.model] else {
      return .failure(.verbModelNotRecognized)
    }

    var stems: [String] = [] // Payer and pouvoir have alternate stems, so this needs to be an array.
    var isConjugatingPasséSimple = false
    var isConjugatingSubjonctifImparfait = false
    var isConjugatingImpératif = false
    var impératifPersonNumber: PersonNumber = .secondSingular
    var passéSimplePersonNumber: PersonNumber = .secondSingular

    switch tense {
    case .indicatifPrésent(let personNumber):
      stems.append(verb.infinitifStem)
      appendAdditiveAlternateStem(to: &stems, from: model, matching: [.indicatifPrésent(personNumber)])

    case .participePassé, .passéComposé, .plusQueParfait, .passéAntérieur, .passéSurcomposé, .futurAntérieur, .conditionnelPassé, .subjonctifPassé, .subjonctifPlusQueParfait:
      stems.append(verb.infinitifStem)
      if appendAdditiveAlternateStem(to: &stems, from: model, matching: [.participePassé]) {
        if stems[1].hasSuffix(Tense.irregularEndingMarker) {
          stems[1] = String(stems[1].dropLast())
        } else {
          stems[1] = stems[1] + model.participeEndingRecursive
        }
      }

    case .participePrésent:
        stems.append(nousPrésentStem(infinitif: infinitif, extraLetters: extraLetters))

    case .imparfait:
      let alternatives = nousPrésentStem(infinitif: infinitif, extraLetters: extraLetters).components(separatedBy: Tense.alternateConjugationSeparator)
      alternatives.forEach {
        stems.append($0)
      }

    case .passéSimple(let personNumber):
      isConjugatingPasséSimple = true
      passéSimplePersonNumber = personNumber
      stems.append(verb.infinitifStem)

    case .subjonctifImparfait(let personNumber):
      isConjugatingSubjonctifImparfait = true
      passéSimplePersonNumber = personNumber
      stems.append(verb.infinitifStem)

    case .subjonctifPrésent(let personNumber):
      stems.append(verb.infinitifStem)
      let subjonctifPersonNumber: PersonNumber
      switch personNumber {
      case .firstSingular, .secondSingular, .thirdSingular, .thirdPlural:
        subjonctifPersonNumber = .thirdPlural
      case .firstPlural, .secondPlural:
        subjonctifPersonNumber = .firstPlural
      }
      appendAdditiveAlternateStem(to: &stems, from: model, matching: [.subjonctifPrésent(subjonctifPersonNumber)])

    case .futurSimple, .conditionnelPrésent, .radicalFutur:
      stems = model.futurStemsRecursive(infinitif: infinitif)

    case .impératif(let personNumber):
      if !personNumber.isValidForImperatif {
        return .failure(.defectiveForPersonNumber(personNumber))
      }
      impératifPersonNumber = personNumber
      stems.append(verb.infinitifStem)
      isConjugatingImpératif = true
      appendAdditiveAlternateStem(to: &stems, from: model, matching: [.indicatifPrésent(personNumber), .impératif(personNumber)])

    case .impératifPassé(let personNumber):
      if !personNumber.isValidForImperatif {
        return .failure(.defectiveForPersonNumber(personNumber))
      }
      stems.append(verb.infinitifStem)
    }

    let isUsingTenseThatUsesPasséSimpleStem = isConjugatingPasséSimple || isConjugatingSubjonctifImparfait

    if let stemAlterations = model.stemAlterationsRecursive {
      for alteration in stemAlterations {
        if
          (alteration.appliesTo.contains(tense) ||
          (isUsingTenseThatUsesPasséSimpleStem && alteration.appliesTo.contains(.passéSimple(passéSimplePersonNumber))) ||
          (isConjugatingImpératif && alteration.appliesTo.contains(.indicatifPrésent(impératifPersonNumber))) ||
            (tense.isCompound && alteration.appliesTo.contains(.participePassé))) && tense != .radicalFutur && !alteration.isAdditive
        {
          stems[0].modifyStem(alteration: alteration)
        }
      }
    }

    switch tense {
    case .indicatifPrésent(let personNumber):
      return .success(composedConjugation(stems: stems, ending: model.indicatifPrésentGroupRecursive.présentEndingForPersonNumber(personNumber)))
    case .passéSimple(let personNumber):
      var ending = model.passéSimpleGroupRecursive.passéSimpleEndingForPersonNumber(personNumber)
      for i in 0 ..< stems.count {
        moveCircumflexIfNeeded(stem: &stems[i], ending: &ending)
      }
      return .success(composedConjugation(stems: stems, ending: ending))
    case .subjonctifImparfait(let personNumber):
      var ending = model.passéSimpleGroupRecursive.subjonctifImparfaitEndingForPersonNumber(personNumber)
      for i in 0 ..< stems.count {
        moveCircumflexIfNeeded(stem: &stems[i], ending: &ending)
      }
      return .success(composedConjugation(stems: stems, ending: ending))
    case .imparfait(let personNumber):
      return .success(composedConjugation(stems: stems, ending: Imparfait.endingForPersonNumber(personNumber)))
    case .subjonctifPrésent(let personNumber):
      return .success(composedConjugation(stems: stems, ending: model.subjonctifPrésentGroupRecursive.endingForPersonNumber(personNumber)))
    case .futurSimple(let personNumber):
      return .success(composedConjugation(stems: stems, ending: FuturSimple.endingForPersonNumber(personNumber)))
    case .conditionnelPrésent(let personNumber):
      return .success(composedConjugation(stems: stems, ending: ConditionnelPrésent.endingForPersonNumber(personNumber)))
    case .participePassé:
      if stems[0].hasSuffix(Tense.irregularEndingMarker) {
        stems[0] = String(stems[0].dropLast())
      } else {
        stems[0] = stems[0] + model.participeEndingRecursive
      }
      return .success(composedConjugation(stems: stems, ending: ""))
    case .participePrésent:
      return .success(stems[0] + Tense.participePrésentEnding)
    case .radicalFutur:
      return .success(composedConjugation(stems: stems, ending: ""))
    case .impératif(let personNumber):
      return .success(composedConjugation(stems: stems, ending: model.indicatifPrésentGroupRecursive.impératifEndingForPersonNumber(personNumber)))
    case .passéComposé(let personNumber), .plusQueParfait(let personNumber), .passéAntérieur(let personNumber), .passéSurcomposé(let personNumber), .futurAntérieur(let personNumber), .conditionnelPassé(let personNumber), .subjonctifPassé(let personNumber), .subjonctifPlusQueParfait(let personNumber), .impératifPassé(let personNumber):
      if stems[0].suffix(1) == Tense.irregularEndingMarker {
        stems[0] = String(stems[0].dropLast())
      }
      let conjugationWithoutAgreement = tense.conjugatedAuxiliary(personNumber: personNumber, auxiliary: verb.auxiliary) + " " + stems[0] + model.participeEndingRecursive
      if verb.isReflexive || verb.auxiliary == .être {
        let agreementEnding = (pronounGender ?? Current.settings.pronounGender).participePasséEndingForPersonNumber(personNumber)
        return .success(conjugationWithoutAgreement + agreementEnding)
      } else {
        return .success(conjugationWithoutAgreement)
      }
    }
  }

  // Finds the first additive stem alteration that applies to any of `tenses` and, if found,
  // appends an alternate stem (a copy of stems[0] with the alteration applied). Returns whether
  // an alternate stem was appended. Callers must have already populated stems[0].
  @discardableResult
  static func appendAdditiveAlternateStem(to stems: inout [String], from model: VerbModel, matching tenses: [Tense]) -> Bool {
    guard let stemAlterations = model.stemAlterationsRecursive else {
      return false
    }
    for alteration in stemAlterations where alteration.isAdditive && tenses.contains(where: { alteration.appliesTo.contains($0) }) {
      stems.append(stems[0])
      stems[1].modifyStem(alteration: alteration)
      return true
    }
    return false
  }

  static func composedConjugation(stems: [String], ending: String) -> String {
    stems
      .map { stem in
        if stem.hasSuffix(Tense.irregularEndingMarker) {
          return String(stem.dropLast())
        } else {
          return stem + ending
        }
      }
      .joined(separator: Tense.alternateConjugationSeparator)
  }

  static let circumflexedVowels: [Character: Character] = ["a": "â", "e": "ê", "i": "î", "o": "ô", "u": "û", "A": "Â", "E": "Ê", "I": "Î", "O": "Ô", "U": "Û"]

  static func moveCircumflexIfNeeded(stem: inout String, ending: inout String) {
    guard ending.first == "^" else {
      return
    }

    ending = String(ending.dropFirst())
    guard let stemLast = stem.last else {
      return
    }
    if let circumflexed = circumflexedVowels[stemLast] {
      stem = String(stem.dropLast()) + String(circumflexed)
    }
  }

  static func nousPrésentStem(infinitif: String, extraLetters: String? = nil) -> String {
    guard let value = Conjugator.conjugatedString(infinitif: infinitif, tense: .indicatifPrésent(.firstPlural), extraLetters: extraLetters) else {
      // Unreachable with today's data, but a future data typo shouldn't crash a user
      // mid-conjugation. Assert for the debug signal and degrade to an empty stem.
      assertionFailure("Could not conjugate nous indicatifPrésent for \(infinitif).")
      return ""
    }
    let ons = IndicatifPrésentGroup.s.présentEndingForPersonNumber(.firstPlural)
    let ONS = ons.uppercased()
    // Strip only the *trailing* -ons ending, not every occurrence: a global
    // replace would mangle any verb whose stem contains an internal "ons"
    // (consommer, conseiller, considérer, …). The nous form can carry two
    // alternates joined by the separator (e.g. asseoir → "asseYons/assOYons"), so
    // strip the trailing ending from each alternate independently.
    return value
      .components(separatedBy: Tense.alternateConjugationSeparator)
      .map { alternate in
        var stem = alternate.replacingOccurrences(of: Tense.irregularEndingMarker, with: "")
        if stem.hasSuffix(ons) {
          stem = String(stem.dropLast(ons.count))
        } else if stem.hasSuffix(ONS) {
          stem = String(stem.dropLast(ONS.count))
        }
        return stem
      }
      .joined(separator: Tense.alternateConjugationSeparator)
  }
}
