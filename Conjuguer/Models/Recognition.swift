//
//  Recognition.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// Name the Conjugation: the quiz shows a conjugation, such as fûmes, and the learner types its
/// infinitive and chooses its tense and person. This is the direction a reader needs, and practice
/// develops in the direction practiced. Recognizing fûmes is not evidence of producing it, so an
/// answer moves nothing in the practice record (Josh, 2026-11-23).
extension QuizScope {
  static let recognition = QuizScope(verbs: nil, questionCount: Quiz.questionCount, source: .recognition, isRecognition: true)
}

/// One cell of one verb whose conjugation is a recognition question's prompt.
struct RecognitionCell: Hashable {
  /// A key of `Verb.verbs`, since a doubled infinitive's entries conjugate differently.
  let verbKey: String
  let tense: Tense

  var verb: Verb? {
    Verb.verbs[verbKey]
  }
}

/// The three parts of a recognition answer.
enum RecognitionPart: CaseIterable {
  case infinitive
  case tense
  case person
}

/// A learner's answer: a typed infinitive, a chosen tense, and, unless the tense is a participle,
/// a chosen person.
struct RecognitionAnswer: Equatable {
  let infinitif: String
  let slot: QuizTenseSlot
  let personNumber: PersonNumber?

  /// The cell the tense and person name, or nil while a personal tense lacks its person.
  var tense: Tense? {
    guard let constructor = slot.constructor else {
      return slot.cells.first
    }
    guard let personNumber, slot.persons.contains(personNumber) else {
      return nil
    }
    return constructor(personNumber)
  }

  /// "être · passé simple · nous", for the results and the correction.
  var summary: String {
    [AnswerSpelling.normalized(infinitif), slot.recognitionName, personNumber.map(RecognitionQuestion.personLabel)]
      .compactMap { $0 }
      .joined(separator: " · ")
  }
}

/// How a recognition answer fared: which parts are wrong, and whether any part was right, which
/// earns one more try at half points, as a slip does.
struct RecognitionGrade: Equatable {
  let wrongParts: Set<RecognitionPart>
  let hasRightPart: Bool

  var isCorrect: Bool {
    wrongParts.isEmpty
  }

  var earnsSecondAttempt: Bool {
    !isCorrect && hasRightPart
  }

  /// What to check, in the order the parts are read: "Check the tense and the person."
  var line: String {
    switch (wrongParts.contains(.infinitive), wrongParts.contains(.tense), wrongParts.contains(.person)) {
    case (true, false, false):
      return L.Recognition.checkInfinitive
    case (false, true, false):
      return L.Recognition.checkTense
    case (false, false, true):
      return L.Recognition.checkPerson
    case (true, true, false):
      return L.Recognition.checkInfinitiveAndTense
    case (true, false, true):
      return L.Recognition.checkInfinitiveAndPerson
    case (false, true, true):
      return L.Recognition.checkTenseAndPerson
    case (false, false, false), (true, true, true):
      return ""
    }
  }
}

/// A recognition question: the prompt, every cell of every verb that writes it, and the tenses the
/// learner chooses among.
///
/// A conjugation often belongs to several cells (parle is the présent and the subjonctif of je
/// and il, and the impératif of tu), or to two verbs (suis, être's and suivre's; vis, vivre's and
/// voir's). Every one is a right answer, since the prompt gives no context to choose between them,
/// and none is avoided, since deciding which cells a text can be is the skill being practiced.
/// Only cells of the offered tenses count, since the learner cannot choose any other.
struct RecognitionQuestion: Equatable {
  /// As the conjugator writes it, irregular letters in capitals, with a pronominal verb's
  /// reflexive pronoun as French writes it: me souviens, s'est souvenue, souviens-toi.
  let prompt: String
  let cells: [RecognitionCell]
  /// The level's tenses, in the verb page's order.
  let slots: [QuizTenseSlot]

  init(prompt: String, cells: [RecognitionCell], slots: [QuizTenseSlot]) {
    self.prompt = prompt
    self.cells = cells
    self.slots = slots
  }

