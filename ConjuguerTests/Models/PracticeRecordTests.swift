//
//  PracticeRecordTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct PracticeRecordTests {
  private static let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
    return calendar
  }()

  private var calendar: Calendar {
    Self.calendar
  }

  /// Day `day` of 2026-11, at `hour` UTC.
  private func date(_ day: Int, hour: Int = 12) -> Date {
    calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour)) ?? .distantPast
  }

  private func startOf(_ day: Int) -> Date {
    date(day, hour: 0)
  }

  private let imparfaitTu = PracticeItem.pattern(model: "1-1", tense: "imparfait", person: "ss", takesÊtre: false)
  private let participePassé = PracticeItem.pattern(model: "1-1", tense: "participe_passe", person: nil, takesÊtre: false)

  private func keys(_ verb: String) -> [PracticeItem] {
    PracticeItem.Stem.shown.map { .keyConjugation(verb: verb, stem: $0) }
  }

  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  private func store(_ getterSetter: GetterSetter = GetterSetterFake()) -> PracticeStore {
    PracticeStore(getterSetter: getterSetter, calendar: calendar)
  }

  @Test func anAnswerClimbsWhenDueAndStartsOverWhenWrong() {
    var record = PracticeRecord()

    record.recordAnswer(imparfaitTu, isCorrect: true, at: date(1), calendar: calendar)
    #expect(record.entry(for: imparfaitTu)?.schedule == ReviewSchedule(box: 1, due: startOf(4)))

    record.recordAnswer(imparfaitTu, isCorrect: true, at: date(2), calendar: calendar)
    #expect(record.entry(for: imparfaitTu)?.schedule == ReviewSchedule(box: 1, due: startOf(4)))

    record.recordAnswer(imparfaitTu, isCorrect: true, at: date(4), calendar: calendar)
    #expect(record.entry(for: imparfaitTu)?.schedule == ReviewSchedule(box: 2, due: startOf(11)))

    record.recordAnswer(imparfaitTu, isCorrect: false, at: date(5), calendar: calendar)
    #expect(record.entry(for: imparfaitTu)?.schedule == ReviewSchedule(box: 0, due: startOf(6)))
    #expect(record.entry(for: imparfaitTu)?.lastAnswerWasRight == false)
    #expect(record.entry(for: imparfaitTu)?.lastAnswered == date(5))
  }

  @Test func dueItemsComeLongestOverdueFirst() {
    var record = PracticeRecord()
    record.recordAnswer(imparfaitTu, isCorrect: false, at: date(3), calendar: calendar)
    record.recordAnswer(participePassé, isCorrect: false, at: date(1), calendar: calendar)
    record.recordLookup(keys("venir"), at: date(2), calendar: calendar)
    record.recordAnswer(.pattern(model: "2-1", tense: "imperatif", person: "sp", takesÊtre: false), isCorrect: true, at: date(9), calendar: calendar)

    #expect(record.dueItems(at: date(9)) == [participePassé] + keys("venir").sorted { $0.key < $1.key } + [imparfaitTu])
    #expect(record.dueItems(at: date(1)).isEmpty)
  }

  @Test func aLookupSendsKeyConjugationsBackToTheFirstBox() {
    var record = PracticeRecord()
    let futur = PracticeItem.keyConjugation(verb: "venir", stem: .futur)
    record.recordAnswer(futur, isCorrect: true, at: date(1), calendar: calendar)
    record.recordAnswer(futur, isCorrect: true, at: date(4), calendar: calendar)

    record.recordLookup(keys("venir"), at: date(6), calendar: calendar)

    for item in keys("venir") {
      #expect(record.entry(for: item)?.schedule == ReviewSchedule(box: 0, due: startOf(7)))
      #expect(record.entry(for: item)?.lastLookedUp == date(6))
    }
  }

  @Test func aLookupFromTheCardKeepsTheSchedule() {
    var record = PracticeRecord()
    record.recordLookup(keys("venir"), at: date(1), calendar: calendar)
    record.recordReview(keys("venir"), at: date(2), calendar: calendar)
    let reviewed = record.entry(for: keys("venir")[0])?.schedule

    record.recordLookup(keys("venir"), at: date(2), reschedules: false, calendar: calendar)

    #expect(reviewed == ReviewSchedule(box: 1, due: startOf(5)))
    #expect(record.entry(for: keys("venir")[0])?.schedule == reviewed)
  }

  @Test func aReviewAndASnoozeMoveOnlyDueItems() {
    var record = PracticeRecord()
    let présent = keys("venir")[0]
    let passéComposé = keys("venir")[1]
    record.recordAnswer(présent, isCorrect: false, at: date(1), calendar: calendar)
    record.recordAnswer(passéComposé, isCorrect: true, at: date(1), calendar: calendar)

    record.recordReview([présent, passéComposé], at: date(2), calendar: calendar)
    #expect(record.entry(for: présent)?.schedule == ReviewSchedule(box: 1, due: startOf(5)))
    #expect(record.entry(for: passéComposé)?.schedule == ReviewSchedule(box: 1, due: startOf(4)))

    record.snooze([présent, passéComposé], at: date(4), calendar: calendar)
    #expect(record.entry(for: présent)?.schedule == ReviewSchedule(box: 1, due: startOf(5)))
    #expect(record.entry(for: passéComposé)?.schedule == ReviewSchedule(box: 1, due: startOf(5)))
  }

  @Test func theRecordSurvivesTheJSONRoundTrip() throws {
    var record = PracticeRecord()
    record.recordAnswer(imparfaitTu, isCorrect: false, at: date(1), calendar: calendar)
    record.recordLookup(keys("haïr France"), at: date(2), calendar: calendar)

    let json = try #require(record.json)
    #expect(PracticeRecord(json: json) == record)
  }

  @Test(arguments: [(10, 23, 0), (11, 0, 1), (13, 7, 3)])
  func daysBetweenCountsCalendarDays(day: Int, hour: Int, expected: Int) {
    #expect(PracticeRecord.daysBetween(date(10, hour: 22), and: date(day, hour: hour), calendar: calendar) == expected)
  }

  @Test func everyAnswerUpdatesItsItemAndSurvivesARelaunch() throws {
    let getterSetter = GetterSetterFake()
    let practice = store(getterSetter)
    practice.recordAnswer(verb: try verb("chanter"), tense: .imparfait(.secondSingular), isCorrect: false, at: date(1))

    let relaunched = store(getterSetter)
    let entry = relaunched.record.entry(for: imparfaitTu)
    #expect(entry?.schedule == ReviewSchedule(box: 0, due: startOf(2)))
    #expect(entry?.lastAnswerWasRight == false)
  }

  @Test func aLookupOfARegularVerbSchedulesNothing() throws {
    let practice = store()
    practice.recordLookup(try verb("parler"), source: .browse, at: date(1))
    practice.recordLookup(try verb("attendre"), source: .search, at: date(1))

    #expect(practice.isEmpty)
  }

  @Test func theCardOffersTheIrregularVerbLongestOverdueAndSaysHowItGotThere() throws {
    let practice = store()
    let venir = try verb("venir")
    practice.recordAnswer(verb: try verb("parler"), tense: .indicatifPrésent(.firstSingular), isCorrect: false, at: date(1))
    practice.recordLookup(venir, source: .search, at: date(2))

    let offer = try #require(practice.cardOffer(at: date(5)))
    #expect(offer.verb == venir)
    #expect(offer.items == keys("venir").sorted { $0.key < $1.key })
    #expect(offer.daysSinceActivity == 3)
    #expect(offer.wasLookedUp)

    practice.recordAnswer(verb: venir, tense: .plusQueParfait(.firstSingular), isCorrect: false, at: date(6))
    let practiced = try #require(practice.cardOffer(at: date(8)))
    #expect(practiced.daysSinceActivity == 2)
    #expect(!practiced.wasLookedUp)
  }

  @Test func revealingTheCardRaisesItsVerbAndDismissingItWaitsADay() throws {
    let practice = store()
    let venir = try verb("venir")
    let prendre = try verb("prendre")
    practice.recordLookup(venir, source: .search, at: date(1))
    practice.recordLookup(prendre, source: .search, at: date(2))

    practice.recordReview(try #require(practice.cardOffer(at: date(3))), at: date(3))
    #expect(practice.cardOffer(at: date(3))?.verb == prendre)

    practice.snooze(try #require(practice.cardOffer(at: date(3))), at: date(3))
    #expect(practice.cardOffer(at: date(3)) == nil)
    let snoozed = try #require(practice.cardOffer(at: date(4)))
    #expect(snoozed.verb == prendre)

    practice.recordReview(snoozed, at: date(4))
    #expect(practice.cardOffer(at: date(5)) == nil)
    #expect(practice.cardOffer(at: date(6))?.verb == venir)
  }

  @Test func aPatternOrAPasséSimpleIsDueButNeverOnTheCard() throws {
    let practice = store()
    practice.recordAnswer(verb: try verb("chanter"), tense: .participePassé, isCorrect: false, at: date(1))
    practice.recordAnswer(verb: try verb("venir"), tense: .passéSimple(.firstPlural), isCorrect: false, at: date(1))

    #expect(practice.dueItems(at: date(5)) == [.keyConjugation(verb: "venir", stem: .passéSimple), participePassé].sorted { $0.key < $1.key })
    #expect(practice.cardOffer(at: date(5)) == nil)
  }

  /// sortir's two entries keep their own items, and only the irregular one reaches the card.
  @Test func theDoubledEntriesHaveTheirOwnItems() throws {
    let practice = store()
    practice.recordLookup(try verb("sortir exit"), source: .browse, at: date(1))
    practice.recordLookup(try verb("sortir obtain"), source: .browse, at: date(1))

    #expect(practice.cardOffer(at: date(3))?.verb == (try verb("sortir exit")))
    #expect(practice.record.entries.keys.allSatisfy { !$0.contains("obtain") })
  }

  @Test func theFirstLoadMigratesIrregularVerbsSchedulesAndDropsRegularOnes() throws {
    let getterSetter = GetterSetterFake()
    let reviewed = ReviewSchedule(box: 2, due: startOf(20))
    let reviewJSON = try #require(String(data: JSONEncoder().encode(reviewed), encoding: .utf8))
    let opened = date(4).timeIntervalSinceReferenceDate
    let json = #"{"entries":{"#
      + #""venir":{"dictionaryKey":"venir","openCount":2,"lastOpened":\#(opened),"review":\#(reviewJSON)},"#
      + #""prendre":{"dictionaryKey":"prendre","openCount":1,"lastOpened":\#(opened)},"#
      + #""parler":{"dictionaryKey":"parler","openCount":1,"lastOpened":\#(opened),"review":\#(reviewJSON)},"#
      + #""accroire":{"dictionaryKey":"accroire","openCount":1,"lastOpened":\#(opened)},"#
      + #""pasunverbe":{"dictionaryKey":"pasunverbe","openCount":1,"lastOpened":\#(opened)}}}"#
    getterSetter.set(key: LearnerVerbs.storageKey, value: json)

    let practice = store(getterSetter)
    practice.migrateIfNeeded()

    for item in keys("venir") {
      #expect(practice.record.entry(for: item)?.schedule == reviewed)
      #expect(practice.record.entry(for: item)?.lastLookedUp == date(4))
    }
    // An entry from before the review card counts as looked up on its last open.
    for item in keys("prendre") {
      #expect(practice.record.entry(for: item)?.schedule == ReviewSchedule(box: 0, due: startOf(5)))
    }
    #expect(practice.record.entries.count == 6)
    #expect(LearnerVerbs(json: json)?.entries["venir"]?.openCount == 2)
    #expect(store(getterSetter).record == practice.record)
  }

  @Test func aResetIsKeptAndDoesNotMigrateAgain() throws {
    let getterSetter = GetterSetterFake()
    let opened = date(4).timeIntervalSinceReferenceDate
    getterSetter.set(key: LearnerVerbs.storageKey, value: #"{"entries":{"venir":{"dictionaryKey":"venir","openCount":1,"lastOpened":\#(opened)}}}"#)
    let practice = store(getterSetter)
    #expect(!practice.isEmpty)

    practice.reset()

    #expect(practice.isEmpty)
    #expect(store(getterSetter).isEmpty)
  }

  @Test func aMigrationWithNothingToMoveIsStillKept() throws {
    let getterSetter = GetterSetterFake()
    let opened = date(4).timeIntervalSinceReferenceDate
    getterSetter.set(key: LearnerVerbs.storageKey, value: #"{"entries":{"parler":{"dictionaryKey":"parler","openCount":1,"lastOpened":\#(opened)}}}"#)

    store(getterSetter).migrateIfNeeded()

    #expect(getterSetter.get(key: PracticeRecord.storageKey) != nil)
  }
}
