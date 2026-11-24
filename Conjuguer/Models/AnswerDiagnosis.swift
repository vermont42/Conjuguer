//
//  AnswerDiagnosis.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// Why a wrong quiz answer is wrong, in the cases where the Conjugator can say so for certain.
/// Every case is an exact construction from the verb's own tables, never a guess at what the
/// learner meant, because a wrong diagnosis is worse than none. An answer that fits no case gets
/// none.
enum AnswerDiagnosis: Equatable {
  /// suis allé for suis allée.
  case agreement(isFeminine: Bool, isPlural: Bool)
  /// ai mangée for ai mangé.
  case agreementWithAvoir
  /// ai allé for suis allé, or est mangé for a mangé.
  case wrongAuxiliary(infinitif: String, expected: Auxiliary)
  /// m'ai lavé for me suis lavé.
  case pronominalAuxiliary
  /// ai monté for suis monté. Monter takes avoir with a direct object, which the quiz gives none.
  case auxiliaryWithoutObject(infinitif: String)
  /// allée alone for suis allée.
  case missingAuxiliary
  /// The asked cell of the infinitive's other entry: sortir (obtain) for sortir (exit).
  case otherEntry(given: String, asked: String)
  /// nous mangons, nous lancons, j'appele, je pese, je céde, j'employe: the verb conjugated as
  /// parler, without its model's spelling change.
  case spellingChange(infinitif: String, SpellingChange)
  /// je venirai, j'envoyerai, je voirai: the futur built on the infinitive.
  case futurStem(infinitif: String)
  /// vous faisez, vous disez.
  case vousTes(infinitif: String)
  /// finissons for vous finissez.
  case otherPerson(pronouns: [String])
  /// finissait for the passé simple. The pronouns are named only when the asked person is not
  /// among the tense's matching cells.
  case otherTense(Tense, pronouns: [String])
  /// prendu, ils prendent: the verb conjugated as the regular model of its infinitive's ending.
  case regularForm(infinitif: String, exemplar: String)
  /// ils finent, nous rendâmes, metté: the verb conjugated as another group's regular model.
  case otherGroup(infinitif: String, exemplar: String)

  enum SpellingChange: Equatable {
    case cedilla
    case softG
    case doubledConsonant(String)
    case graveForE
    case graveForEAcute
    case yToI
  }

  var line: String {
    switch self {
    case let .agreement(isFeminine, isPlural):
      return L.Diagnosis.agreement(Self.agreementName(isFeminine: isFeminine, isPlural: isPlural))
    case .agreementWithAvoir:
      return L.Diagnosis.agreementWithAvoir
    case let .wrongAuxiliary(infinitif, expected):
      let given: Auxiliary = expected == .être ? .avoir : .être
      return L.Diagnosis.wrongAuxiliary(infinitif.capitalizedFirstLetter, expected.verb, given.verb)
    case .pronominalAuxiliary:
      return L.Diagnosis.pronominalAuxiliary
    case .auxiliaryWithoutObject(let infinitif):
      return L.Diagnosis.auxiliaryWithoutObject(infinitif)
    case .missingAuxiliary:
      return L.Diagnosis.missingAuxiliary
    case let .otherEntry(given, asked):
      return L.Diagnosis.otherEntry(given, asked)
    case let .spellingChange(infinitif, change):
      switch change {
      case .cedilla:
        return L.Diagnosis.cedilla(infinitif)
      case .softG:
        return L.Diagnosis.softG(infinitif)
      case .doubledConsonant(let letter):
        return L.Diagnosis.doubledConsonant(infinitif, letter)
      case .graveForE:
        return L.Diagnosis.graveForE(infinitif)
      case .graveForEAcute:
        return L.Diagnosis.graveForEAcute(infinitif)
      case .yToI:
        return L.Diagnosis.yToI(infinitif)
      }
    case .futurStem(let infinitif):
      return L.Diagnosis.futurStem(infinitif.capitalizedFirstLetter)
    case .vousTes(let infinitif):
      return L.Diagnosis.vousTes(infinitif)
    case .otherPerson(let pronouns):
      return L.Diagnosis.otherPerson(ListFormatter.localizedString(byJoining: pronouns))
    case let .otherTense(tense, pronouns):
      let name = tense.titleCaseName.lowercased()
      let isElided = name.first.map { "aeiouéè".contains($0) } ?? false
      guard !pronouns.isEmpty else {
        return isElided ? L.Diagnosis.otherTenseElided(name) : L.Diagnosis.otherTense(name)
      }
      let persons = ListFormatter.localizedString(byJoining: pronouns)
      return isElided ? L.Diagnosis.otherTensePersonsElided(name, persons) : L.Diagnosis.otherTensePersons(name, persons)
    case let .regularForm(infinitif, exemplar):
      return L.Diagnosis.regularForm(exemplar, infinitif.capitalizedFirstLetter)
    case let .otherGroup(infinitif, exemplar):
      return L.Diagnosis.otherGroup(exemplar, infinitif)
    }
  }