  init(verb: Verb, tense: Tense, slots: [QuizTenseSlot], map: ConjugationMap = .bundled) {
    let prompt = Self.prompts(of: verb, tense: tense, pronounGender: verb.pronounGender).first ?? ""
    let ordered = Self.inPageOrder(slots)
    let asked = RecognitionCell(verbKey: verb.dictionaryKey, tense: tense)
    self.init(prompt: prompt, cells: Self.cells(writing: prompt, asked: asked, slots: ordered, map: map), slots: ordered)
  }

  static func inPageOrder(_ slots: [QuizTenseSlot]) -> [QuizTenseSlot] {
    func position(_ slot: QuizTenseSlot) -> Int {
      slot.cells.first.flatMap(TenseTable.allTenses.firstIndex) ?? .max
    }
    return slots.sorted { position($0) < position($1) }
  }

  /// The prompt of each alternate of a cell ("paie", "paye"). A pronominal verb takes its
  /// reflexive pronoun before the conjugation, or after an impératif's hyphen, but not before a
  /// participe passé, which a text writes bare. Its impératif passé, which no text writes, has
  /// none.
  static func prompts(of verb: Verb, tense: Tense, pronounGender: PronounGender) -> [String] {
    guard let conjugation = Conjugator.conjugatedString(
      infinitif: verb.infinitif,
      tense: tense,
      extraLetters: verb.extraLetters,
      pronounGender: verb.pronounGender(for: pronounGender)
    ) else {
      return []
    }
    let alternates = conjugation.components(separatedBy: Tense.alternateConjugationSeparator).filter { !$0.isEmpty }
    guard verb.isReflexive else {
      return alternates
    }
    switch tense {
    case .impératif(let personNumber):
      return alternates.map { $0 + (AnswerSpelling.impératifReflexiveSuffix(for: personNumber) ?? "") }
    case .impératifPassé:
      return []
    case .participePassé, .radicalFutur:
      return alternates
    case .participePrésent:
      return alternates.map { PersonNumber.thirdPersonReflexivePronoun(before: $0, hasAspiratedH: verb.hasAspiratedH) + $0 }
    default:
      guard let personNumber = tense.personNumber else {
        return alternates
      }
      return alternates.map { reflexivePronoun(personNumber, before: $0, hasAspiratedH: verb.hasAspiratedH) + $0 }
    }
  }

  private static func reflexivePronoun(_ personNumber: PersonNumber, before word: String, hasAspiratedH: Bool) -> String {
    let elides = PersonNumber.elides(before: word, hasAspiratedH: hasAspiratedH)
    switch personNumber {
    case .firstSingular:
      return elides ? "m'" : "me "
    case .secondSingular:
      return elides ? "t'" : "te "
    case .thirdSingular, .thirdPlural:
      return elides ? "s'" : "se "
    case .firstPlural:
      return "nous "
    case .secondPlural:
      return "vous "
    }
  }

  /// Every cell of the offered tenses, of every verb, that writes `prompt`, the asked verb's
  /// first. The conjugation map names the verbs to try, by each word of the prompt with any
  /// elided pronoun and impératif suffix taken off, and each is then matched cell by cell in both
  /// genders, so that est allée accepts aller's passé composé of il whatever the setting.
  static func cells(writing prompt: String, asked: RecognitionCell, slots: [QuizTenseSlot], map: ConjugationMap) -> [RecognitionCell] {
    let wanted = AnswerSpelling.normalized(prompt)
    var verbKeys = [asked.verbKey]
    for word in words(of: wanted) {
      for key in map.verbs(for: word) where !verbKeys.contains(key) {
        verbKeys.append(key)
      }
    }
    let lastWord = wanted.split(separator: " ").last.map(String.init) ?? ""
    var cells: [RecognitionCell] = []
    for key in verbKeys {
      guard let verb = Verb.verbs[key] else {
        continue
      }
      // A compound cell ends in the verb's participle, so a verb whose participle is not the
      // prompt's last word is spared conjugating its compound tenses in both genders.
      let endsInParticiple = participleForms(of: verb).contains(lastWord)
      for slot in slots {
        for tense in slot.cells where verb.hasCell(tense) && (endsInParticiple || !tense.isCompound) {
          let genders: [PronounGender] = tense.isCompound ? [.masculine, .feminine] : [.masculine]
          let writes = genders.contains { gender in
            prompts(of: verb, tense: tense, pronounGender: gender).contains { AnswerSpelling.normalized($0) == wanted }
          }
          if writes {
            cells.append(RecognitionCell(verbKey: key, tense: tense))
          }
        }
      }
    }
    if !cells.contains(asked) {
      cells.insert(asked, at: 0)
    }
    return cells
  }

