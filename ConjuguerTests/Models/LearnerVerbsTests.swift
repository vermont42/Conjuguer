//
//  LearnerVerbsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct LearnerVerbsTests {
  private let day: TimeInterval = 86_400

  private func date(_ days: Double) -> Date {
    Date(timeIntervalSinceReferenceDate: days * day)
  }

  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  @Test func recordOpenKeepsFirstAndLastDatesAndCount() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("aller", at: date(3))

    let entry = record.entries["aller"]
    #expect(entry?.firstOpened == date(1))
    #expect(entry?.lastOpened == date(3))
    #expect(entry?.openCount == 2)
    #expect(entry?.isStarred == false)
  }

  @Test func hasOpenedCountsOpensNotStars() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.setStarred(true, key: "être", at: date(2))

    #expect(record.hasOpened("aller"))
    #expect(!record.hasOpened("être"))
    #expect(!record.hasOpened("avoir"))
  }

  @Test func recentIsNewestFirst() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("être", at: date(2))
    record.recordOpen("avoir", at: date(3))
    record.recordOpen("aller", at: date(4))

    #expect(record.recent() == ["aller", "avoir", "être"])
  }

  @Test func recentStopsAtItsLimit() {
    var record = LearnerVerbs()
    for index in 0..<(LearnerVerbs.recentLimit + 5) {
      record.recordOpen("verbe\(index)", at: date(Double(index)))
    }

    let recent = record.recent()
    #expect(recent.count == LearnerVerbs.recentLimit)
    #expect(recent.first == "verbe\(LearnerVerbs.recentLimit + 4)")
  }

  @Test func equalDatesFallBackToTheKey() {
    var record = LearnerVerbs()
    record.recordOpen("être", at: date(1))
    record.recordOpen("aller", at: date(1))

    #expect(record.recent() == ["aller", "être"])
  }

  @Test func starringAndUnstarring() {
    var record = LearnerVerbs()
    record.setStarred(true, key: "aller", at: date(1))
    record.setStarred(true, key: "être", at: date(2))
    #expect(record.isStarred("aller"))
    #expect(record.starred == ["être", "aller"])

    record.setStarred(false, key: "aller", at: date(3))
    #expect(!record.isStarred("aller"))
    #expect(record.starred == ["être"])
  }

  @Test func starringAgainKeepsTheFirstDate() {
    var record = LearnerVerbs()
    record.setStarred(true, key: "aller", at: date(1))
    record.setStarred(true, key: "aller", at: date(5))

    #expect(record.entries["aller"]?.starred == date(1))
  }

  @Test func unstarringAVerbNeverOpenedForgetsIt() {
    var record = LearnerVerbs()
    record.setStarred(true, key: "aller", at: date(1))
    record.setStarred(false, key: "aller", at: date(2))

    #expect(record.entries.isEmpty)
  }

  @Test func unstarringAnOpenedVerbKeepsItsOpens() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.setStarred(true, key: "aller", at: date(2))
    record.setStarred(false, key: "aller", at: date(3))

    #expect(record.recent() == ["aller"])
    #expect(record.entries["aller"]?.openCount == 1)
  }

  @Test func myVerbsListsStarredThenRecentWithoutRepeats() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("être", at: date(2))
    record.setStarred(true, key: "être", at: date(3))
    record.setStarred(true, key: "pouvoir", at: date(4))

    #expect(record.myVerbs == ["pouvoir", "être", "aller"])
  }

  @Test func clearRecentsKeepsStars() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("être", at: date(2))
    record.setStarred(true, key: "être", at: date(3))

    record.clearRecents()

    #expect(record.recent().isEmpty)
    #expect(!record.hasOpened("aller"))
    #expect(record.starred == ["être"])
    #expect(record.entries.count == 1)
    #expect(record.entries["être"]?.openCount == 0)
  }

  @Test func removingAStarredVerbThatWasOpenedForgetsItEntirely() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.setStarred(true, key: "aller", at: date(2))
    record.recordOpen("être", at: date(3))

    record.remove("aller")

    #expect(record.starred.isEmpty)
    #expect(record.myVerbs == ["être"])
  }

  @Test func removingAVerbNotInTheRecordChangesNothing() {
    var record = LearnerVerbs()
    record.recordOpen("être", at: date(1))
    let before = record

    record.remove("aller")

    #expect(record == before)
  }

  @Test func jsonRoundTrips() throws {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.setStarred(true, key: "être", at: date(2))

    let json = try #require(record.json)
    #expect(LearnerVerbs(json: json) == record)
  }

  /// A field added later, such as a due date, must stay optional, so that what an older build
  /// wrote still decodes. This pins the decoding of an entry that carries only its key and count.
  @Test func anEntryWithoutItsOptionalFieldsDecodes() throws {
    let json = #"{"entries":{"aller":{"dictionaryKey":"aller","openCount":0}}}"#

    let record = try #require(LearnerVerbs(json: json))
    #expect(record.entries["aller"]?.lastOpened == nil)
    #expect(record.entries["aller"]?.isStarred == false)
  }

  @Test func garbageDoesNotDecode() {
    #expect(LearnerVerbs(json: "not json") == nil)
  }

  /// Every learner before this record existed starts with nothing stored.
  @Test func theStoreStartsEmptyWithNothingStored() {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())

    #expect(store.record == LearnerVerbs())
    #expect(store.myVerbs.isEmpty)
  }

  @Test func theStoreStartsEmptyFromAnUnreadableRecord() {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake(dictionary: [LearnerVerbs.storageKey: "{"]))

    #expect(store.myVerbs.isEmpty)
  }

  @Test func theStoreSavesAndReloads() throws {
    let getterSetter = GetterSetterFake()
    let store = LearnerVerbStore(getterSetter: getterSetter)
    let aller = try verb("aller")
    let être = try verb("être")

    store.recordOpen(aller, source: .browse, at: date(1))
    #expect(store.toggleStar(être, at: date(2)))

    let reloaded = LearnerVerbStore(getterSetter: getterSetter)
    #expect(reloaded.recentVerbs.map(\.infinitif) == ["aller"])
    #expect(reloaded.starredVerbs.map(\.infinitif) == ["être"])
    #expect(reloaded.myVerbs.map(\.infinitif) == ["être", "aller"])
    #expect(reloaded.isStarred(être))

    #expect(!reloaded.toggleStar(être, at: date(3)))
    #expect(!LearnerVerbStore(getterSetter: getterSetter).isStarred(être))
  }

  @Test func theStoreSavesARemoval() throws {
    let getterSetter = GetterSetterFake()
    let store = LearnerVerbStore(getterSetter: getterSetter)
    let aller = try verb("aller")
    store.recordOpen(aller, source: .browse, at: date(1))
    store.toggleStar(aller, at: date(2))

    store.remove(aller)

    let reloaded = LearnerVerbStore(getterSetter: getterSetter)
    #expect(reloaded.myVerbs.isEmpty)
    #expect(!reloaded.isStarred(aller))
  }

  @Test func theStoreSavesAClear() throws {
    let getterSetter = GetterSetterFake()
    let store = LearnerVerbStore(getterSetter: getterSetter)
    store.recordOpen(try verb("aller"), source: .browse, at: date(1))
    store.toggleStar(try verb("être"), at: date(2))

    store.clearRecents()

    let reloaded = LearnerVerbStore(getterSetter: getterSetter)
    #expect(reloaded.recentVerbs.isEmpty)
    #expect(reloaded.starredVerbs.map(\.infinitif) == ["être"])
  }

  @Test func theStoreSkipsAVerbNoLongerInTheList() throws {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("pasunverbe", at: date(2))
    let getterSetter = GetterSetterFake(dictionary: [LearnerVerbs.storageKey: try #require(record.json)])

    let store = LearnerVerbStore(getterSetter: getterSetter)
    #expect(store.recentVerbs.map(\.infinitif) == ["aller"])
  }

  @Test func recentUnstarredLeavesOutStarredVerbs() throws {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    let aller = try verb("aller")
    let être = try verb("être")
    store.recordOpen(aller, source: .browse, at: date(1))
    store.recordOpen(être, source: .browse, at: date(2))
    store.toggleStar(être, at: date(3))

    #expect(store.recentVerbs.map(\.infinitif) == ["être", "aller"])
    #expect(store.recentUnstarredVerbs.map(\.infinitif) == ["aller"])
  }

  @Test func theDoubledEntriesStayApart() throws {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    let france = try verb("haïr France")
    let québec = try verb("haïr Québec")

    store.recordOpen(france, source: .browse, at: date(1))
    store.toggleStar(québec, at: date(2))

    #expect(store.hasOpened(france))
    #expect(!store.hasOpened(québec))
    #expect(store.isStarred(québec))
    #expect(!store.isStarred(france))
    #expect(store.myVerbs.map(\.dictionaryKey) == ["haïr Québec", "haïr France"])
  }

  @Test func theListModesMapToTheSortOrders() {
    #expect(VerbListMode.allCases == [.frequency, .alphabetical, .myVerbs])
    for sort in VerbSort.allCases {
      #expect(VerbListMode(sort).sort == sort)
    }
    #expect(VerbListMode.myVerbs.sort == nil)
  }
}