  private static func agreementName(isFeminine: Bool, isPlural: Bool) -> String {
    switch (isFeminine, isPlural) {
    case (true, false):
      return L.Diagnosis.feminine
    case (false, false):
      return L.Diagnosis.masculine
    case (true, true):
      return L.Diagnosis.femininePlural
    case (false, true):
      return L.Diagnosis.masculinePlural
    }
  }

  /// The diagnosis of a wrong answer to `tense` of `verb`, or nil when it is right or nothing
  /// certain can be said. The checks run from the most specific explanation to the least and
  /// stop at the first that fits, since one answer can fit several: ai allé is both a wrong
  /// auxiliary and, for a verb with two entries, perhaps another entry's cell, and the first says
  /// more about the learner's error.
  static func diagnose(proposedAnswer: String, correctAnswers: String, verb: Verb, tense: Tense, pronounGender: PronounGender) -> AnswerDiagnosis? {
    guard ConjugationResult.grade(proposedAnswer: proposedAnswer, correctAnswers: correctAnswers, verb: verb, tense: tense).result == .noMatch else {
      return nil
    }
    let candidates = Set(AnswerSpelling.candidates(for: proposedAnswer, tense: tense, isReflexive: verb.isReflexive))
    guard !candidates.isEmpty else {
      return nil
    }
    let diagnoser = AnswerDiagnoser(verb: verb, tense: tense, correctAnswers: correctAnswers, candidates: candidates, pronounGender: pronounGender)
    let checks: [(AnswerDiagnoser) -> () -> AnswerDiagnosis?] = [
      AnswerDiagnoser.agreement,
      AnswerDiagnoser.agreementWithAvoir,
      AnswerDiagnoser.wrongAuxiliary,
      AnswerDiagnoser.missingAuxiliary,
      AnswerDiagnoser.otherEntry,
      AnswerDiagnoser.spellingChange,
      AnswerDiagnoser.futurStem,
      AnswerDiagnoser.vousTes,
      AnswerDiagnoser.otherCell,
      AnswerDiagnoser.regularForm,
      AnswerDiagnoser.otherGroup
    ]
    for check in checks {
      if let diagnosis = check(diagnoser)() {
        return diagnosis
      }
    }
    return nil
  }
}

/// The checks behind `AnswerDiagnosis.diagnose`. Each builds the wrong conjugations a particular
/// error would produce and asks whether the learner's answer is one of them.
private struct AnswerDiagnoser {
  let verb: Verb
  let tense: Tense
  let correctAnswers: [String]
  let candidates: Set<String>
  let pronounGender: PronounGender

  private static let parlerModelID = "1-1"
  private static let finirModelID = "2-1"
  private static let rendreModelID = "5-1A"
  private static let regularModelIDs = [parlerModelID, finirModelID, rendreModelID]

  /// Être verbs that take avoir with a direct object (j'ai monté la valise), which the quiz gives
  /// them none of.
  private static let transitiveWithAvoir: Set<String> = [
    "descendre", "entrer", "monter", "redescendre", "remonter", "rentrer", "ressortir", "retourner", "sortir", "tomber"
  ]