  private static func participleForms(of verb: Verb) -> Set<String> {
    let participle = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .participePassé, extraLetters: verb.extraLetters, pronounGender: .masculine) ?? ""
    let alternates = participle.lowercased().components(separatedBy: Tense.alternateConjugationSeparator)
    return Set(alternates + alternates.flatMap(ConjugationMap.agreedForms))
  }

  private static func words(of prompt: String) -> [String] {
    prompt.split { $0 == " " || $0 == "-" }.map { word in
      for elided in ["m'", "t'", "s'"] where word.hasPrefix(elided) {
        return String(word.dropFirst(elided.count))
      }
      return String(word)
    }
  }

  /// The persons a tense's chips offer: none for a participle, three for the impératif.
  static func persons(of slot: QuizTenseSlot) -> [PersonNumber] {
    slot.constructor == nil ? [] : slot.persons
  }

  /// A person's chip: the subject pronouns, both genders of the third person.
  static func personLabel(_ personNumber: PersonNumber) -> String {
    switch personNumber {
    case .firstSingular:
      return "je"
    case .secondSingular:
      return "tu"
    case .thirdSingular:
      return "il/elle"
    case .firstPlural:
      return "nous"
    case .secondPlural:
      return "vous"
    case .thirdPlural:
      return "ils/elles"
    }
  }

  /// The infinitive as it is named, with a pronominal verb's se: se souvenir, s'absenter.
  static func infinitiveName(of verb: Verb) -> String {
    guard verb.isReflexive else {
      return verb.infinitif
    }
    return PersonNumber.thirdPersonReflexivePronoun(before: verb.infinitif, hasAspiratedH: verb.hasAspiratedH) + verb.infinitif
  }

  /// The spellings of a verb's infinitive that count as right: the infinitive, its 1990
  /// rectification (connaitre), and for a pronominal verb, each with or without its se.
  static func spellings(of verb: Verb) -> Set<String> {
    let infinitif = verb.infinitif.lowercased()
    var bare = [infinitif]
    if !circumflexKeepers.contains(infinitif) {
      let rectified = String(infinitif.map { $0 == "î" ? "i" : $0 == "û" ? "u" : $0 })
      if rectified != infinitif {
        bare.append(rectified)
      }
    }
    var spellings = Set(bare)
    if verb.isReflexive {
      for spelling in bare {
        spellings.insert(PersonNumber.thirdPersonReflexivePronoun(before: spelling, hasAspiratedH: verb.hasAspiratedH) + spelling)
      }
    }
    return spellings
  }

  // As `StandardVariants` reads the rectifications: croître keeps its circumflex, which tells it
  // from croire, and jeûner keeps it as jeûne does.
  private static let circumflexKeepers: Set<String> = ["croître", "jeûner"]

  static func spells(_ typed: String, _ verb: Verb) -> Bool {
    spellings(of: verb).contains(AnswerSpelling.normalized(typed))
  }

  /// Which parts of an answer are wrong, judged against the cells of the typed verb when it is
  /// one of them, and against every cell otherwise. A part is called wrong only when changing it
  /// alone, or with the other parts called wrong, can make the answer right, so a repair prompt
  /// never sends the learner to change something that was right.
  func grade(_ answer: RecognitionAnswer) -> RecognitionGrade {
    let ofInfinitive = cells.filter { cell in
      cell.verb.map { Self.spells(answer.infinitif, $0) } ?? false
    }
    let infinitiveIsRight = !ofInfinitive.isEmpty
    let candidates = infinitiveIsRight ? ofInfinitive : cells
    var wrong: Set<RecognitionPart> = infinitiveIsRight ? [] : [.infinitive]

    if let chosen = answer.tense, candidates.contains(where: { $0.tense == chosen }) {
      return RecognitionGrade(wrongParts: wrong, hasRightPart: true)
    }
    if candidates.contains(where: { QuizTenseSlot(tense: $0.tense) == answer.slot }) {
      wrong.insert(.person)
      return RecognitionGrade(wrongParts: wrong, hasRightPart: true)
    }
    wrong.insert(.tense)
    // A person is judged only between tenses that have persons. Between a participle and a
    // personal tense, the tense alone is wrong, and the person follows from it.
    let personIsRight = answer.personNumber.map { person in
      candidates.contains { $0.tense.personNumber == person }
    } ?? false
    if answer.personNumber != nil, !personIsRight, candidates.contains(where: { $0.tense.personNumber != nil }) {
      wrong.insert(.person)
    }
    return RecognitionGrade(wrongParts: wrong, hasRightPart: infinitiveIsRight || personIsRight)
  }

  /// The right answers as the correction lists them, one line per infinitive and tense, the
  /// persons together: "parler · indicatif présent · je, il/elle". A doubled infinitive's
  /// entries share their lines, since the learner types the infinitive alone.
  var answerLines: [String] {
    var lines: [(key: String, infinitive: String, slot: QuizTenseSlot, persons: [PersonNumber])] = []
    for cell in cells {
      guard let verb = cell.verb, let slot = QuizTenseSlot(tense: cell.tense) else {
        continue
      }
      let infinitive = Self.infinitiveName(of: verb)
      let key = "\(infinitive)|\(slot)"
      if let index = lines.firstIndex(where: { $0.key == key }) {
        if let person = cell.tense.personNumber, !lines[index].persons.contains(person) {
          lines[index].persons.append(person)
        }
      } else {
        lines.append((key, infinitive, slot, cell.tense.personNumber.map { [$0] } ?? []))
      }
    }
    return lines.map { line in
      let persons = PersonNumber.allCases.filter(line.persons.contains).map(Self.personLabel).joined(separator: ", ")
      return [line.infinitive, line.slot.recognitionName, persons.isEmpty ? nil : persons]
        .compactMap { $0 }
        .joined(separator: " · ")
    }
  }

  /// The right infinitive nearest a typed one, for marking the letters that differ.
  func nearestInfinitive(to typed: String) -> String {
    let typed = Array(AnswerSpelling.normalized(typed))
    let names = cells.compactMap(\.verb).map(Self.infinitiveName)
    return names.min { VerbSearch.editDistance(typed, Array($0)) < VerbSearch.editDistance(typed, Array($1)) } ?? ""
  }

  /// The infinitive's traditional spelling, when a right answer used the 1990 rectification, as
  /// connaitre for connaître. Nil when the answer is wrong or already spelled so.
  func preferredSpelling(of typed: String) -> String? {
    let normalized = AnswerSpelling.normalized(typed)
    guard let verb = cells.compactMap(\.verb).first(where: { Self.spells(typed, $0) }) else {
      return nil
    }
    let bare = verb.infinitif.lowercased()
    let named = Self.infinitiveName(of: verb).lowercased()
    guard normalized != bare, normalized != named else {
      return nil
    }
    let typedPronoun = verb.isReflexive && normalized.count > bare.count
    return typedPronoun ? Self.infinitiveName(of: verb) : verb.infinitif
  }
}

extension QuizTenseSlot {
  /// The tense as a recognition chip and answer name it: "passé simple", "participe passé".
  var recognitionName: String {
    cells.first?.titleCaseName.lowercased() ?? ""
  }
}

extension QuizQuestion {
  /// The question as a recognition question offering `slots`. A pronominal verb's impératif
  /// passé, which no text writes, is asked as its passé composé.
  static func recognizing(_ question: QuizQuestion, slots: [QuizTenseSlot]) -> QuizQuestion {
    var tense = question.tense
    if question.verb.isReflexive, case .impératifPassé(let personNumber) = tense {
      tense = .passéComposé(personNumber)
    }
    var recognized = QuizQuestion(verb: question.verb, tense: tense, isReask: question.isReask, stepID: question.stepID)
    recognized.recognition = RecognitionQuestion(verb: question.verb, tense: tense, slots: slots)
    return recognized
  }
}
