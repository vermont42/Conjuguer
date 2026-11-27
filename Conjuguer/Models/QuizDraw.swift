//
//  QuizDraw.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// A kind of verb a tense is asked of, read from the data: an être verb for the passé composé, an
/// irregular stem for the futur. The default quiz applies it to the level's band.
enum QuizVerbPool: CaseIterable {
  case regularEr
  case regularIr
  case regularRe
  case bigThree
  case indicatifPrésentStemChanger
  case êtreAuxiliary
  case irregularParticipePassé
  case anyVerb
  case regularRadicalFutur
  case irregularRadicalFutur

  static let bigThreeInfinitifs: Set<String> = ["être", "avoir", "aller"]
  static let rendreModelID = "5-1A"

  @MainActor func admits(_ verb: Verb) -> Bool {
    switch self {
    case .regularEr:
      return verb.modelGroup == 1 && verb.model != VerbDraw.alleModelID
    case .regularIr:
      return verb.modelGroup == 2
    case .regularRe:
      return verb.model == Self.rendreModelID
    case .bigThree:
      return Self.bigThreeInfinitifs.contains(verb.infinitif)
    case .indicatifPrésentStemChanger:
      return !Self.bigThreeInfinitifs.contains(verb.infinitif) && QuizVerbTraits.of(verb).hasIrregularIndicatifPrésent
    case .êtreAuxiliary:
      return verb.auxiliary == .être && !verb.isReflexive
    case .irregularParticipePassé:
      // Fichu, maudit, and féru are marked too, but a pool of three oddities would be drawn as
      // often as the third group's participles whenever a question asks a regular verb.
      return VerbDraw.isIrregular(verb) && QuizVerbTraits.of(verb).hasIrregularParticipePassé
    case .anyVerb:
      return true
    case .regularRadicalFutur:
      return !QuizVerbTraits.of(verb).hasIrregularRadicalFutur
    case .irregularRadicalFutur:
      return QuizVerbTraits.of(verb).hasIrregularRadicalFutur
    }
  }
}

/// Where a verb's model departs from the regular pattern, read from the capitals with which the
/// conjugator marks irregular letters (je viens, venu, viendrai), so that the quiz and the verb
/// page agree on what is irregular. Every verb of a model shares its marks.
struct QuizVerbTraits {
  let hasIrregularIndicatifPrésent: Bool
  let hasIrregularParticipePassé: Bool
  let hasIrregularRadicalFutur: Bool

  @MainActor private static var traitsByModel: [String: QuizVerbTraits] = [:]

  @MainActor static func of(_ verb: Verb) -> QuizVerbTraits {
    if let traits = traitsByModel[verb.model] {
      return traits
    }
    func isMarked(_ tense: Tense) -> Bool {
      Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters)?.contains(where: \.isUppercase) == true
    }
    let traits = QuizVerbTraits(
      hasIrregularIndicatifPrésent: PersonNumber.allCases.contains { isMarked(.indicatifPrésent($0)) },
      hasIrregularParticipePassé: isMarked(.participePassé),
      hasIrregularRadicalFutur: isMarked(.radicalFutur)
    )
    traitsByModel[verb.model] = traits
    return traits
  }
}

/// A question as drawn, before its person is chosen.
struct QuizDrawnQuestion: Equatable {
  let verb: Verb
  let slot: QuizTenseSlot
}

/// Chooses the verbs of a quiz whose verbs the learner did not list, from a band: the level's for
/// the default quiz, or the one a custom quiz chose. Each question draws its tense by weight, as
/// in any quiz. Then the questions get roles and an exact half of them an irregular verb, and only
/// then does each draw one of its tense's pools that fits both, and a verb from it, so that the
/// counts come out exact rather than likely.
///
/// At least two questions ask a core verb. A prefixed verb in `frequentDerivativeBand` draws as
/// freely as a base verb, since revenir and comprendre are as basic as venir and prendre. Where the
/// band reaches past it, one to three questions ask a prefixed verb from beyond it, and no other
/// question does. Where it does not, at least one question asks a prefixed verb.
enum QuizDraw {
  /// Half of the questions, rounded up, ask an irregular verb, as `VerbDraw.isIrregular` counts
  /// them: the third group as French schools teach it, rendre's verbs among them, and aller. Rounded
  /// up, since the two core verbs are irregular, and a round of nine, beside its choice question or
  /// a due item, would otherwise leave its other questions mostly regular.
  static let irregularShareDivisor = 2
  static let minimumCoreQuestions = 2
  static let rareDerivativeRange = 1 ... 3
  static let frequentDerivativeBand = FrequencyBand.top300
  static let coreInfinitifs: Set<String> = ["être", "avoir", "aller", "faire", "pouvoir", "vouloir", "devoir", "savoir"]

