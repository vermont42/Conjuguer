//
//  VerbDraw.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// Chooses the widget's verb of the day and every random verb. Once My Verbs has entries, it
/// supplies one draw in three: every third day for the widget, and a third of random verbs by
/// chance. The rest come from the 1,000 most frequent verbs, where an irregular verb counts
/// double, and so does a verb built on no other.
enum VerbDraw {
  static let myVerbsOdds = 3
  static let frequentBand = FrequencyBand.top1000
  static let favoredFactor: UInt64 = 2
  static let alleModelID = "1-9"

  private static let firstIrregularGroup = 3
  private static let referenceDate = WidgetDateHelper.calendar.date(from: DateComponents(year: 2025, month: 1, day: 1)) ?? .distantPast

  @MainActor static var frequentVerbs: [Verb] {
    Verb.verbs(in: frequentBand)
  }

  @MainActor static func randomVerb(myVerbs: [Verb]) -> Verb? {
    var generator = SystemRandomNumberGenerator()
    return randomVerb(myVerbs: myVerbs, frequentVerbs: frequentVerbs, using: &generator)
  }

  @MainActor static func randomVerb(myVerbs: [Verb], frequentVerbs: [Verb], using generator: inout some RandomNumberGenerator) -> Verb? {
    let goesToMyVerbs = generator.next() % UInt64(myVerbsOdds) == 0
    return draw(goesToMyVerbs: goesToMyVerbs, myVerbs: myVerbs, frequentVerbs: frequentVerbs, using: &generator)
  }

  /// The same verb for the same day, lists, and `lastShown`, in any process. My Verbs gets every
  /// third day rather than a chance of one in three, since chance leaves gaps of two weeks. Those
  /// days take the verb whose last My Verbs day is longest ago, a verb never given one first, and
  /// the key breaks a tie. An index into the list, by turn, cannot serve: opening the widget's
  /// verb moves it to the front of Recent, and a verb opened between turns changes the list's
  /// length, so the index lands anywhere, often on the verb just shown.
  @MainActor static func verbOfTheDay(on date: Date, myVerbs: [Verb], frequentVerbs: [Verb], lastShown: [String: Date] = [:]) -> Verb? {
    if isMyVerbsDay(date), let verb = myVerbs.min(by: { lhs, rhs in
      (lastShown[lhs.dictionaryKey] ?? .distantPast, lhs.dictionaryKey) < (lastShown[rhs.dictionaryKey] ?? .distantPast, rhs.dictionaryKey)
    }) {
      return verb
    }
    var generator = SeededRandomNumberGenerator(seed: UInt64(bitPattern: Int64(dayNumber(of: date))))
    return draw(goesToMyVerbs: false, myVerbs: myVerbs, frequentVerbs: frequentVerbs, using: &generator)
  }

  static func isMyVerbsDay(_ date: Date) -> Bool {
    dayNumber(of: date) % myVerbsOdds == 0
  }

  @MainActor static func draw(goesToMyVerbs: Bool, myVerbs: [Verb], frequentVerbs: [Verb], using generator: inout some RandomNumberGenerator) -> Verb? {
    if goesToMyVerbs, !myVerbs.isEmpty {
      return myVerbs[Int(generator.next() % UInt64(myVerbs.count))]
    }
    return weightedVerb(from: frequentVerbs, using: &generator) ?? myVerbs.first
  }

  @MainActor static func weight(of verb: Verb) -> UInt64 {
    (isIrregular(verb) ? favoredFactor : 1) * (isBase(verb) ? favoredFactor : 1)
  }

  /// Irregular as French schools teach it, the third group: every model outside the first two
  /// groups, and aller. The spelling changes of manger, lancer, and appeler do not count, though
  /// `VerbModel.irregularity` scores them above zero.
  static func isIrregular(_ verb: Verb) -> Bool {
    guard verb.model != alleModelID else {
      return true
    }
    return verb.modelGroup >= firstIrregularGroup
  }

  @MainActor static func isBase(_ verb: Verb) -> Bool {
    VerbBase.base(of: verb.infinitif) == nil
  }

  static func dayNumber(of date: Date) -> Int {
    let calendar = WidgetDateHelper.calendar
    return calendar.dateComponents([.day], from: referenceDate, to: calendar.startOfDay(for: date)).day ?? 0
  }

  // `Int.random(in:using:)` would serve, but its use of the generator is not documented, so a
  // Swift update could change which verb a day's seed names.
  @MainActor private static func weightedVerb(from verbs: [Verb], using generator: inout some RandomNumberGenerator) -> Verb? {
    let weights = verbs.map(weight(of:))
    let total = weights.reduce(0, +)
    guard total > 0 else {
      return nil
    }
    var remaining = generator.next() % total
    for (verb, weight) in zip(verbs, weights) {
      if remaining < weight {
        return verb
      }
      remaining -= weight
    }
    return verbs.last
  }
}