  /// Verbs whose other auxiliary is also standard in some sense or register (j'ai demeuré à Paris,
  /// il est accouru, le livre est paru), so that no line about the auxiliary is certain.
  private static let eitherAuxiliary: Set<String> = [
    "accourir", "apparaître", "convenir", "déchoir", "demeurer", "disconvenir", "disparaître", "échapper", "expirer", "paraître",
    "réapparaître", "réchapper", "repartir", "ressusciter", "trépasser", "vieillir"
  ]

  init(verb: Verb, tense: Tense, correctAnswers: String, candidates: Set<String>, pronounGender: PronounGender) {
    self.verb = verb
    self.tense = tense
    self.correctAnswers = correctAnswers.components(separatedBy: Tense.alternateConjugationSeparator).map { $0.lowercased() }
    self.candidates = candidates
    self.pronounGender = pronounGender
  }

  private var takesÊtre: Bool {
    verb.auxiliary == .être || verb.isReflexive
  }

  private var acceptsAvoir: Bool {
    !verb.isReflexive && StandardVariants.avoirAlsoAccepted.contains(verb.infinitif)
  }

  private func isAnswer(among wrongConjugations: some Sequence<String>) -> Bool {
    let spellings = Set(wrongConjugations.map { $0.lowercased() }).subtracting(correctAnswers)
    return !candidates.isDisjoint(with: spellings)
  }

  private static func alternates(of conjugation: String?) -> [String] {
    conjugation?.lowercased().components(separatedBy: Tense.alternateConjugationSeparator) ?? []
  }