  /// Entries the default quiz never asks, by `Verb.dictionaryKey`. Sortir's two entries share
  /// its counts, which measure sortir to exit, so sortir to obtain, a legal term conjugated like
  /// finir, would otherwise rank among the 100 most frequent verbs.
  static let excludedEntries: Set<String> = ["sortir obtain"]

  private static let freshVerbTries = 20

  static func isCore(_ verb: Verb) -> Bool {
    coreInfinitifs.contains(verb.infinitif)
  }

  @MainActor static func isDerivative(_ verb: Verb) -> Bool {
    VerbBase.base(of: verb.infinitif) != nil
  }

  @MainActor static func isRareDerivative(_ verb: Verb) -> Bool {
    !verb.isIn(frequentDerivativeBand) && isDerivative(verb)
  }

  /// `asked` holds the IDs of verbs asked earlier in the session, which a draw passes over while
  /// another verb fits.
  @MainActor static func questions(
    level: QuizLevel,
    count: Int,
    asked earlier: Set<String>,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizDrawnQuestion] {
    questions(slots: level.slots, band: level.band, count: count, asked: earlier, using: &generator)
  }

  /// The questions of `slots` over `band`, nil for every verb, as a level's default quiz or a
  /// custom quiz that left its verbs to a band asks them.
  @MainActor static func questions(
    slots tenseSlots: [QuizTenseSlot],
    band: FrequencyBand?,
    count: Int,
    asked earlier: Set<String>,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizDrawnQuestion] {
    var slots = (0 ..< count).compactMap { _ in
      QuizTenseSlot.drawWeighted(from: tenseSlots, using: &generator).map { Slot(tense: $0) }
    }
    func candidates(_ tense: QuizTenseSlot, _ pool: QuizVerbPool) -> Candidates {
      Candidates.of(band: band, slot: tense, pool: pool)
    }
    func admits(_ slot: Slot, role: Role, isIrregular: Bool? = nil) -> Bool {
      Set(slot.tense.verbPools).contains { !candidates(slot.tense, $0).verbs(role: role, isIrregular: isIrregular).isEmpty }
    }

    let reachesRareDerivatives = verbs(in: band).contains(where: isRareDerivative)
    var roleNeeds: [(role: Role, count: Int)] = [(.core, minimumCoreQuestions)]
    if reachesRareDerivatives {
      roleNeeds.append((.rareDerivative, Int.random(in: rareDerivativeRange, using: &generator)))
    } else {
      roleNeeds.append((.derivative, 1))
    }
    var unassigned = Array(slots.indices).shuffled(using: &generator)
    for (role, needed) in roleNeeds {
      for _ in 0 ..< needed {
        guard let position = unassigned.firstIndex(where: { admits(slots[$0], role: role) }) else {
          break
        }
        slots[unassigned.remove(at: position)].role = role
      }
    }

    var flexible: [Int] = []
    for index in slots.indices {
      let admitsIrregular = admits(slots[index], role: slots[index].role, isIrregular: true)
      let admitsRegular = admits(slots[index], role: slots[index].role, isIrregular: false)
      if admitsIrregular, admitsRegular {
        flexible.append(index)
      } else {
        slots[index].isIrregular = admitsIrregular
      }
    }
    let irregularNeeded = (count + irregularShareDivisor - 1) / irregularShareDivisor - slots.filter { $0.isIrregular == true }.count
    for (offset, index) in flexible.shuffled(using: &generator).enumerated() {
      slots[index].isIrregular = offset < irregularNeeded
    }

    var asked = earlier
    return slots.compactMap { slot in
      let pools = slot.tense.verbPools
      let fitting = pools.filter { !candidates(slot.tense, $0).verbs(role: slot.role, isIrregular: slot.isIrregular).isEmpty }
      let verbs: CandidateVerbs
      if let pool = fitting.randomElement(using: &generator) {
        verbs = candidates(slot.tense, pool).verbs(role: slot.role, isIrregular: slot.isIrregular)
      } else if let pool = pools.randomElement(using: &generator) {
        verbs = candidates(slot.tense, pool).verbs(role: .free, isIrregular: nil)
      } else {
        return nil
      }
      guard let verb = freshVerb(from: verbs, asked: asked, using: &generator) else {
        return nil
      }
      asked.insert(verb.id)
      return QuizDrawnQuestion(verb: verb, slot: slot.tense)
    }
  }

  @MainActor static func verbs(in band: FrequencyBand?) -> [Verb] {
    band.map(Verb.verbs(in:)) ?? Verb.verbsByFrequency
  }

  private static func freshVerb(from verbs: CandidateVerbs, asked: Set<String>, using generator: inout some RandomNumberGenerator) -> Verb? {
    var verb = verbs.randomElement(using: &generator)
    for _ in 0 ..< freshVerbTries {
      guard let drawn = verb, asked.contains(drawn.id) else {
        break
      }
      verb = verbs.randomElement(using: &generator)
    }
    return verb
  }

  fileprivate enum Role {
    case core
    case derivative
    case rareDerivative
    case free
  }

  private struct Slot {
    let tense: QuizTenseSlot
    var role = Role.free
    var isIrregular: Bool?
  }

  /// The band's verbs that a pool admits and that have some cell of the tense, sorted once by
  /// what a role and the irregular share ask of them. A quiz reads them thirty times, and the
  /// tests draw thousands of quizzes, so they are kept.
  fileprivate struct Candidates {
    private let buckets: [Bucket: [Verb]]

    private struct Bucket: Hashable {
      let kind: Kind
      let isIrregular: Bool
    }

    private enum Kind: CaseIterable {
      case core
      case frequentDerivative
      case rareDerivative
      case other
    }

    private struct Key: Hashable {
      let band: FrequencyBand?
      let slot: QuizTenseSlot
      let pool: QuizVerbPool
    }

    @MainActor private static var cache: [Key: Candidates] = [:]

    @MainActor static func of(band: FrequencyBand?, slot: QuizTenseSlot, pool: QuizVerbPool) -> Candidates {
      let key = Key(band: band, slot: slot, pool: pool)
      if let cached = cache[key] {
        return cached
      }
      let cells = slot.cells
      var buckets: [Bucket: [Verb]] = [:]
      for verb in QuizDraw.verbs(in: band) where !QuizDraw.excludedEntries.contains(verb.dictionaryKey) && pool.admits(verb) && cells.contains(where: verb.hasCell) {
        let kind: Kind
        if QuizDraw.isCore(verb) {
          kind = .core
        } else if QuizDraw.isRareDerivative(verb) {
          kind = .rareDerivative
        } else if QuizDraw.isDerivative(verb) {
          kind = .frequentDerivative
        } else {
          kind = .other
        }
        buckets[Bucket(kind: kind, isIrregular: VerbDraw.isIrregular(verb)), default: []].append(verb)
      }
      let candidates = Candidates(buckets: buckets)
      cache[key] = candidates
      return candidates
    }

    func verbs(role: Role, isIrregular: Bool?) -> CandidateVerbs {
      let kinds: [Kind]
      switch role {
      case .core:
        kinds = [.core]
      case .derivative:
        kinds = [.frequentDerivative, .rareDerivative]
      case .rareDerivative:
        kinds = [.rareDerivative]
      case .free:
        kinds = [.core, .frequentDerivative, .other]
      }
      let irregularities = isIrregular.map { [$0] } ?? [true, false]
      return CandidateVerbs(parts: kinds.flatMap { kind in
        irregularities.compactMap { buckets[Bucket(kind: kind, isIrregular: $0)] }
      })
    }
  }

  /// The buckets a role and an irregularity draw from, read in place. Joining them into one array
  /// copied thousands of verbs at Advanced for each of the hundred-odd reads a quiz makes. A draw
  /// consumes the generator as `Array.randomElement(using:)` does, so a seed draws the same quiz.
  fileprivate struct CandidateVerbs {
    private let parts: [[Verb]]
    let count: Int

    init(parts: [[Verb]]) {
      self.parts = parts
      count = parts.reduce(0) { $0 + $1.count }
    }

    var isEmpty: Bool {
      parts.allSatisfy(\.isEmpty)
    }

    func randomElement(using generator: inout some RandomNumberGenerator) -> Verb? {
      guard !isEmpty else {
        return nil
      }
      var index = Int.random(in: 0 ..< count, using: &generator)
      for part in parts {
        if index < part.count {
          return part[index]
        }
        index -= part.count
      }
      return nil
    }
  }
}

extension Verb {
  var modelGroup: Int {
    model.split(separator: "-").first.flatMap { Int($0) } ?? 0
  }
}