  /// The participe passé as it stands alone and agreed every way: allé, allée, allés, allées.
  private var participles: [String] {
    let bare = Self.alternates(of: Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .participePassé, extraLetters: verb.extraLetters, pronounGender: .masculine))
    return bare.flatMap { [$0] + ConjugationMap.agreedForms(ofParticiple: $0) }
  }

  private var agreedParticiples: [String] {
    let bare = Self.alternates(of: Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .participePassé, extraLetters: verb.extraLetters, pronounGender: .masculine))
    return bare.flatMap { ConjugationMap.agreedForms(ofParticiple: $0) }
  }

  private func compound(with auxiliary: Auxiliary, participles: [String]) -> [String] {
    guard tense.isCompound, let personNumber = tense.personNumber else {
      return []
    }
    let conjugatedAuxiliary = tense.conjugatedAuxiliary(personNumber: personNumber, auxiliary: auxiliary).lowercased()
    return participles.map { conjugatedAuxiliary + " " + $0 }
  }

  func agreement() -> AnswerDiagnosis? {
    guard takesÊtre, let personNumber = tense.personNumber, isAnswer(among: compound(with: .être, participles: participles)) else {
      return nil
    }
    let isPlural = [.firstPlural, .secondPlural, .thirdPlural].contains(personNumber)
    return .agreement(isFeminine: pronounGender.isFeminine(personNumber), isPlural: isPlural)
  }

  func agreementWithAvoir() -> AnswerDiagnosis? {
    guard !takesÊtre || acceptsAvoir, isAnswer(among: compound(with: .avoir, participles: agreedParticiples)) else {
      return nil
    }
    return .agreementWithAvoir
  }

  func wrongAuxiliary() -> AnswerDiagnosis? {
    guard !Self.eitherAuxiliary.contains(verb.infinitif), !acceptsAvoir else {
      return nil
    }
    let given: Auxiliary = takesÊtre ? .avoir : .être
    guard isAnswer(among: compound(with: given, participles: participles)) else {
      return nil
    }
    if verb.isReflexive {
      return .pronominalAuxiliary
    }
    if verb.auxiliary == .être, Self.transitiveWithAvoir.contains(verb.infinitif) {
      return .auxiliaryWithoutObject(infinitif: verb.infinitif)
    }
    return .wrongAuxiliary(infinitif: verb.infinitif, expected: verb.auxiliary)
  }

  func missingAuxiliary() -> AnswerDiagnosis? {
    guard tense.isCompound, isAnswer(among: participles) else {
      return nil
    }
    return .missingAuxiliary
  }

  func otherEntry() -> AnswerDiagnosis? {
    let others = Verb.verbs.values
      .filter { $0.infinitif == verb.infinitif && $0.id != verb.id }
      .sorted { $0.id < $1.id }
    for other in others {
      let isOthersCell = candidates.contains { candidate in
        !correctAnswers.contains(candidate) && other.conjugations(matching: candidate).contains { $0.tense == tense }
      }
      if isOthersCell {
        return .otherEntry(given: other.infinitifWithPossibleExtraLetters, asked: verb.infinitifWithPossibleExtraLetters)
      }
    }
    return nil
  }

  /// The asked cell as `modelID` conjugates the verb, in each agreement a compound tense allows.
  private func cell(asModel modelID: String) -> [String] {
    guard let model = VerbModel.models[modelID] else {
      return []
    }
    let genders: [PronounGender] = tense.isCompound ? [.masculine, .feminine] : [pronounGender]
    return genders.flatMap { gender in
      guard case .success(let conjugation) = Conjugator.conjugate(verb: verb, model: model, tense: tense, pronounGender: gender) else {
        return [String]()
      }
      return Self.alternates(of: conjugation)
    }
  }

  /// A first-group verb whose model changes its spelling (manger, lancer, appeler, céder), conjugated
  /// as parler. The change is read from where parler's form and the right one differ, and an answer
  /// whose difference is none of the five changes gets no line.
  func spellingChange() -> AnswerDiagnosis? {
    guard verb.model != Self.parlerModelID, PracticeItem.patternBase(of: verb) == Self.parlerModelID else {
      return nil
    }
    for base in cell(asModel: Self.parlerModelID) where candidates.contains(base) && !correctAnswers.contains(base) {
      for correct in correctAnswers {
        if let change = Self.spellingChange(from: base, to: correct) {
          return .spellingChange(infinitif: verb.infinitif, change)
        }
      }
    }
    return nil
  }

  private static func spellingChange(from base: String, to correct: String) -> AnswerDiagnosis.SpellingChange? {
    let base = Array(base)
    let correct = Array(correct)
    var prefixCount = 0
    while prefixCount < base.count, prefixCount < correct.count, base[prefixCount] == correct[prefixCount] {
      prefixCount += 1
    }
    var suffixCount = 0
    while suffixCount < base.count - prefixCount, suffixCount < correct.count - prefixCount,
      base[base.count - 1 - suffixCount] == correct[correct.count - 1 - suffixCount] {
      suffixCount += 1
    }
    let removed = String(base[prefixCount ..< base.count - suffixCount])
    let added = String(correct[prefixCount ..< correct.count - suffixCount])
    let before = prefixCount > 0 ? String(correct[prefixCount - 1]) : ""
    switch (removed, added) {
    case ("c", "ç"):
      return .cedilla
    case ("", "e") where before == "g":
      return .softG
    case ("", "l") where before == "l", ("", "t") where before == "t":
      return .doubledConsonant(added)
    case ("e", "è"):
      return .graveForE
    case ("é", "è"):
      return .graveForEAcute
    case ("y", "i"):
      return .yToI
    default:
      return nil
    }
  }

  /// The futur or conditionnel built on the whole infinitive, as a regular verb builds it.
  func futurStem() -> AnswerDiagnosis? {
    let ending: String
    switch tense {
    case .futurSimple(let personNumber):
      ending = FuturSimple.endingForPersonNumber(personNumber)
    case .conditionnelPrésent(let personNumber):
      ending = ConditionnelPrésent.endingForPersonNumber(personNumber)
    default:
      return nil
    }
    let stem = verb.infinitif.hasSuffix("e") ? String(verb.infinitif.dropLast()) : verb.infinitif
    guard isAnswer(among: [stem + ending]) else {
      return nil
    }
    return .futurStem(infinitif: verb.infinitif)
  }

  /// Dire's and faire's families end in -tes with vous, where every other verb builds on the nous
  /// stem: vous disez, by analogy with nous disons.
  func vousTes() -> AnswerDiagnosis? {
    guard tense == .indicatifPrésent(.secondPlural), correctAnswers.contains(where: { $0.hasSuffix("tes") }) else {
      return nil
    }
    let stems = Self.alternates(of: Conjugator.nousPrésentStem(infinitif: verb.infinitif, extraLetters: verb.extraLetters))
    guard isAnswer(among: stems.map { $0 + "ez" }) else {
      return nil
    }
    return .vousTes(infinitif: verb.infinitif)
  }

  /// Another cell of the verb. Another person of the asked tense is named first, since it is the
  /// nearer error.
  func otherCell() -> AnswerDiagnosis? {
    let askedName = tense.titleCaseName
    let matches = candidates
      .filter { !correctAnswers.contains($0) }
      .flatMap { verb.conjugations(matching: $0) }
      .filter { $0.tense != tense }
    let sameTense = matches.filter { $0.tense.titleCaseName == askedName }
    if !sameTense.isEmpty {
      return .otherPerson(pronouns: pronouns(of: sameTense))
    }
    let ordered = TenseTable.allTenses.filter { tense in matches.contains { $0.tense == tense } }
    guard let first = ordered.first else {
      return nil
    }
    let firstName = first.titleCaseName
    let persons = matches.filter { $0.tense.titleCaseName == firstName }
    let isAskedPersonAmong = persons.contains { $0.tense.personNumber == tense.personNumber }
    return .otherTense(first, pronouns: isAskedPersonAmong ? [] : pronouns(of: persons))
  }

  /// Distinct, in the conjugation table's order.
  private func pronouns(of matches: [ConjugationMatch]) -> [String] {
    let found = Set(matches.compactMap(\.tense.personNumber))
    return PersonNumber.allCases.filter { found.contains($0) }.map(pronoun(of:))
  }

  private func pronoun(of personNumber: PersonNumber) -> String {
    switch personNumber {
    case .firstSingular:
      return "je"
    case .secondSingular:
      return "tu"
    case .thirdSingular:
      return pronounGender.thirdSingular
    case .firstPlural:
      return "nous"
    case .secondPlural:
      return "vous"
    case .thirdPlural:
      return pronounGender.thirdPlural
    }
  }

  /// The regular model of the infinitive's ending: parler's for -er, finir's for -ir, and
  /// rendre's for -re. An -oir verb has none.
  private var endingModelID: String? {
    if verb.infinitif.hasSuffix("er") {
      return Self.parlerModelID
    }
    if verb.infinitif.hasSuffix("oir") {
      return nil
    }
    if verb.infinitif.hasSuffix("ir") || verb.infinitif.hasSuffix("ïr") {
      return Self.finirModelID
    }
    if verb.infinitif.hasSuffix("re") {
      return Self.rendreModelID
    }
    return nil
  }

  /// An irregular verb conjugated as the regular model of its ending: prendu, ils prendent, ouvri.
  func regularForm() -> AnswerDiagnosis? {
    guard PracticeItem.patternBase(of: verb) == nil, let modelID = endingModelID, verb.model != modelID,
      isAnswer(among: cell(asModel: modelID)), let exemplar = VerbModel.models[modelID]?.exemplar else {
      return nil
    }
    return .regularForm(infinitif: verb.infinitif, exemplar: exemplar)
  }

  /// A verb conjugated as the regular model of another group: ils finent, nous rendâmes, metté.
  func otherGroup() -> AnswerDiagnosis? {
    let own = [endingModelID, PracticeItem.patternBase(of: verb)].compactMap { $0 }
    for modelID in Self.regularModelIDs where !own.contains(modelID) && verb.model != modelID {
      if isAnswer(among: cell(asModel: modelID)), let exemplar = VerbModel.models[modelID]?.exemplar {
        return .otherGroup(infinitif: verb.infinitif, exemplar: exemplar)
      }
    }
    return nil
  }
}

private extension String {
  var capitalizedFirstLetter: String {
    prefix(1).uppercased() + dropFirst()
  }
}
